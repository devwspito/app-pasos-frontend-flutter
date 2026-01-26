import 'package:logger/logger.dart' as log;
import '../config/app_config.dart';

/// Application-wide logging utility.
///
/// Provides centralized logging with different log levels.
/// Must be initialized after [AppConfig] is initialized.
///
/// Example:
/// ```dart
/// AppConfig.initialize(EnvironmentConfig.development);
/// AppLogger.initialize();
///
/// AppLogger.debug('Debug message');
/// AppLogger.info('Info message');
/// AppLogger.warning('Warning message');
/// AppLogger.error('Error message', exception, stackTrace);
/// ```
class AppLogger {
  static late log.Logger _logger;
  static bool _initialized = false;

  /// Initializes the logger based on current [AppConfig] settings.
  ///
  /// Should be called once after [AppConfig.initialize] in main().
  /// Multiple calls are safe - only the first call has effect.
  static void initialize() {
    if (_initialized) return;

    _logger = log.Logger(
      printer: log.PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: log.DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: AppConfig.enableLogging ? log.Level.debug : log.Level.off,
    );
    _initialized = true;
  }

  /// Logs a debug message.
  ///
  /// Use for detailed information useful during development.
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_initialized) _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an info message.
  ///
  /// Use for general information about app operation.
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_initialized) _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message.
  ///
  /// Use for potentially harmful situations.
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_initialized) _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message.
  ///
  /// Use for error events that might still allow the app to continue running.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_initialized) _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
