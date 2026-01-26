/// Application-wide constants used throughout the app.
///
/// Contains configuration values, storage keys, and timeout settings.
class AppConstants {
  /// Application display name
  static const String appName = 'App Pasos';

  /// Current application version
  static const String appVersion = '1.0.0';

  /// HTTP connection timeout in milliseconds (30 seconds)
  static const int connectionTimeout = 30000;

  /// HTTP receive timeout in milliseconds (30 seconds)
  static const int receiveTimeout = 30000;

  /// Maximum number of retry attempts for failed requests
  static const int maxRetries = 3;

  // Storage keys for secure storage
  /// Key for storing access token in secure storage
  static const String accessTokenKey = 'access_token';

  /// Key for storing refresh token in secure storage
  static const String refreshTokenKey = 'refresh_token';

  /// Key for storing user data in secure storage
  static const String userDataKey = 'user_data';

  /// Prevent instantiation - this is a utility class
  AppConstants._();
}
