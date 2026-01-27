import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';
import 'api_interceptor.dart';

/// HTTP client wrapper around Dio with authentication support.
///
/// Provides a configured Dio instance with:
/// - Automatic token injection via [ApiInterceptor]
/// - Automatic token refresh on 401 responses
/// - Proper error mapping to [AppException] hierarchy
/// - Configurable timeouts from [AppConstants]
///
/// Usage:
/// ```dart
/// final client = DioClient(secureStorage: FlutterSecureStorage());
///
/// // Make authenticated requests
/// final response = await client.get('/users/me');
///
/// // Access token management
/// await client.apiInterceptor.saveTokens(accessToken, refreshToken);
/// await client.apiInterceptor.clearTokens();
/// ```
class DioClient {
  late final Dio _dio;
  late final ApiInterceptor _apiInterceptor;

  /// Creates a DioClient with the provided secure storage.
  ///
  /// [secureStorage] - FlutterSecureStorage instance for token persistence
  DioClient({required FlutterSecureStorage secureStorage}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.defaultTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.defaultTimeout),
        sendTimeout: const Duration(milliseconds: AppConstants.defaultTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _apiInterceptor = ApiInterceptor(
      secureStorage: secureStorage,
      dio: _dio,
    );

    _dio.interceptors.add(_apiInterceptor);
  }

  /// Access the API interceptor for token management.
  ///
  /// Use this to:
  /// - Save tokens after login: `apiInterceptor.saveTokens(access, refresh)`
  /// - Clear tokens on logout: `apiInterceptor.clearTokens()`
  /// - Check authentication status: `apiInterceptor.hasValidToken()`
  ApiInterceptor get apiInterceptor => _apiInterceptor;

  /// The underlying Dio instance (for advanced use cases).
  Dio get dio => _dio;

  /// Performs a GET request.
  ///
  /// [path] - The endpoint path (relative to baseUrl)
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional Dio request options
  ///
  /// Throws [AppException] on error.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Performs a POST request.
  ///
  /// [path] - The endpoint path (relative to baseUrl)
  /// [data] - Request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional Dio request options
  ///
  /// Throws [AppException] on error.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Performs a PUT request.
  ///
  /// [path] - The endpoint path (relative to baseUrl)
  /// [data] - Request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional Dio request options
  ///
  /// Throws [AppException] on error.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Performs a PATCH request.
  ///
  /// [path] - The endpoint path (relative to baseUrl)
  /// [data] - Request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional Dio request options
  ///
  /// Throws [AppException] on error.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Performs a DELETE request.
  ///
  /// [path] - The endpoint path (relative to baseUrl)
  /// [data] - Optional request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional Dio request options
  ///
  /// Throws [AppException] on error.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Maps Dio exceptions to the application's exception hierarchy.
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
          code: 'TIMEOUT',
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'No internet connection. Please check your network.',
          code: 'NO_CONNECTION',
          originalError: error,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request was cancelled.',
          code: 'CANCELLED',
          originalError: error,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Certificate verification failed.',
          code: 'BAD_CERTIFICATE',
          originalError: error,
        );

      case DioExceptionType.unknown:
      default:
        return NetworkException(
          message: error.message ?? 'An unexpected network error occurred.',
          code: 'UNKNOWN',
          originalError: error,
        );
    }
  }

  /// Handles HTTP error responses (4xx, 5xx).
  AppException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Extract error message from response
    String? message;
    if (data is Map) {
      message = data['message'] as String? ??
          data['error'] as String? ??
          data['errors']?.toString();
    } else if (data is String) {
      message = data;
    }

    // Handle specific status codes
    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message ?? 'Bad request. Please check your input.',
          code: 'BAD_REQUEST',
          originalError: error,
        );

      case 401:
        return AuthException(
          message: message ?? 'Unauthorized. Please login again.',
          code: 'UNAUTHORIZED',
          originalError: error,
        );

      case 403:
        return AuthException(
          message: message ?? 'Access forbidden. You do not have permission.',
          code: 'FORBIDDEN',
          originalError: error,
        );

      case 404:
        return ServerException(
          message: message ?? 'Resource not found.',
          code: 'NOT_FOUND',
          statusCode: statusCode,
          originalError: error,
        );

      case 422:
        return ValidationException(
          message: message ?? 'Validation failed. Please check your input.',
          code: 'VALIDATION_ERROR',
          originalError: error,
        );

      case 429:
        return ServerException(
          message: message ?? 'Too many requests. Please try again later.',
          code: 'RATE_LIMITED',
          statusCode: statusCode,
          originalError: error,
        );

      case 500:
        return ServerException(
          message: message ?? 'Internal server error. Please try again later.',
          code: 'INTERNAL_ERROR',
          statusCode: statusCode,
          originalError: error,
        );

      case 502:
      case 503:
      case 504:
        return ServerException(
          message: message ?? 'Service temporarily unavailable. Please try again later.',
          code: 'SERVICE_UNAVAILABLE',
          statusCode: statusCode,
          originalError: error,
        );

      default:
        return ServerException(
          message: message ?? 'Server error occurred.',
          code: 'SERVER_ERROR',
          statusCode: statusCode,
          originalError: error,
        );
    }
  }
}
