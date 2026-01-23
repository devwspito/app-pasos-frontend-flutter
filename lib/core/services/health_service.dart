/// Abstract service interface for health data operations.
///
/// Defines the contract for interacting with platform health APIs
/// (HealthKit on iOS, Health Connect on Android) to read step data.
///
/// This interface is platform-agnostic and should not depend on
/// any concrete health package implementations.
///
/// All methods handle platform-specific details internally:
/// - Availability checks for the current platform
/// - Permission requests and status checks
/// - Data reading from platform health stores
abstract interface class HealthService {
  /// Checks if health data is available on this platform.
  ///
  /// Returns `true` if the device supports health data access:
  /// - iOS: HealthKit is available
  /// - Android: Health Connect is installed and available
  ///
  /// Returns `false` if health data is not supported on this device
  /// or if the platform is not recognized (e.g., web).
  Future<bool> isAvailable();

  /// Requests permissions to read step data from the platform health store.
  ///
  /// This method should be called before attempting to read health data.
  /// The user will be prompted with a system dialog to grant permissions.
  ///
  /// Returns `true` if permissions were granted by the user.
  /// Returns `false` if permissions were denied or an error occurred.
  ///
  /// Note: On some platforms, permission requests can only be shown once.
  /// Subsequent calls may return the cached permission status.
  Future<bool> requestPermissions();

  /// Checks if permissions to read step data are already granted.
  ///
  /// Use this method to check permission status without triggering
  /// a permission request dialog.
  ///
  /// Returns `true` if permissions are currently granted.
  /// Returns `false` if permissions are denied or not yet requested.
  Future<bool> hasPermissions();

  /// Reads the total step count for a specified date range.
  ///
  /// Aggregates all step data from the platform health store
  /// between [startDate] and [endDate] (inclusive).
  ///
  /// [startDate] The start of the date range (inclusive).
  /// [endDate] The end of the date range (inclusive).
  ///
  /// Returns the total number of steps recorded in the date range.
  /// Returns `0` if no step data is available for the range.
  ///
  /// Throws an exception if permissions are not granted or
  /// if health data is not available on this platform.
  Future<int> readStepCount({
    required DateTime startDate,
    required DateTime endDate,
  });
}
