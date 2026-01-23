import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration singleton that manages environment variables.
///
/// Must be initialized before use by calling [AppConfig.initialize()].
class AppConfig {
  static AppConfig? _instance;

  AppConfig._();

  /// Initialize the app configuration by loading environment variables.
  ///
  /// Should be called at app startup before accessing any config values.
  static Future<void> initialize() async {
    if (_instance != null) return;

    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // .env file might not exist in development, use defaults
    }

    _instance = AppConfig._();
  }

  /// Get the singleton instance. Throws if not initialized.
  static AppConfig get instance {
    if (_instance == null) {
      throw StateError('AppConfig not initialized. Call AppConfig.initialize() first.');
    }
    return _instance!;
  }

  /// Base URL for the API
  String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  /// API timeout in milliseconds
  int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '') ?? 30000;

  /// Whether the app is in debug mode
  bool get isDebug => dotenv.env['DEBUG'] == 'true';

  /// App environment (development, staging, production)
  String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
}
