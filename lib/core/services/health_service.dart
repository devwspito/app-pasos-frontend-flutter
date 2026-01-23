/// Abstract interface for health data services.
///
/// Provides methods to interact with device health data (e.g., step count).
/// Implementations should handle platform-specific health APIs.
abstract interface class HealthService {
  /// Checks if health data is available on the device.
  ///
  /// Returns `true` if health features can be accessed.
  Future<bool> isAvailable();

  /// Requests permissions to read health data.
  ///
  /// Returns `true` if permissions were granted.
  Future<bool> requestPermissions();

  /// Checks if the app already has health data permissions.
  ///
  /// Returns `true` if permissions are granted.
  Future<bool> hasPermissions();

  /// Reads the total step count for a given date range.
  ///
  /// [startDate] - The beginning of the date range.
  /// [endDate] - The end of the date range.
  ///
  /// Returns the total number of steps in the range, or 0 if unavailable.
  Future<int> readStepCount({
    required DateTime startDate,
    required DateTime endDate,
  });
}
