import 'package:dio/dio.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/errors/failure.dart';
import '../../core/network/dio_client.dart';

/// Base class for all repositories
/// Provides common functionality for API calls and error handling
abstract class BaseRepository {
  final DioClient dioClient;

  const BaseRepository({required this.dioClient});

  /// Wraps API calls with standard error handling
  /// Returns data on success, throws AppException on failure
  Future<T> safeApiCall<T>(
    Future<Response<dynamic>> Function() apiCall,
    T Function(dynamic data) parser,
  ) async {
    try {
      final response = await apiCall();
      return parser(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Unexpected error occurred',
        code: 'UNEXPECTED',
        originalError: e,
      );
    }
  }

  /// Converts AppException to Failure for cleaner error handling in UI
  Failure mapExceptionToFailure(AppException exception) {
    if (exception is NetworkException) {
      return NetworkFailure(message: exception.message, code: exception.code);
    }
    if (exception is AuthException) {
      return AuthFailure(message: exception.message, code: exception.code);
    }
    if (exception is ValidationException) {
      return ValidationFailure(message: exception.message, code: exception.code);
    }
    if (exception is ServerException) {
      return ServerFailure(
        message: exception.message,
        code: exception.code,
        statusCode: exception.statusCode,
      );
    }
    return ServerFailure(message: exception.message, code: exception.code);
  }
}
