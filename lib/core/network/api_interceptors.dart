/// HTTP interceptors for the API client in App Pasos.
///
/// This file contains Dio interceptors for:
/// - Authentication token injection
/// - Request/response logging
/// - Error transformation to app-specific exceptions
library;

import 'dart:io';

import 'package:app_pasos_frontend/core/constants/app_constants.dart';
import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/core/storage/secure_storage_service.dart';
import 'package:app_pasos_frontend/core/utils/logger.dart';
import 'package:dio/dio.dart';

/// Interceptor that adds authentication headers to outgoing requests.
///
/// This interceptor:
/// - Reads the auth token from secure storage
/// - Adds the Bearer token to the Authorization header
/// - Skips token injection for auth endpoints (login, register)
///
/// Example:
/// ```dart
/// dio.interceptors.add(AuthInterceptor(secureStorage));
/// ```
class AuthInterceptor extends Interceptor {
  /// Creates an [AuthInterceptor] with the given storage service.
  AuthInterceptor(this._storage);

  /// The secure storage service for reading auth tokens.
  final SecureStorageService _storage;

  /// Endpoints that don't require authentication.
  static const List<String> _publicEndpoints = [
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/reset-password',
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints
    final isPublicEndpoint = _publicEndpoints.any(
      (endpoint) => options.path.contains(endpoint),
    );

    if (!isPublicEndpoint) {
      final token = await _storage.getAuthToken();
      if (token != null && token.isNotEmpty) {
        options.headers[ApiHeaders.authorization] = 'Bearer $token';
      }
    }

    // Add common headers
    options.headers[ApiHeaders.contentType] = ContentTypes.json;
    options.headers[ApiHeaders.accept] = ContentTypes.json;

    handler.next(options);
  }
}

/// Interceptor that logs all HTTP requests and responses.
///
/// This interceptor provides detailed logging for debugging:
/// - Request method, URL, headers, and body
/// - Response status, headers, and body
/// - Error details with stack traces
///
/// Logging is automatically filtered based on the current log level.
///
/// Example:
/// ```dart
/// dio.interceptors.add(LoggingInterceptor());
/// ```
class LoggingInterceptor extends Interceptor {
  /// Creates a [LoggingInterceptor].
  LoggingInterceptor() : _logger = AppLogger();

  /// The logger instance for output.
  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════════════════════')
      ..writeln('║ 🌐 REQUEST')
      ..writeln('╠══════════════════════════════════════════════════════════')
      ..writeln('║ ${options.method} ${options.uri}')
      ..writeln('║ Headers: ${_sanitizeHeaders(options.headers)}');

    if (options.data != null) {
      buffer.writeln('║ Body: ${_truncateBody(options.data)}');
    }

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('║ Query: ${options.queryParameters}');
    }

    buffer.writeln(
      '╚══════════════════════════════════════════════════════════',
    );

    _logger.debug(buffer.toString());
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════════════════════')
      ..writeln('║ ✅ RESPONSE')
      ..writeln('╠══════════════════════════════════════════════════════════')
      ..writeln('║ ${response.statusCode} ${response.requestOptions.uri}')
      ..writeln('║ Data: ${_truncateBody(response.data)}')
      ..writeln(
        '╚══════════════════════════════════════════════════════════',
      );

    _logger.debug(buffer.toString());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════════════════════')
      ..writeln('║ ❌ ERROR')
      ..writeln('╠══════════════════════════════════════════════════════════')
      ..writeln('║ ${err.type} ${err.requestOptions.uri}')
      ..writeln('║ Message: ${err.message}');

    if (err.response != null) {
      buffer
        ..writeln('║ Status: ${err.response?.statusCode}')
        ..writeln('║ Response: ${_truncateBody(err.response?.data)}');
    }

    buffer.writeln(
      '╚══════════════════════════════════════════════════════════',
    );

    _logger.error(buffer.toString(), err, err.stackTrace);
    handler.next(err);
  }

  /// Sanitizes headers to hide sensitive information.
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);

    // Hide authorization token value
    if (sanitized.containsKey(ApiHeaders.authorization)) {
      final authValue = sanitized[ApiHeaders.authorization] as String?;
      if (authValue != null && authValue.length > 15) {
        sanitized[ApiHeaders.authorization] =
            '${authValue.substring(0, 15)}...';
      }
    }

    return sanitized;
  }

  /// Truncates response body for logging.
  String _truncateBody(dynamic body) {
    if (body == null) return 'null';

    final stringBody = body.toString();
    const maxLength = 500;

    if (stringBody.length > maxLength) {
      return '${stringBody.substring(0, maxLength)}... (truncated)';
    }

    return stringBody;
  }
}

