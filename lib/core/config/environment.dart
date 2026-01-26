/// Application environment types.
///
/// Defines the different deployment environments the app can run in.
enum Environment {
  /// Development environment - local development
  development,

  /// Staging environment - pre-production testing
  staging,

  /// Production environment - live deployment
  production,
}

/// Configuration values for each environment.
///
/// Contains URLs and settings specific to each deployment environment.
class EnvironmentConfig {
  // Private constructor to prevent instantiation
  EnvironmentConfig._();

  /// Get the base API URL for the given environment.
  ///
  /// - Development: Uses Android emulator localhost (10.0.2.2)
  /// - Staging: Uses staging server
  /// - Production: Uses production server
  static String getBaseUrl(Environment env) {
    switch (env) {
      case Environment.development:
        // Android emulator uses 10.0.2.2 to access host machine's localhost
        return 'http://10.0.2.2:3000';
      case Environment.staging:
        return 'https://staging-api.apppasos.com';
      case Environment.production:
        return 'https://api.apppasos.com';
    }
  }

  /// Get the WebSocket URL for the given environment.
  ///
  /// Used for real-time updates and notifications.
  static String getSocketUrl(Environment env) {
    switch (env) {
      case Environment.development:
        return 'ws://10.0.2.2:3000';
      case Environment.staging:
        return 'wss://staging-api.apppasos.com';
      case Environment.production:
        return 'wss://api.apppasos.com';
    }
  }

  /// Check if the environment is a debug environment.
  static bool isDebug(Environment env) {
    return env == Environment.development || env == Environment.staging;
  }

  /// Check if the environment is production.
  static bool isProduction(Environment env) {
    return env == Environment.production;
  }
}
