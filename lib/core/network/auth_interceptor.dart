import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interceptor that handles JWT authentication for API requests.
///
/// This interceptor:
/// - Adds Authorization header with Bearer token to outgoing requests
/// - Handles 401 Unauthorized responses by attempting token refresh
/// - Clears tokens when refresh fails (user needs to re-login)
///
/// Token storage keys:
/// - `access_token`: The JWT access token
/// - `refresh_token`: The refresh token for obtaining new access tokens
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  /// Storage key for the access token.
  static const String accessTokenKey = 'access_token';

  /// Storage key for the refresh token.
  static const String refreshTokenKey = 'refresh_token';

  /// Flag to prevent multiple simultaneous refresh attempts.
  bool _isRefreshing = false;

  /// Creates an [AuthInterceptor] with the provided [FlutterSecureStorage].
  AuthInterceptor(this._storage);

  /// Adds the Authorization header to outgoing requests.
  ///
  /// If an access token exists in secure storage, it will be added
  /// as a Bearer token in the Authorization header.
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints if needed
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    final accessToken = await _storage.read(key: accessTokenKey);

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  /// Handles error responses, particularly 401 Unauthorized.
  ///
  /// When a 401 is received:
  /// 1. Attempts to refresh the access token using the refresh token
  /// 2. If successful, retries the original request with the new token
  /// 3. If refresh fails, clears stored tokens and rejects the error
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized errors
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Skip refresh for auth endpoints to prevent infinite loops
    if (_isAuthEndpoint(err.requestOptions.path)) {
      return handler.next(err);
    }

    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      final refreshed = await _refreshToken(err.requestOptions);

      if (refreshed) {
        // Retry the original request with new token
        final response = await _retryRequest(err.requestOptions);
        _isRefreshing = false;
        return handler.resolve(response);
      } else {
        // Refresh failed, clear tokens
        await _clearTokens();
        _isRefreshing = false;
        return handler.next(err);
      }
    } catch (e) {
      await _clearTokens();
      _isRefreshing = false;
      return handler.next(err);
    }
  }

  /// Checks if the request path is an auth endpoint.
  ///
  /// Auth endpoints should not trigger token refresh to prevent loops.
  bool _isAuthEndpoint(String path) {
    final authPaths = ['/auth/login', '/auth/register', '/auth/refresh'];
    return authPaths.any((authPath) => path.contains(authPath));
  }

  /// Attempts to refresh the access token.
  ///
  /// Returns `true` if refresh was successful, `false` otherwise.
  Future<bool> _refreshToken(RequestOptions originalOptions) async {
    final refreshToken = await _storage.read(key: refreshTokenKey);

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      // Create a new Dio instance to avoid interceptor loops
      final dio = Dio(BaseOptions(
        baseUrl: originalOptions.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      final response = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data!['access_token'] as String?;
        final newRefreshToken = response.data!['refresh_token'] as String?;

        if (newAccessToken != null) {
          await _storage.write(key: accessTokenKey, value: newAccessToken);

          if (newRefreshToken != null) {
            await _storage.write(key: refreshTokenKey, value: newRefreshToken);
          }

          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Retries the original request with the refreshed token.
  Future<Response<dynamic>> _retryRequest(RequestOptions options) async {
    final accessToken = await _storage.read(key: accessTokenKey);

    final newOptions = Options(
      method: options.method,
      headers: {
        ...options.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );

    // Create a new Dio instance to avoid interceptor loops
    final dio = Dio(BaseOptions(
      baseUrl: options.baseUrl,
    ));

    return dio.request<dynamic>(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: newOptions,
    );
  }

  /// Clears all stored tokens.
  ///
  /// Called when token refresh fails and user needs to re-authenticate.
  Future<void> _clearTokens() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
  }
}
