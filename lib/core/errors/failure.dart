import 'package:equatable/equatable.dart';

import 'app_exception.dart';

/// Base failure class for domain layer error representation.
/// Uses sealed classes for exhaustive pattern matching (Dart 3).
sealed class Failure extends Equatable {
  /// Human-readable error message
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  /// Factory constructor to convert AppException to domain-specific Failure.
  /// Ensures all exception types are mapped to corresponding failure types.
  factory Failure.fromException(AppException e) {
    return switch (e) {
      NetworkException() => NetworkFailure(e.message),
      ServerException() => ServerFailure(e.message),
      UnauthorizedException() => AuthFailure(e.message),
      ValidationException() => ValidationFailure(e.message, e.fieldErrors),
      UnknownException() => UnknownFailure(e.message),
    };
  }
}

/// Failure for network-related errors.
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure for server errors.
final class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failure for authentication errors.
final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Failure for validation errors with field-level details.
final class ValidationFailure extends Failure {
  /// Map of field names to their error messages.
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure(super.message, this.fieldErrors);

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// Failure for unknown/unexpected errors.
final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

// =============================================================================
// Result Pattern for Functional Error Handling
// =============================================================================

/// A Result type that represents either success (data) or failure.
/// Uses Dart record syntax for lightweight, type-safe error handling.
///
/// Usage:
/// ```dart
/// Future<Result<User>> getUser(String id) async {
///   try {
///     final user = await api.getUser(id);
///     return (data: user, failure: null);
///   } on AppException catch (e) {
///     return (data: null, failure: Failure.fromException(e));
///   }
/// }
///
/// final result = await getUser('123');
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => showUser(user),
/// );
/// ```
typedef Result<T> = ({T? data, Failure? failure});

/// Extension methods for Result type to provide functional operations.
extension ResultExtension<T> on Result<T> {
  /// Returns true if the result contains data (success case).
  bool get isSuccess => data != null && failure == null;

  /// Returns true if the result contains a failure.
  bool get isFailure => failure != null;

  /// Folds the result into a single value.
  ///
  /// Calls [onFailure] if this is a failure, or [onSuccess] if this is success.
  /// This ensures exhaustive handling of both cases.
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) {
    if (isFailure) return onFailure(failure!);
    return onSuccess(data as T);
  }

  /// Maps the success value to a new type.
  ///
  /// If this is a failure, returns the failure unchanged.
  /// If this is a success, applies [transform] to the data.
  Result<R> map<R>(R Function(T) transform) {
    if (isFailure) return (data: null, failure: failure);
    return (data: transform(data as T), failure: null);
  }

  /// Chains another Result-returning operation.
  ///
  /// If this is a failure, returns the failure unchanged.
  /// If this is a success, applies [transform] which returns a new Result.
  Result<R> flatMap<R>(Result<R> Function(T) transform) {
    if (isFailure) return (data: null, failure: failure);
    return transform(data as T);
  }

  /// Returns the data or a default value if this is a failure.
  T getOrElse(T defaultValue) {
    if (isSuccess) return data as T;
    return defaultValue;
  }

  /// Returns the data or throws the failure's message as an exception.
  T getOrThrow() {
    if (isSuccess) return data as T;
    throw Exception(failure!.message);
  }
}

// =============================================================================
// Helper Functions for Creating Results
// =============================================================================

/// Creates a successful Result with the given data.
Result<T> success<T>(T data) => (data: data, failure: null);

/// Creates a failed Result with the given failure.
Result<T> failed<T>(Failure failure) => (data: null, failure: failure);

/// Creates a failed Result from an AppException.
Result<T> failedFromException<T>(AppException exception) =>
    (data: null, failure: Failure.fromException(exception));
