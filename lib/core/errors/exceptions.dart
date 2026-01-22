/// Base exception class for all application exceptions.
///
/// Uses Dart 3 sealed class pattern for exhaustive pattern matching.
sealed class AppException implements Exception {
  const AppException({
    required this.message,
    this.statusCode,
    this.details,
  });

  /// Human-readable error message.
  final String message;

  /// Optional HTTP status code (for server exceptions).
  final int? statusCode;

  /// Optional additional details about the exception.
  final Map<String, dynamic>? details;

  @override
  String toString() => 'AppException: $message (statusCode: $statusCode)';
}

/// Exception thrown when a server request fails.
final class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.details,
    this.endpoint,
    this.requestMethod,
  });

  /// The endpoint that was called.
  final String? endpoint;

  /// The HTTP method used (GET, POST, etc.).
  final String? requestMethod;

  /// Factory for creating from a status code.
  factory ServerException.fromStatusCode(int statusCode, {String? endpoint}) {
    final message = switch (statusCode) {
      400 => 'Bad request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Resource not found',
      408 => 'Request timeout',
      409 => 'Conflict',
      422 => 'Validation error',
      429 => 'Too many requests',
      500 => 'Internal server error',
      502 => 'Bad gateway',
      503 => 'Service unavailable',
      504 => 'Gateway timeout',
      _ => 'Server error occurred',
    };

    return ServerException(
      message: message,
      statusCode: statusCode,
      endpoint: endpoint,
    );
  }

  @override
  String toString() =>
      'ServerException: $message (statusCode: $statusCode, endpoint: $endpoint)';
}

/// Exception thrown when local cache operations fail.
final class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.details,
    this.key,
    this.operation,
  });

  /// The cache key involved.
  final String? key;

  /// The operation that failed (read, write, delete).
  final CacheOperation? operation;

  /// Factory for common cache errors.
  factory CacheException.notFound(String key) {
    return CacheException(
      message: 'Cache entry not found',
      key: key,
      operation: CacheOperation.read,
    );
  }

  factory CacheException.writeError(String key, [String? details]) {
    return CacheException(
      message: details ?? 'Failed to write to cache',
      key: key,
      operation: CacheOperation.write,
    );
  }

  factory CacheException.expired(String key) {
    return CacheException(
      message: 'Cache entry has expired',
      key: key,
      operation: CacheOperation.read,
    );
  }

  factory CacheException.invalidData(String key) {
    return CacheException(
      message: 'Invalid data in cache',
      key: key,
      operation: CacheOperation.read,
    );
  }

  @override
  String toString() =>
      'CacheException: $message (key: $key, operation: $operation)';
}

/// Represents cache operation types.
enum CacheOperation {
  read,
  write,
  delete,
  clear,
}

/// Exception thrown when network connectivity issues occur.
final class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.details,
    this.isTimeout,
    this.isConnectionError,
  });

  /// Whether this was a timeout error.
  final bool? isTimeout;

  /// Whether this was a connection error.
  final bool? isConnectionError;

  /// Factory for no internet connection.
  factory NetworkException.noConnection() {
    return const NetworkException(
      message: 'No internet connection',
      isConnectionError: true,
    );
  }

  /// Factory for connection timeout.
  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'Connection timed out',
      isTimeout: true,
    );
  }

  /// Factory for DNS resolution failure.
  factory NetworkException.dnsFailure(String host) {
    return NetworkException(
      message: 'Could not resolve host: $host',
      isConnectionError: true,
    );
  }

  /// Factory for SSL/TLS errors.
  factory NetworkException.sslError() {
    return const NetworkException(
      message: 'Secure connection failed',
      isConnectionError: true,
    );
  }

  @override
  String toString() =>
      'NetworkException: $message (timeout: $isTimeout, connectionError: $isConnectionError)';
}

