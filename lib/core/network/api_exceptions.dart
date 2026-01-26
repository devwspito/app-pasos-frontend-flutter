/// API exception classes for handling network errors.
///
/// This file contains a hierarchy of exception classes that represent
/// different types of API errors, allowing for granular error handling
/// throughout the application.

/// Base class for all API-related exceptions.
///
/// Provides a common interface with message, statusCode, and optional
/// underlying cause for debugging purposes.
///
/// Example:
/// ```dart
/// try {
///   await apiClient.get('/users');
/// } on ApiException catch (e) {
///   print('API Error: ${e.message} (${e.statusCode})');
/// }
/// ```
class ApiException implements Exception {
  /// Human-readable error message
  final String message;

  /// HTTP status code associated with the error
  final int? statusCode;

  /// The underlying cause of this exception, if any
  final dynamic cause;

  /// Creates an [ApiException] with the given [message] and optional [statusCode].
  const ApiException(
    this.message, {
    this.statusCode,
    this.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ApiException: $message');
    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }
    return buffer.toString();
  }
}

/// Exception thrown when there is no network connectivity.
///
/// This exception is thrown when the device cannot reach the server
/// due to network issues such as airplane mode, no WiFi/data connection,
/// or DNS resolution failures.
///
/// Example:
/// ```dart
/// try {
///   await apiClient.get('/users');
/// } on NetworkException catch (e) {
///   showDialog(message: 'No internet connection. Please check your network.');
/// }
/// ```
class NetworkException extends ApiException {
  /// Creates a [NetworkException] with the given [message].
  const NetworkException(
    super.message, {
    super.cause,
  }) : super(statusCode: null);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when the server returns a 5xx error.
///
/// Server errors indicate that the server failed to fulfill a valid request.
/// The client should typically retry the request or inform the user
/// that the service is temporarily unavailable.
///
/// Example:
/// ```dart
/// try {
///   await apiClient.post('/orders', data: orderData);
/// } on ServerException catch (e) {
///   showDialog(message: 'Server error. Please try again later.');
///   reportToSentry(e);
/// }
/// ```
class ServerException extends ApiException {
  /// Creates a [ServerException] with the given [message] and [statusCode].
  const ServerException(
    super.message, {
    required int super.statusCode,
    super.cause,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// Exception thrown when the server returns a 401 Unauthorized error.
///
/// This exception indicates that the request requires authentication
/// or the provided credentials are invalid. The application should
/// typically prompt the user to log in again or attempt token refresh.
///
/// Example:
/// ```dart
/// try {
///   await apiClient.get('/profile');
/// } on UnauthorizedException catch (e) {
///   // Redirect to login or attempt token refresh
///   authBloc.add(TokenRefreshRequested());
/// }
/// ```
class UnauthorizedException extends ApiException {
  /// Creates an [UnauthorizedException] with the given [message].
  const UnauthorizedException(
    super.message, {
    super.cause,
  }) : super(statusCode: 401);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception thrown when the server returns a 400 Bad Request error.
///
/// This exception is typically thrown when the request contains invalid
/// data that failed server-side validation. It includes a list of
/// field-specific validation errors for displaying to the user.
///
/// Example:
/// ```dart
/// try {
///   await apiClient.post('/register', data: userData);
/// } on ValidationException catch (e) {
///   for (final error in e.errors) {
///     formKey.currentState?.fields[error.field]?.invalidate(error.message);
///   }
/// }
/// ```
class ValidationException extends ApiException {
  /// List of field-specific validation errors
  final List<FieldError> errors;

  /// Creates a [ValidationException] with the given [message] and [errors].
  const ValidationException(
    super.message, {
    this.errors = const [],
    super.cause,
  }) : super(statusCode: 400);

  @override
  String toString() {
    final buffer = StringBuffer('ValidationException: $message');
    if (errors.isNotEmpty) {
      buffer.write('\nErrors:');
      for (final error in errors) {
        buffer.write('\n  - ${error.field}: ${error.message}');
      }
    }
    return buffer.toString();
  }
}

/// Represents a field-specific validation error.
///
/// Contains the [field] name that failed validation and
/// the error [message] describing what went wrong.
class FieldError {
  /// The name of the field that failed validation
  final String field;

  /// Human-readable error message
  final String message;

  /// Creates a [FieldError] with the given [field] and [message].
  const FieldError({
    required this.field,
    required this.message,
  });

  /// Creates a [FieldError] from a JSON map.
  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] as String? ?? '',
      message: json['message'] as String? ?? 'Validation error',
    );
  }

  /// Converts this [FieldError] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'message': message,
    };
  }

