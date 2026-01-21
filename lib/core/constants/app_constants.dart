/// Application-wide constants.
///
/// Uses Dart 3 `abstract final class` pattern to prevent instantiation
/// while providing static constant access.
abstract final class AppConstants {
  /// Application name displayed throughout the app.
  static const String appName = 'App Pasos';

  /// Current application version.
  static const String appVersion = '1.0.0';

  /// Application build number.
  static const int buildNumber = 1;

  /// Default timeout for HTTP requests in seconds.
  static const int httpTimeoutSeconds = 30;

  /// Default timeout for HTTP connection in seconds.
  static const int httpConnectTimeoutSeconds = 15;

  /// Default timeout for HTTP receive in seconds.
  static const int httpReceiveTimeoutSeconds = 30;

  /// Maximum number of retry attempts for failed requests.
  static const int maxRetryAttempts = 3;

  /// Delay between retry attempts in milliseconds.
  static const int retryDelayMs = 1000;

  /// Default page size for paginated requests.
  static const int defaultPageSize = 20;

  /// Maximum page size allowed for paginated requests.
  static const int maxPageSize = 100;

  /// Minimum password length for validation.
  static const int minPasswordLength = 8;

  /// Maximum password length for validation.
  static const int maxPasswordLength = 128;

  /// Minimum username length for validation.
  static const int minUsernameLength = 3;

  /// Maximum username length for validation.
  static const int maxUsernameLength = 50;

  /// Cache duration for local data in minutes.
  static const int cacheDurationMinutes = 30;

  /// Token refresh threshold in minutes before expiry.
  static const int tokenRefreshThresholdMinutes = 5;

  /// Animation duration in milliseconds for standard transitions.
  static const int animationDurationMs = 300;

  /// Long animation duration in milliseconds.
  static const int animationDurationLongMs = 500;

  /// Debounce duration in milliseconds for search inputs.
  static const int searchDebounceMs = 500;

  /// Maximum file upload size in bytes (10 MB).
  static const int maxFileUploadSizeBytes = 10 * 1024 * 1024;

  /// Supported image extensions for uploads.
  static const List<String> supportedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  /// Supported document extensions for uploads.
  static const List<String> supportedDocumentExtensions = [
    'pdf',
    'doc',
    'docx',
    'txt',
  ];
}
