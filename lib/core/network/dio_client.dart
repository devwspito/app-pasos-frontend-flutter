import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import 'api_interceptor.dart';
import 'network_info.dart';

/// A singleton HTTP client built on Dio with interceptors for authentication,
/// logging, and error handling.
///
/// This class provides a centralized HTTP client for the entire application.
/// It includes:
/// - Automatic authentication header injection
/// - Request/response logging (when enabled)
/// - Automatic retry for failed network requests
/// - Network connectivity checking
///
/// Usage:
/// ```dart
/// final client = DioClient();
/// final response = await client.get('/users');
/// ```
class DioClient {
  static DioClient? _instance;
  late final Dio _dio;
  late final AuthInterceptor _authInterceptor;
  late final NetworkInfo _networkInfo;

  /// Private constructor for singleton pattern.
  DioClient._internal() {
    _authInterceptor = AuthInterceptor();
    _networkInfo = NetworkInfoImpl();

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors in order: auth first, then logging, then retry
    _dio.interceptors.addAll([
      _authInterceptor,
      if (AppConfig.enableLogging) LoggingInterceptor(),
      RetryInterceptor(dio: _dio),
    ]);
  }

  /// Factory constructor that returns the singleton instance.
  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  /// Resets the singleton instance.
  ///
  /// Call this method when you need to reinitialize the client with
  /// different configuration, such as after environment changes.
  static void reset() {
    _instance = null;
  }

  /// Returns the underlying Dio instance.
  ///
  /// Use this for advanced Dio operations not covered by the convenience methods.
  Dio get dio => _dio;

  /// Returns the network info service for checking connectivity.
  NetworkInfo get networkInfo => _networkInfo;

  /// Returns the auth interceptor for external token management.
  AuthInterceptor get authInterceptor => _authInterceptor;

  /// Sets the authentication tokens for subsequent requests.
  ///
  /// [accessToken] - The JWT access token
  /// [refreshToken] - The refresh token for token renewal
  void setTokens({String? accessToken, String? refreshToken}) {
    _authInterceptor.setTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Clears all authentication tokens.
  ///
  /// Call this when the user logs out or tokens become invalid.
  void clearTokens() {
    _authInterceptor.clearTokens();
  }

  /// Returns true if authentication tokens are currently set.
  bool get hasTokens => _authInterceptor.hasToken;

  /// Checks if the device is currently connected to a network.
  Future<bool> get isConnected => _networkInfo.isConnected;

  /// Performs a GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
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
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
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
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
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
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
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
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Performs a multipart form data upload.
  Future<Response<T>> upload<T>(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    return _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  /// Downloads a file from the given URL.
  Future<Response> download(
    String urlPath,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    return _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );
  }
}
