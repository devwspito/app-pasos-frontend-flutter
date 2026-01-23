import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the application.
///
/// Provides access to environment-specific settings and flags.
/// Values are loaded from the .env file using flutter_dotenv.
///
/// Make sure to call `await dotenv.load()` in main() before using these getters.
abstract final class Environment {
  // ============================================================================
  // API Configuration (from .env)
  // ============================================================================

  /// Base URL for API requests.
  /// Defaults to localhost if not specified in .env.
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';

  /// WebSocket URL for real-time connections.
  /// Defaults to localhost if not specified in .env.
  static String get wsUrl => dotenv.env['WS_URL'] ?? 'ws://localhost:3000';

  /// Current environment name from .env.
  /// Returns 'development' if not specified.
  static String get environment =>
      dotenv.env['ENVIRONMENT'] ?? 'development';

  // ============================================================================
  // Feature Flags (from .env)
  // ============================================================================

  /// Whether analytics is enabled.
  /// Defaults to false if not specified in .env.
  static bool get enableAnalytics =>
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';

  /// Whether crashlytics is enabled.
  /// Defaults to false if not specified in .env.
  static bool get enableCrashlytics =>
      dotenv.env['ENABLE_CRASHLYTICS']?.toLowerCase() == 'true';

  // ============================================================================
  // Deep Linking Configuration (from .env)
  // ============================================================================

  /// App URL scheme for deep linking.
  static String get appScheme =>
      dotenv.env['APP_SCHEME'] ?? 'apppasosfrontendflutter';

  /// App host for deep linking.
  static String get appHost => dotenv.env['APP_HOST'] ?? 'app.example.com';

  // ============================================================================
  // Runtime Environment Detection
  // ============================================================================

  /// Whether the app is running in development mode.
  /// Uses both .env ENVIRONMENT value and Dart's assert-based detection.
  static bool get isDevelopment {
    // First check .env configuration
    if (environment.toLowerCase() == 'production') {
      return false;
    }

    // Fall back to Dart's debug mode detection
    bool inDebugMode = false;
    assert(() {
      inDebugMode = true;
      return true;
    }());
    return inDebugMode;
  }

  /// Whether the app is running in production mode.
  static bool get isProduction => !isDevelopment;

  /// The current environment name.
  /// Returns the ENVIRONMENT value from .env, falling back to
  /// 'development' or 'production' based on [isDevelopment].
  static String get name => environment.isNotEmpty
      ? environment
      : (isDevelopment ? 'development' : 'production');
}
