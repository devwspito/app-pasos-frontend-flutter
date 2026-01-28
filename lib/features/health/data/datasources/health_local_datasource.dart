/// Local data source for health platform operations.
///
/// This file defines the interface and implementation for health
/// platform operations using the health package.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/features/health/data/models/step_sample_model.dart';
import 'package:health/health.dart';

/// Abstract interface for health local data operations.
///
/// This interface defines all health-related platform calls.
/// Implementations should use the [Health] package for native health
/// platform access (Apple Health on iOS, Google Fit on Android).
abstract interface class HealthLocalDatasource {
  /// Requests health data permissions from the user.
  ///
  /// On iOS, this will show the Apple Health permissions dialog.
  /// On Android, this will show the Google Fit permissions dialog.
  ///
  /// Returns `true` if permissions were granted, `false` otherwise.
  /// Throws [CacheException] if the health platform is unavailable.
  Future<bool> requestPermissions();

  /// Checks if the app has health data permissions.
  ///
  /// Returns `true` if permissions are granted, `false` otherwise.
  /// Throws [CacheException] if the health platform is unavailable.
  Future<bool> hasPermissions();

  /// Gets step samples for a specific date range from the health platform.
  ///
  /// [start] - The start date/time for the query.
  /// [end] - The end date/time for the query.
  ///
  /// Returns a list of [StepSampleModel] containing step data samples.
  /// Throws [UnauthorizedException] if health permissions not granted.
  /// Throws [CacheException] on data retrieval errors.
  Future<List<StepSampleModel>> getStepSamples({
    required DateTime start,
    required DateTime end,
  });

  /// Gets today's total steps from the health platform.
  ///
  /// This is a convenience method that queries from midnight today
  /// until the current time.
  ///
  /// Returns the total step count for today.
  /// Throws [UnauthorizedException] if health permissions not granted.
  /// Throws [CacheException] on data retrieval errors.
  Future<int> getTodaySteps();
}

/// Implementation of [HealthLocalDatasource] using the [Health] package.
///
/// This class handles all health platform calls, converting
/// data to models and handling errors appropriately.
///
/// Example usage:
/// ```dart
/// final datasource = HealthLocalDatasourceImpl();
/// final hasPerms = await datasource.hasPermissions();
/// if (!hasPerms) {
///   await datasource.requestPermissions();
/// }
/// final todaySteps = await datasource.getTodaySteps();
/// ```
class HealthLocalDatasourceImpl implements HealthLocalDatasource {
  /// Creates a [HealthLocalDatasourceImpl].
  HealthLocalDatasourceImpl();

  /// The health plugin instance for platform access.
  final Health _health = Health();

  /// The types of health data we want to access.
  static const List<HealthDataType> _types = [HealthDataType.STEPS];

  /// The permission levels we need for health data.
  static const List<HealthDataAccess> _permissions = [HealthDataAccess.READ];

  @override
  Future<bool> requestPermissions() async {
    try {
      // Configure health plugin for use
      await _health.configure();

      // Request authorization for step data
      final granted = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );

      return granted;
    } catch (e, stackTrace) {
      throw CacheException(
        message: 'Failed to request health permissions: ${e.toString()}',
        code: 'HEALTH_PERMISSION_ERROR',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      // Configure health plugin for use
      await _health.configure();

      // Check if we have authorization
      final hasPerms = await _health.hasPermissions(
        _types,
        permissions: _permissions,
      );

      // hasPermissions returns nullable bool, treat null as false
      return hasPerms ?? false;
    } catch (e, stackTrace) {
      throw CacheException(
        message: 'Failed to check health permissions: ${e.toString()}',
        code: 'HEALTH_PERMISSION_CHECK_ERROR',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<StepSampleModel>> getStepSamples({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      // Check permissions first
      final hasPerms = await hasPermissions();
      if (!hasPerms) {
        throw UnauthorizedException.permissionDenied(
          message: 'Health data permissions not granted',
        );
      }

      // Fetch health data from the platform
      final healthDataList = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: start,
        endTime: end,
      );

      // Remove duplicates that may come from different sources
      final uniqueData = _health.removeDuplicates(healthDataList);

      // Convert to step sample models
      final samples = <StepSampleModel>[];
      for (final dataPoint in uniqueData) {
        if (dataPoint.type == HealthDataType.STEPS) {
          final steps = _extractStepValue(dataPoint.value);
          if (steps > 0) {
            samples.add(
              StepSampleModel(
                steps: steps,
                startTime: dataPoint.dateFrom,
                endTime: dataPoint.dateTo,
                source: dataPoint.sourceName,
              ),
            );
          }
        }
      }

      return samples;
    } on UnauthorizedException {
      rethrow;
    } catch (e, stackTrace) {
      throw CacheException(
        message: 'Failed to get step samples: ${e.toString()}',
        code: 'HEALTH_DATA_ERROR',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<int> getTodaySteps() async {
    try {
      // Check permissions first
      final hasPerms = await hasPermissions();
      if (!hasPerms) {
        throw UnauthorizedException.permissionDenied(
          message: 'Health data permissions not granted',
        );
      }

      // Get today's date range
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      // Use getTotalStepsInInterval for efficient total step count
      final totalSteps = await _health.getTotalStepsInInterval(
        startOfDay,
        now,
      );

      return totalSteps ?? 0;
    } on UnauthorizedException {
      rethrow;
    } catch (e, stackTrace) {
      throw CacheException(
        message: 'Failed to get today steps: ${e.toString()}',
        code: 'HEALTH_TODAY_STEPS_ERROR',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Extracts the step count from a [HealthValue].
  ///
  /// The health package can return different value types,
  /// so we need to handle the conversion appropriately.
  int _extractStepValue(HealthValue value) {
    if (value is NumericHealthValue) {
      return value.numericValue.toInt();
    }
    // For other value types, try to parse from string
    final stringValue = value.toString();
    return int.tryParse(stringValue) ?? 0;
  }
}
