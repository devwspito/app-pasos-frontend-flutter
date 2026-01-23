/// Secure storage keys for the application.
///
/// Provides centralized access to all storage keys used with flutter_secure_storage.
/// Using constants ensures consistency across the app and prevents typos.
abstract final class StorageKeys {
  // ============================================================================
  // Authentication Keys
  // ============================================================================

  /// Key for storing the access token.
  static const String accessToken = 'access_token';

  /// Key for storing the refresh token.
  static const String refreshToken = 'refresh_token';

  /// Key for storing the token expiration timestamp.
  static const String tokenExpiry = 'token_expiry';

  // ============================================================================
  // User Data Keys
  // ============================================================================

  /// Key for storing the user ID.
  static const String userId = 'user_id';

  /// Key for storing the user email.
  static const String userEmail = 'user_email';

  /// Key for storing the user display name.
  static const String userName = 'user_name';

  /// Key for storing the cached user profile JSON.
  static const String userProfile = 'user_profile';

  // ============================================================================
  // App State Keys
  // ============================================================================

  /// Key for storing whether onboarding has been completed.
  static const String onboardingCompleted = 'onboarding_completed';

  /// Key for storing the last sync timestamp.
  static const String lastSyncTimestamp = 'last_sync_timestamp';

  /// Key for storing the selected theme mode.
  static const String themeMode = 'theme_mode';

  /// Key for storing the selected locale.
  static const String locale = 'locale';

  // ============================================================================
  // Device Keys
  // ============================================================================

  /// Key for storing the device ID for push notifications.
  static const String deviceId = 'device_id';

  /// Key for storing the FCM token.
  static const String fcmToken = 'fcm_token';

  // ============================================================================
  // Feature Flags Keys
  // ============================================================================

  /// Key for storing analytics opt-in status.
  static const String analyticsEnabled = 'analytics_enabled';

  /// Key for storing crash reporting opt-in status.
  static const String crashlyticsEnabled = 'crashlytics_enabled';
}
