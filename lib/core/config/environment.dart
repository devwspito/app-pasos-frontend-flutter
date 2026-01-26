/// Environment types for the application.
///
/// This enum defines the different environments the app can run in:
/// - [development]: Local development environment
/// - [staging]: Pre-production testing environment
/// - [production]: Live production environment
enum Environment {
  development,
  staging,
  production,
}

/// Extension methods for [Environment] enum providing convenience getters.
extension EnvironmentExtension on Environment {
  /// Returns true if the current environment is development.
  bool get isDevelopment => this == Environment.development;

  /// Returns true if the current environment is staging.
  bool get isStaging => this == Environment.staging;

  /// Returns true if the current environment is production.
  bool get isProduction => this == Environment.production;

  /// Returns the environment name as a string.
  String get displayName {
    switch (this) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }
}
