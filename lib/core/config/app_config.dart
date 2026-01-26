import 'environment.dart';

/// Global application configuration.
///
/// Provides access to environment-specific settings throughout the app.
/// Must be initialized before use with [AppConfig.init].
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  static EnvironmentConfig? _config;

  /// Initialize the app configuration with the specified environment.
  ///
  /// This should be called once at app startup before accessing any config values.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   AppConfig.init(EnvironmentConfig.development);
  ///   runApp(MyApp());
  /// }
  /// ```
  static void init(EnvironmentConfig config) {
    _config = config;
  }

  /// Get the current environment configuration.
  ///
  /// Throws [StateError] if [init] has not been called.
  static EnvironmentConfig get config {
    if (_config == null) {
      throw StateError(
        'AppConfig has not been initialized. Call AppConfig.init() first.',
      );
    }
    return _config!;
  }

  /// Get the API base URL.
  static String get baseUrl => config.baseUrl;

  /// Check if logging is enabled.
  static bool get enableLogging => config.enableLogging;

  /// Get the current environment type.
  static Environment get environment => config.environment;

  /// Check if running in development environment.
  static bool get isDevelopment => config.environment == Environment.development;

  /// Check if running in staging environment.
  static bool get isStaging => config.environment == Environment.staging;

  /// Check if running in production environment.
  static bool get isProduction => config.environment == Environment.production;

  /// Check if running in a debug environment (development or staging).
  static bool get isDebug => config.isDebug;

  /// Check if secure storage should be used.
  static bool get useSecureStorage => config.useSecureStorage;

  /// Check if the configuration has been initialized.
  static bool get isInitialized => _config != null;

  /// Reset the configuration (mainly for testing purposes).
  static void reset() {
    _config = null;
  }
}
