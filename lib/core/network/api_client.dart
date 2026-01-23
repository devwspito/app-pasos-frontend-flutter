import 'package:dio/dio.dart';

/// A type-safe wrapper around [Dio] HTTP client.
///
/// Provides typed methods for common HTTP operations (GET, POST, PUT, DELETE).
/// Use this class instead of accessing Dio directly in application code.
///
/// Example:
/// ```dart
/// final response = await apiClient.get<Map<String, dynamic>>('/users/1');
/// print(response.data);
/// ```
class ApiClient {
  final Dio _dio;

  /// Creates an [ApiClient] with the provided [Dio] instance.
  ///
  /// The Dio instance should be configured with base URL and interceptors
  /// through [NetworkModule].
  ApiClient(this._dio);

  /// The underlying Dio instance.
  ///
  /// Avoid using this directly unless absolutely necessary.
  /// Prefer using the typed methods instead.
  Dio get dio => _dio;

  /// Performs a GET request to the specified [path].
  ///
  /// [path] - The endpoint path (relative to base URL).
  /// [queryParameters] - Optional query parameters to append to the URL.
  /// [options] - Optional request configuration overrides.
  ///
  /// Returns a [Response] with typed data.
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.get<List<dynamic>>(
  ///   '/users',
  ///   queryParameters: {'page': 1, 'limit': 10},
  /// );
  /// ```
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a POST request to the specified [path].
  ///
  /// [path] - The endpoint path (relative to base URL).
  /// [data] - The request body data.
  /// [queryParameters] - Optional query parameters to append to the URL.
  /// [options] - Optional request configuration overrides.
  ///
  /// Returns a [Response] with typed data.
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.post<Map<String, dynamic>>(
  ///   '/users',
  ///   data: {'name': 'John', 'email': 'john@example.com'},
  /// );
  /// ```
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a PUT request to the specified [path].
  ///
  /// [path] - The endpoint path (relative to base URL).
  /// [data] - The request body data.
  /// [queryParameters] - Optional query parameters to append to the URL.
  /// [options] - Optional request configuration overrides.
  ///
  /// Returns a [Response] with typed data.
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.put<Map<String, dynamic>>(
  ///   '/users/1',
  ///   data: {'name': 'John Updated'},
  /// );
  /// ```
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a DELETE request to the specified [path].
  ///
  /// [path] - The endpoint path (relative to base URL).
  /// [data] - Optional request body data.
  /// [queryParameters] - Optional query parameters to append to the URL.
  /// [options] - Optional request configuration overrides.
  ///
  /// Returns a [Response] with typed data.
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.delete<void>('/users/1');
  /// ```
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a PATCH request to the specified [path].
  ///
  /// [path] - The endpoint path (relative to base URL).
  /// [data] - The request body data.
  /// [queryParameters] - Optional query parameters to append to the URL.
  /// [options] - Optional request configuration overrides.
  ///
  /// Returns a [Response] with typed data.
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.patch<Map<String, dynamic>>(
  ///   '/users/1',
  ///   data: {'status': 'active'},
  /// );
  /// ```
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
