/// Custom exception hierarchy for App Pasos.
///
/// This file defines a sealed class hierarchy for standardized error handling
/// across the application. Using sealed classes enables exhaustive switch
/// statements for comprehensive error handling.
library;

/// Base exception class for all application-specific exceptions.
///
/// This is a sealed class, which means:
/// - All subclasses must be defined in this file
/// - Switch statements on [AppException] can be exhaustively checked
/// - The compiler ensures all exception types are handled
///
/// Example usage:
/// ```dart
/// try {
///   await fetchData();
/// } on AppException catch (e) {
///   switch (e) {
///     case NetworkException():
///       showNetworkError(e.message);
///     case ServerException():
///       showServerError(e.message, e.statusCode);
///     case CacheException():
///       showCacheError(e.message);
///     case ValidationException():
///       showValidationError(e.message, e.fieldErrors);
///     case UnauthorizedException():
///       redirectToLogin();
///   }
/// }
/// ```
sealed class AppException implements Exception {
  /// Creates an [AppException] with the given parameters.
  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  /// Human-readable error message.
  final String message;

  /// Optional error code for categorization and logging.
  final String? code;

  /// The original error that caused this exception, if any.
  final dynamic originalError;

  /// Stack trace from the original error, if available.
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buffer = StringBuffer('$_typeName: $message');
    if (code != null) {
      buffer.write(' (code: $code)');
    }
    return buffer.toString();
  }

  String get _typeName {
    // Use explicit type name to avoid runtimeType.toString() in production
    return switch (this) {
      NetworkException() => 'NetworkException',
      ServerException() => 'ServerException',
      CacheException() => 'CacheException',
      ValidationException() => 'ValidationException',
      UnauthorizedException() => 'UnauthorizedException',
    };
  }
}

