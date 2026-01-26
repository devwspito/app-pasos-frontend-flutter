import 'environment.dart';

/// Application configuration singleton.
///
/// Manages app-wide configuration including API URLs, timeouts,
/// and environment-specific settings.
///
/// Usage:
/// ```dart
/// await AppConfig.instance.init(Environment.development);
/// final baseUrl = AppConfig.instance.baseUrl;
/// ```
class AppConfig {
  // Private constructor for singleton pattern
  AppConfig._internal();

  /// Singleton instance
  static final AppConfig _instance = AppConfig._internal();

  /// Access the singleton instance
  static AppConfig get instance => _instance;

  /// Whether the config has been initialized
  bool _initialized = false;

  /// Current environment
  Environment _environment = Environment.development;

  /// Base URL for API requests
  String _baseUrl = '';

  /// WebSocket URL for real-time connections
  String _socketUrl = '';

  /// Connection timeout in seconds
  int _connectTimeout = 30;

  /// Receive timeout in seconds
  int _receiveTimeout = 30;

  // ==========================================================================
  // Getters
  // ==========================================================================

  /// Get the current environment
  Environment get environment => _environment;

  /// Get the base URL for API requests
  String get baseUrl => _baseUrl;

  /// Get the WebSocket URL
  String get socketUrl => _socketUrl;

  /// Get the connection timeout in seconds
  int get connectTimeout => _connectTimeout;

  /// Get the receive timeout in seconds
  int get receiveTimeout => _receiveTimeout;

  /// Get the connection timeout as Duration
  Duration get connectTimeoutDuration => Duration(seconds: _connectTimeout);

  /// Get the receive timeout as Duration
  Duration get receiveTimeoutDuration => Duration(seconds: _receiveTimeout);

  /// Check if running in debug mode
  bool get isDebug => EnvironmentConfig.isDebug(_environment);

  /// Check if running in production
  bool get isProduction => EnvironmentConfig.isProduction(_environment);

  /// Check if the config has been initialized
  bool get isInitialized => _initialized;

  // ==========================================================================
  // Initialization
  // ==========================================================================

  /// Initialize the app configuration with the specified environment.
  ///
  /// This should be called once at app startup before any API calls.
  ///
  /// [env] The environment to configure for.
  /// [connectTimeout] Optional custom connection timeout in seconds (default: 30).
  /// [receiveTimeout] Optional custom receive timeout in seconds (default: 30).
  ///
  /// Throws [StateError] if already initialized.
  void init(
    Environment env, {
    int connectTimeout = 30,
    int receiveTimeout = 30,
  }) {
    if (_initialized) {
      throw StateError('AppConfig has already been initialized');
    }

    _environment = env;
    _baseUrl = EnvironmentConfig.getBaseUrl(env);
    _socketUrl = EnvironmentConfig.getSocketUrl(env);
    _connectTimeout = connectTimeout;
    _receiveTimeout = receiveTimeout;
    _initialized = true;
  }

  /// Reset the configuration (useful for testing).
  ///
  /// This allows re-initialization with different settings.
  void reset() {
    _initialized = false;
    _environment = Environment.development;
    _baseUrl = '';
    _socketUrl = '';
    _connectTimeout = 30;
    _receiveTimeout = 30;
  }
}
