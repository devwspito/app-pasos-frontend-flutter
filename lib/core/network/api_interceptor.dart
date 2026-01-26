import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Keys used for secure storage of authentication tokens.
class StorageKeys {
  StorageKeys._();

  /// Key for storing the access token
  static const String accessToken = 'access_token';

  /// Key for storing the refresh token
  static const String refreshToken = 'refresh_token';
}

/// Interceptor that adds authentication headers to requests.
///
/// This interceptor:
/// - Adds Bearer token to Authorization header on requests
/// - Handles 401 errors by attempting token refresh
/// - Triggers logout if token refresh fails
///
/// Example:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(AuthInterceptor(
///   secureStorage: FlutterSecureStorage(),
///   onTokenRefresh: () async => await authService.refreshToken(),
///   onLogout: () => authBloc.add(LogoutRequested()),
/// ));
/// ```
class AuthInterceptor extends Interceptor {
  /// Secure storage for reading/writing tokens
  final FlutterSecureStorage _secureStorage;

  /// Callback to refresh the access token
  final Future<String?> Function()? _onTokenRefresh;

  /// Callback when user should be logged out (token refresh failed)
  final void Function()? _onLogout;

  /// Whether a token refresh is currently in progress
  bool _isRefreshing = false;

  /// Creates an [AuthInterceptor] with the given dependencies.
  ///
  /// [secureStorage] is used to read and store tokens.
  /// [onTokenRefresh] is called when a 401 is received to get a new token.
  /// [onLogout] is called when token refresh fails.
  AuthInterceptor({
    required FlutterSecureStorage secureStorage,
    Future<String?> Function()? onTokenRefresh,
    void Function()? onLogout,
  })  : _secureStorage = secureStorage,
        _onTokenRefresh = onTokenRefresh,
        _onLogout = onLogout;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Read token from secure storage
    final token = await _secureStorage.read(key: StorageKeys.accessToken);

    // Add Authorization header if token exists
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        // Attempt to refresh token
        if (_onTokenRefresh != null) {
          final newToken = await _onTokenRefresh();

          if (newToken != null && newToken.isNotEmpty) {
            // Store the new token
            await _secureStorage.write(
              key: StorageKeys.accessToken,
              value: newToken,
            );

            // Retry the original request with new token
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            try {
              final response = await Dio().fetch(options);
              _isRefreshing = false;
              return handler.resolve(response);
            } catch (retryError) {
              _isRefreshing = false;
              // If retry fails, trigger logout
              _onLogout?.call();
              return handler.reject(err);
            }
          }
        }

        // Token refresh failed or not available, trigger logout
        _onLogout?.call();
      } catch (e) {
        // Token refresh threw an error, trigger logout
        _onLogout?.call();
      } finally {
        _isRefreshing = false;
      }
    }

    handler.next(err);
  }
}

/// Interceptor that logs HTTP requests and responses.
///
/// This interceptor logs:
/// - Request method, path, and headers (with auth tokens masked)
/// - Response status code and duration
/// - Error details
///
/// Example:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(LoggingInterceptor(
///   logger: Logger(),
///   enableInRelease: false,
/// ));
/// ```
class LoggingInterceptor extends Interceptor {
  /// Logger instance for outputting logs
  final Logger _logger;

  /// Whether logging is enabled in release mode
  final bool _enableInRelease;

  /// Stores request start times for calculating duration
  final Map<int, DateTime> _requestTimestamps = {};

  /// Creates a [LoggingInterceptor] with the given [logger].
  ///
  /// If [enableInRelease] is false (default), logging is disabled
  /// in release builds.
  LoggingInterceptor({
    required Logger logger,
    bool enableInRelease = false,
  })  : _logger = logger,
        _enableInRelease = enableInRelease;

