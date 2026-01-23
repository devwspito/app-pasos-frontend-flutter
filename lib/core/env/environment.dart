/// Environment configuration for the Pasos app.
///
/// Provides configuration management for different deployment environments
/// (development, staging, production) with appropriate settings for each.
library;

/// Available application environments.
enum Environment {
  /// Development environment - local development with debug features.
  dev,

  /// Staging environment - pre-production testing.
  staging,

  /// Production environment - live application.
  prod,
}

/// Environment-specific configuration.
///
/// Example usage:
/// ```dart
/// // Initialize in main.dart
/// void main() {
///   EnvironmentConfig.initialize(Environment.dev);
///   runApp(const MyApp());
/// }
///
/// // Access anywhere
/// final apiUrl = EnvironmentConfig.instance.apiBaseUrl;
/// ```
class EnvironmentConfig {
  /// Private constructor for singleton pattern.
  EnvironmentConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.enableLogging,
    required this.enableCrashReporting,
    required this.enableAnalytics,
    required this.enablePerformanceMonitoring,
    required this.apiVersion,
    required this.appStoreUrl,
    required this.playStoreUrl,
  });

  /// Current environment.
  final Environment environment;

  /// Base URL for REST API requests.
  final String apiBaseUrl;

  /// Base URL for WebSocket connections.
  final String wsBaseUrl;

  /// Whether logging is enabled.
  final bool enableLogging;

  /// Whether crash reporting is enabled.
  final bool enableCrashReporting;

  /// Whether analytics tracking is enabled.
  final bool enableAnalytics;

  /// Whether performance monitoring is enabled.
  final bool enablePerformanceMonitoring;

  /// API version string.
  final String apiVersion;

  /// iOS App Store URL.
  final String appStoreUrl;

  /// Android Play Store URL.
  final String playStoreUrl;

  /// Singleton instance.
  static EnvironmentConfig? _instance;

  /// Gets the current environment configuration instance.
  ///
  /// Throws [StateError] if [initialize] has not been called.
  static EnvironmentConfig get instance {
    if (_instance == null) {
      throw StateError(
        'EnvironmentConfig has not been initialized. '
        'Call EnvironmentConfig.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Whether the configuration has been initialized.
  static bool get isInitialized => _instance != null;

  /// Initializes the environment configuration.
  ///
  /// Must be called before accessing [instance].
  /// Typically called in main.dart before runApp().
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   EnvironmentConfig.initialize(Environment.dev);
  ///   runApp(const MyApp());
  /// }
  /// ```
  static void initialize(Environment environment) {
    _instance = _createConfig(environment);
  }

  /// Creates configuration for the specified environment.
  static EnvironmentConfig _createConfig(Environment environment) {
    switch (environment) {
      case Environment.dev:
        return EnvironmentConfig._(
          environment: Environment.dev,
          apiBaseUrl: 'http://localhost:3000',
          wsBaseUrl: 'ws://localhost:3000',
          enableLogging: true,
          enableCrashReporting: false,
          enableAnalytics: false,
          enablePerformanceMonitoring: false,
          apiVersion: 'v1',
          appStoreUrl: '',
          playStoreUrl: '',
        );

      case Environment.staging:
        return EnvironmentConfig._(
          environment: Environment.staging,
          apiBaseUrl: 'https://staging-api.pasos.app',
          wsBaseUrl: 'wss://staging-api.pasos.app',
          enableLogging: true,
          enableCrashReporting: true,
          enableAnalytics: false,
          enablePerformanceMonitoring: true,
          apiVersion: 'v1',
          appStoreUrl: 'https://testflight.apple.com/join/pasos',
          playStoreUrl:
              'https://play.google.com/apps/testing/com.pasos.app',
        );

      case Environment.prod:
        return EnvironmentConfig._(
          environment: Environment.prod,
          apiBaseUrl: 'https://api.pasos.app',
          wsBaseUrl: 'wss://api.pasos.app',
          enableLogging: false,
          enableCrashReporting: true,
          enableAnalytics: true,
          enablePerformanceMonitoring: true,
          apiVersion: 'v1',
          appStoreUrl: 'https://apps.apple.com/app/pasos/id123456789',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.pasos.app',
        );
    }
  }

  /// Resets the configuration (useful for testing).
  static void reset() {
    _instance = null;
  }

  /// Whether this is a development environment.
  bool get isDev => environment == Environment.dev;

  /// Whether this is a staging environment.
  bool get isStaging => environment == Environment.staging;

  /// Whether this is a production environment.
  bool get isProd => environment == Environment.prod;

  /// Whether this is a debug build (dev or staging).
  bool get isDebug => isDev || isStaging;

  /// Full API URL with version.
  String get fullApiUrl => '$apiBaseUrl/api/$apiVersion';

  /// Full WebSocket URL.
  String get fullWsUrl => '$wsBaseUrl/ws';

  @override
  String toString() {
    return 'EnvironmentConfig('
        'environment: $environment, '
        'apiBaseUrl: $apiBaseUrl, '
        'enableLogging: $enableLogging)';
  }
}

/// Extension on Environment for display names.
extension EnvironmentExtension on Environment {
  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case Environment.dev:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.prod:
        return 'Production';
    }
  }

  /// Short identifier for the environment.
  String get shortName {
    switch (this) {
      case Environment.dev:
        return 'DEV';
      case Environment.staging:
        return 'STG';
      case Environment.prod:
        return 'PROD';
    }
  }
}
