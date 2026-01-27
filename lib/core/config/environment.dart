/// Application environment types.
enum Environment {
  /// Local development environment
  development,

  /// Staging/testing environment
  staging,

  /// Production environment
  production,
}

/// Configuration for each environment.
///
/// Contains environment-specific settings like API base URL and logging.
class EnvironmentConfig {
  /// The current environment type
  final Environment environment;

  /// The base URL for API requests
  final String baseUrl;

  /// Whether logging is enabled
  final bool enableLogging;

  /// Whether to use secure storage (HTTPS)
  final bool useSecureStorage;

  const EnvironmentConfig({
    required this.environment,
    required this.baseUrl,
    required this.enableLogging,
    this.useSecureStorage = true,
  });

  /// Development environment configuration
  static const EnvironmentConfig development = EnvironmentConfig(
    environment: Environment.development,
    baseUrl: 'http://localhost:3001/api',
    enableLogging: true,
    useSecureStorage: false,
  );

  /// Staging environment configuration
  static const EnvironmentConfig staging = EnvironmentConfig(
    environment: Environment.staging,
    baseUrl: 'https://staging-api.apppasos.com/api',
    enableLogging: true,
    useSecureStorage: true,
  );

  /// Production environment configuration
  static const EnvironmentConfig production = EnvironmentConfig(
    environment: Environment.production,
    baseUrl: 'https://api.apppasos.com/api',
    enableLogging: false,
    useSecureStorage: true,
  );

  /// Get environment name as string
  String get name => environment.name;

  /// Check if this is a debug environment (development or staging)
  bool get isDebug =>
      environment == Environment.development ||
      environment == Environment.staging;

  @override
  String toString() => 'EnvironmentConfig(environment: $name, baseUrl: $baseUrl)';
}
