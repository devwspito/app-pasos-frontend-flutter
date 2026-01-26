/// HTTP interceptors for Dio client.
///
/// Contains interceptors for:
/// - Authentication (JWT token injection)
/// - Logging (request/response logging)
/// - Error handling (converting DioException to ApiException)
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_exceptions.dart';

// ============================================================
// Interface for Secure Storage (will be implemented by storage module)
// ============================================================

/// Interface for secure token storage.
///
/// This interface defines the contract for storing and retrieving
/// authentication tokens securely. Implementation should use
/// flutter_secure_storage or similar secure storage solution.
abstract class ISecureStorage {
  /// Retrieves the stored authentication token.
  /// Returns null if no token is stored.
  Future<String?> getToken();

  /// Stores the authentication token securely.
  Future<void> setToken(String token);

  /// Removes the stored authentication token.
  Future<void> deleteToken();

  /// Retrieves the stored refresh token.
  /// Returns null if no refresh token is stored.
  Future<String?> getRefreshToken();

  /// Stores the refresh token securely.
  Future<void> setRefreshToken(String token);

  /// Removes the stored refresh token.
  Future<void> deleteRefreshToken();

  /// Clears all stored authentication data.
  Future<void> clearAll();
}

// ============================================================
// Simple Logger (will be replaced by logger module)
// ============================================================

/// Simple logger for API operations.
///
/// This provides basic logging functionality until the full
/// logger module is implemented.
class ApiLogger {
  /// Log info message.
  static void i(String message) {
    if (kDebugMode) {
      debugPrint('[API INFO] $message');
    }
  }

  /// Log error message.
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[API ERROR] $message');
      if (error != null) {
        debugPrint('[API ERROR] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[API ERROR] Stack: $stackTrace');
      }
    }
  }

  /// Log debug message.
  static void d(String message) {
    if (kDebugMode) {
      debugPrint('[API DEBUG] $message');
    }
  }

  /// Log warning message.
  static void w(String message) {
    if (kDebugMode) {
      debugPrint('[API WARNING] $message');
    }
  }
}

// ============================================================
// Authentication Interceptor
// ============================================================

/// Interceptor that adds JWT authentication token to requests.
///
/// This interceptor retrieves the stored authentication token and
/// adds it to the Authorization header of outgoing requests.
///
/// Usage:
/// ```dart
/// dio.interceptors.add(AuthInterceptor(secureStorage));
/// ```
class AuthInterceptor extends Interceptor {
  /// The secure storage instance for token retrieval.
  final ISecureStorage _secureStorage;

  /// List of paths that should not include authentication token.
  final List<String> _excludedPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/refresh',
    '/health',
    '/version',
  ];

  /// Creates a new [AuthInterceptor] with the given secure storage.
  AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if this path should be excluded from auth
    final isExcluded = _excludedPaths.any(
      (path) => options.path.contains(path),
    );

    if (!isExcluded) {
      try {
        final token = await _secureStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          ApiLogger.d('Added auth token to request: ${options.path}');
        } else {
          ApiLogger.w('No auth token available for request: ${options.path}');
        }
      } catch (e) {
        ApiLogger.e('Error retrieving auth token', e);
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 specifically for token expiration
    if (err.response?.statusCode == 401) {
      ApiLogger.w('Received 401 - Token may be expired');
      // The error interceptor will handle the conversion to ApiException
    }
    handler.next(err);
  }
}

// ============================================================
// Logging Interceptor
// ============================================================

/// Interceptor that logs HTTP requests and responses.
///
/// In debug mode, this interceptor logs:
/// - Request method, path, and headers
/// - Response status code and path
/// - Errors with status codes
///
/// Usage:
/// ```dart
/// dio.interceptors.add(LoggingInterceptor());
/// ```
class LoggingInterceptor extends Interceptor {
  /// Whether to log request body (may contain sensitive data).
  final bool logRequestBody;

  /// Whether to log response body (may be large).
  final bool logResponseBody;

  /// Creates a new [LoggingInterceptor].
  LoggingInterceptor({
    this.logRequestBody = false,
    this.logResponseBody = false,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uri = options.uri;
    ApiLogger.i('REQUEST[${options.method}] => ${uri.path}');

    if (kDebugMode) {
      ApiLogger.d('Headers: ${_sanitizeHeaders(options.headers)}');
      if (logRequestBody && options.data != null) {
        ApiLogger.d('Body: ${options.data}');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final path = response.requestOptions.path;
    ApiLogger.i('RESPONSE[${response.statusCode}] => $path');

    if (kDebugMode && logResponseBody && response.data != null) {
      final dataString = response.data.toString();
      // Limit logged data length
      final truncated = dataString.length > 500
          ? '${dataString.substring(0, 500)}... (truncated)'
          : dataString;
      ApiLogger.d('Response Data: $truncated');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final path = err.requestOptions.path;
    final statusCode = err.response?.statusCode ?? 'N/A';
    ApiLogger.e(
      'ERROR[$statusCode] => $path',
      err.message,
    );

    if (kDebugMode && err.response?.data != null) {
      ApiLogger.e('Error Response: ${err.response?.data}');
    }

    handler.next(err);
  }

  /// Sanitizes headers to hide sensitive information.
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    const sensitiveKeys = ['Authorization', 'authorization', 'Cookie', 'cookie'];

    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        sanitized[key] = '***REDACTED***';
      }
    }

    return sanitized;
  }
}

// ============================================================
// Error Interceptor
// ============================================================

/// Interceptor that converts DioException to custom ApiException.
///
/// This interceptor catches DioExceptions and converts them to
/// appropriate ApiException subclasses for consistent error handling.
///
/// Usage:
/// ```dart
/// dio.interceptors.add(ErrorInterceptor());
/// ```
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ApiException apiException = _convertToApiException(err);

