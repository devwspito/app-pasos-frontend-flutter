import 'package:logger/logger.dart';

/// Application-wide logger utility providing structured logging.
///
/// Uses the `logger` package with pretty printing for development.
/// All logging methods are static for easy access throughout the app.
///
/// Usage:
/// ```dart
/// AppLogger.d('Debug message');
/// AppLogger.i('Info message');
/// AppLogger.w('Warning message');
/// AppLogger.e('Error message', error, stackTrace);
/// ```
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log a debug message.
  ///
  /// Use for detailed information during development.
  static void d(String message) => _logger.d(message);

  /// Log an info message.
  ///
  /// Use for general information about app flow.
  static void i(String message) => _logger.i(message);

  /// Log a warning message.
  ///
  /// Use for potentially harmful situations.
  static void w(String message) => _logger.w(message);

  /// Log an error message with optional error object and stack trace.
  ///
  /// Use for error events that might still allow the app to continue running.
  static void e(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  /// Log a verbose message.
  ///
  /// Use for very detailed tracing information.
  static void t(String message) => _logger.t(message);

  /// Log a fatal/wtf message.
  ///
  /// Use for severe errors that will lead to application abort.
  static void f(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.f(message, error: error, stackTrace: stackTrace);
}
