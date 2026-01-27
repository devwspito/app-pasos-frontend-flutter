/// Centralized logging utility for App Pasos.
///
/// Provides a singleton [AppLogger] instance for structured logging across
/// the application. Uses the `logger` package under the hood for beautiful
/// console output during development.
library;

import 'package:logger/logger.dart';

/// Centralized logging utility using the singleton pattern.
///
/// This class wraps the `logger` package to provide consistent logging
/// throughout the application. All logging should go through this class
/// rather than using `print()` or creating Logger instances directly.
///
/// Example usage:
/// ```dart
/// final logger = AppLogger();
/// logger.info('User logged in successfully');
/// logger.error('Failed to fetch data', error, stackTrace);
/// ```
class AppLogger {
  /// Returns the singleton instance of [AppLogger].
  factory AppLogger() => _instance;

  /// Private constructor for singleton pattern.
  AppLogger._internal();

  /// The singleton instance.
  static final AppLogger _instance = AppLogger._internal();

  /// The underlying logger instance with custom configuration.
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: Level.debug,
  );

  /// Logs a debug message.
  ///
  /// Use this for detailed debugging information that helps during
  /// development but should not appear in production logs.
  ///
  /// [message] - The debug message to log.
  /// [error] - Optional error object associated with this log.
  /// [stackTrace] - Optional stack trace for additional context.
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an informational message.
  ///
  /// Use this for general application flow information, such as
  /// successful operations or state changes.
  ///
  /// [message] - The informational message to log.
  /// [error] - Optional error object associated with this log.
  /// [stackTrace] - Optional stack trace for additional context.
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message.
  ///
  /// Use this for potentially problematic situations that don't
  /// prevent the application from functioning but should be reviewed.
  ///
  /// [message] - The warning message to log.
  /// [error] - Optional error object associated with this log.
  /// [stackTrace] - Optional stack trace for additional context.
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message.
  ///
  /// Use this for error conditions that affect operation. Always include
  /// the error object and stack trace when available for debugging.
  ///
  /// [message] - The error message to log.
  /// [error] - Optional error object that caused the error.
  /// [stackTrace] - Optional stack trace for debugging.
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a verbose message.
  ///
  /// Use this for extremely detailed output that would be overwhelming
  /// under normal circumstances but useful for deep debugging.
  ///
  /// [message] - The verbose message to log.
  /// [error] - Optional error object associated with this log.
  /// [stackTrace] - Optional stack trace for additional context.
  void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a fatal/critical message.
  ///
  /// Use this for severe errors that will likely lead to application crash
  /// or complete loss of functionality.
  ///
  /// [message] - The fatal message to log.
  /// [error] - Optional error object that caused the fatal condition.
  /// [stackTrace] - Optional stack trace for debugging.
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