/// Interceptor that transforms [DioException] into app-specific exceptions.
///
/// This interceptor catches all Dio errors and converts them to the
/// appropriate [AppException] subtype, enabling consistent error handling
/// throughout the application.
///
/// Transformation rules:
/// - Connection errors → [NetworkException.noConnection]
/// - Timeout errors → [NetworkException.timeout]
/// - 401 Unauthorized → [UnauthorizedException]
/// - 400 Bad Request → [ValidationException] or [ServerException.badRequest]
/// - 404 Not Found → [ServerException.notFound]
/// - 500+ Server errors → [ServerException.internalError]
///
/// Example:
/// ```dart
/// dio.interceptors.add(ErrorInterceptor());
/// ```
class ErrorInterceptor extends Interceptor {
  /// Creates an [ErrorInterceptor].
  ErrorInterceptor() : _logger = AppLogger();

  /// The logger instance for error logging.
  final AppLogger _logger;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = _transformError(err);

    _logger.error(
      'API Error: ${appException.message}',
      appException.originalError,
      appException.stackTrace,
    );

    // Re-throw as DioException with app exception in error field
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: appException,
        stackTrace: err.stackTrace,
        message: appException.message,
      ),
    );
  }

  /// Transforms a [DioException] into an [AppException].
  AppException _transformError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout(
          message: 'Request timed out. Please check your connection.',
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.connectionError:
        return NetworkException.noConnection(
          message: _getConnectionErrorMessage(error),
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request was cancelled',
          code: 'REQUEST_CANCELLED',
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Invalid SSL certificate',
          code: 'BAD_CERTIFICATE',
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.unknown:
        // Check if it's a socket exception (no internet)
        if (error.error is SocketException) {
          return NetworkException.noConnection(
            message: 'No internet connection. Please check your network.',
            originalError: error,
            stackTrace: error.stackTrace,
          );
        }
        return NetworkException(
          message: error.message ?? 'An unexpected network error occurred',
          code: 'UNKNOWN_ERROR',
          originalError: error,
          stackTrace: error.stackTrace,
        );
    }
  }

  /// Gets a user-friendly message for connection errors.
  String _getConnectionErrorMessage(DioException error) {
    if (error.error is SocketException) {
      return 'No internet connection. Please check your network settings.';
    }
    return 'Unable to connect to the server. Please try again later.';
  }

  /// Handles HTTP error responses (4xx, 5xx).
  AppException _handleBadResponse(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final responseBody = _extractErrorMessage(response?.data);

    switch (statusCode) {
      case 400:
        // Check if it's a validation error with field details
        final fieldErrors = _extractFieldErrors(response?.data);
        if (fieldErrors.isNotEmpty) {
          return ValidationException.multiple(
            fieldErrors: fieldErrors,
            message: responseBody,
          );
        }
        return ServerException.badRequest(
          message: responseBody,
          responseBody: response?.data?.toString(),
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case 401:
        return UnauthorizedException.invalidToken(
          message: responseBody.isNotEmpty
              ? responseBody
              : 'Authentication required. Please log in.',
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case 403:
        return UnauthorizedException.permissionDenied(
          message: responseBody.isNotEmpty
              ? responseBody
              : 'You do not have permission to perform this action.',
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case 404:
        return ServerException.notFound(
          message: responseBody.isNotEmpty
              ? responseBody
              : 'The requested resource was not found.',
          responseBody: response?.data?.toString(),
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case 422:
        // Unprocessable Entity - usually validation errors
        final fieldErrors = _extractFieldErrors(response?.data);
        return ValidationException.multiple(
          fieldErrors:
              fieldErrors.isNotEmpty ? fieldErrors : {'_': [responseBody]},
          message: responseBody,
        );

      case 429:
        return ServerException(
          message: 'Too many requests. Please wait and try again.',
          code: 'RATE_LIMITED',
          statusCode: 429,
          responseBody: response?.data?.toString(),
          originalError: error,
          stackTrace: error.stackTrace,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException.internalError(
          message: 'Server error. Please try again later.',
          responseBody: response?.data?.toString(),
          originalError: error,
          stackTrace: error.stackTrace,
        );

      default:
        return ServerException(
          message: responseBody.isNotEmpty
              ? responseBody
              : 'An error occurred (status: $statusCode)',
          code: 'HTTP_$statusCode',
          statusCode: statusCode,
          responseBody: response?.data?.toString(),
          originalError: error,
          stackTrace: error.stackTrace,
        );
    }
  }

  /// Extracts an error message from the response data.
  String _extractErrorMessage(dynamic data) {
    if (data == null) return '';

    if (data is String) return data;

    if (data is Map) {
      // Try common error message fields
      final message = data['message'] ??
          data['error'] ??
          data['error_description'] ??
          data['detail'];
      if (message is String) return message;

      // Handle nested errors
      if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        final firstError = (data['errors'] as List).first;
        if (firstError is String) return firstError;
        if (firstError is Map && firstError['message'] is String) {
          return firstError['message'] as String;
        }
      }
    }

    return '';
  }

  /// Extracts field-specific validation errors from the response.
  Map<String, List<String>> _extractFieldErrors(dynamic data) {
    final fieldErrors = <String, List<String>>{};

    if (data is! Map) return fieldErrors;

    // Handle common validation error formats

    // Format 1: { errors: { field: ['error1', 'error2'] } }
    if (data['errors'] is Map) {
      (data['errors'] as Map).forEach((key, value) {
        if (key is String) {
          if (value is List) {
            fieldErrors[key] = value.map((e) => e.toString()).toList();
          } else if (value is String) {
            fieldErrors[key] = [value];
          }
        }
      });
    }

    // Format 2: { fieldErrors: { field: 'error' } }
    if (data['fieldErrors'] is Map) {
      (data['fieldErrors'] as Map).forEach((key, value) {
        if (key is String) {
          if (value is List) {
            fieldErrors[key] = value.map((e) => e.toString()).toList();
          } else if (value is String) {
            fieldErrors[key] = [value];
          }
        }
      });
    }

    // Format 3: { errors: [{ field: 'name', message: 'error' }] }
    if (data['errors'] is List) {
      for (final error in data['errors'] as List) {
        if (error is Map && error['field'] is String) {
          final field = error['field'] as String;
          final message =
              (error['message'] ?? error['error'] ?? 'Invalid').toString();
          fieldErrors.putIfAbsent(field, () => []).add(message);
        }
      }
    }

    return fieldErrors;
  }
}

/// Interceptor for handling token refresh on 401 responses.
///
/// This interceptor:
/// - Catches 401 Unauthorized responses
/// - Attempts to refresh the token
/// - Retries the original request with new token
/// - Clears auth data if refresh fails
///
/// Note: This interceptor should be added after [AuthInterceptor].
class TokenRefreshInterceptor extends Interceptor {
  /// Creates a [TokenRefreshInterceptor].
  TokenRefreshInterceptor({
    required SecureStorageService storage,
    required Dio dio,
  })  : _storage = storage,
        _dio = dio,
        _logger = AppLogger();

  final SecureStorageService _storage;
  final Dio _dio;
  final AppLogger _logger;

  /// Flag to prevent multiple refresh attempts.
  bool _isRefreshing = false;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 errors
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Skip if already refreshing or if the failed request was the refresh call
    if (_isRefreshing ||
        err.requestOptions.path.contains('/auth/refresh') ||
        err.requestOptions.path.contains('/auth/login')) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storage.getRefreshToken();

      if (refreshToken == null) {
        _logger.warning('No refresh token available');
        await _clearAuthAndReject(err, handler);
        return;
      }

      _logger.info('Attempting to refresh token...');

      // Create a fresh Dio instance to avoid interceptor loops
      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));

      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newToken = response.data!['token'] as String?;
        final newRefreshToken = response.data!['refreshToken'] as String?;

        if (newToken != null) {
          await _storage.saveAuthToken(newToken);
          if (newRefreshToken != null) {
            await _storage.saveRefreshToken(newRefreshToken);
          }

          _logger.info('Token refreshed successfully');

          // Retry the original request with new token
          final retryOptions = err.requestOptions;
          retryOptions.headers[ApiHeaders.authorization] = 'Bearer $newToken';

          final retryResponse = await _dio.fetch<dynamic>(retryOptions);
          handler.resolve(retryResponse);
          return;
        }
      }

      await _clearAuthAndReject(err, handler);
    } on DioException catch (refreshError) {
      _logger.error('Token refresh failed', refreshError);
      await _clearAuthAndReject(err, handler);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Clears auth data and rejects with original error.
  Future<void> _clearAuthAndReject(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _logger.warning('Clearing auth data due to failed refresh');
    await _storage.clearAuthData();
    handler.next(err);
  }
}
