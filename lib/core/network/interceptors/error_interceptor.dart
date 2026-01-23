import 'package:dio/dio.dart';

import '../../errors/app_exception.dart';
import '../../utils/logger.dart';

/// Interceptor for converting DioException to domain-specific AppException.
///
/// Centralizes error handling and ensures consistent error transformation
/// throughout the application. Uses the existing AppException.fromDioException
/// factory for type-safe error mapping.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Convert DioException to AppException using existing factory
    final appException = AppException.fromDioException(err);

    // Log the error for debugging
    AppLogger.e(
      'API Error: ${appException.message}',
      err,
      err.stackTrace,
    );

    // Reject with the converted exception
    // We wrap it back in a DioException to maintain Dio's error flow,
    // but attach our AppException for easy retrieval
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: appException,
        stackTrace: err.stackTrace,
        message: appException.message,
      ),
    );
  }
}

/// Extension on DioException to easily extract AppException.
extension DioExceptionExtension on DioException {
  /// Gets the AppException from this DioException.
  ///
  /// If the error was processed by ErrorInterceptor, returns the attached
  /// AppException. Otherwise, creates a new one from the DioException.
  AppException get appException {
    if (error is AppException) {
      return error as AppException;
    }
    return AppException.fromDioException(this);
  }
}
