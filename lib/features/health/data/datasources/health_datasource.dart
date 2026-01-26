import 'package:health/health.dart' as health_pkg;

import '../../../../core/utils/logger.dart';

/// Domain entity representing health data from the device's health store.
///
/// This entity represents a single health data point (e.g., steps) retrieved
/// from HealthKit (iOS) or Health Connect (Android).
///
/// TODO: Move this to lib/features/health/domain/entities/ when that story is created.
class HealthData {
  /// The numeric value of the health data (e.g., step count).
  final double value;

  /// The type of health data (e.g., 'STEPS', 'DISTANCE').
  final String type;

  /// The unit of measurement (e.g., 'COUNT', 'METER').
  final String unit;

  /// The start time of the data recording period.
  final DateTime startTime;

  /// The end time of the data recording period.
  final DateTime endTime;

  /// The source of the health data (e.g., app name, device name).
  final String source;

  /// Creates a [HealthData] instance.
  const HealthData({
    required this.value,
    required this.type,
    required this.unit,
    required this.startTime,
    required this.endTime,
    required this.source,
  });

  /// Returns true if this is step count data.
  bool get isSteps => type.toUpperCase() == 'STEPS';

  /// Returns the value as an integer (useful for step counts).
  int get intValue => value.round();

  @override
  String toString() {
    return 'HealthData(type: $type, value: $value, unit: $unit, '
        'startTime: $startTime, endTime: $endTime, source: $source)';
  }
}

/// Abstract interface for health data operations.
///
/// Defines the contract for accessing health data from the device's health store
/// (HealthKit on iOS, Health Connect on Android). This interface provides methods
/// to fetch step data and manage health data permissions.
///
/// Example:
/// ```dart
/// final dataSource = HealthDataSourceImpl();
///
/// // Check if we have permission
/// final hasPermission = await dataSource.hasAuthorization();
///
/// if (!hasPermission) {
///   // Request permission
///   final granted = await dataSource.requestAuthorization();
///   if (!granted) {
///     print('Permission denied');
///     return;
///   }
/// }
///
/// // Fetch steps for today
/// final now = DateTime.now();
/// final startOfDay = DateTime(now.year, now.month, now.day);
/// final steps = await dataSource.fetchSteps(startOfDay, now);
/// ```
abstract class HealthDataSource {
  /// Fetches step count data within the specified time range.
  ///
  /// [start] - The start of the time range to fetch data for.
  /// [end] - The end of the time range to fetch data for.
  ///
  /// Returns a list of [HealthData] entities containing step count data.
  /// May return an empty list if no data is available for the time range.
  ///
  /// Throws an exception if authorization has not been granted or on
  /// platform-specific errors.
  Future<List<HealthData>> fetchSteps(DateTime start, DateTime end);

  /// Requests authorization to read step data from the health store.
  ///
  /// This method will display the platform's health data permission dialog
  /// to the user if permissions haven't been granted yet.
  ///
  /// Returns true if authorization was granted, false otherwise.
  Future<bool> requestAuthorization();

  /// Checks if the app has authorization to read step data.
  ///
  /// Returns true if authorization has been granted, false otherwise.
  /// This method does not request permission; it only checks the current status.
  Future<bool> hasAuthorization();
}

/// Implementation of [HealthDataSource] using the health package.
///
/// This class provides access to health data (specifically step counts) using
/// the health package, which integrates with HealthKit on iOS and Health Connect
/// on Android.
///
/// Example:
/// ```dart
/// // In production
/// final dataSource = HealthDataSourceImpl();
///
/// // In tests (with mock Health instance)
/// final mockHealth = MockHealth();
/// final dataSource = HealthDataSourceImpl(health: mockHealth);
///
/// // Fetch today's steps
/// final now = DateTime.now();
/// final startOfDay = DateTime(now.year, now.month, now.day);
/// final steps = await dataSource.fetchSteps(startOfDay, now);
/// final totalSteps = steps.fold<int>(0, (sum, data) => sum + data.intValue);
/// ```
class HealthDataSourceImpl implements HealthDataSource {
  final health_pkg.Health _health;

  /// The health data types that this datasource works with.
  static const List<health_pkg.HealthDataType> _dataTypes = [
    health_pkg.HealthDataType.STEPS,
  ];

  /// Creates a [HealthDataSourceImpl] instance.
  ///
  /// Optionally accepts a [Health] instance for testing purposes.
  /// If not provided, a default singleton instance will be used.
  HealthDataSourceImpl({health_pkg.Health? health})
      : _health = health ?? health_pkg.Health();

  @override
  Future<List<HealthData>> fetchSteps(DateTime start, DateTime end) async {
    AppLogger.debug('Fetching steps from $start to $end');

    try {
      // Ensure we have permissions before fetching
      final hasPermission = await hasAuthorization();
      if (!hasPermission) {
        AppLogger.warning('No authorization to fetch steps');
        return [];
      }

      // Fetch health data points
      final healthDataPoints = await _health.getHealthDataFromTypes(
        types: _dataTypes,
        startTime: start,
        endTime: end,
      );

      AppLogger.info('Retrieved ${healthDataPoints.length} health data points');

      // Convert to domain entities
      final healthDataList = healthDataPoints
          .map(_healthDataPointToEntity)
          .toList();

      // Calculate total steps for logging
      final totalSteps = healthDataList.fold<int>(
        0,
        (sum, data) => sum + data.intValue,
      );
      AppLogger.info('Total steps in range: $totalSteps');

      return healthDataList;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching steps', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> requestAuthorization() async {
    AppLogger.debug('Requesting health authorization for steps');

    try {
      // Configure health for the specific platform
      await _health.configure();

      // Request authorization for step data (READ only)
      final granted = await _health.requestAuthorization(
        _dataTypes,
        permissions: [health_pkg.HealthDataAccess.READ],
      );

      if (granted) {
        AppLogger.info('Health authorization granted for steps');
      } else {
        AppLogger.warning('Health authorization denied for steps');
      }

      return granted;
    } catch (e, stackTrace) {
      AppLogger.error('Error requesting health authorization', e, stackTrace);
      return false;
    }
  }

  @override
  Future<bool> hasAuthorization() async {
    AppLogger.debug('Checking health authorization for steps');

    try {
      final hasPermission = await _health.hasPermissions(
        _dataTypes,
        permissions: [health_pkg.HealthDataAccess.READ],
      );

      final result = hasPermission == true;

      AppLogger.info(
        'Health authorization check for steps: ${result ? "granted" : "not granted"}',
      );

      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Error checking health authorization', e, stackTrace);
      return false;
    }
  }

  /// Converts a [health_pkg.HealthDataPoint] to a [HealthData] entity.
  ///
  /// Maps all relevant fields from the health package data point to our
  /// domain entity.
  HealthData _healthDataPointToEntity(health_pkg.HealthDataPoint dataPoint) {
    // Extract numeric value from the data point
    final numericValue = dataPoint.value;
    double value;

    if (numericValue is health_pkg.NumericHealthValue) {
      value = numericValue.numericValue.toDouble();
    } else {
      // Fallback for other value types
      value = 0.0;
    }

    return HealthData(
      value: value,
      type: dataPoint.type.name,
      unit: dataPoint.unit.name,
      startTime: dataPoint.dateFrom,
      endTime: dataPoint.dateTo,
      source: dataPoint.sourceName,
    );
  }
}
