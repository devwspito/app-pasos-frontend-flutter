/// Base exception class for application-specific errors.
///
/// All custom exceptions should extend this class.
class AppException implements Exception {
  /// Human-readable error message
  final String message;

  /// Optional error code for programmatic handling
  final String? code;

  /// Original error that caused this exception
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for network-related errors.
///
/// Use when there are connectivity issues or network timeouts.
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });

  /// Create from a connection timeout
  factory NetworkException.timeout() => const NetworkException(
        message: 'Connection timed out. Please check your internet connection.',
        code: 'NETWORK_TIMEOUT',
      );

  /// Create from no internet connection
  factory NetworkException.noInternet() => const NetworkException(
        message: 'No internet connection. Please check your network settings.',
        code: 'NO_INTERNET',
      );

  @override
  String toString() => 'NetworkException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for authentication-related errors.
///
/// Use when there are login, token, or permission issues.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });

  /// Create from invalid credentials
  factory AuthException.invalidCredentials() => const AuthException(
        message: 'Invalid email or password.',
        code: 'INVALID_CREDENTIALS',
      );

  /// Create from expired token
  factory AuthException.tokenExpired() => const AuthException(
        message: 'Your session has expired. Please log in again.',
        code: 'TOKEN_EXPIRED',
      );

  /// Create from unauthorized access
  factory AuthException.unauthorized() => const AuthException(
        message: 'You are not authorized to perform this action.',
        code: 'UNAUTHORIZED',
      );

  /// Create from user not found
  factory AuthException.userNotFound() => const AuthException(
        message: 'User not found.',
        code: 'USER_NOT_FOUND',
      );

  @override
  String toString() => 'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for validation-related errors.
///
/// Use when input validation fails.
class ValidationException extends AppException {
  /// Map of field names to error messages
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });

  /// Create with field-specific errors
  factory ValidationException.fields(Map<String, String> errors) =>
      ValidationException(
        message: 'Validation failed',
        code: 'VALIDATION_ERROR',
        fieldErrors: errors,
      );

  @override
  String toString() =>
      'ValidationException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for server-related errors.
///
/// Use when the server returns an error response.
class ServerException extends AppException {
  /// HTTP status code from the response
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });

  /// Create from a bad request (400)
  factory ServerException.badRequest([String? message]) => ServerException(
        message: message ?? 'Bad request. Please check your input.',
        code: 'BAD_REQUEST',
        statusCode: 400,
      );

  /// Create from not found (404)
  factory ServerException.notFound([String? message]) => ServerException(
        message: message ?? 'The requested resource was not found.',
        code: 'NOT_FOUND',
        statusCode: 404,
      );

  /// Create from internal server error (500)
  factory ServerException.internalError([String? message]) => ServerException(
        message: message ?? 'An unexpected error occurred. Please try again later.',
        code: 'INTERNAL_ERROR',
        statusCode: 500,
      );

  /// Create from service unavailable (503)
  factory ServerException.serviceUnavailable([String? message]) => ServerException(
        message: message ?? 'Service is temporarily unavailable. Please try again later.',
        code: 'SERVICE_UNAVAILABLE',
        statusCode: 503,
      );

  @override
  String toString() =>
      'ServerException: $message (status: $statusCode)${code != null ? ' (code: $code)' : ''}';
}

/// Exception for cache-related errors.
///
/// Use when there are local storage or cache issues.
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });

  /// Create from cache read error
  factory CacheException.readError([String? message]) => CacheException(
        message: message ?? 'Failed to read from cache.',
        code: 'CACHE_READ_ERROR',
      );

  /// Create from cache write error
  factory CacheException.writeError([String? message]) => CacheException(
        message: message ?? 'Failed to write to cache.',
        code: 'CACHE_WRITE_ERROR',
      );

  /// Create from cache not found
  factory CacheException.notFound([String? message]) => CacheException(
        message: message ?? 'Data not found in cache.',
        code: 'CACHE_NOT_FOUND',
      );

  @override
  String toString() => 'CacheException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for parsing-related errors.
///
/// Use when data parsing or serialization fails.
class ParseException extends AppException {
  const ParseException({
    required super.message,
    super.code,
    super.originalError,
  });

  /// Create from JSON parse error
  factory ParseException.json([dynamic error]) => ParseException(
        message: 'Failed to parse JSON data.',
        code: 'JSON_PARSE_ERROR',
        originalError: error,
      );

  @override
  String toString() => 'ParseException: $message${code != null ? ' (code: $code)' : ''}';
}
