import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';

/// Dio interceptor for handling authentication and request/response logging.
///
/// Features:
/// - Automatic token injection on all requests
/// - Automatic token refresh on 401 responses
/// - Request/response logging (when enabled)
/// - Secure token storage using FlutterSecureStorage
///
/// Usage:
/// ```dart
/// final interceptor = ApiInterceptor(
///   secureStorage: FlutterSecureStorage(),
///   dio: Dio(),
/// );
/// dio.interceptors.add(interceptor);
/// ```
class ApiInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;

  /// Flag to prevent recursive refresh attempts
  bool _isRefreshing = false;

  /// Creates an API interceptor with secure storage and Dio instance.
  ///
  /// [secureStorage] - FlutterSecureStorage instance for token persistence
  /// [dio] - Dio instance for making refresh requests
  ApiInterceptor({
    required FlutterSecureStorage secureStorage,
    required Dio dio,
  })  : _secureStorage = secureStorage,
        _dio = dio;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header if explicitly requested (e.g., for refresh token endpoint)
    final skipAuth = options.headers['skipAuthInterceptor'] == true;

    if (!skipAuth) {
      final token = await _secureStorage.read(key: AppConstants.accessTokenKey);

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    // Remove the skip flag before sending
    options.headers.remove('skipAuthInterceptor');

    if (AppConfig.enableLogging) {
      AppLogger.d('REQUEST[${options.method}] => PATH: ${options.path}');
    }

    return handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (AppConfig.enableLogging) {
      AppLogger.d(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
      );
    }
    return handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (AppConfig.enableLogging) {
      AppLogger.e(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
        err,
      );
    }

    // Handle 401 Unauthorized - attempt token refresh
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        try {
          final response = await _retryRequest(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // If retry fails, continue with original error
          AppLogger.e('Request retry failed after token refresh', e);
        }
      }
    }

    return handler.next(err);
  }

  /// Attempts to refresh the access token using the stored refresh token.
  ///
  /// Returns `true` if refresh was successful, `false` otherwise.
  Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.read(
        key: AppConstants.refreshTokenKey,
      );

      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.w('No refresh token available');
        return false;
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'skipAuthInterceptor': true}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await _secureStorage.write(
            key: AppConstants.accessTokenKey,
            value: newAccessToken,
          );

          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await _secureStorage.write(
              key: AppConstants.refreshTokenKey,
              value: newRefreshToken,
            );
          }

          AppLogger.i('Token refreshed successfully');
          return true;
        }
      }
    } catch (e) {
      AppLogger.e('Token refresh failed', e);
      // Clear tokens on refresh failure - user needs to re-authenticate
      await clearTokens();
    } finally {
      _isRefreshing = false;
    }

    return false;
  }

  /// Retries a failed request with the new access token.
  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);

    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Saves access and refresh tokens to secure storage.
  ///
  /// Call this after successful login/registration.
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      _secureStorage.write(key: AppConstants.accessTokenKey, value: accessToken),
      _secureStorage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
    ]);
    AppLogger.i('Tokens saved to secure storage');
  }

  /// Clears all authentication tokens from secure storage.
  ///
  /// Call this on logout or when authentication fails.
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: AppConstants.accessTokenKey),
      _secureStorage.delete(key: AppConstants.refreshTokenKey),
    ]);
    AppLogger.i('Tokens cleared from secure storage');
  }

  /// Retrieves the current access token.
  ///
  /// Returns `null` if no token is stored.
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  /// Checks if a valid token exists in storage.
  ///
  /// Note: This only checks for token presence, not validity.
  /// The server will determine if the token is still valid.
  Future<bool> hasValidToken() async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }
}
