import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

/// Base exception class for all application exceptions.
/// Uses sealed classes for exhaustive pattern matching (Dart 3).
sealed class AppException extends Equatable implements Exception {
  /// Human-readable error message
  final String message;

  /// HTTP status code if applicable
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];

  /// Factory constructor to convert DioException to domain-specific AppException.
  /// Maps network errors, timeouts, and server responses to appropriate types.
  factory AppException.fromDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const NetworkException(
        message: 'Connection timeout. Please check your internet.',
      ),
      DioExceptionType.badResponse => _handleBadResponse(e),
      DioExceptionType.connectionError => const NetworkException(
        message: 'No internet connection',
      ),
      _ => UnknownException(message: e.message ?? 'Unknown error occurred'),
    };
  }

  /// Handles bad response errors and maps them to appropriate exception types.
  static AppException _handleBadResponse(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // Extract message from response
    String message = 'Server error occurred';
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? message;
    }

    // Map status codes to specific exception types
    return switch (statusCode) {
      401 => const UnauthorizedException(),
      422 => ValidationException(
        message: message,
        fieldErrors: _extractFieldErrors(data),
      ),
      _ => ServerException(
        message: message,
        statusCode: statusCode,
      ),
    };
  }

  /// Extracts field-level validation errors from response data.
  static Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final errors = data['errors'];
    if (errors is! Map<String, dynamic>) return null;

    return errors.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.map((e) => e.toString()).toList());
      }
      return MapEntry(key, [value.toString()]);
    });
  }
}

/// Exception for network-related errors (no connection, timeouts).
final class NetworkException extends AppException {
  const NetworkException({required super.message});
}

/// Exception for server errors (5xx, 4xx except 401/422).
final class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

/// Exception for authentication failures (401).
final class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Session expired. Please login again.',
  }) : super(statusCode: 401);
}

/// Exception for validation errors (422) with field-level details.
final class ValidationException extends AppException {
  /// Map of field names to their error messages.
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors,
  }) : super(statusCode: 422);

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Exception for unexpected/unknown errors.
final class UnknownException extends AppException {
  const UnknownException({required super.message});
}
