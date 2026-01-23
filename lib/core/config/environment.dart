/// Environment configuration for the application.
///
/// Provides access to environment-specific settings and flags.
abstract final class Environment {
  /// Whether the app is running in development mode.
  static bool get isDevelopment {
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
  static String get name => isDevelopment ? 'development' : 'production';
}