  /// Whether logging should be performed.
  bool get _shouldLog {
    // In production, only log if explicitly enabled
    const bool isRelease = bool.fromEnvironment('dart.vm.product');
    return !isRelease || _enableInRelease;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (_shouldLog) {
      // Store request start time
      _requestTimestamps[options.hashCode] = DateTime.now();

      // Mask sensitive headers
      final maskedHeaders = _maskSensitiveHeaders(options.headers);

      _logger.i(
        '→ ${options.method} ${options.path}\n'
        '  Headers: $maskedHeaders\n'
        '  Query: ${options.queryParameters}',
      );

      // Log request body for non-GET requests (masked for sensitive data)
      if (options.method != 'GET' && options.data != null) {
        final maskedData = _maskSensitiveData(options.data);
        _logger.d('  Body: $maskedData');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (_shouldLog) {
      // Calculate request duration
      final startTime = _requestTimestamps.remove(response.requestOptions.hashCode);
      final duration = startTime != null
          ? DateTime.now().difference(startTime).inMilliseconds
          : 0;

      _logger.i(
        '← ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.path} (${duration}ms)',
      );
    }

    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (_shouldLog) {
      // Calculate request duration
      final startTime = _requestTimestamps.remove(err.requestOptions.hashCode);
      final duration = startTime != null
          ? DateTime.now().difference(startTime).inMilliseconds
          : 0;

      _logger.e(
        '✗ ${err.response?.statusCode ?? 'NO_STATUS'} '
        '${err.requestOptions.method} ${err.requestOptions.path} (${duration}ms)\n'
        '  Type: ${err.type}\n'
        '  Message: ${err.message}',
      );

      // Log response body for error responses
      if (err.response?.data != null) {
        _logger.e('  Response: ${err.response?.data}');
      }
    }

    handler.next(err);
  }

  /// Masks sensitive header values like Authorization tokens.
  Map<String, dynamic> _maskSensitiveHeaders(Map<String, dynamic> headers) {
    final masked = Map<String, dynamic>.from(headers);

    const sensitiveHeaders = [
      'authorization',
      'x-api-key',
      'cookie',
      'set-cookie',
    ];

    for (final key in masked.keys.toList()) {
      if (sensitiveHeaders.contains(key.toLowerCase())) {
        final value = masked[key]?.toString() ?? '';
        if (value.length > 10) {
          masked[key] = '${value.substring(0, 10)}...***';
        } else {
          masked[key] = '***';
        }
      }
    }

    return masked;
  }

  /// Masks sensitive data fields like passwords.
  dynamic _maskSensitiveData(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return data;
    }

    final masked = Map<String, dynamic>.from(data);

    const sensitiveFields = [
      'password',
      'newPassword',
      'currentPassword',
      'confirmPassword',
      'secret',
      'token',
      'accessToken',
      'refreshToken',
      'pin',
      'otp',
      'creditCard',
      'cardNumber',
      'cvv',
      'ssn',
    ];

    for (final key in masked.keys.toList()) {
      if (sensitiveFields.any(
        (field) => key.toLowerCase().contains(field.toLowerCase()),
      )) {
        masked[key] = '***';
      }
    }

    return masked;
  }
}

/// Interceptor that handles retry logic for failed requests.
///
/// This interceptor automatically retries requests that fail due to
/// network issues or server errors, with configurable retry count
/// and delay.
///
/// Example:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(RetryInterceptor(
///   dio: dio,
///   maxRetries: 3,
///   retryDelayMs: 1000,
/// ));
/// ```
class RetryInterceptor extends Interceptor {
  /// The Dio instance to use for retries
  final Dio _dio;

  /// Maximum number of retry attempts
  final int _maxRetries;

  /// Delay between retries in milliseconds
  final int _retryDelayMs;

  /// HTTP status codes that should trigger a retry
  final Set<int> _retryStatusCodes;

  /// Creates a [RetryInterceptor] with the given configuration.
  ///
  /// [dio] is the Dio instance used for retry requests.
  /// [maxRetries] is the maximum number of retry attempts (default: 3).
  /// [retryDelayMs] is the delay between retries in milliseconds (default: 1000).
  /// [retryStatusCodes] are the HTTP status codes that trigger retry (default: 500-599).
  RetryInterceptor({
    required Dio dio,
    int maxRetries = 3,
    int retryDelayMs = 1000,
    Set<int>? retryStatusCodes,
  })  : _dio = dio,
        _maxRetries = maxRetries,
        _retryDelayMs = retryDelayMs,
        _retryStatusCodes = retryStatusCodes ??
            {500, 502, 503, 504};

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Get current retry count from extras
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    // Check if we should retry
    final shouldRetry = _shouldRetry(err, retryCount);

    if (shouldRetry) {
      // Wait before retrying
      await Future.delayed(Duration(milliseconds: _retryDelayMs));

      // Update retry count
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      try {
        // Retry the request
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // If retry also fails, continue to error handling
        if (e is DioException) {
          return handler.reject(e);
        }
        return handler.reject(err);
      }
    }

    handler.next(err);
  }

  /// Determines if a request should be retried.
  bool _shouldRetry(DioException err, int currentRetryCount) {
    // Don't retry if max retries exceeded
    if (currentRetryCount >= _maxRetries) {
      return false;
    }

    // Retry on connection errors
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // Retry on specific status codes
    final statusCode = err.response?.statusCode;
    if (statusCode != null && _retryStatusCodes.contains(statusCode)) {
      return true;
    }

    return false;
  }
}
