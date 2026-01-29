/// Health service implementation for native health platform integration.
///
/// This file provides the concrete implementation of [HealthService] using
/// the health package for platform-specific integrations with
/// HealthKit (iOS) and Health Connect (Android).
library;

import 'package:app_pasos_frontend/core/services/health_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:health/health.dart';

/// Implementation of [HealthService] using the health package.
///
/// This implementation provides access to step data through:
/// - iOS: HealthKit integration
/// - Android: Health Connect integration
/// - Web: Returns unavailable (health APIs not supported)
///
/// Example usage:
/// ```dart
/// final healthService = HealthServiceImpl();
/// if (await healthService.isAvailable()) {
///   final hasPermission = await healthService.requestPermission();
///   if (hasPermission) {
///     final steps = await healthService.getTodaySteps();
///     print('Today\'s steps: $steps');
///   }
/// }
/// ```
class HealthServiceImpl implements HealthService {
  /// Creates a [HealthServiceImpl] instance.
  ///
  /// Optionally accepts a [Health] instance for testing.
  HealthServiceImpl({Health? health}) : _health = health ?? Health();

  /// The underlying health package instance.
  final Health _health;

  /// The health data types used for step tracking.
  static const List<HealthDataType> _stepTypes = [HealthDataType.STEPS];

  // ============================================================
  // Platform Availability
  // ============================================================

  @override
  Future<bool> isAvailable() async {
    // Web platform does not support health APIs
    if (kIsWeb) {
      return false;
    }

    try {
      // Check if Health Connect is available on Android
      // On iOS, HealthKit is always available on supported devices
      final status = await _health.getHealthConnectSdkStatus();
      return status == HealthConnectSdkStatus.sdkAvailable;
    } catch (e) {
      // If the check fails, assume health is not available
      // This handles cases where the platform doesn't support the check
      return false;
    }
  }

  // ============================================================
  // Permission Management
  // ============================================================

  @override
  Future<bool> hasPermission() async {
    // Web platform does not support health APIs
    if (kIsWeb) {
      return false;
    }

    try {
      final permissions = await _health.hasPermissions(
        _stepTypes,
        permissions: [HealthDataAccess.READ],
      );
      return permissions ?? false;
    } catch (e) {
      // If permission check fails, assume no permission
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    // Web platform does not support health APIs
    if (kIsWeb) {
      return false;
    }

    try {
      // Request read permission for step data
      final granted = await _health.requestAuthorization(
        _stepTypes,
        permissions: [HealthDataAccess.READ],
      );
      return granted;
    } catch (e) {
      // If permission request fails, return false
      return false;
    }
  }

  // ============================================================
  // Step Data Access
  // ============================================================

  @override
  Future<int> getTodaySteps() async {
    // Web platform does not support health APIs
    if (kIsWeb) {
      return 0;
    }

    try {
      // Define time range from midnight today to now
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Fetch step data for today
      final healthData = await _health.getHealthDataFromTypes(
        types: _stepTypes,
        startTime: midnight,
        endTime: now,
      );

      // Sum up all step records
      var totalSteps = 0;
      for (final dataPoint in healthData) {
        if (dataPoint.type == HealthDataType.STEPS) {
          final value = dataPoint.value;
          if (value is NumericHealthValue) {
            totalSteps += value.numericValue.toInt();
          }
        }
      }

      return totalSteps;
    } catch (e) {
      // If fetching fails, return 0 instead of throwing
      return 0;
    }
  }

  @override
  Future<List<HealthStepRecord>> getStepsForDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    // Web platform does not support health APIs
    if (kIsWeb) {
      return [];
    }

    // Validate date range
    if (start.isAfter(end)) {
      return [];
    }

    try {
      // Fetch step data for the specified range
      final healthData = await _health.getHealthDataFromTypes(
        types: _stepTypes,
        startTime: start,
        endTime: end,
      );

      // Convert health data points to HealthStepRecords
      final records = <HealthStepRecord>[];
      for (final dataPoint in healthData) {
        if (dataPoint.type == HealthDataType.STEPS) {
          final value = dataPoint.value;
          if (value is NumericHealthValue) {
            records.add(
              HealthStepRecord(
                steps: value.numericValue.toInt(),
                startTime: dataPoint.dateFrom,
                endTime: dataPoint.dateTo,
              ),
            );
          }
        }
      }

      // Sort by start time in ascending order
      records.sort((a, b) => a.startTime.compareTo(b.startTime));

      return records;
    } catch (e) {
      // If fetching fails, return empty list instead of throwing
      return [];
    }
  }
}