  @override
  String toString() => 'FieldError($field: $message)';
}

/// Exception thrown when the server returns a 404 Not Found error.
///
/// This exception indicates that the requested resource does not exist
/// on the server. The application should handle this gracefully,
/// perhaps by showing a "not found" message or navigating away.
///
/// Example:
/// ```dart
/// try {
///   final user = await apiClient.get('/users/$userId');
/// } on NotFoundException catch (e) {
///   showDialog(message: 'User not found.');
///   navigator.pop();
/// }
/// ```
class NotFoundException extends ApiException {
  /// Creates a [NotFoundException] with the given [message].
  const NotFoundException(
    super.message, {
    super.cause,
  }) : super(statusCode: 404);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when the request times out.
///
/// This exception indicates that the server did not respond within
/// the configured timeout period. The application should typically
/// allow the user to retry the request.
///
/// Example:
/// ```dart
/// try {
///   await apiClient.get('/slow-endpoint');
/// } on TimeoutException catch (e) {
///   showSnackBar('Request timed out. Please try again.');
/// }
/// ```
class TimeoutException extends ApiException {
  /// Creates a [TimeoutException] with the given [message].
  const TimeoutException(
    super.message, {
    super.cause,
  }) : super(statusCode: null);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Exception thrown when the request is cancelled.
///
/// This exception indicates that the request was intentionally cancelled,
/// typically due to user action or component disposal.
///
/// Example:
/// ```dart
/// final cancelToken = CancelToken();
/// // User navigates away
/// cancelToken.cancel();
/// // The request will throw CancelledException
/// ```
class CancelledException extends ApiException {
  /// Creates a [CancelledException] with the given [message].
  const CancelledException(
    super.message, {
    super.cause,
  }) : super(statusCode: null);

  @override
  String toString() => 'CancelledException: $message';
}

/// Exception thrown when the server returns a 403 Forbidden error.
///
/// This exception indicates that the user is authenticated but does not
/// have permission to access the requested resource.
///
/// Example:
/// ```dart
/// try {
///   await apiClient.get('/admin/dashboard');
/// } on ForbiddenException catch (e) {
///   showDialog(message: 'You do not have permission to access this resource.');
/// }
/// ```
class ForbiddenException extends ApiException {
  /// Creates a [ForbiddenException] with the given [message].
  const ForbiddenException(
    super.message, {
    super.cause,
  }) : super(statusCode: 403);

  @override
  String toString() => 'ForbiddenException: $message';
}

/// Exception thrown when the request has a conflict with server state.
///
/// This exception indicates HTTP 409 Conflict, typically when trying
/// to create a resource that already exists or update a resource
/// that has been modified by another request.
///
/// Example:
/// ```dart
/// try {
///   await apiClient.post('/users', data: {'email': existingEmail});
/// } on ConflictException catch (e) {
///   showDialog(message: 'A user with this email already exists.');
/// }
/// ```
class ConflictException extends ApiException {
  /// Creates a [ConflictException] with the given [message].
  const ConflictException(
    super.message, {
    super.cause,
  }) : super(statusCode: 409);

  @override
  String toString() => 'ConflictException: $message';
}
