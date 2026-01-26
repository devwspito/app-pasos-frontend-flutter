/// Enum representing the different deployment environments.
enum Environment {
  /// Development environment - local development
  development,

  /// Staging environment - pre-production testing
  staging,

  /// Production environment - live application
  production,
}

/// Configuration class for environment-specific settings.
///
/// Contains base URL, logging settings, and crash reporting configuration
/// for each environment.
class EnvironmentConfig {
  /// The current environment type
  final Environment environment;

  /// Base URL for API requests
  final String baseUrl;

  /// Whether debug logging is enabled
  final bool enableLogging;

  /// Whether crash reporting is enabled
  final bool enableCrashReporting;

  /// Creates an environment configuration.
  const EnvironmentConfig({
    required this.environment,
    required this.baseUrl,
    this.enableLogging = true,
    this.enableCrashReporting = false,
  });

  /// Development environment configuration.
  ///
  /// - Local API server at localhost:3000
  /// - Logging enabled
  /// - Crash reporting disabled
  static const EnvironmentConfig development = EnvironmentConfig(
    environment: Environment.development,
    baseUrl: 'http://localhost:3000/api/v1',
    enableLogging: true,
    enableCrashReporting: false,
  );

  /// Staging environment configuration.
  ///
  /// - Staging API server
  /// - Logging enabled
  /// - Crash reporting enabled
  static const EnvironmentConfig staging = EnvironmentConfig(
    environment: Environment.staging,
    baseUrl: 'https://staging-api.apppasos.com/api/v1',
    enableLogging: true,
    enableCrashReporting: true,
  );

  /// Production environment configuration.
  ///
  /// - Production API server
  /// - Logging disabled
  /// - Crash reporting enabled
  static const EnvironmentConfig production = EnvironmentConfig(
    environment: Environment.production,
    baseUrl: 'https://api.apppasos.com/api/v1',
    enableLogging: false,
    enableCrashReporting: true,
  );
}
