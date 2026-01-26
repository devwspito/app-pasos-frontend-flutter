/// Core application constants used throughout the app.
///
/// This class uses the Dart 3 `abstract final class` pattern to prevent
/// instantiation and extension while providing a clean namespace for constants.
abstract final class AppConstants {
  /// Application name displayed in UI and metadata.
  static const String appName = 'App Pasos';

  /// HTTP connection timeout duration.
  static const Duration connectionTimeout = Duration(seconds: 30);

  /// HTTP receive/read timeout duration.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Key used to store the authentication token in secure storage.
  static const String tokenKey = 'auth_token';

  /// Key used to store the refresh token in secure storage.
  static const String refreshTokenKey = 'refresh_token';

  /// Key used to store serialized user data in storage.
  static const String userKey = 'user_data';

  /// Default pagination page size for list requests.
  static const int defaultPageSize = 20;

  /// Maximum number of retry attempts for failed network requests.
  static const int maxRetryAttempts = 3;

  /// Delay between retry attempts.
  static const Duration retryDelay = Duration(seconds: 2);
}
