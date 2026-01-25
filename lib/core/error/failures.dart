import 'package:equatable/equatable.dart';

import 'exceptions.dart';

/// Base class for all application failures.
///
/// Failures represent expected error states in the application and are used
/// with the `dartz` Either type for functional error handling. All failures
/// extend [Equatable] for proper value equality comparison.
///
/// Example usage:
/// ```dart
/// Future<Either<Failure, User>> getUser(String id) async {
///   try {
///     final user = await api.fetchUser(id);
///     return Right(user);
///   } on ServerException catch (e) {
///     return Left(ServerFailure.fromException(e));
///   }
/// }
/// ```
abstract class Failure extends Equatable {
  /// Creates a new [Failure] instance.
  ///
  /// [message] is required and should describe what went wrong.
  /// [code] is optional and can be used for specific error codes.
  const Failure({
    required this.message,
    this.code,
  });

  /// A human-readable message describing the failure.
  final String message;

  /// An optional error code associated with the failure.
  final int? code;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Failure representing server-side errors.
///
/// Used when API requests fail due to server issues such as internal errors,
/// bad gateway, service unavailable, etc.
///
/// Example usage:
/// ```dart
/// try {
///   final response = await dio.get('/users');
///   return Right(response.data);
/// } on DioException catch (e) {
///   return Left(ServerFailure(
///     message: e.message ?? 'Server error occurred',
///     code: e.response?.statusCode,
///   ));
/// }
/// ```
class ServerFailure extends Failure {
  /// Creates a new [ServerFailure] instance.
  const ServerFailure({
    required super.message,
    super.code,
  });

  /// Creates a [ServerFailure] from a [ServerException].
  ///
  /// This factory constructor converts exceptions to failures for use
  /// with the Either type pattern.
  factory ServerFailure.fromException(ServerException exception) {
    return ServerFailure(
      message: exception.message,
      code: exception.statusCode,
    );
  }

  /// Creates a generic server failure with default message.
  factory ServerFailure.generic() {
    return const ServerFailure(
      message: 'An unexpected server error occurred. Please try again later.',
      code: 500,
    );
  }
}

/// Failure representing local cache/storage errors.
///
/// Used when operations involving local storage, shared preferences,
/// or cached data fail.
///
/// Example usage:
/// ```dart
/// try {
///   final cachedData = await localStorage.read('user_data');
///   return Right(cachedData);
/// } on CacheException catch (e) {
///   return Left(CacheFailure.fromException(e));
/// }
/// ```
class CacheFailure extends Failure {
  /// Creates a new [CacheFailure] instance.
  const CacheFailure({
    required super.message,
    super.code,
  });

  /// Creates a [CacheFailure] from a [CacheException].
  factory CacheFailure.fromException(CacheException exception) {
    return CacheFailure(
      message: exception.message,
      code: exception.statusCode,
    );
  }

  /// Creates a failure for when cached data is not found.
  factory CacheFailure.notFound() {
    return const CacheFailure(
      message: 'Requested data not found in cache.',
      code: 404,
    );
  }

  /// Creates a failure for when cache write operations fail.
  factory CacheFailure.writeFailed() {
    return const CacheFailure(
      message: 'Failed to write data to cache.',
      code: 500,
    );
  }
}

/// Failure representing network connectivity issues.
///
/// Used when the device has no internet connection or when network
/// requests time out.
///
/// Example usage:
/// ```dart
/// final hasConnection = await connectivity.checkConnection();
/// if (!hasConnection) {
///   return Left(NetworkFailure.noConnection());
/// }
/// ```
class NetworkFailure extends Failure {
  /// Creates a new [NetworkFailure] instance.
  const NetworkFailure({
    required super.message,
    super.code,
  });

  /// Creates a [NetworkFailure] from a [NetworkException].
  factory NetworkFailure.fromException(NetworkException exception) {
    return NetworkFailure(
      message: exception.message,
      code: exception.statusCode,
    );
  }

  /// Creates a failure for when there is no internet connection.
  factory NetworkFailure.noConnection() {
    return const NetworkFailure(
      message: 'No internet connection. Please check your network settings.',
      code: 0,
    );
  }

