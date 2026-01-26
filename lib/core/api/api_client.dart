/// Dio HTTP client wrapper for API communication.
///
/// Provides a configured Dio instance with:
/// - Base URL and timeout configuration
/// - Authentication interceptor for JWT tokens
/// - Logging interceptor for debugging
/// - Error interceptor for consistent error handling
/// - Optional retry interceptor for resilience
library;

import 'package:dio/dio.dart';

import 'api_exceptions.dart';
import 'api_interceptors.dart';

// ============================================================
// API Configuration (will be replaced by app_config module)
// ============================================================

/// API configuration settings.
///
/// This class provides configuration values for the API client.
/// In production, these values should come from AppConfig.
class ApiConfig {
  /// Base URL for API requests.
  final String baseUrl;

  /// Connection timeout in milliseconds.
  final Duration connectTimeout;

  /// Receive timeout in milliseconds.
  final Duration receiveTimeout;

  /// Send timeout in milliseconds.
  final Duration sendTimeout;

  /// Whether to enable retry interceptor.
  final bool enableRetry;

  /// Creates API configuration.
  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.enableRetry = true,
  });

  /// Default development configuration.
  factory ApiConfig.development() {
    return const ApiConfig(
      baseUrl: 'http://localhost:3000/api/v1',
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
      enableRetry: true,
    );
  }

  /// Default staging configuration.
  factory ApiConfig.staging() {
    return const ApiConfig(
      baseUrl: 'https://staging-api.example.com/api/v1',
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
      enableRetry: true,
    );
  }

  /// Default production configuration.
  factory ApiConfig.production() {
    return const ApiConfig(
      baseUrl: 'https://api.example.com/api/v1',
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
      enableRetry: true,
    );
  }
}

// ============================================================
// API Response Wrapper
// ============================================================

/// Generic wrapper for API responses.
///
/// Provides a consistent structure for handling API responses
/// with success/failure states.
class ApiResponse<T> {
  /// The response data (null if error occurred).
  final T? data;

  /// Error message (null if successful).
  final String? error;

  /// HTTP status code.
  final int? statusCode;

  /// Whether the request was successful.
  final bool success;

  /// Creates a successful response.
  ApiResponse.success(this.data, {this.statusCode})
      : error = null,
        success = true;

  /// Creates a failed response.
  ApiResponse.failure(this.error, {this.statusCode})
      : data = null,
        success = false;

  /// Creates a response from a Dio Response.
  factory ApiResponse.fromResponse(Response<T> response) {
    return ApiResponse.success(
      response.data,
      statusCode: response.statusCode,
    );
  }

  /// Creates a response from an ApiException.
  factory ApiResponse.fromException(ApiException exception) {
    return ApiResponse.failure(
      exception.message,
      statusCode: exception.statusCode,
    );
  }
}

// ============================================================
// API Client
// ============================================================

/// Main HTTP client for API communication.
///
/// This client wraps Dio and provides a consistent interface
/// for making HTTP requests with proper error handling.
///
/// Usage:
/// ```dart
/// final client = ApiClient(
///   config: ApiConfig.development(),
///   secureStorage: mySecureStorage,
/// );
///
/// final response = await client.get<Map<String, dynamic>>('/users/profile');
/// ```
class ApiClient {
  /// The underlying Dio instance.
  late final Dio _dio;

  /// The secure storage instance for token management.
  final ISecureStorage _secureStorage;

  /// The API configuration.
  final ApiConfig config;

  /// Creates a new [ApiClient] with the given configuration and storage.
  ApiClient({
    required this.config,
    required ISecureStorage secureStorage,
  }) : _secureStorage = secureStorage {
    _dio = _createDio();
    _setupInterceptors();
  }

  /// Factory constructor with default development configuration.
  factory ApiClient.development({
    required ISecureStorage secureStorage,
  }) {
    return ApiClient(
      config: ApiConfig.development(),
      secureStorage: secureStorage,
    );
  }

