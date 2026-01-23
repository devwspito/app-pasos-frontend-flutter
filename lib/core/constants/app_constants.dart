/// Application-wide constants for the Pasos app.
///
/// This class contains all constant values used throughout the application.
/// Uses Dart 3's `abstract final class` pattern to prevent instantiation
/// and inheritance while providing a clean namespace for constants.
library;

/// Core application constants.
///
/// Example usage:
/// ```dart
/// final appName = AppConstants.appName;
/// final timeout = AppConstants.apiTimeout;
/// ```
abstract final class AppConstants {
  /// Application name displayed throughout the app.
  static const String appName = 'Pasos';

  /// Application version for display purposes.
  static const String appVersion = '1.0.0';

  /// Default daily steps goal for new users.
  static const int defaultStepsGoal = 10000;

  /// Minimum allowed daily steps goal.
  static const int minStepsGoal = 1000;

  /// Maximum allowed daily steps goal.
  static const int maxStepsGoal = 100000;

  /// Default timeout duration for API requests.
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Default timeout for connection establishment.
  static const Duration connectionTimeout = Duration(seconds: 15);

  /// Default timeout for receiving data.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Interval for step count updates in milliseconds.
  static const int stepUpdateIntervalMs = 1000;

  /// Maximum number of retry attempts for failed API requests.
  static const int maxRetryAttempts = 3;

  /// Delay between retry attempts.
  static const Duration retryDelay = Duration(seconds: 2);

  /// Cache duration for step data.
  static const Duration stepDataCacheDuration = Duration(minutes: 5);

  /// Cache duration for user profile data.
  static const Duration profileCacheDuration = Duration(hours: 1);
}

/// Storage key constants for local persistence.
///
/// Example usage:
/// ```dart
/// await storage.write(key: StorageKeys.authToken, value: token);
/// ```
abstract final class StorageKeys {
  /// Key for storing authentication token.
  static const String authToken = 'auth_token';

  /// Key for storing refresh token.
  static const String refreshToken = 'refresh_token';

  /// Key for storing user ID.
  static const String userId = 'user_id';

  /// Key for storing user preferences.
  static const String userPreferences = 'user_preferences';

  /// Key for storing daily steps goal.
  static const String stepsGoal = 'steps_goal';

  /// Key for storing theme mode preference.
  static const String themeMode = 'theme_mode';

  /// Key for storing locale preference.
  static const String locale = 'locale';

  /// Key for storing onboarding completion status.
  static const String onboardingComplete = 'onboarding_complete';

  /// Key for storing last sync timestamp.
  static const String lastSyncTimestamp = 'last_sync_timestamp';
}

/// Animation duration constants.
///
/// Example usage:
/// ```dart
/// AnimatedContainer(duration: AnimationDurations.short);
/// ```
abstract final class AnimationDurations {
  /// Short animation duration (150ms).
  static const Duration short = Duration(milliseconds: 150);

  /// Medium animation duration (300ms).
  static const Duration medium = Duration(milliseconds: 300);

  /// Long animation duration (500ms).
  static const Duration long = Duration(milliseconds: 500);

  /// Extra long animation duration (800ms).
  static const Duration extraLong = Duration(milliseconds: 800);
}

/// Pagination constants.
abstract final class PaginationConstants {
  /// Default page size for paginated requests.
  static const int defaultPageSize = 20;

  /// Maximum page size allowed.
  static const int maxPageSize = 100;

  /// Initial page number.
  static const int initialPage = 1;
}
