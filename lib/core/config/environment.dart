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
/// Contains base URL, WebSocket URL, logging settings, and crash reporting
/// configuration for each environment.
class EnvironmentConfig {
  /// The current environment type
  final Environment environment;

  /// Base URL for API requests
  final String baseUrl;

  /// WebSocket URL for real-time communication
  final String wsUrl;

  /// Whether debug logging is enabled
  final bool enableLogging;

  /// Whether crash reporting is enabled
  final bool enableCrashReporting;

  /// Creates an environment configuration.
  const EnvironmentConfig({
    required this.environment,
    required this.baseUrl,
    required this.wsUrl,
    this.enableLogging = true,
    this.enableCrashReporting = false,
  });

  /// Development environment configuration.
  ///
  /// - Local API server at localhost:3000
  /// - Local WebSocket server at localhost:3000
  /// - Logging enabled
  /// - Crash reporting disabled
  static const EnvironmentConfig development = EnvironmentConfig(
    environment: Environment.development,
    baseUrl: 'http://localhost:3000/api/v1',
    wsUrl: 'ws://localhost:3000',
    enableLogging: true,
    enableCrashReporting: false,
  );

  /// Staging environment configuration.
  ///
  /// - Staging API server
  /// - Staging WebSocket server (secure)
  /// - Logging enabled
  /// - Crash reporting enabled
  static const EnvironmentConfig staging = EnvironmentConfig(
    environment: Environment.staging,
    baseUrl: 'https://staging-api.apppasos.com/api/v1',
    wsUrl: 'wss://staging-api.apppasos.com',
    enableLogging: true,
    enableCrashReporting: true,
  );

  /// Production environment configuration.
  ///
  /// - Production API server
  /// - Production WebSocket server (secure)
  /// - Logging disabled
  /// - Crash reporting enabled
  static const EnvironmentConfig production = EnvironmentConfig(
    environment: Environment.production,
    baseUrl: 'https://api.apppasos.com/api/v1',
    wsUrl: 'wss://api.apppasos.com',
    enableLogging: false,
    enableCrashReporting: true,
  );
}
