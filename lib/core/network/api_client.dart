/// HTTP client for API communication in App Pasos.
///
/// This file provides a configured Dio instance with interceptors for
/// authentication, logging, and error handling. All network requests
/// should go through this client.
library;

import 'package:app_pasos_frontend/core/constants/app_constants.dart';
import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/core/network/api_endpoints.dart';
import 'package:app_pasos_frontend/core/network/api_interceptors.dart';
import 'package:app_pasos_frontend/core/storage/secure_storage_service.dart';
import 'package:dio/dio.dart';

/// HTTP client wrapper around Dio for making API requests.
///
/// This class provides a pre-configured Dio instance with:
/// - Base URL from environment configuration
/// - Proper timeout settings
/// - Authentication token injection
/// - Request/response logging
/// - Error transformation to [AppException] types
///
/// Example usage:
/// ```dart
/// final client = ApiClient(storage: secureStorage);
///
/// // GET request
/// final response = await client.get<Map<String, dynamic>>('/users/profile');
///
/// // POST request with data
/// final loginResponse = await client.post<Map<String, dynamic>>(
///   '/auth/login',
///   data: {'email': 'user@example.com', 'password': 'secret'},
/// );
/// ```
class ApiClient {
  /// Creates an [ApiClient] with the given storage service.
  ///
  /// The [storage] parameter is required for auth token management.
  /// Optionally provide [enableLogging] to control request/response logging.
  /// Optionally provide [enableTokenRefresh] to enable automatic token refresh.
  ApiClient({
    required SecureStorageService storage,
    bool enableLogging = true,
    bool enableTokenRefresh = true,
  }) : _storage = storage {
    _dio = _createDio(
      enableLogging: enableLogging,
      enableTokenRefresh: enableTokenRefresh,
    );
  }

  /// The secure storage service for token management.
  final SecureStorageService _storage;

  /// The underlying Dio instance.
  late final Dio _dio;

  /// Creates and configures the Dio instance.
  Dio _createDio({
    required bool enableLogging,
    required bool enableTokenRefresh,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.connectionTimeout,
        headers: {
          ApiHeaders.contentType: ContentTypes.json,
          ApiHeaders.accept: ContentTypes.json,
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add interceptors in order of execution
    // 1. Auth interceptor (adds token to requests)
    dio.interceptors.add(AuthInterceptor(_storage));

    // 2. Logging interceptor (for debugging)
    if (enableLogging) {
      dio.interceptors.add(LoggingInterceptor());
    }

    // 3. Token refresh interceptor (handles 401 responses)
    if (enableTokenRefresh) {
      dio.interceptors.add(
        TokenRefreshInterceptor(storage: _storage, dio: dio),
      );
    }

    // 4. Error interceptor (transforms errors to AppException)
    dio.interceptors.add(ErrorInterceptor());

    return dio;
  }

  /// Returns the underlying Dio instance for advanced use cases.
  ///
  /// Use this only when the standard methods don't meet your needs.
  Dio get dio => _dio;

  // ============================================================
  // HTTP Methods
  // ============================================================

  /// Performs a GET request to the specified [path].
  ///
  /// [path] - The endpoint path (relative to base URL).
  /// [queryParameters] - Optional query parameters to append.
  /// [options] - Optional request options for customization.
  /// [cancelToken] - Optional token to cancel the request.
  ///
  /// Returns a [Response] with the response data.
  /// Throws [AppException] on errors.
  ///
  /// Example:
  /// ```dart
  /// final response = await client.get<Map<String, dynamic>>(
  ///   '/users/profile',
  ///   queryParameters: {'include': 'settings'},
  /// );
  /// ```
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _extractAppException(e);
    }
  }

