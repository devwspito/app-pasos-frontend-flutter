import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';

/// Interceptor that adds authentication token to requests.
///
/// Retrieves the access token from secure storage and adds it
/// as a Bearer token in the Authorization header.
final class AuthInterceptor extends Interceptor {
  AuthInterceptor({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  final SecureStorage _secureStorage;

  /// List of public endpoints that don't require authentication.
  static const List<String> _publicEndpoints = [
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.forgotPassword,
    ApiEndpoints.resetPassword,
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    final isPublicEndpoint = _publicEndpoints.any(
      (endpoint) => options.path.contains(endpoint),
    );

    if (!isPublicEndpoint) {
      final token = await _secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 errors - token might be expired
    if (err.response?.statusCode == 401) {
      // Could trigger token refresh or logout here
      developer.log(
        'Auth error: Token might be expired or invalid',
        name: 'AuthInterceptor',
        level: 900, // Warning level
      );
    }
    handler.next(err);
  }
}

/// Interceptor that logs HTTP requests and responses.
///
/// Uses dart:developer.log for logging. Sanitizes sensitive
/// data like tokens and passwords from logs.
final class LoggingInterceptor extends Interceptor {
  /// Keys that should be redacted in logs.
  static const List<String> _sensitiveKeys = [
    'password',
    'token',
    'accessToken',
    'refreshToken',
    'authorization',
    'secret',
    'apiKey',
    'api_key',
    'credential',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final sanitizedHeaders = _sanitizeMap(options.headers);
    final sanitizedData = options.data is Map
        ? _sanitizeMap(options.data as Map<String, dynamic>)
        : options.data?.toString();

    developer.log(
      '→ ${options.method} ${options.uri}\n'
      'Headers: $sanitizedHeaders\n'
      'Data: $sanitizedData',
      name: 'HTTP',
      level: 500, // Info level
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final sanitizedData = response.data is Map
        ? _sanitizeMap(response.data as Map<String, dynamic>)
        : response.data?.toString();

    developer.log(
      '← ${response.statusCode} ${response.requestOptions.uri}\n'
      'Data: $sanitizedData',
      name: 'HTTP',
      level: 500, // Info level
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '✕ ${err.response?.statusCode ?? 'NO STATUS'} ${err.requestOptions.uri}\n'
      'Error: ${err.message}\n'
      'Type: ${err.type}',
      name: 'HTTP',
      level: 1000, // Error level
    );

    handler.next(err);
  }

  /// Sanitizes a map by redacting sensitive values.
  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (_sensitiveKeys.any(
        (sensitive) => key.toLowerCase().contains(sensitive.toLowerCase()),
      )) {
        return MapEntry(key, '[REDACTED]');
      }
      if (value is Map<String, dynamic>) {
        return MapEntry(key, _sanitizeMap(value));
      }
      return MapEntry(key, value);
    });
  }
}

/// Interceptor that converts Dio errors to app-specific exceptions.
///
/// Maps DioExceptionType to appropriate AppException subtypes
/// for consistent error handling throughout the app.
final class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioExceptionToAppException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }

  /// Maps a DioException to the appropriate AppException subtype.
  AppException _mapDioExceptionToAppException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout();

      case DioExceptionType.connectionError:
        return NetworkException.noConnection();

      case DioExceptionType.badCertificate:
        return NetworkException.sslError();

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return const ServerException(
          message: 'Request was cancelled',
          statusCode: 0,
        );

      case DioExceptionType.unknown:
      default:
        if (error.error != null && error.error is AppException) {
          return error.error as AppException;
        }
        return UnexpectedException.from(
          error.error ?? error,
          error.stackTrace,
        );
    }
  }

  /// Handles bad response (4xx and 5xx) status codes.
  AppException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    final endpoint = error.requestOptions.path;

    // Handle specific status codes
    switch (statusCode) {
      case 401:
        return AuthException.invalidCredentials();

      case 403:
        return AuthException.unauthorized();

      case 404:
        return NotFoundException(
          message: _extractErrorMessage(responseData) ?? 'Resource not found',
          resourceType: _extractResourceType(endpoint),
        );

      case 422:
        final fieldErrors = _extractFieldErrors(responseData);
        if (fieldErrors != null) {
          return ValidationException.fields(fieldErrors);
        }
        return ValidationException(
          message: _extractErrorMessage(responseData) ?? 'Validation failed',
        );

      case 429:
        return RateLimitException.fromHeaders(
          error.response?.headers.map,
        );

      default:
        return ServerException.fromStatusCode(
          statusCode ?? 500,
          endpoint: endpoint,
        );
    }
  }

  /// Extracts error message from response data.
  String? _extractErrorMessage(dynamic data) {
    if (data is Map) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['errors']?.toString();
    }
    if (data is String) {
      return data;
    }
    return null;
  }

  /// Extracts resource type from endpoint path.
  String? _extractResourceType(String endpoint) {
    final parts = endpoint.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.isNotEmpty) {
      // Return the first meaningful segment (e.g., 'users', 'goals')
      return parts.first.replaceAll(RegExp(r's$'), ''); // Remove trailing 's'
    }
    return null;
  }

  /// Extracts field errors from response data.
  Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is! Map) return null;

    final errors = data['errors'] ?? data['fieldErrors'];
    if (errors is! Map) return null;

    return errors.map((key, value) {
      if (value is List) {
        return MapEntry(
          key.toString(),
          value.map((e) => e.toString()).toList(),
        );
      }
      return MapEntry(key.toString(), [value.toString()]);
    });
  }
}