  /// Creates the Dio instance with base configuration.
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
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  /// Sets up all interceptors in the correct order.
  void _setupInterceptors() {
    // Order matters:
    // 1. Auth first (adds token to requests)
    // 2. Logging (logs requests/responses)
    // 3. Retry (retries failed requests)
    // 4. Error (converts exceptions)

    _dio.interceptors.addAll([
      AuthInterceptor(_secureStorage),
      LoggingInterceptor(
        logRequestBody: false, // Set to true for debugging
        logResponseBody: false, // Set to true for debugging
      ),
      if (config.enableRetry)
        RetryInterceptor(
          dio: _dio,
          options: const RetryOptions(
            maxRetries: 3,
            retryDelayMs: 1000,
          ),
        ),
      ErrorInterceptor(),
    ]);
  }

  /// Exposes the underlying Dio instance for advanced use cases.
  Dio get dio => _dio;

  // ============================================================
  // HTTP Methods
  // ============================================================

  /// Performs a GET request.
  ///
  /// [path] - The endpoint path (will be appended to base URL)
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options override
  ///
  /// Returns the response data of type [T].
  /// Throws [ApiException] on error.
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
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _extractApiException(e);
    }
  }

  /// Performs a POST request.
  ///
  /// [path] - The endpoint path
  /// [data] - Request body (will be JSON encoded)
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options override
  ///
  /// Returns the response data of type [T].
  /// Throws [ApiException] on error.
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
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _extractApiException(e);
    }
  }

  /// Performs a PUT request.
  ///
  /// [path] - The endpoint path
  /// [data] - Request body (will be JSON encoded)
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options override
  ///
  /// Returns the response data of type [T].
  /// Throws [ApiException] on error.
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
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _extractApiException(e);
    }
  }

  /// Performs a PATCH request.
  ///
  /// [path] - The endpoint path
  /// [data] - Request body (will be JSON encoded)
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options override
  ///
  /// Returns the response data of type [T].
  /// Throws [ApiException] on error.
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
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _extractApiException(e);
    }
  }

  /// Performs a DELETE request.
  ///
  /// [path] - The endpoint path
  /// [data] - Optional request body
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options override
  ///
  /// Returns the response data of type [T].
  /// Throws [ApiException] on error.
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
      throw _extractApiException(e);
    }
  }

  // ============================================================
  // Convenience Methods
  // ============================================================

  /// Performs a multipart form data upload.
  ///
  /// [path] - The endpoint path
  /// [formData] - The form data to upload
  /// [onSendProgress] - Optional progress callback
  ///
  /// Returns the response data of type [T].
  /// Throws [ApiException] on error.
  Future<Response<T>> uploadFormData<T>(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
    } on DioException catch (e) {
      throw _extractApiException(e);
    }
  }

  /// Downloads a file from the given URL.
  ///
  /// [urlPath] - The URL or path to download from
  /// [savePath] - Local path to save the file
  /// [onReceiveProgress] - Optional progress callback
  ///
  /// Returns the response.
  /// Throws [ApiException] on error.
  Future<Response> downloadFile(
    String urlPath,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _extractApiException(e);
    }
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Extracts ApiException from DioException.
  ApiException _extractApiException(DioException e) {
    final error = e.error;
    if (error is ApiException) {
      return error;
    }
    return ApiException(
      message: e.message ?? 'An unexpected error occurred',
      statusCode: e.response?.statusCode,
      data: e.response?.data,
    );
  }

  /// Clears authentication tokens and resets client state.
  Future<void> clearAuth() async {
    await _secureStorage.clearAll();
  }

  /// Updates the base URL dynamically.
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Adds a custom header to all requests.
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// Removes a custom header.
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Closes the client and cancels any pending requests.
  void close({bool force = false}) {
    _dio.close(force: force);
  }
}

// ============================================================
// Extension Methods
// ============================================================

/// Extension methods for Response to simplify data extraction.
extension ResponseExtension<T> on Response<T> {
  /// Returns the data, throwing if null.
  T get requireData {
    if (data == null) {
      throw ApiException(message: 'Response data is null');
    }
    return data as T;
  }

  /// Returns true if the response is successful (2xx).
  bool get isSuccess {
    final code = statusCode ?? 0;
    return code >= 200 && code < 300;
  }
}
