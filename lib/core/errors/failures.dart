import 'package:equatable/equatable.dart';

import 'exceptions.dart';

/// Base failure class for functional error handling.
///
/// Extends [Equatable] for value-based equality comparison.
/// Use failures with Either pattern for functional error handling.
sealed class Failure extends Equatable {
  const Failure({
    required this.message,
    this.statusCode,
    this.details,
  });

  /// Human-readable error message.
  final String message;

  /// Optional HTTP status code.
  final int? statusCode;

  /// Optional additional details.
  final Map<String, dynamic>? details;

  @override
  List<Object?> get props => [message, statusCode, details];

  @override
  String toString() => 'Failure: $message';
}

/// Failure representing server/API errors.
final class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
    super.details,
    this.endpoint,
  });

  /// The endpoint that failed.
  final String? endpoint;

  /// Creates a ServerFailure from a ServerException.
  factory ServerFailure.fromException(ServerException exception) {
    return ServerFailure(
      message: exception.message,
      statusCode: exception.statusCode,
      details: exception.details,
      endpoint: exception.endpoint,
    );
  }

  /// Factory for common server failures.
  factory ServerFailure.badRequest([String? message]) {
    return ServerFailure(
      message: message ?? 'Bad request',
      statusCode: 400,
    );
  }

  factory ServerFailure.unauthorized([String? message]) {
    return ServerFailure(
      message: message ?? 'Unauthorized',
      statusCode: 401,
    );
  }

  factory ServerFailure.forbidden([String? message]) {
    return ServerFailure(
      message: message ?? 'Access denied',
      statusCode: 403,
    );
  }

  factory ServerFailure.notFound([String? message]) {
    return ServerFailure(
      message: message ?? 'Resource not found',
      statusCode: 404,
    );
  }

  factory ServerFailure.internalError([String? message]) {
    return ServerFailure(
      message: message ?? 'Internal server error',
      statusCode: 500,
    );
  }

  @override
  List<Object?> get props => [...super.props, endpoint];

  @override
  String toString() => 'ServerFailure: $message (statusCode: $statusCode)';
}

/// Failure representing local cache errors.
final class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.details,
    this.key,
  });

  /// The cache key involved.
  final String? key;

  /// Creates a CacheFailure from a CacheException.
  factory CacheFailure.fromException(CacheException exception) {
    return CacheFailure(
      message: exception.message,
      details: exception.details,
      key: exception.key,
    );
  }

  /// Factory for common cache failures.
  factory CacheFailure.notFound([String? key]) {
    return CacheFailure(
      message: 'Cached data not found',
      key: key,
    );
  }

  factory CacheFailure.expired([String? key]) {
    return CacheFailure(
      message: 'Cached data has expired',
      key: key,
    );
  }

  factory CacheFailure.writeError([String? message]) {
    return CacheFailure(
      message: message ?? 'Failed to write to cache',
    );
  }

  factory CacheFailure.readError([String? message]) {
    return CacheFailure(
      message: message ?? 'Failed to read from cache',
    );
  }

  @override
  List<Object?> get props => [...super.props, key];

  @override
  String toString() => 'CacheFailure: $message (key: $key)';
}

/// Failure representing network connectivity issues.
final class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.details,
    this.isTimeout = false,
  });

  /// Whether this was a timeout failure.
  final bool isTimeout;

  /// Creates a NetworkFailure from a NetworkException.
  factory NetworkFailure.fromException(NetworkException exception) {
    return NetworkFailure(
      message: exception.message,
      details: exception.details,
      isTimeout: exception.isTimeout ?? false,
    );
  }

  /// Factory for no connection.
  factory NetworkFailure.noConnection() {
    return const NetworkFailure(
      message: 'No internet connection. Please check your network settings.',
    );
  }

  /// Factory for timeout.
  factory NetworkFailure.timeout() {
    return const NetworkFailure(
      message: 'Connection timed out. Please try again.',
      isTimeout: true,
    );
  }

  /// Factory for poor connection.
  factory NetworkFailure.poorConnection() {
    return const NetworkFailure(
      message: 'Poor network connection. Please try again.',
    );
  }

  @override
  List<Object?> get props => [...super.props, isTimeout];

  @override
  String toString() => 'NetworkFailure: $message (timeout: $isTimeout)';
}