/// Exception thrown when a network-related error occurs.
///
/// This includes:
/// - No internet connection
/// - DNS resolution failures
/// - Connection timeouts
/// - Socket errors
final class NetworkException extends AppException {
  /// Creates a [NetworkException] with the given parameters.
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.isNoConnection = false,
    this.isTimeout = false,
  });

  /// Creates a [NetworkException] for no internet connection.
  factory NetworkException.noConnection({
    String message = 'No internet connection available',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return NetworkException(
      message: message,
      code: 'NO_CONNECTION',
      originalError: originalError,
      stackTrace: stackTrace,
      isNoConnection: true,
    );
  }

  /// Creates a [NetworkException] for connection timeout.
  factory NetworkException.timeout({
    String message = 'Connection timed out',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return NetworkException(
      message: message,
      code: 'TIMEOUT',
      originalError: originalError,
      stackTrace: stackTrace,
      isTimeout: true,
    );
  }

  /// Whether the device appears to have no network connectivity.
  final bool isNoConnection;

  /// Whether this was a timeout error.
  final bool isTimeout;
}

/// Exception thrown when the server returns an error response.
///
/// This is used for HTTP errors like 4xx and 5xx status codes.
final class ServerException extends AppException {
  /// Creates a [ServerException] with the given parameters.
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.statusCode,
    this.responseBody,
  });

  /// Creates a [ServerException] for a 400 Bad Request response.
  factory ServerException.badRequest({
    String message = 'Bad request',
    String? responseBody,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return ServerException(
      message: message,
      code: 'BAD_REQUEST',
      statusCode: 400,
      responseBody: responseBody,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates a [ServerException] for a 404 Not Found response.
  factory ServerException.notFound({
    String message = 'Resource not found',
    String? responseBody,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return ServerException(
      message: message,
      code: 'NOT_FOUND',
      statusCode: 404,
      responseBody: responseBody,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates a [ServerException] for a 500 Internal Server Error response.
  factory ServerException.internalError({
    String message = 'Internal server error',
    String? responseBody,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return ServerException(
      message: message,
      code: 'INTERNAL_ERROR',
      statusCode: 500,
      responseBody: responseBody,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// The HTTP status code returned by the server.
  final int? statusCode;

  /// The response body from the server, if available.
  final String? responseBody;

  @override
  String toString() {
    final buffer = StringBuffer('ServerException: $message');
    if (statusCode != null) {
      buffer.write(' (status: $statusCode)');
    }
    if (code != null) {
      buffer.write(' [code: $code]');
    }
    return buffer.toString();
  }
}

/// Exception thrown when a local cache operation fails.
///
/// This includes:
/// - Reading from cache fails
/// - Writing to cache fails
/// - Cache is corrupted
/// - Cache has expired
final class CacheException extends AppException {
  /// Creates a [CacheException] with the given parameters.
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.cacheKey,
    this.isExpired = false,
    this.isCorrupted = false,
  });

  /// Creates a [CacheException] for cache not found.
  factory CacheException.notFound({
    String message = 'Cache entry not found',
    String? cacheKey,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return CacheException(
      message: message,
      code: 'CACHE_NOT_FOUND',
      cacheKey: cacheKey,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates a [CacheException] for expired cache.
  factory CacheException.expired({
    String message = 'Cache entry has expired',
    String? cacheKey,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return CacheException(
      message: message,
      code: 'CACHE_EXPIRED',
      cacheKey: cacheKey,
      isExpired: true,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates a [CacheException] for write failure.
  factory CacheException.writeFailed({
    String message = 'Failed to write to cache',
    String? cacheKey,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return CacheException(
      message: message,
      code: 'CACHE_WRITE_FAILED',
      cacheKey: cacheKey,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// The key that was being accessed when the error occurred.
  final String? cacheKey;

  /// Whether this error is due to the cache being expired.
  final bool isExpired;

  /// Whether this error is due to the cache being corrupted.
  final bool isCorrupted;
}

/// Exception thrown when input validation fails.
///
/// Use this for form validation errors, invalid data formats, etc.
final class ValidationException extends AppException {
  /// Creates a [ValidationException] with the given parameters.
  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.fieldErrors = const {},
  });

  /// Creates a [ValidationException] for a single field error.
  factory ValidationException.field({
    required String field,
    required String error,
    String? message,
  }) {
    return ValidationException(
      message: message ?? 'Validation failed for field: $field',
      code: 'VALIDATION_ERROR',
      fieldErrors: {
        field: [error],
      },
    );
  }

  /// Creates a [ValidationException] for multiple field errors.
  factory ValidationException.multiple({
    required Map<String, List<String>> fieldErrors,
    String message = 'Validation failed',
  }) {
    return ValidationException(
      message: message,
      code: 'VALIDATION_ERROR',
      fieldErrors: fieldErrors,
    );
  }

  /// Map of field names to their validation error messages.
  final Map<String, List<String>> fieldErrors;

  /// Returns true if there are any field errors.
  bool get hasFieldErrors => fieldErrors.isNotEmpty;

  /// Gets all error messages for a specific field.
  List<String> errorsForField(String field) => fieldErrors[field] ?? [];

  @override
  String toString() {
    final buffer = StringBuffer('ValidationException: $message');
    if (fieldErrors.isNotEmpty) {
      buffer.write(' Fields: ${fieldErrors.keys.join(', ')}');
    }
    return buffer.toString();
  }
}

/// Exception thrown when authentication or authorization fails.
///
/// This is used when:
/// - The user's session has expired
/// - The authentication token is invalid
/// - The user doesn't have permission for an action
final class UnauthorizedException extends AppException {
  /// Creates an [UnauthorizedException] with the given parameters.
  const UnauthorizedException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.isTokenExpired = false,
    this.isPermissionDenied = false,
  });

  /// Creates an [UnauthorizedException] for expired token.
  factory UnauthorizedException.tokenExpired({
    String message = 'Your session has expired. Please log in again.',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return UnauthorizedException(
      message: message,
      code: 'TOKEN_EXPIRED',
      isTokenExpired: true,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates an [UnauthorizedException] for invalid token.
  factory UnauthorizedException.invalidToken({
    String message = 'Invalid authentication token',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return UnauthorizedException(
      message: message,
      code: 'INVALID_TOKEN',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates an [UnauthorizedException] for insufficient permissions.
  factory UnauthorizedException.permissionDenied({
    String message = 'You do not have permission to perform this action',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return UnauthorizedException(
      message: message,
      code: 'PERMISSION_DENIED',
      isPermissionDenied: true,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates an [UnauthorizedException] for unauthenticated access.
  factory UnauthorizedException.unauthenticated({
    String message = 'Authentication required',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return UnauthorizedException(
      message: message,
      code: 'UNAUTHENTICATED',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Whether the token has expired (as opposed to being invalid).
  final bool isTokenExpired;

  /// Whether this is a permission/authorization issue (vs authentication).
  final bool isPermissionDenied;
}
