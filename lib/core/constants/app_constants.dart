/// Application-wide constants used throughout the app.
///
/// This class contains static const values that are used across
/// different parts of the application.
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  /// Application name displayed in UI
  static const String appName = 'App Pasos';

  /// Current application version
  static const String appVersion = '1.0.0';

  /// Default page size for paginated lists
  static const int defaultPageSize = 20;

  /// Maximum page size allowed
  static const int maxPageSize = 100;

  /// Minimum password length for validation
  static const int minPasswordLength = 8;

  /// Maximum username length
  static const int maxUsernameLength = 50;

  /// Date format for display
  static const String dateFormat = 'yyyy-MM-dd';

  /// DateTime format for display
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  /// Time format for display
  static const String timeFormat = 'HH:mm';

  /// Animation duration in milliseconds
  static const int animationDurationMs = 300;

  /// Debounce duration for search in milliseconds
  static const int searchDebounceDurationMs = 500;
}

/// Enum representing the source of a step entry.
///
/// Steps can be recorded manually by the user, automatically
/// by the device's health sensors, or synced from external services.
enum StepSource {
  /// Step entered manually by user
  manual('manual'),

  /// Step recorded automatically from device sensors
  automatic('automatic'),

  /// Step synced from external health service
  synced('synced');

  const StepSource(this.value);

  /// The string value representation for API communication
  final String value;

  /// Creates a StepSource from a string value
  static StepSource fromString(String value) {
    return StepSource.values.firstWhere(
      (source) => source.value == value,
      orElse: () => StepSource.manual,
    );
  }
}
