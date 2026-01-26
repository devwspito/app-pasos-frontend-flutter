import 'package:equatable/equatable.dart';

/// Base failure class for representing errors in the domain layer.
///
/// Failures are used in the domain layer to represent errors in a way that
/// is independent of the data layer implementation. This allows for clean
/// separation between layers and easier testing.
///
/// Use [Failure] subclasses with Either types (e.g., dartz package) or
/// sealed classes for result handling.
abstract class Failure extends Equatable {
  /// Human-readable error message
  final String message;

  /// Optional error code for programmatic handling
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => '$runtimeType: $message${code != null ? ' (code: $code)' : ''}';
}

/// Failure for network-related errors.
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });

  /// Create from a connection timeout
  factory NetworkFailure.timeout() => const NetworkFailure(
        message: 'Connection timed out. Please check your internet connection.',
        code: 'NETWORK_TIMEOUT',
      );

  /// Create from no internet connection
  factory NetworkFailure.noInternet() => const NetworkFailure(
        message: 'No internet connection. Please check your network settings.',
        code: 'NO_INTERNET',
      );
}

/// Failure for authentication-related errors.
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  /// Create from invalid credentials
  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Invalid email or password.',
        code: 'INVALID_CREDENTIALS',
      );

  /// Create from expired token
  factory AuthFailure.tokenExpired() => const AuthFailure(
        message: 'Your session has expired. Please log in again.',
        code: 'TOKEN_EXPIRED',
      );

  /// Create from unauthorized access
  factory AuthFailure.unauthorized() => const AuthFailure(
        message: 'You are not authorized to perform this action.',
        code: 'UNAUTHORIZED',
      );
}

/// Failure for server-related errors.
class ServerFailure extends Failure {
  /// HTTP status code from the response
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];

  /// Create from a bad request (400)
  factory ServerFailure.badRequest([String? message]) => ServerFailure(
        message: message ?? 'Bad request. Please check your input.',
        code: 'BAD_REQUEST',
        statusCode: 400,
      );

  /// Create from not found (404)
  factory ServerFailure.notFound([String? message]) => ServerFailure(
        message: message ?? 'The requested resource was not found.',
        code: 'NOT_FOUND',
        statusCode: 404,
      );

  /// Create from internal server error (500)
  factory ServerFailure.internalError([String? message]) => ServerFailure(
        message: message ?? 'An unexpected error occurred. Please try again later.',
        code: 'INTERNAL_ERROR',
        statusCode: 500,
      );
}

/// Failure for validation-related errors.
class ValidationFailure extends Failure {
  /// Map of field names to error messages
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];

  /// Create with field-specific errors
  factory ValidationFailure.fields(Map<String, String> errors) =>
      ValidationFailure(
        message: 'Validation failed',
        code: 'VALIDATION_ERROR',
        fieldErrors: errors,
      );
}

/// Failure for cache-related errors.
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });

  /// Create from cache read error
  factory CacheFailure.readError([String? message]) => CacheFailure(
        message: message ?? 'Failed to read from cache.',
        code: 'CACHE_READ_ERROR',
      );

  /// Create from cache write error
  factory CacheFailure.writeError([String? message]) => CacheFailure(
        message: message ?? 'Failed to write to cache.',
        code: 'CACHE_WRITE_ERROR',
      );

  /// Create from cache not found
  factory CacheFailure.notFound([String? message]) => CacheFailure(
        message: message ?? 'Data not found in cache.',
        code: 'CACHE_NOT_FOUND',
      );
}

/// Failure for unexpected errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred.',
    super.code = 'UNEXPECTED_ERROR',
  });
}
