import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for App Pasos.
///
/// This class provides access to environment-specific configuration values
/// loaded from the `.env` file using flutter_dotenv.
///
/// **Setup required:**
/// 1. Add `flutter_dotenv` to pubspec.yaml dependencies
/// 2. Create a `.env` file in the project root
/// 3. Add `.env` to the assets in pubspec.yaml:
///    ```yaml
///    flutter:
///      assets:
///        - .env
///    ```
/// 4. Load the .env file in main.dart before runApp:
///    ```dart
///    await dotenv.load(fileName: ".env");
///    ```
///
/// Example usage:
/// ```dart
/// final baseUrl = EnvConfig.apiBaseUrl;
/// if (EnvConfig.isDevelopment) {
///   print('Running in development mode');
/// }
/// ```
abstract final class EnvConfig {
  /// The base URL for all API requests.
  ///
  /// Defaults to 'http://localhost:3000/api' if not specified in .env file.
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';

  /// The current environment name.
  ///
  /// Possible values: 'development', 'staging', 'production'.
  /// Defaults to 'development' if not specified.
  static String get environment =>
      dotenv.env['ENVIRONMENT'] ?? 'development';

  /// Whether the app is running in production environment.
  static bool get isProduction => environment == 'production';

  /// Whether the app is running in development environment.
  static bool get isDevelopment => environment == 'development';

  /// Whether the app is running in staging environment.
  static bool get isStaging => environment == 'staging';

  /// Whether debug mode is enabled.
  ///
  /// Defaults to true in development, false otherwise.
  static bool get isDebugMode {
    final debugEnv = dotenv.env['DEBUG_MODE'];
    if (debugEnv != null) {
      return debugEnv.toLowerCase() == 'true';
    }
    return isDevelopment;
  }

  /// Whether to enable verbose logging.
  ///
  /// Defaults to true in development, false in production.
  static bool get enableLogging {
    final loggingEnv = dotenv.env['ENABLE_LOGGING'];
    if (loggingEnv != null) {
      return loggingEnv.toLowerCase() == 'true';
    }
    return !isProduction;
  }

  /// The app name from environment or default.
  static String get appName =>
      dotenv.env['APP_NAME'] ?? 'App Pasos';

  /// API version prefix.
  ///
  /// Defaults to 'v1' if not specified.
  static String get apiVersion =>
      dotenv.env['API_VERSION'] ?? 'v1';

  /// Full API URL including version.
  ///
  /// Example: 'http://localhost:3000/api/v1'
  static String get apiUrl => '$apiBaseUrl/$apiVersion';
}
