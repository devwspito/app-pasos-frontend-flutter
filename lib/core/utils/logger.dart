import 'package:logger/logger.dart';

import '../config/app_config.dart';

/// Application-wide logger service.
///
/// Provides a singleton wrapper around the [Logger] package with
/// environment-aware log level configuration.
///
/// Log levels are automatically configured based on the environment:
/// - Development/Staging: All logs (verbose level)
/// - Production: Warnings and above only
///
/// Example:
/// ```dart
/// AppLogger.instance.info('User logged in', {'userId': '123'});
/// AppLogger.instance.error('API call failed', error, stackTrace);
/// ```
class AppLogger {
  // Private constructor for singleton pattern
  AppLogger._internal() {
    _initializeLogger();
  }

  /// Singleton instance
  static final AppLogger _instance = AppLogger._internal();

  /// Access the singleton instance
  static AppLogger get instance => _instance;

  /// The underlying Logger instance
  late final Logger _logger;

  /// Whether the logger has been initialized
  bool _initialized = false;

  /// Initializes the logger with appropriate configuration.
  void _initializeLogger() {
    if (_initialized) return;

    // Determine log level based on environment
    // In production, only show warnings and above to avoid exposing sensitive data
    final Level logLevel = _getLogLevel();

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: logLevel,
      filter: ProductionFilter(),
    );

    _initialized = true;
  }

  /// Gets the appropriate log level based on environment.
  Level _getLogLevel() {
    // Check if AppConfig is initialized
    try {
      if (AppConfig.instance.isInitialized) {
        return AppConfig.instance.isProduction ? Level.warning : Level.trace;
      }
    } catch (_) {
      // AppConfig not initialized yet, use default
    }
    // Default to verbose for development
    return Level.trace;
  }

  // ==========================================================================
  // Logging Methods
  // ==========================================================================

  /// Logs a trace/verbose message.
  ///
  /// Use for detailed debugging information that is typically only needed
  /// when tracking down specific issues.
  ///
  /// [message] The message to log.
  /// [error] Optional error object.
  /// [stackTrace] Optional stack trace.
  void trace(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a debug message.
  ///
  /// Use for development debugging information.
  ///
  /// [message] The message to log.
  /// [error] Optional error object.
  /// [stackTrace] Optional stack trace.
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an info message.
  ///
  /// Use for general information about application flow.
  ///
  /// [message] The message to log.
  /// [error] Optional error object.
  /// [stackTrace] Optional stack trace.
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message.
  ///
  /// Use for potentially harmful situations that aren't errors.
  ///
  /// [message] The message to log.
  /// [error] Optional error object.
  /// [stackTrace] Optional stack trace.
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message.
  ///
  /// Use for error events that might still allow the application to continue.
  ///
  /// [message] The message to log.
  /// [error] Optional error object.
  /// [stackTrace] Optional stack trace.
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a fatal/wtf message.
  ///
  /// Use for severe errors that will likely cause the application to abort.
  /// WTF stands for "What a Terrible Failure".
  ///
  /// [message] The message to log.
  /// [error] Optional error object.
  /// [stackTrace] Optional stack trace.
  void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a fatal message (alias for wtf).
  ///
  /// Use for severe errors that will likely cause the application to abort.
  ///
  /// [message] The message to log.
  /// [error] Optional error object.
  /// [stackTrace] Optional stack trace.
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // ==========================================================================
  // Utility Methods
  // ==========================================================================

  /// Gets the underlying Logger instance.
  ///
  /// Use this if you need direct access to the Logger for advanced use cases.
  Logger get logger => _logger;

  /// Closes the logger and releases resources.
  ///
  /// Call this when the application is shutting down.
  void close() {
    _logger.close();
  }
}

/// A log filter that respects production settings.
///
/// In production, this filter will only allow warning level and above.
/// In development, all log levels are allowed.
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Check if AppConfig is initialized and we're in production
    try {
      if (AppConfig.instance.isInitialized && AppConfig.instance.isProduction) {
        return event.level.index >= Level.warning.index;
      }
    } catch (_) {
      // AppConfig not initialized, allow all logs
    }
    return true;
  }
}
