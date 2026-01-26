import 'dart:io';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

/// HTTP client wrapper for making API requests.
///
/// Wraps Dio to provide a clean, type-safe interface for API communication.
/// Handles error conversion, timeout configuration, and response parsing.
///
/// Example:
/// ```dart
/// final apiClient = ApiClient(
///   baseUrl: 'https://api.example.com',
///   interceptors: [authInterceptor, loggingInterceptor],
/// );
///
/// final response = await apiClient.get<User>(
///   '/users/me',
///   fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
/// );
/// ```
class ApiClient {
  /// The underlying Dio instance
  final Dio _dio;

  /// Creates an [ApiClient] with the given configuration.
  ///
  /// [baseUrl] is the base URL for all requests.
  /// [interceptors] are optional Dio interceptors to add.
  /// [connectTimeout] is the connection timeout (default from AppConfig).
  /// [receiveTimeout] is the receive timeout (default from AppConfig).
  ApiClient({
    required String baseUrl,
    List<Interceptor>? interceptors,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: connectTimeout ?? _getDefaultConnectTimeout(),
            receiveTimeout: receiveTimeout ?? _getDefaultReceiveTimeout(),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    // Add provided interceptors
    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  /// Creates an [ApiClient] using the app configuration.
  ///
  /// This is the recommended way to create an ApiClient in production.
  ///
  /// Example:
  /// ```dart
  /// final apiClient = ApiClient.fromConfig(
  ///   interceptors: [authInterceptor],
  /// );
  /// ```
  factory ApiClient.fromConfig({
    List<Interceptor>? interceptors,
  }) {
    final config = AppConfig.instance;
    return ApiClient(
      baseUrl: config.baseUrl,
      interceptors: interceptors,
      connectTimeout: config.connectTimeoutDuration,
      receiveTimeout: config.receiveTimeoutDuration,
    );
  }

  /// Gets the default connect timeout from AppConfig or fallback.
  static Duration _getDefaultConnectTimeout() {
    try {
      if (AppConfig.instance.isInitialized) {
        return AppConfig.instance.connectTimeoutDuration;
      }
    } catch (_) {}
    return const Duration(seconds: 30);
  }

  /// Gets the default receive timeout from AppConfig or fallback.
  static Duration _getDefaultReceiveTimeout() {
    try {
      if (AppConfig.instance.isInitialized) {
        return AppConfig.instance.receiveTimeoutDuration;
      }
    } catch (_) {}
    return const Duration(seconds: 30);
  }

  /// The underlying Dio instance for advanced usage.
  Dio get dio => _dio;

  /// Performs a GET request.
  ///
  /// [path] is the endpoint path (appended to baseUrl).
  /// [queryParameters] are optional URL query parameters.
  /// [fromJson] is used to deserialize the response data.
  /// [cancelToken] can be used to cancel the request.
  ///
  /// Returns an [ApiResponse] containing the parsed data.
  /// Throws an [ApiException] subclass on error.
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.get<User>(
  ///   '/users/me',
  ///   fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
  /// );
  /// ```
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    return _executeRequest<T>(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      ),
      fromJson: fromJson,
    );
  }

  /// Performs a POST request.
  ///
  /// [path] is the endpoint path (appended to baseUrl).
  /// [data] is the request body (will be JSON encoded).
  /// [queryParameters] are optional URL query parameters.
  /// [fromJson] is used to deserialize the response data.
  /// [cancelToken] can be used to cancel the request.
  ///
  /// Returns an [ApiResponse] containing the parsed data.
  /// Throws an [ApiException] subclass on error.
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.post<AuthResponse>(
  ///   '/auth/login',
  ///   data: {'email': email, 'password': password},
  ///   fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
  /// );
  /// ```
  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    return _executeRequest<T>(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      ),
      fromJson: fromJson,
    );
  }

