/// Sentry configuration for App Pasos.
///
/// This file contains the Sentry SDK configuration loaded from environment
/// variables at compile-time using `String.fromEnvironment`.
///
/// Environment variables:
/// - `SENTRY_DSN`: The Sentry DSN for error reporting
///   (required for Sentry to be enabled)
/// - `ENV`: The environment name (development, staging, production)
library;

/// Sentry configuration with compile-time environment variables.
///
/// All configuration values are loaded from environment variables using
/// `String.fromEnvironment` for compile-time constants.
///
/// Example usage:
/// ```dart
/// if (SentryConfig.isEnabled) {
///   await SentryFlutter.init(
///     (options) {
///       options.dsn = SentryConfig.dsn;
///       options.environment = SentryConfig.environment;
///       options.tracesSampleRate = SentryConfig.tracesSampleRate;
///     },
///   );
/// }
/// ```
abstract final class SentryConfig {
  /// Sentry DSN (Data Source Name).
  ///
  /// Loaded from the `SENTRY_DSN` environment variable.
  /// Defaults to empty string, which disables Sentry if not provided.
  ///
  /// Set this at compile time:
  /// ```bash
  /// flutter build --dart-define=SENTRY_DSN=https://your-dsn@sentry.io/project
  /// ```
  static String get dsn => const String.fromEnvironment('SENTRY_DSN');

  /// Current environment name.
  ///
  /// Loaded from the `ENV` environment variable.
  /// Defaults to 'development' if not provided.
  ///
  /// Expected values: 'development', 'staging', 'production'
  static String get environment => const String.fromEnvironment(
        'ENV',
        defaultValue: 'development',
      );

  /// Traces sample rate for performance monitoring.
  ///
  /// Returns different rates based on environment:
  /// - Development: 1.0 (100% of traces captured for debugging)
  /// - Production/Staging: 0.2 (20% of traces captured to reduce overhead)
  static double get tracesSampleRate {
    if (environment == 'development') {
      return 1;
    }
    return 0.2;
  }

  /// Whether Sentry error reporting is enabled.
  ///
  /// Returns `true` if a valid DSN is configured, `false` otherwise.
  /// Use this to conditionally initialize Sentry.
  ///
  /// Example:
  /// ```dart
  /// if (SentryConfig.isEnabled) {
  ///   await SentryFlutter.init(...);
  /// }
  /// ```
  static bool get isEnabled => dsn.isNotEmpty;
}