/// Failure representing authentication errors.
final class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
    super.details,
    this.errorCode,
  });

  /// Auth-specific error code.
  final AuthErrorCode? errorCode;

  /// Creates an AuthFailure from an AuthException.
  factory AuthFailure.fromException(AuthException exception) {
    return AuthFailure(
      message: exception.message,
      statusCode: exception.statusCode,
      details: exception.details,
      errorCode: exception.errorCode,
    );
  }

  /// Factory for common auth failures.
  factory AuthFailure.invalidCredentials() {
    return const AuthFailure(
      message: 'Invalid email or password',
      statusCode: 401,
      errorCode: AuthErrorCode.invalidCredentials,
    );
  }

  factory AuthFailure.sessionExpired() {
    return const AuthFailure(
      message: 'Your session has expired. Please log in again.',
      statusCode: 401,
      errorCode: AuthErrorCode.tokenExpired,
    );
  }

  factory AuthFailure.unauthorized() {
    return const AuthFailure(
      message: 'You are not authorized to perform this action',
      statusCode: 403,
      errorCode: AuthErrorCode.unauthorized,
    );
  }

  factory AuthFailure.accountLocked() {
    return const AuthFailure(
      message: 'Your account has been locked. Please contact support.',
      statusCode: 403,
      errorCode: AuthErrorCode.accountLocked,
    );
  }

  @override
  List<Object?> get props => [...super.props, errorCode];

  @override
  String toString() => 'AuthFailure: $message (code: $errorCode)';
}

/// Failure representing input validation errors.
final class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.details,
    this.fieldErrors,
  });

  /// Map of field names to their validation errors.
  final Map<String, List<String>>? fieldErrors;

  /// Creates a ValidationFailure from a ValidationException.
  factory ValidationFailure.fromException(ValidationException exception) {
    return ValidationFailure(
      message: exception.message,
      details: exception.details,
      fieldErrors: exception.fieldErrors,
    );
  }

  /// Factory for a single field error.
  factory ValidationFailure.field(String field, String error) {
    return ValidationFailure(
      message: error,
      fieldErrors: {
        field: [error],
      },
    );
  }

  /// Factory for multiple field errors.
  factory ValidationFailure.fields(Map<String, List<String>> errors) {
    final firstError = errors.values.expand((e) => e).firstOrNull;
    return ValidationFailure(
      message: firstError ?? 'Validation failed',
      fieldErrors: errors,
    );
  }

  /// Returns true if there are any field errors.
  bool get hasFieldErrors => fieldErrors?.isNotEmpty ?? false;

  /// Gets errors for a specific field.
  List<String> errorsFor(String field) => fieldErrors?[field] ?? [];

  @override
  List<Object?> get props => [...super.props, fieldErrors];

  @override
  String toString() => 'ValidationFailure: $message';
}

/// Failure representing a resource not found.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.details,
    this.resourceType,
    this.resourceId,
  });

  /// The type of resource that was not found.
  final String? resourceType;

  /// The ID of the resource that was not found.
  final String? resourceId;

  /// Creates a NotFoundFailure from a NotFoundException.
  factory NotFoundFailure.fromException(NotFoundException exception) {
    return NotFoundFailure(
      message: exception.message,
      details: exception.details,
      resourceType: exception.resourceType,
      resourceId: exception.resourceId,
    );
  }

  /// Factory for a resource not found.
  factory NotFoundFailure.resource(String resourceType, [String? resourceId]) {
    return NotFoundFailure(
      message: '$resourceType not found',
      resourceType: resourceType,
      resourceId: resourceId,
    );
  }

  @override
  List<Object?> get props => [...super.props, resourceType, resourceId];

  @override
  String toString() =>
      'NotFoundFailure: $message (type: $resourceType, id: $resourceId)';
}

/// Failure for unexpected errors.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred',
    super.details,
  });

  /// Creates an UnexpectedFailure from an UnexpectedException.
  factory UnexpectedFailure.fromException(UnexpectedException exception) {
    return UnexpectedFailure(
      message: exception.message,
      details: exception.details,
    );
  }

  /// Creates an UnexpectedFailure from any error.
  factory UnexpectedFailure.from(Object error) {
    return UnexpectedFailure(
      message: error.toString(),
    );
  }

  @override
  String toString() => 'UnexpectedFailure: $message';
}

/// Extension to convert exceptions to failures.
extension ExceptionToFailure on AppException {
  /// Converts this exception to the corresponding failure type.
  Failure toFailure() {
    return switch (this) {
      ServerException e => ServerFailure.fromException(e),
      CacheException e => CacheFailure.fromException(e),
      NetworkException e => NetworkFailure.fromException(e),
      AuthException e => AuthFailure.fromException(e),
      ValidationException e => ValidationFailure.fromException(e),
      NotFoundException e => NotFoundFailure.fromException(e),
      RateLimitException _ => const ServerFailure(
          message: 'Too many requests. Please try again later.',
          statusCode: 429,
        ),
      UnexpectedException e => UnexpectedFailure.fromException(e),
    };
  }
}