  /// Creates a failure for when a network request times out.
  factory NetworkFailure.timeout() {
    return const NetworkFailure(
      message: 'Connection timed out. Please try again.',
      code: 408,
    );
  }
}

/// Failure representing input validation errors.
///
/// Used when user input fails validation rules such as invalid email format,
/// password requirements, or required fields.
///
/// Example usage:
/// ```dart
/// if (!EmailValidator.isValid(email)) {
///   return Left(ValidationFailure.invalidEmail());
/// }
/// ```
class ValidationFailure extends Failure {
  /// Creates a new [ValidationFailure] instance.
  const ValidationFailure({
    required super.message,
    super.code,
    this.field,
  });

  /// Creates a failure for invalid email format.
  factory ValidationFailure.invalidEmail() {
    return const ValidationFailure(
      message: 'Please enter a valid email address.',
      field: 'email',
      code: 422,
    );
  }

  /// Creates a failure for invalid password.
  factory ValidationFailure.invalidPassword({String? reason}) {
    return ValidationFailure(
      message: reason ?? 'Password does not meet requirements.',
      field: 'password',
      code: 422,
    );
  }

  /// Creates a failure for a required field that is empty.
  factory ValidationFailure.requiredField(String fieldName) {
    return ValidationFailure(
      message: '$fieldName is required.',
      field: fieldName,
      code: 422,
    );
  }

  /// Creates a failure for generic invalid input.
  factory ValidationFailure.invalidInput(String fieldName, String reason) {
    return ValidationFailure(
      message: reason,
      field: fieldName,
      code: 422,
    );
  }

  /// The field that failed validation, if applicable.
  final String? field;

  @override
  List<Object?> get props => [message, code, field];
}

/// Failure representing authentication and authorization errors.
///
/// Used when user authentication fails, tokens expire, or the user
/// doesn't have permission to access a resource.
///
/// Example usage:
/// ```dart
/// if (response.statusCode == 401) {
///   return Left(AuthenticationFailure.sessionExpired());
/// }
/// ```
class AuthenticationFailure extends Failure {
  /// Creates a new [AuthenticationFailure] instance.
  const AuthenticationFailure({
    required super.message,
    super.code,
  });

  /// Creates a [AuthenticationFailure] from an [UnauthorizedException].
  factory AuthenticationFailure.fromException(
    UnauthorizedException exception,
  ) {
    return AuthenticationFailure(
      message: exception.message,
      code: exception.statusCode,
    );
  }

  /// Creates a failure for invalid credentials.
  factory AuthenticationFailure.invalidCredentials() {
    return const AuthenticationFailure(
      message: 'Invalid email or password. Please try again.',
      code: 401,
    );
  }

  /// Creates a failure for expired session/token.
  factory AuthenticationFailure.sessionExpired() {
    return const AuthenticationFailure(
      message: 'Your session has expired. Please log in again.',
      code: 401,
    );
  }

  /// Creates a failure for unauthorized access.
  factory AuthenticationFailure.unauthorized() {
    return const AuthenticationFailure(
      message: 'You are not authorized to perform this action.',
      code: 403,
    );
  }

  /// Creates a failure for when account is locked or suspended.
  factory AuthenticationFailure.accountLocked() {
    return const AuthenticationFailure(
      message: 'Your account has been locked. Please contact support.',
      code: 403,
    );
  }
}

/// Failure for unexpected or unknown errors.
///
/// Used as a catch-all for errors that don't fit into other categories.
/// This should be used sparingly and only when the error cannot be
/// properly categorized.
///
/// Example usage:
/// ```dart
/// try {
///   // Some operation
/// } catch (e) {
///   return Left(UnknownFailure.fromError(e));
/// }
/// ```
class UnknownFailure extends Failure {
  /// Creates a new [UnknownFailure] instance.
  const UnknownFailure({
    required super.message,
    super.code,
    this.originalError,
  });

  /// Creates an [UnknownFailure] from any error object.
  factory UnknownFailure.fromError(Object error) {
    return UnknownFailure(
      message: 'An unexpected error occurred: ${error.toString()}',
      originalError: error,
    );
  }

  /// Creates a generic unknown failure.
  factory UnknownFailure.generic() {
    return const UnknownFailure(
      message: 'An unexpected error occurred. Please try again.',
    );
  }

  /// The original error that caused this failure, if available.
  final Object? originalError;

  @override
  List<Object?> get props => [message, code, originalError];
}
