import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import 'api_interceptors.dart';

/// HTTP API client wrapper using Dio.
///
/// Configures base URL, timeouts, and interceptors for all API requests.
/// Uses factory constructor to ensure singleton-like behavior when used with DI.
final class ApiClient {
  ApiClient._internal(this._dio);

  /// Factory constructor that creates and configures a new ApiClient instance.
  factory ApiClient({
    required AuthInterceptor authInterceptor,
    required LoggingInterceptor loggingInterceptor,
    required ErrorInterceptor errorInterceptor,
  }) {
    final dio = Dio(_createBaseOptions());

    // Add interceptors in order: Auth → Logging → Error
    dio.interceptors.addAll([
      authInterceptor,
      loggingInterceptor,
      errorInterceptor,
    ]);

    return ApiClient._internal(dio);
  }

  /// The underlying Dio instance.
  final Dio _dio;

  /// Exposes the Dio instance for direct access if needed.
  Dio get dio => _dio;

  /// Creates base options with default configuration.
  static BaseOptions _createBaseOptions() {
    return BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: Duration(
        seconds: AppConstants.httpConnectTimeoutSeconds,
      ),
      receiveTimeout: Duration(
        seconds: AppConstants.httpReceiveTimeoutSeconds,
      ),
      sendTimeout: Duration(
        seconds: AppConstants.httpTimeoutSeconds,
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => status != null && status < 500,
    );
  }

  // ============================================
  // HTTP Methods
  // ============================================

  /// Performs a GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Performs a POST request.
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Performs a PUT request.
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Performs a PATCH request.
  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Performs a DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Downloads a file to the specified path.
  Future<Response> download(
    String urlPath,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _dio.download(
      urlPath,
      savePath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Uploads a file using multipart form data.
  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fileFieldName,
    Map<String, dynamic>? additionalData,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      fileFieldName: await MultipartFile.fromFile(filePath),
      if (additionalData != null) ...additionalData,
    });

    return _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }
}
