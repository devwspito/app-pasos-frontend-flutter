/// Custom API exceptions for handling HTTP errors in the application.
///
/// These exceptions provide type-safe error handling with status codes
/// and messages for different HTTP error scenarios.
library;

/// Base class for all API-related exceptions.
///
/// Contains a message describing the error, an optional HTTP status code,
/// and optional additional data from the response.
class ApiException implements Exception {
  /// Human-readable error message.
  final String message;

  /// HTTP status code associated with the error, if applicable.
  final int? statusCode;

  /// Additional data from the error response.
  final dynamic data;

  /// Creates a new [ApiException].
  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => message.hashCode ^ (statusCode?.hashCode ?? 0);
}

/// Exception thrown when the user is not authorized (HTTP 401).
///
/// This typically occurs when:
/// - The JWT token is missing or invalid
/// - The token has expired
/// - The user doesn't have access to the requested resource
class UnauthorizedException extends ApiException {
  /// Creates a new [UnauthorizedException].
  UnauthorizedException({String? message})
      : super(
          message: message ?? 'Unauthorized',
          statusCode: 401,
        );
}

/// Exception thrown when a requested resource is not found (HTTP 404).
///
/// This typically occurs when:
/// - The requested endpoint doesn't exist
/// - The requested resource (user, study plan, etc.) doesn't exist
class NotFoundException extends ApiException {
  /// Creates a new [NotFoundException].
  NotFoundException({String? message})
      : super(
          message: message ?? 'Not found',
          statusCode: 404,
        );
}

/// Exception thrown when the server encounters an error (HTTP 5xx).
///
/// This typically occurs when:
/// - The server has an internal error (500)
/// - The server is unavailable (503)
/// - A bad gateway error occurs (502)
class ServerException extends ApiException {
  /// Creates a new [ServerException].
  ServerException({String? message})
      : super(
          message: message ?? 'Server error',
          statusCode: 500,
        );
}

/// Exception thrown when there's a network connectivity issue.
///
/// This typically occurs when:
/// - The device has no internet connection
/// - Connection times out
/// - DNS resolution fails
class NetworkException extends ApiException {
  /// Creates a new [NetworkException].
  NetworkException({String? message})
      : super(
          message: message ?? 'Network error',
        );
}

/// Exception thrown when the request is invalid (HTTP 400).
///
/// This typically occurs when:
/// - Request body is malformed
/// - Required fields are missing
/// - Validation fails on the server
class BadRequestException extends ApiException {
  /// Creates a new [BadRequestException].
  BadRequestException({String? message, super.data})
      : super(
          message: message ?? 'Bad request',
          statusCode: 400,
        );
}

/// Exception thrown when the user doesn't have permission (HTTP 403).
///
/// This typically occurs when:
/// - The user is authenticated but lacks permissions
/// - The resource is restricted
class ForbiddenException extends ApiException {
  /// Creates a new [ForbiddenException].
  ForbiddenException({String? message})
      : super(
          message: message ?? 'Forbidden',
          statusCode: 403,
        );
}

/// Exception thrown when there's a conflict (HTTP 409).
///
/// This typically occurs when:
/// - Duplicate resource creation attempt
/// - Concurrent modification conflict
class ConflictException extends ApiException {
  /// Creates a new [ConflictException].
  ConflictException({String? message})
      : super(
          message: message ?? 'Conflict',
          statusCode: 409,
        );
}

/// Exception thrown when request times out.
///
/// This can occur during:
/// - Connection timeout
/// - Send timeout
/// - Receive timeout
class TimeoutException extends ApiException {
  /// Creates a new [TimeoutException].
  TimeoutException({String? message})
      : super(
          message: message ?? 'Request timed out',
        );
}
