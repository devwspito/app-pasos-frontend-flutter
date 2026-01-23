import 'package:logger/logger.dart' as log;
import '../config/environment.dart';

/// Centralized logging utility for the application.
///
/// Provides structured logging with different levels (debug, info, warning, error).
/// In development mode, shows detailed stack traces and method counts.
/// In production mode, only logs warnings and above with minimal output.
class AppLogger {
  static final log.Logger _logger = log.Logger(
    printer: log.PrettyPrinter(
      methodCount: Environment.isDevelopment ? 2 : 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
    level: Environment.isDevelopment ? log.Level.debug : log.Level.warning,
  );

  /// Log a debug message.
  ///
  /// Use for detailed information useful during development.
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log an info message.
  ///
  /// Use for general informational messages about app state.
  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message.
  ///
  /// Use for potentially harmful situations or recoverable errors.
  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log an error message.
  ///
  /// Use for error events that might still allow the app to continue running.
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
