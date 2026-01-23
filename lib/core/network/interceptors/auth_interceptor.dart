import 'package:dio/dio.dart';

import '../../utils/logger.dart';

/// Contract for secure storage operations.
///
/// This abstract class defines the interface for token storage.
/// Implement this with flutter_secure_storage in the data layer.
abstract interface class TokenStorage {
  /// Retrieves the access token from secure storage.
  /// Returns null if no token is stored.
  Future<String?> getAccessToken();

  /// Retrieves the refresh token from secure storage.
  /// Returns null if no token is stored.
  Future<String?> getRefreshToken();

  /// Stores the access token in secure storage.
  Future<void> saveAccessToken(String token);

  /// Stores the refresh token in secure storage.
  Future<void> saveRefreshToken(String token);

  /// Clears all stored tokens.
  Future<void> clearTokens();
}

/// Interceptor for adding authentication headers to requests.
///
/// Automatically injects Bearer token from TokenStorage into request headers.
/// Skips authentication for public endpoints (login, register, etc.).
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  /// Endpoints that don't require authentication.
  static const List<String> _publicEndpoints = [
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/refresh',
  ];

  AuthInterceptor({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    final path = options.path;
    if (_isPublicEndpoint(path)) {
      AppLogger.d('Skipping auth for public endpoint: $path');
      return handler.next(options);
    }

    // Skip if already has Authorization header (e.g., refresh token flow)
    if (options.headers.containsKey('Authorization')) {
      return handler.next(options);
    }

    try {
      final token = await _tokenStorage.getAccessToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        AppLogger.d('Added auth header to request: $path');
      } else {
        AppLogger.w('No access token available for request: $path');
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error retrieving access token', e, stackTrace);
    }

    handler.next(options);
  }

  /// Checks if the given path is a public endpoint.
  bool _isPublicEndpoint(String path) {
    return _publicEndpoints.any((endpoint) => path.contains(endpoint));
  }
}
