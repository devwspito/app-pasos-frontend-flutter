/// Application-wide constants for the Pasos app.
///
/// Uses Dart 3 abstract final class pattern for type-safe constant groupings.
/// These constants should not be changed at runtime.
abstract final class AppConstants {
  /// Application identification
  static const String appName = 'Pasos';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  /// Network timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Storage keys for secure/shared preferences
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'app_locale';
  static const String onboardingCompletedKey = 'onboarding_completed';

  /// Pagination defaults
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  /// Input validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;
}
