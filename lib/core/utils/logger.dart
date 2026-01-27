import 'package:logger/logger.dart' as log_pkg;
import '../config/app_config.dart';

/// Application logger utility.
///
/// Provides structured logging with different severity levels.
/// Must be initialized after [AppConfig.init] by calling [AppLogger.init].
///
/// Usage:
/// ```dart
/// AppLogger.d('Debug message');
/// AppLogger.i('Info message');
/// AppLogger.w('Warning message');
/// AppLogger.e('Error message', error, stackTrace);
/// ```
class AppLogger {
  // Private constructor to prevent instantiation
  AppLogger._();

  static log_pkg.Logger? _logger;

  /// Initialize the logger with the appropriate configuration.
  ///
  /// This should be called after [AppConfig.init] at app startup.
  static void init() {
    _logger = log_pkg.Logger(
      printer: log_pkg.PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: log_pkg.DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: AppConfig.enableLogging ? log_pkg.Level.debug : log_pkg.Level.off,
    );
  }

  /// Get the logger instance.
  ///
  /// Returns a no-op logger if not initialized to prevent null errors.
  static log_pkg.Logger get _safeLogger {
    if (_logger == null) {
      // Return a no-op logger if not initialized
      return log_pkg.Logger(level: log_pkg.Level.off);
    }
    return _logger!;
  }

  /// Log a debug message.
  ///
  /// Use for detailed development information.
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _safeLogger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log an info message.
  ///
  /// Use for general information about app execution.
  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _safeLogger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message.
  ///
  /// Use for potentially harmful situations.
  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _safeLogger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log an error message.
  ///
  /// Use for error events that might still allow the app to continue.
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _safeLogger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log a fatal message.
  ///
  /// Use for severe error events that will presumably lead to app crash.
  static void f(String message, [dynamic error, StackTrace? stackTrace]) {
    _safeLogger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log a trace message.
  ///
  /// Use for very detailed diagnostic information.
  static void t(String message, [dynamic error, StackTrace? stackTrace]) {
    _safeLogger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Check if the logger has been initialized.
  static bool get isInitialized => _logger != null;

  /// Reset the logger (mainly for testing purposes).
  static void reset() {
    _logger = null;
  }
}
