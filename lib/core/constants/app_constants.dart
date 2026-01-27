/// Application-wide constants for App Pasos.
///
/// This file contains all configuration constants, storage keys,
/// and API headers used throughout the application.
library;

/// Core application configuration constants.
///
/// Use these values for timeouts, retry logic, and app identification.
abstract final class AppConstants {
  /// The name of the application.
  static const String appName = 'App Pasos';

  /// HTTP connection timeout duration.
  static const Duration connectionTimeout = Duration(seconds: 30);

  /// HTTP receive timeout duration for reading response data.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Maximum number of retry attempts for failed network requests.
  static const int maxRetries = 3;

  /// Delay between retry attempts.
  static const Duration retryDelay = Duration(seconds: 1);

  /// Minimum password length for validation.
  static const int minPasswordLength = 8;

  /// Maximum password length for validation.
  static const int maxPasswordLength = 128;

  /// Minimum username length for validation.
  static const int minUsernameLength = 3;

  /// Maximum username length for validation.
  static const int maxUsernameLength = 50;
}

/// Keys used for local storage operations.
///
/// These constants ensure consistent key names across all storage operations.
abstract final class StorageKeys {
  /// Key for storing the authentication JWT token.
  static const String authToken = 'auth_token';

  /// Key for storing the refresh token.
  static const String refreshToken = 'refresh_token';

  /// Key for storing the current user's ID.
  static const String userId = 'user_id';

  /// Key for storing the user's email.
  static const String userEmail = 'user_email';

  /// Key for storing the user's display name.
  static const String userName = 'user_name';

  /// Key for storing app theme preference.
  static const String themeMode = 'theme_mode';

  /// Key for storing app locale preference.
  static const String locale = 'locale';

  /// Key for storing whether onboarding has been completed.
  static const String onboardingComplete = 'onboarding_complete';

  /// Key for storing the last sync timestamp.
  static const String lastSyncTimestamp = 'last_sync_timestamp';
}

/// Standard HTTP header names used in API requests.
///
/// These constants ensure consistent header naming across all
/// network operations.
abstract final class ApiHeaders {
  /// Authorization header for bearer tokens.
  static const String authorization = 'Authorization';

  /// Content-Type header for request body format.
  static const String contentType = 'Content-Type';

  /// Accept header for response format preference.
  static const String accept = 'Accept';

  /// Custom header for API version specification.
  static const String apiVersion = 'X-API-Version';

  /// Custom header for device identification.
  static const String deviceId = 'X-Device-ID';

  /// Custom header for platform identification (iOS, Android, Web).
  static const String platform = 'X-Platform';

  /// Custom header for app version.
  static const String appVersion = 'X-App-Version';
}

/// Common content type values for HTTP requests.
abstract final class ContentTypes {
  /// JSON content type.
  static const String json = 'application/json';

  /// Form URL encoded content type.
  static const String formUrlEncoded = 'application/x-www-form-urlencoded';

  /// Multipart form data content type.
  static const String multipartFormData = 'multipart/form-data';
}