/// Exception thrown when authentication fails.
final class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.statusCode,
    super.details,
    this.errorCode,
  });

  /// Auth-specific error code.
  final AuthErrorCode? errorCode;

  /// Factory for invalid credentials.
  factory AuthException.invalidCredentials() {
    return const AuthException(
      message: 'Invalid email or password',
      statusCode: 401,
      errorCode: AuthErrorCode.invalidCredentials,
    );
  }

  /// Factory for expired token.
  factory AuthException.tokenExpired() {
    return const AuthException(
      message: 'Your session has expired',
      statusCode: 401,
      errorCode: AuthErrorCode.tokenExpired,
    );
  }

  /// Factory for invalid token.
  factory AuthException.invalidToken() {
    return const AuthException(
      message: 'Invalid authentication token',
      statusCode: 401,
      errorCode: AuthErrorCode.invalidToken,
    );
  }

  /// Factory for unauthorized access.
  factory AuthException.unauthorized() {
    return const AuthException(
      message: 'You are not authorized to perform this action',
      statusCode: 403,
      errorCode: AuthErrorCode.unauthorized,
    );
  }

  /// Factory for account locked.
  factory AuthException.accountLocked() {
    return const AuthException(
      message: 'Your account has been locked',
      statusCode: 403,
      errorCode: AuthErrorCode.accountLocked,
    );
  }

  /// Factory for email not verified.
  factory AuthException.emailNotVerified() {
    return const AuthException(
      message: 'Please verify your email address',
      statusCode: 403,
      errorCode: AuthErrorCode.emailNotVerified,
    );
  }

  @override
  String toString() =>
      'AuthException: $message (code: $errorCode, statusCode: $statusCode)';
}

/// Auth-specific error codes.
enum AuthErrorCode {
  invalidCredentials,
  tokenExpired,
  invalidToken,
  unauthorized,
  accountLocked,
  emailNotVerified,
  registrationFailed,
  passwordResetFailed,
}

/// Exception thrown when input validation fails.
final class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.details,
    this.fieldErrors,
  });

  /// Map of field names to their validation errors.
  final Map<String, List<String>>? fieldErrors;

  /// Factory for a single field error.
  factory ValidationException.field(String field, String error) {
    return ValidationException(
      message: error,
      fieldErrors: {
        field: [error],
      },
    );
  }

  /// Factory for multiple field errors.
  factory ValidationException.fields(Map<String, List<String>> errors) {
    final firstError = errors.values.expand((e) => e).firstOrNull;
    return ValidationException(
      message: firstError ?? 'Validation failed',
      fieldErrors: errors,
    );
  }

  /// Returns true if there are any field errors.
  bool get hasFieldErrors => fieldErrors?.isNotEmpty ?? false;

  /// Gets errors for a specific field.
  List<String> errorsFor(String field) => fieldErrors?[field] ?? [];

  @override
  String toString() => 'ValidationException: $message (fields: $fieldErrors)';
}

/// Exception thrown when a requested resource is not found.
final class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.details,
    this.resourceType,
    this.resourceId,
  });

  /// The type of resource that was not found.
  final String? resourceType;

  /// The ID of the resource that was not found.
  final String? resourceId;

  /// Factory for resource not found.
  factory NotFoundException.resource(String resourceType, String resourceId) {
    return NotFoundException(
      message: '$resourceType not found',
      resourceType: resourceType,
      resourceId: resourceId,
    );
  }

  @override
  String toString() =>
      'NotFoundException: $message (type: $resourceType, id: $resourceId)';
}

/// Exception thrown when rate limits are exceeded.
final class RateLimitException extends AppException {
  const RateLimitException({
    required super.message,
    super.statusCode = 429,
    super.details,
    this.retryAfterSeconds,
  });

  /// Number of seconds to wait before retrying.
  final int? retryAfterSeconds;

  factory RateLimitException.fromHeaders(Map<String, dynamic>? headers) {
    final retryAfter = headers?['retry-after'];
    final seconds = retryAfter != null ? int.tryParse(retryAfter.toString()) : null;

    return RateLimitException(
      message: 'Too many requests. Please try again later.',
      retryAfterSeconds: seconds,
    );
  }

  @override
  String toString() =>
      'RateLimitException: $message (retryAfter: $retryAfterSeconds seconds)';
}

/// Exception thrown for unexpected application errors.
final class UnexpectedException extends AppException {
  const UnexpectedException({
    super.message = 'An unexpected error occurred',
    super.details,
    this.originalException,
    this.stackTrace,
  });

  /// The original exception that was caught.
  final Object? originalException;

  /// The stack trace when the exception occurred.
  final StackTrace? stackTrace;

  factory UnexpectedException.from(Object error, [StackTrace? stackTrace]) {
    return UnexpectedException(
      message: error.toString(),
      originalException: error,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() =>
      'UnexpectedException: $message (original: $originalException)';
}
