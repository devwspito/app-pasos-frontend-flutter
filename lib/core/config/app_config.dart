import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'environment.dart';

/// Application configuration singleton that loads settings from environment variables.
///
/// This class provides centralized access to all configuration values used throughout
/// the application. It uses the singleton pattern to ensure consistent configuration
/// state across the app.
///
/// ## Usage
///
/// Initialize at app startup (before runApp):
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await AppConfig.initialize();
///   runApp(MyApp());
/// }
/// ```
///
/// Access configuration values:
/// ```dart
/// final apiUrl = AppConfig.instance.apiBaseUrl;
/// final isProduction = AppConfig.instance.environment.isProduction;
/// ```
class AppConfig {
  /// Private singleton instance.
  static AppConfig? _instance;

  /// The base URL for all API requests.
  final String apiBaseUrl;

  /// The WebSocket URL for real-time communication.
  final String wsUrl;

  /// The current environment (development, staging, production).
  final Environment environment;

  /// Whether analytics tracking is enabled.
  final bool enableAnalytics;

  /// Whether Crashlytics error reporting is enabled.
  final bool enableCrashlytics;

  /// The custom URL scheme for deep linking.
  final String appScheme;

  /// The host domain for deep linking.
  final String appHost;

  /// Private constructor to prevent external instantiation.
  AppConfig._internal({
    required this.apiBaseUrl,
    required this.wsUrl,
    required this.environment,
    required this.enableAnalytics,
    required this.enableCrashlytics,
    required this.appScheme,
    required this.appHost,
  });

  /// Returns the singleton instance of [AppConfig].
  ///
  /// Throws a [StateError] if [initialize] has not been called first.
  static AppConfig get instance {
    if (_instance == null) {
      throw StateError(
        'AppConfig not initialized. Call AppConfig.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Returns true if the AppConfig has been initialized.
  static bool get isInitialized => _instance != null;

  /// Initializes the application configuration from environment variables.
  ///
  /// This method must be called before accessing [instance].
  /// It loads the `.env` file and parses all configuration values.
  ///
  /// ```dart
  /// await AppConfig.initialize();
  /// ```
  ///
  /// Optionally, you can specify a custom `.env` file:
  /// ```dart
  /// await AppConfig.initialize(fileName: '.env.staging');
  /// ```
  static Future<void> initialize({String fileName = '.env'}) async {
    await dotenv.load(fileName: fileName);

    final envString = dotenv.env['ENVIRONMENT'] ?? 'development';
    final environment = Environment.values.firstWhere(
      (e) => e.name == envString,
      orElse: () => Environment.development,
    );

    _instance = AppConfig._internal(
      apiBaseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:3001/api',
      wsUrl: dotenv.env['WS_URL'] ?? 'ws://localhost:3001',
      environment: environment,
      enableAnalytics: dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true',
      enableCrashlytics:
          dotenv.env['ENABLE_CRASHLYTICS']?.toLowerCase() == 'true',
      appScheme: dotenv.env['APP_SCHEME'] ?? 'apppasos',
      appHost: dotenv.env['APP_HOST'] ?? 'app.example.com',
    );
  }

  /// Resets the singleton instance.
  ///
  /// This is primarily useful for testing purposes to reset state between tests.
  static void reset() {
    _instance = null;
  }

  /// Returns all configuration values as a map for debugging purposes.
  ///
  /// **Warning**: Do not log this in production as it may contain sensitive data.
  Map<String, dynamic> toMap() {
    return {
      'apiBaseUrl': apiBaseUrl,
      'wsUrl': wsUrl,
      'environment': environment.name,
      'enableAnalytics': enableAnalytics,
      'enableCrashlytics': enableCrashlytics,
      'appScheme': appScheme,
      'appHost': appHost,
    };
  }

  @override
  String toString() {
    return 'AppConfig(environment: ${environment.displayName}, apiBaseUrl: $apiBaseUrl)';
  }
}
