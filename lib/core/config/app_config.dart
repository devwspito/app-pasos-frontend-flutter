import 'environment.dart';

/// Global application configuration manager.
///
/// This class provides a centralized way to access environment-specific
/// configuration throughout the application. Must be initialized at app startup.
///
/// Example:
/// ```dart
/// void main() {
///   AppConfig.initialize(EnvironmentConfig.development);
///   runApp(MyApp());
/// }
/// ```
class AppConfig {
  static late EnvironmentConfig _config;

  /// Initializes the application configuration with the specified environment.
  ///
  /// This should be called once at application startup, typically in main().
  static void initialize(EnvironmentConfig config) {
    _config = config;
  }

  /// Returns the current environment configuration.
  static EnvironmentConfig get current => _config;

  /// Returns the base URL for API requests.
  static String get baseUrl => _config.baseUrl;

  /// Returns whether logging is enabled for the current environment.
  static bool get enableLogging => _config.enableLogging;

  /// Returns whether crash reporting is enabled for the current environment.
  static bool get enableCrashReporting => _config.enableCrashReporting;

  /// Returns the current environment type.
  static Environment get environment => _config.environment;

  /// Returns true if running in development environment.
  static bool get isDevelopment =>
      _config.environment == Environment.development;

  /// Returns true if running in staging environment.
  static bool get isStaging => _config.environment == Environment.staging;

  /// Returns true if running in production environment.
  static bool get isProduction => _config.environment == Environment.production;
}
