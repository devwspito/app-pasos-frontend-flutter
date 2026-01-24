/// Application-wide constants for App Pasos.
///
/// This class contains static constants that are used throughout the application
/// such as app name, version, timeout configurations, and retry settings.
///
/// Example usage:
/// ```dart
/// final name = AppConstants.appName;
/// final timeout = AppConstants.defaultTimeout;
/// ```
abstract final class AppConstants {
  /// The display name of the application.
  static const String appName = 'App Pasos';

  /// Current application version.
  static const String appVersion = '1.0.0';

  /// Default timeout duration for general operations.
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Timeout duration for establishing network connections.
  static const Duration connectionTimeout = Duration(seconds: 15);

  /// Timeout duration for receiving data from the server.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Maximum number of retry attempts for failed operations.
  static const int maxRetries = 3;

  /// Delay between retry attempts.
  static const Duration retryDelay = Duration(seconds: 1);

  /// Default page size for paginated requests.
  static const int defaultPageSize = 20;

  /// Maximum allowed page size for paginated requests.
  static const int maxPageSize = 100;

  /// Minimum password length for user authentication.
  static const int minPasswordLength = 8;

  /// Maximum password length for user authentication.
  static const int maxPasswordLength = 128;
}