  /// Performs a POST request to the specified [path].
  ///
  /// [path] - The endpoint path (relative to base URL).
  /// [data] - The request body data (will be JSON encoded).
  /// [queryParameters] - Optional query parameters to append.
  /// [options] - Optional request options for customization.
  /// [cancelToken] - Optional token to cancel the request.
  ///
  /// Returns a [Response] with the response data.
  /// Throws [AppException] on errors.
  ///
  /// Example:
  /// ```dart
  /// final response = await client.post<Map<String, dynamic>>(
  ///   '/auth/login',
  ///   data: {'email': 'user@example.com', 'password': 'secret'},
  /// );
  /// ```
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _extractAppException(e);
    }
  }

  /// Performs a PUT request to the specified [path].
  ///
  /// [path] - The endpoint path (relative to base URL).
  /// [data] - The request body data (will be JSON encoded).
  /// [queryParameters] - Optional query parameters to append.
  /// [options] - Optional request options for customization.
  /// [cancelToken] - Optional token to cancel the request.
  ///
  /// Returns a [Response] with the response data.
  /// Throws [AppException] on errors.
  ///
  /// Example:
  /// ```dart
  /// final response = await client.put<Map<String, dynamic>>(
  ///   '/users/profile',
  ///   data: {'name': 'New Name'},
  /// );
  /// ```
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _extractAppException(e);
    }
  }

  /// Performs a PATCH request to the specified [path].
  ///
  /// [path] - The endpoint path (relative to base URL).
  /// [data] - The request body data (will be JSON encoded).
  /// [queryParameters] - Optional query parameters to append.
  /// [options] - Optional request options for customization.
  /// [cancelToken] - Optional token to cancel the request.
  ///
  /// Returns a [Response] with the response data.
  /// Throws [AppException] on errors.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _extractAppException(e);
    }
  }

  /// Performs a DELETE request to the specified [path].
  ///
  /// [path] - The endpoint path (relative to base URL).
  /// [data] - Optional request body data.
  /// [queryParameters] - Optional query parameters to append.
  /// [options] - Optional request options for customization.
  /// [cancelToken] - Optional token to cancel the request.
  ///
  /// Returns a [Response] with the response data.
  /// Throws [AppException] on errors.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _extractAppException(e);
    }
  }

  // ============================================================
  // Multipart Upload
  // ============================================================

  /// Uploads a file using multipart/form-data.
  ///
  /// [path] - The endpoint path (relative to base URL).
  /// [file] - The file data as bytes.
  /// [filename] - The filename to send to the server.
  /// [fieldName] - The form field name (default: 'file').
  /// [additionalData] - Additional form data to include.
  /// [onSendProgress] - Callback for upload progress.
  ///
  /// Returns a [Response] with the response data.
  /// Throws [AppException] on errors.
  Future<Response<T>> uploadFile<T>(
    String path, {
    required List<int> file,
    required String filename,
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: MultipartFile.fromBytes(file, filename: filename),
        if (additionalData != null) ...additionalData,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        options: Options(
          contentType: ContentTypes.multipartFormData,
        ),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _extractAppException(e);
    }
  }

  // ============================================================
  // Request Cancellation
  // ============================================================

  /// Creates a [CancelToken] for request cancellation.
  ///
  /// Use this to cancel ongoing requests:
  /// ```dart
  /// final cancelToken = client.createCancelToken();
  /// client.get('/data', cancelToken: cancelToken);
  ///
  /// // Later, to cancel:
  /// cancelToken.cancel('User cancelled');
  /// ```
  CancelToken createCancelToken() => CancelToken();

  // ============================================================
  // Error Handling
  // ============================================================

  /// Extracts [AppException] from a [DioException].
  ///
  /// The error interceptor attaches the [AppException] to the error field,
  /// so we extract it here for proper error handling.
  AppException _extractAppException(DioException e) {
    if (e.error is AppException) {
      return e.error! as AppException;
    }

    // Fallback if error wasn't transformed (shouldn't happen)
    return NetworkException(
      message: e.message ?? 'An unexpected error occurred',
      code: 'UNKNOWN',
      originalError: e,
      stackTrace: e.stackTrace,
    );
  }

  // ============================================================
  // Configuration
  // ============================================================

  /// Gets the current base URL.
  String get baseUrl => _dio.options.baseUrl;

  /// Updates the base URL for all future requests.
  ///
  /// Use this to switch between environments (dev, staging, prod).
  set baseUrl(String value) => _dio.options.baseUrl = value;

  /// Adds a custom interceptor to the client.
  ///
  /// Custom interceptors are added after the built-in ones.
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Removes all interceptors from the client.
  ///
  /// Use with caution - this removes auth, logging, and error handling.
  void clearInterceptors() {
    _dio.interceptors.clear();
  }
}
