/// Centralized error handling service for App Pasos.
///
/// Provides a consistent way to convert [AppException]s and other errors
/// into user-friendly messages that can be displayed in the UI.
///
/// Integrates with Sentry for remote error tracking when enabled.
library;

import 'package:app_pasos_frontend/core/config/sentry_config.dart';
import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/core/utils/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Service for handling errors and converting them to user-friendly messages.
///
/// This class centralizes error handling logic, ensuring that:
/// - All errors are logged consistently
/// - Users see friendly messages instead of technical error details
/// - Exception types are mapped to appropriate UI messages
///
/// Example usage:
/// ```dart
/// final errorHandler = ErrorHandler();
/// try {
///   await fetchData();
/// } catch (error, stackTrace) {
///   final message = errorHandler.handleError(error, stackTrace);
///   showSnackBar(message);
/// }
/// ```
class ErrorHandler {
  /// Creates an [ErrorHandler] instance.
  ///
  /// Uses the singleton [AppLogger] for logging errors.
  ErrorHandler() : _logger = AppLogger();

  /// Logger instance for recording errors.
  final AppLogger _logger;

  /// Handles an error and returns a user-friendly message.
  ///
  /// This method:
  /// 1. Logs the error with full details for debugging
  /// 2. Sends the error to Sentry for remote tracking (if enabled)
  /// 3. Converts the error to a user-friendly message
  /// 4. Returns the message for display in the UI
  ///
  /// [error] - The error that occurred.
  /// [stackTrace] - Optional stack trace for debugging.
  ///
  /// Returns a user-friendly error message string.
  String handleError(Object error, [StackTrace? stackTrace]) {
    // Local logging first
    _logger.error('Error occurred', error, stackTrace);

    // Send to Sentry for remote tracking
    if (SentryConfig.isEnabled) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'error_type': error.runtimeType.toString(),
          if (error is AppException) 'error_code': error.code,
        }),
      );
    }

    return switch (error) {
      NetworkException(:final isNoConnection, :final isTimeout) =>
        _getNetworkMessage(isNoConnection, isTimeout),
      ServerException(:final statusCode) => _getServerMessage(statusCode),
      UnauthorizedException(:final isTokenExpired, :final isPermissionDenied) =>
        _getAuthMessage(isTokenExpired, isPermissionDenied),
      ValidationException(:final message) => message,
      CacheException(:final isExpired) => _getCacheMessage(isExpired),
      FormatException() => 'Invalid data format received.',
      TypeError() => 'A data type error occurred.',
      _ => 'An unexpected error occurred. Please try again.',
    };
  }

  /// Gets the appropriate message for network errors.
  String _getNetworkMessage(bool isNoConnection, bool isTimeout) {
    if (isNoConnection) {
      return 'No internet connection. Please check your network settings.';
    }
    if (isTimeout) {
      return 'Request timed out. Please check your connection and try again.';
    }
    return 'Network error. Please check your connection and try again.';
  }

  /// Gets the appropriate message for server errors.
  String _getServerMessage(int? statusCode) {
    return switch (statusCode) {
      400 => 'Invalid request. Please check your input and try again.',
      404 => 'The requested resource was not found.',
      403 => 'Access denied. You do not have permission for this action.',
      500 || 502 || 503 => 'Server error. Please try again later.',
      _ => 'Server error. Please try again later.',
    };
  }

  /// Gets the appropriate message for authentication errors.
  String _getAuthMessage(bool isTokenExpired, bool isPermissionDenied) {
    if (isTokenExpired) {
      return 'Your session has expired. Please log in again.';
    }
    if (isPermissionDenied) {
      return 'You do not have permission to perform this action.';
    }
    return 'Authentication required. Please log in again.';
  }

  /// Gets the appropriate message for cache errors.
  String _getCacheMessage(bool isExpired) {
    if (isExpired) {
      return 'Cached data has expired. Refreshing...';
    }
    return 'Unable to access cached data. Please try again.';
  }

  /// Handles an error silently, logging it without returning a message.
  ///
  /// Use this for non-critical errors that should be logged but not
  /// displayed to the user.
  ///
  /// [error] - The error that occurred.
  /// [stackTrace] - Optional stack trace for debugging.
  /// [captureToSentry] - Whether to send this error to Sentry. Defaults to
  ///   `false` since silent errors are typically non-critical.
  void handleSilently(
    Object error, {
    StackTrace? stackTrace,
    bool captureToSentry = false,
  }) {
    _logger.warning('Silent error handled', error, stackTrace);

    if (captureToSentry && SentryConfig.isEnabled) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'error_type': error.runtimeType.toString(),
          'silent': true,
          if (error is AppException) 'error_code': error.code,
        }),
      );
    }
  }

  /// Checks if an error is recoverable.
  ///
  /// Recoverable errors are those where retrying the operation might succeed.
  ///
  /// [error] - The error to check.
  ///
  /// Returns true if the error is potentially recoverable.
  bool isRecoverable(Object error) {
    return switch (error) {
      NetworkException(:final isTimeout) => isTimeout,
      ServerException(:final statusCode) =>
        statusCode == 500 || statusCode == 502 || statusCode == 503,
      CacheException() => true,
      _ => false,
    };
  }

  /// Determines if the user should be logged out based on the error.
  ///
  /// [error] - The error to check.
  ///
  /// Returns true if the error indicates the user should be logged out.
  bool shouldLogout(Object error) {
    return switch (error) {
      UnauthorizedException(:final isTokenExpired, :final code) =>
        isTokenExpired ||
            code == 'INVALID_TOKEN' ||
            code == 'UNAUTHENTICATED',
      _ => false,
    };
  }

  /// Sets user context for Sentry error tracking.
  ///
  /// Call this when a user logs in to associate errors with the user.
  /// Call with null values when the user logs out to clear the context.
  ///
  /// [userId] - The unique identifier for the user.
  /// [email] - The user's email address.
  ///
  /// Example:
  /// ```dart
  /// // On login
  /// errorHandler.setUserContext(userId: user.id, email: user.email);
  ///
  /// // On logout
  /// errorHandler.setUserContext();
  /// ```
  void setUserContext({String? userId, String? email}) {
    if (SentryConfig.isEnabled) {
      Sentry.configureScope((scope) {
        if (userId != null || email != null) {
          scope.setUser(SentryUser(id: userId, email: email));
        } else {
          scope.setUser(null);
        }
      });
    }
  }

  /// Adds a breadcrumb for Sentry error tracking.
  ///
  /// Breadcrumbs provide context for errors by recording a trail of events
  /// that happened before the error occurred.
  ///
  /// [message] - Description of the event.
  /// [category] - Category for grouping breadcrumbs (e.g., 'navigation', 'ui').
  /// [data] - Additional key-value data to attach to the breadcrumb.
  ///
  /// Example:
  /// ```dart
  /// // Navigation event
  /// errorHandler.addBreadcrumb(
  ///   message: 'Navigated to profile screen',
  ///   category: 'navigation',
  /// );
  ///
  /// // User action with data
  /// errorHandler.addBreadcrumb(
  ///   message: 'User submitted form',
  ///   category: 'ui',
  ///   data: {'form_type': 'registration'},
  /// );
  /// ```
  void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) {
    if (SentryConfig.isEnabled) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          category: category,
          data: data,
        ),
      );
    }
  }
}
