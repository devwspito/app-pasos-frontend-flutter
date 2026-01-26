// TODO: Replace this temporary HealthData definition when
// lib/features/health/domain/entities/health_data.dart is created by another story.
// This placeholder allows the repository interface to compile.

/// Temporary HealthData entity placeholder.
///
/// This class should be replaced with the proper import from
/// `../entities/health_data.dart` once that file is created.
///
/// Expected location: lib/features/health/domain/entities/health_data.dart
class HealthData {
  /// The type of health data (e.g., steps, distance, calories).
  final String type;

  /// The numeric value of the health data.
  final double value;

  /// The unit of measurement (e.g., 'count', 'meters', 'kcal').
  final String unit;

  /// The start timestamp for this data point.
  final DateTime startTime;

  /// The end timestamp for this data point.
  final DateTime endTime;

  /// Creates a [HealthData] instance.
  const HealthData({
    required this.type,
    required this.value,
    required this.unit,
    required this.startTime,
    required this.endTime,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthData &&
        other.type == type &&
        other.value == value &&
        other.unit == unit &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode {
    return Object.hash(type, value, unit, startTime, endTime);
  }

  @override
  String toString() {
    return 'HealthData(type: $type, value: $value, unit: $unit, '
        'startTime: $startTime, endTime: $endTime)';
  }
}

/// Abstract interface for health data repository operations.
///
/// Defines the contract for health data access and permission management.
/// This interface lives in the domain layer and should be implemented
/// by a concrete class in the data layer.
///
/// The repository provides methods to:
/// - Read step count data from the device's health data store
/// - Request and check health data permissions
///
/// Example usage:
/// ```dart
/// final repository = HealthRepositoryImpl();
///
/// // Check if we have permissions
/// if (await repository.hasPermissions()) {
///   // Get today's steps
///   final todaySteps = await repository.getTodaySteps();
///   print('Steps today: ${todaySteps?.value ?? 0}');
///
///   // Get steps for a date range
///   final weekSteps = await repository.getStepsForDateRange(
///     DateTime.now().subtract(Duration(days: 7)),
///     DateTime.now(),
///   );
/// } else {
///   // Request permissions first
///   final granted = await repository.requestPermissions();
///   if (granted) {
///     print('Permissions granted!');
///   }
/// }
/// ```
abstract class HealthRepository {
  /// Fetches step count data for a specific date range.
  ///
  /// [start] - The start date/time for the range (inclusive).
  /// [end] - The end date/time for the range (inclusive).
  ///
  /// Returns a list of [HealthData] entities representing step count records.
  /// Each record contains the step count value, timestamps, and metadata.
  /// May return an empty list if no step data exists for the range.
  ///
  /// Throws an exception if permissions are not granted or on platform errors.
  Future<List<HealthData>> getStepsForDateRange(DateTime start, DateTime end);

  /// Fetches the step count for the current day.
  ///
  /// Returns a [HealthData] entity with the aggregated step count for today,
  /// or null if no step data is available for today.
  ///
  /// This is a convenience method that internally calls [getStepsForDateRange]
  /// with today's date range (midnight to now).
  ///
  /// Throws an exception if permissions are not granted or on platform errors.
  Future<HealthData?> getTodaySteps();

  /// Requests permissions to access health data.
  ///
  /// This method will trigger the platform's health data permission dialog
  /// (HealthKit on iOS, Health Connect on Android) asking the user to grant
  /// read access to step count data.
  ///
  /// Returns true if all required permissions were granted, false otherwise.
  ///
  /// Note: On iOS, even if the user denies permission, this may still return
  /// true due to platform limitations in detecting denial. Always verify
  /// with [hasPermissions] before reading data.
  Future<bool> requestPermissions();

  /// Checks if the app has permissions to access health data.
  ///
  /// Returns true if all required permissions (step count read access)
  /// have been granted, false otherwise.
  ///
  /// Use this method to verify permissions before attempting to read
  /// health data, especially since [requestPermissions] may not accurately
  /// reflect denial on all platforms.
  Future<bool> hasPermissions();
}
