import 'package:dio/dio.dart';

import '../errors/app_exception.dart';
import '../utils/logger.dart';
import 'api_endpoints.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Configuration options for the API client.
class ApiClientConfig {
  /// Base URL for all API requests.
  final String baseUrl;

  /// Connection timeout in milliseconds.
  final Duration connectTimeout;

  /// Request timeout in milliseconds.
  final Duration receiveTimeout;

  /// Send timeout in milliseconds.
  final Duration sendTimeout;

  const ApiClientConfig({
    this.baseUrl = ApiEndpoints.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
  });
}

/// HTTP client wrapper providing typed request methods.
///
/// Wraps Dio with interceptors for authentication, error handling, and logging.
/// Provides type-safe methods for common HTTP operations.
///
/// Usage:
/// ```dart
/// final client = ApiClient(
///   config: ApiClientConfig(baseUrl: 'https://api.example.com'),
///   tokenStorage: myTokenStorage,
/// );
///
/// // GET request
/// final response = await client.get<Map<String, dynamic>>(
///   ApiEndpoints.userProfile,
/// );
///
/// // POST request with body
/// final response = await client.post<Map<String, dynamic>>(
///   ApiEndpoints.login,
///   data: {'email': 'user@example.com', 'password': 'secret'},
/// );
/// ```
class ApiClient {
  late final Dio _dio;
  final ApiClientConfig config;
  final TokenStorage? _tokenStorage;

  ApiClient({
    this.config = const ApiClientConfig(),
    TokenStorage? tokenStorage,
  }) : _tokenStorage = tokenStorage {
    _dio = _createDio();
    _setupInterceptors();
  }

  /// Creates and configures the Dio instance.
  Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Accept all status codes to handle them in interceptors
          return status != null && status < 500;
        },
      ),
    );
  }

  /// Sets up interceptors in the correct order.
  ///
  /// Order matters:
  /// 1. Logging (first to log raw requests)
  /// 2. Auth (add token before sending)
  /// 3. Error (last to catch and transform errors)
  void _setupInterceptors() {
    // Logging interceptor (only logs in development)
    _dio.interceptors.add(LoggingInterceptor());

    // Auth interceptor (if token storage is provided)
    if (_tokenStorage != null) {
      _dio.interceptors.add(AuthInterceptor(tokenStorage: _tokenStorage));
    }

    // Error interceptor (converts DioException to AppException)
    _dio.interceptors.add(ErrorInterceptor());
  }

  /// Exposes the underlying Dio instance for advanced use cases.
  ///
  /// Use with caution - prefer the typed methods when possible.
  Dio get dio => _dio;

  /// Performs a GET request.
  ///
  /// [path] - API endpoint path (can be relative or absolute).
  /// [queryParameters] - Optional query parameters.
  /// [options] - Optional Dio request options.
  /// [cancelToken] - Optional cancellation token.
  ///
  /// Returns the response data.
  /// Throws [AppException] on error.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: _addRequestTime(options),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  /// Performs a POST request.
  ///
  /// [path] - API endpoint path.
  /// [data] - Request body (will be JSON encoded).
  /// [queryParameters] - Optional query parameters.
  /// [options] - Optional Dio request options.
  /// [cancelToken] - Optional cancellation token.
  ///
  /// Returns the response data.
  /// Throws [AppException] on error.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _addRequestTime(options),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  /// Performs a PUT request.
  ///
  /// [path] - API endpoint path.
  /// [data] - Request body (will be JSON encoded).
  /// [queryParameters] - Optional query parameters.
  /// [options] - Optional Dio request options.
  /// [cancelToken] - Optional cancellation token.
  ///
  /// Returns the response data.
  /// Throws [AppException] on error.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _addRequestTime(options),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  /// Performs a PATCH request.
  ///
  /// [path] - API endpoint path.
  /// [data] - Request body (will be JSON encoded).
  /// [queryParameters] - Optional query parameters.
  /// [options] - Optional Dio request options.
  /// [cancelToken] - Optional cancellation token.
  ///
  /// Returns the response data.
  /// Throws [AppException] on error.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _addRequestTime(options),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  /// Performs a DELETE request.
  ///
  /// [path] - API endpoint path.
  /// [data] - Optional request body.
  /// [queryParameters] - Optional query parameters.
  /// [options] - Optional Dio request options.
  /// [cancelToken] - Optional cancellation token.
  ///
  /// Returns the response data.
  /// Throws [AppException] on error.
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
        options: _addRequestTime(options),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  /// Performs a multipart file upload request.
  ///
  /// [path] - API endpoint path.
  /// [data] - FormData containing files and fields.
  /// [onSendProgress] - Optional callback for upload progress.
  /// [cancelToken] - Optional cancellation token.
  ///
  /// Returns the response data.
  /// Throws [AppException] on error.
  Future<Response<T>> upload<T>(
    String path, {
    required FormData data,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        options: _addRequestTime(Options(
          headers: {'Content-Type': 'multipart/form-data'},
        )),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  /// Performs a file download request.
  ///
  /// [path] - API endpoint path or full URL.
  /// [savePath] - Local path to save the downloaded file.
  /// [onReceiveProgress] - Optional callback for download progress.
  /// [cancelToken] - Optional cancellation token.
  ///
  /// Returns the response.
  /// Throws [AppException] on error.
  Future<Response> download(
    String path, {
    required String savePath,
    void Function(int, int)? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  /// Adds request timestamp to options for logging purposes.
  Options _addRequestTime(Options? options) {
    final opts = options ?? Options();
    opts.extra = {...?opts.extra, 'requestTime': DateTime.now()};
    return opts;
  }

  /// Cancels all pending requests.
  void cancelAllRequests() {
    AppLogger.w('Cancelling all pending API requests');
    _dio.close(force: true);
  }

  /// Converts DioException to AppException.
  ///
  /// Uses the extension from error_interceptor.dart for consistency.
  AppException _toAppException(DioException e) {
    return DioExceptionExtension(e).appException;
  }
}
