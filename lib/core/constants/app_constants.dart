/// Application-wide constants used throughout the app.
///
/// Contains configuration values like timeouts, limits, and app metadata.
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  /// The display name of the application
  static const String appName = 'App Pasos';

  /// Default HTTP timeout in milliseconds
  static const int defaultTimeout = 30000;

  /// Maximum number of steps that can be recorded per day
  static const int maxStepsPerDay = 100000;

  /// Minimum required password length for user authentication
  static const int minPasswordLength = 6;

  /// Maximum allowed username length
  static const int maxUsernameLength = 30;

  /// Minimum allowed username length
  static const int minUsernameLength = 3;

  /// Default pagination page size
  static const int defaultPageSize = 20;

  /// Maximum pagination page size
  static const int maxPageSize = 100;

  /// Token refresh buffer in seconds (refresh 5 minutes before expiry)
  static const int tokenRefreshBuffer = 300;

  /// Local storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}
