import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../utils/logger.dart';

/// Interceptor that handles authentication by adding JWT tokens to requests.
///
/// This interceptor automatically adds the Authorization header with Bearer token
/// to all outgoing requests when a token is set. It also handles logging of
/// requests, responses, and errors.
class AuthInterceptor extends Interceptor {
  String? _accessToken;
  String? _refreshToken;

  /// Sets the authentication tokens.
  ///
  /// [accessToken] - The JWT access token for API requests
  /// [refreshToken] - The refresh token for obtaining new access tokens
  void setTokens({String? accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  /// Clears all stored tokens.
  ///
  /// Call this method when the user logs out or tokens become invalid.
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  /// Returns the current access token, if any.
  String? get accessToken => _accessToken;

  /// Returns the current refresh token, if any.
  String? get refreshToken => _refreshToken;

  /// Returns true if an access token is currently set.
  bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add authorization header if token exists
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }

    // Set default content type headers
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    AppLogger.debug('REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      err,
    );
    handler.next(err);
  }
}

/// Interceptor that provides detailed logging of HTTP requests and responses.
///
/// This interceptor logs request details including method, URL, and body,
/// as well as response status codes. It's useful for debugging API calls
/// during development.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.info('┌─────────────────────────────────────────────────────');
    AppLogger.info('│ ${options.method} ${options.uri}');
    if (options.data != null) {
      AppLogger.debug('│ Body: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      AppLogger.debug('│ Query: ${options.queryParameters}');
    }
    AppLogger.info('└─────────────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info('┌─────────────────────────────────────────────────────');
    AppLogger.info('│ ${response.statusCode} ${response.requestOptions.uri}');
    AppLogger.info('└─────────────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('┌─────────────────────────────────────────────────────');
    AppLogger.error(
      '│ ERROR ${err.response?.statusCode ?? 'N/A'} ${err.requestOptions.uri}',
    );
    AppLogger.error('│ Message: ${err.message}');
    AppLogger.error('└─────────────────────────────────────────────────────');
    handler.next(err);
  }
}

/// Interceptor that automatically retries failed requests.
///
/// This interceptor will retry requests that fail due to connection timeouts,
/// receive timeouts, or connection errors. It uses exponential backoff between
/// retry attempts.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  /// Creates a new [RetryInterceptor].
  ///
  /// [dio] - The Dio instance to use for retry requests
  /// [maxRetries] - Maximum number of retry attempts (default: AppConstants.maxRetries)
  RetryInterceptor({required this.dio, int? maxRetries})
    : maxRetries = maxRetries ?? AppConstants.maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Check if this is a retryable error and we haven't exceeded max retries
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      final newRetryCount = retryCount + 1;
      AppLogger.warning(
        'Retrying request (attempt $newRetryCount/$maxRetries)',
      );

      try {
        // Mark this request with the retry count
        err.requestOptions.extra['retryCount'] = newRetryCount;

        // Wait with exponential backoff before retrying
        await Future.delayed(Duration(seconds: newRetryCount));

        // Retry the request
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // If max retries exceeded or another error, propagate the original error
        if (newRetryCount >= maxRetries) {
          AppLogger.error(
            'Max retries ($maxRetries) exceeded for ${err.requestOptions.path}',
          );
          return handler.next(err);
        }
        // Recursively retry on failure
        if (e is DioException) {
          return onError(e, handler);
        }
      }
    }

    // Not a retryable error or max retries exceeded
    handler.next(err);
  }

  /// Determines if a request should be retried based on the error type.
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}