    // Reject with a new DioException containing our ApiException
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: apiException,
        type: err.type,
        response: err.response,
        message: apiException.message,
      ),
    );
  }

  /// Converts a DioException to an appropriate ApiException.
  ApiException _convertToApiException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Request timed out. Please check your connection.',
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Unable to connect. Please check your internet connection.',
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'SSL certificate error. Please try again later.',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(err);

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
        );

      case DioExceptionType.unknown:
      default:
        // Check if it's a socket exception (no internet)
        final errorMessage = err.message?.toLowerCase() ?? '';
        if (errorMessage.contains('socket') ||
            errorMessage.contains('network') ||
            errorMessage.contains('connection')) {
          return NetworkException(
            message: 'Network error. Please check your connection.',
          );
        }
        return ApiException(
          message: err.message ?? 'An unexpected error occurred.',
        );
    }
  }

  /// Handles bad response errors (4xx and 5xx status codes).
  ApiException _handleBadResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final responseData = err.response?.data;

    // Try to extract error message from response
    String? message;
    if (responseData is Map) {
      message = responseData['message'] as String? ??
          responseData['error'] as String? ??
          responseData['detail'] as String?;
    } else if (responseData is String && responseData.isNotEmpty) {
      message = responseData;
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: message ?? 'Invalid request. Please check your input.',
          data: responseData,
        );

      case 401:
        return UnauthorizedException(
          message: message ?? 'Authentication required. Please log in.',
        );

      case 403:
        return ForbiddenException(
          message: message ?? 'Access denied. You don\'t have permission.',
        );

      case 404:
        return NotFoundException(
          message: message ?? 'The requested resource was not found.',
        );

      case 409:
        return ConflictException(
          message: message ?? 'A conflict occurred with the current state.',
        );

      case 422:
        return BadRequestException(
          message: message ?? 'Validation error. Please check your input.',
          data: responseData,
        );

      case 429:
        return ApiException(
          message: 'Too many requests. Please wait and try again.',
          statusCode: 429,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: message ?? 'Server error. Please try again later.',
        );

      default:
        return ApiException(
          message: message ?? 'An error occurred (status: $statusCode).',
          statusCode: statusCode,
          data: responseData,
        );
    }
  }
}

// ============================================================
// Retry Interceptor (Optional - for resilience)
// ============================================================

/// Configuration for retry behavior.
class RetryOptions {
  /// Maximum number of retry attempts.
  final int maxRetries;

  /// Delay between retries in milliseconds.
  final int retryDelayMs;

  /// Status codes that should trigger a retry.
  final List<int> retryStatusCodes;

  /// Creates retry options.
  const RetryOptions({
    this.maxRetries = 3,
    this.retryDelayMs = 1000,
    this.retryStatusCodes = const [408, 500, 502, 503, 504],
  });
}

/// Interceptor that retries failed requests.
///
/// This interceptor automatically retries requests that fail
/// due to network issues or specific server errors.
class RetryInterceptor extends Interceptor {
  /// The Dio instance for retrying requests.
  final Dio dio;

  /// Retry configuration options.
  final RetryOptions options;

  /// Creates a new [RetryInterceptor].
  RetryInterceptor({
    required this.dio,
    this.options = const RetryOptions(),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    // Check if we should retry
    if (_shouldRetry(err, retryCount)) {
      ApiLogger.w(
        'Retrying request (${retryCount + 1}/${options.maxRetries}): '
        '${err.requestOptions.path}',
      );

      // Wait before retrying
      await Future.delayed(Duration(milliseconds: options.retryDelayMs));

      // Clone the request with updated retry count
      final newOptions = err.requestOptions;
      newOptions.extra['retryCount'] = retryCount + 1;

      try {
        final response = await dio.fetch(newOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Let the error propagate for further retry attempts
        if (e is DioException) {
          return onError(e, handler);
        }
      }
    }

    handler.next(err);
  }

  /// Determines if the request should be retried.
  bool _shouldRetry(DioException err, int retryCount) {
    if (retryCount >= options.maxRetries) {
      return false;
    }

    // Retry on timeout
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // Retry on connection error
    if (err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on specific status codes
    final statusCode = err.response?.statusCode;
    if (statusCode != null && options.retryStatusCodes.contains(statusCode)) {
      return true;
    }

    return false;
  }
}