  /// Performs a PUT request.
  ///
  /// [path] is the endpoint path (appended to baseUrl).
  /// [data] is the request body (will be JSON encoded).
  /// [queryParameters] are optional URL query parameters.
  /// [fromJson] is used to deserialize the response data.
  /// [cancelToken] can be used to cancel the request.
  ///
  /// Returns an [ApiResponse] containing the parsed data.
  /// Throws an [ApiException] subclass on error.
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.put<User>(
  ///   '/users/${user.id}',
  ///   data: user.toJson(),
  ///   fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
  /// );
  /// ```
  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    return _executeRequest<T>(
      () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      ),
      fromJson: fromJson,
    );
  }

  /// Performs a DELETE request.
  ///
  /// [path] is the endpoint path (appended to baseUrl).
  /// [data] is the optional request body.
  /// [queryParameters] are optional URL query parameters.
  /// [fromJson] is used to deserialize the response data.
  /// [cancelToken] can be used to cancel the request.
  ///
  /// Returns an [ApiResponse] containing the parsed data.
  /// Throws an [ApiException] subclass on error.
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.delete<void>(
  ///   '/users/${user.id}',
  ///   fromJson: (_) => null,
  /// );
  /// ```
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    return _executeRequest<T>(
      () => _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      ),
      fromJson: fromJson,
    );
  }

  /// Performs a PATCH request.
  ///
  /// [path] is the endpoint path (appended to baseUrl).
  /// [data] is the request body (will be JSON encoded).
  /// [queryParameters] are optional URL query parameters.
  /// [fromJson] is used to deserialize the response data.
  /// [cancelToken] can be used to cancel the request.
  ///
  /// Returns an [ApiResponse] containing the parsed data.
  /// Throws an [ApiException] subclass on error.
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.patch<User>(
  ///   '/users/${user.id}',
  ///   data: {'name': 'New Name'},
  ///   fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
  /// );
  /// ```
  Future<ApiResponse<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    return _executeRequest<T>(
      () => _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      ),
      fromJson: fromJson,
    );
  }

  /// Uploads a file using multipart/form-data.
  ///
  /// [path] is the endpoint path.
  /// [file] is the file to upload.
  /// [fieldName] is the form field name for the file.
  /// [data] is optional additional form data.
  /// [fromJson] is used to deserialize the response data.
  /// [onSendProgress] callback for upload progress.
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.uploadFile<FileUploadResponse>(
  ///   '/files/upload',
  ///   file: File('/path/to/file.jpg'),
  ///   fieldName: 'image',
  ///   fromJson: (json) => FileUploadResponse.fromJson(json as Map<String, dynamic>),
  ///   onSendProgress: (sent, total) {
  ///     print('Upload progress: ${(sent / total * 100).toStringAsFixed(1)}%');
  ///   },
  /// );
  /// ```
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required File file,
    String fieldName = 'file',
    Map<String, dynamic>? data,
    required T Function(Object? json) fromJson,
    void Function(int sent, int total)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(file.path, filename: fileName),
      if (data != null) ...data,
    });

    return _executeRequest<T>(
      () => _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      ),
      fromJson: fromJson,
    );
  }

  /// Downloads a file from the server.
  ///
  /// [urlPath] is the file URL path.
  /// [savePath] is the local path to save the file.
  /// [onReceiveProgress] callback for download progress.
  ///
  /// Example:
  /// ```dart
  /// await apiClient.downloadFile(
  ///   '/files/document.pdf',
  ///   savePath: '/path/to/save/document.pdf',
  ///   onReceiveProgress: (received, total) {
  ///     print('Download progress: ${(received / total * 100).toStringAsFixed(1)}%');
  ///   },
  /// );
  /// ```
  Future<void> downloadFile(
    String urlPath, {
    required String savePath,
    void Function(int received, int total)? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _convertDioException(e);
    }
  }

  /// Executes a request and handles the response/errors.
  Future<ApiResponse<T>> _executeRequest<T>(
    Future<Response<dynamic>> Function() request, {
    required T Function(Object? json) fromJson,
  }) async {
    try {
      final response = await request();
      return _parseResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _convertDioException(e);
    } on SocketException catch (e) {
      throw NetworkException(
        'No internet connection',
        cause: e,
      );
    } catch (e) {
      throw ApiException(
        'An unexpected error occurred: $e',
        cause: e,
      );
    }
  }

  /// Parses a successful response into an ApiResponse.
  ApiResponse<T> _parseResponse<T>(
    Response<dynamic> response,
    T Function(Object? json) fromJson,
  ) {
    final data = response.data;

    // If response is already a Map with our expected structure
    if (data is Map<String, dynamic>) {
      // Check if it matches our ApiResponse structure
      if (data.containsKey('success')) {
        return ApiResponse<T>.fromJson(data, fromJson);
      }

      // If not, wrap the data in a success response
      return ApiResponse<T>(
        success: true,
        data: fromJson(data),
      );
    }

    // For non-map responses, wrap in a success response
    return ApiResponse<T>(
      success: true,
      data: data != null ? fromJson(data) : null,
    );
  }

  /// Converts a DioException to an appropriate ApiException.
  ApiException _convertDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return NetworkException(
          'Unable to connect to server. Please check your internet connection.',
          cause: e,
        );

      case DioExceptionType.connectionTimeout:
        return TimeoutException(
          'Connection timed out. Please try again.',
          cause: e,
        );

      case DioExceptionType.sendTimeout:
        return TimeoutException(
          'Request timed out while sending data. Please try again.',
          cause: e,
        );

      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          'Server took too long to respond. Please try again.',
          cause: e,
        );

      case DioExceptionType.cancel:
        return CancelledException(
          'Request was cancelled.',
          cause: e,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(e);

      case DioExceptionType.badCertificate:
        return NetworkException(
          'SSL certificate error. Please check your connection.',
          cause: e,
        );

      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException) {
          return NetworkException(
            'No internet connection',
            cause: e,
          );
        }
        return ApiException(
          e.message ?? 'An unexpected error occurred',
          cause: e,
        );
    }
  }

  /// Handles bad response (4xx/5xx) errors.
  ApiException _handleBadResponse(DioException e) {
    final statusCode = e.response?.statusCode ?? 0;
    final responseData = e.response?.data;

    // Extract error message from response
    String message = 'An error occurred';
    List<FieldError> validationErrors = [];

    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] as String? ?? message;

      // Extract validation errors if present
      final errors = responseData['errors'];
      if (errors is List) {
        validationErrors = errors
            .whereType<Map<String, dynamic>>()
            .map((e) => FieldError.fromJson(e))
            .toList();
      }
    } else if (responseData is String && responseData.isNotEmpty) {
      message = responseData;
    }

    // Map status codes to specific exceptions
    switch (statusCode) {
      case 400:
        return ValidationException(
          message,
          errors: validationErrors,
          cause: e,
        );

      case 401:
        return UnauthorizedException(
          message,
          cause: e,
        );

      case 403:
        return ForbiddenException(
          message,
          cause: e,
        );

      case 404:
        return NotFoundException(
          message,
          cause: e,
        );

      case 409:
        return ConflictException(
          message,
          cause: e,
        );

      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message,
          statusCode: statusCode,
          cause: e,
        );

      default:
        if (statusCode >= 500) {
          return ServerException(
            message,
            statusCode: statusCode,
            cause: e,
          );
        }
        return ApiException(
          message,
          statusCode: statusCode,
          cause: e,
        );
    }
  }

  /// Sets a default header that will be sent with all requests.
  void setHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// Removes a default header.
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Clears all default headers.
  void clearHeaders() {
    _dio.options.headers.clear();
  }

  /// Closes the client and cancels any pending requests.
  void close({bool force = false}) {
    _dio.close(force: force);
  }
}
