/// Base class for all application exceptions.
///
/// This abstract class implements [Exception] and provides a consistent
/// structure for all custom exceptions in the application. Exceptions are
/// typically thrown in data layer operations and converted to [Failure]
/// types in repositories.
///
/// Example usage:
/// ```dart
/// try {
///   final response = await dio.get('/users');
///   if (response.statusCode != 200) {
///     throw ServerException(
///       message: 'Failed to fetch users',
///       statusCode: response.statusCode,
///     );
///   }
///   return response.data;
/// } on ServerException catch (e) {
///   // Handle or convert to Failure
///   return Left(ServerFailure.fromException(e));
/// }
/// ```
abstract class AppException implements Exception {
  /// Creates a new [AppException] instance.
  ///
  /// [message] is required and should describe what went wrong.
  /// [statusCode] is optional and typically contains HTTP status codes.
  const AppException({
    required this.message,
    this.statusCode,
  });

  /// A human-readable message describing the exception.
  final String message;

  /// An optional HTTP status code or error code associated with the exception.
  final int? statusCode;

  @override
  String toString() =>
      '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// Exception thrown when server-side errors occur.
///
/// Used for HTTP errors like 5xx status codes, API failures, or when
/// the server returns an unexpected response.
///
/// Example usage:
/// ```dart
/// if (response.statusCode >= 500) {
///   throw ServerException(
///     message: 'Internal server error',
///     statusCode: response.statusCode,
///   );
/// }
/// ```
class ServerException extends AppException {
  /// Creates a new [ServerException] instance.
  const ServerException({
    required super.message,
    super.statusCode,
    this.responseBody,
  });

  /// Creates a [ServerException] from an HTTP response.
  factory ServerException.fromResponse({
    required int statusCode,
    dynamic body,
  }) {
    String message;
    switch (statusCode) {
      case 500:
        message = 'Internal server error. Please try again later.';
      case 502:
        message = 'Bad gateway. The server is temporarily unavailable.';
      case 503:
        message = 'Service unavailable. Please try again later.';
      case 504:
        message = 'Gateway timeout. The server took too long to respond.';
      default:
        message = 'Server error occurred (Code: $statusCode).';
    }
    return ServerException(
      message: message,
      statusCode: statusCode,
      responseBody: body,
    );
  }

  /// Creates a generic server exception.
  factory ServerException.generic() {
    return const ServerException(
      message: 'An unexpected server error occurred.',
      statusCode: 500,
    );
  }

  /// Optional response body from the server.
  final dynamic responseBody;
}

/// Exception thrown when local cache operations fail.
///
/// Used for errors involving shared preferences, local database,
/// file system operations, or any cached data operations.
///
/// Example usage:
/// ```dart
/// try {
///   final data = prefs.getString('user_data');
///   if (data == null) {
///     throw CacheException.notFound('user_data');
///   }
///   return jsonDecode(data);
/// } on CacheException catch (e) {
///   // Handle cache miss or error
/// }
/// ```
class CacheException extends AppException {
  /// Creates a new [CacheException] instance.
  const CacheException({
    required super.message,
    super.statusCode,
    this.cacheKey,
  });

  /// Creates a [CacheException] for when a cache key is not found.
  factory CacheException.notFound(String key) {
    return CacheException(
      message: 'Cache key "$key" not found.',
      cacheKey: key,
      statusCode: 404,
    );
  }

  /// Creates a [CacheException] for when writing to cache fails.
  factory CacheException.writeFailed(String key) {
    return CacheException(
      message: 'Failed to write to cache key "$key".',
      cacheKey: key,
      statusCode: 500,
    );
  }

  /// Creates a [CacheException] for when reading from cache fails.
  factory CacheException.readFailed(String key) {
    return CacheException(
      message: 'Failed to read from cache key "$key".',
      cacheKey: key,
      statusCode: 500,
    );
  }

  /// Creates a [CacheException] for when cached data is corrupted.
  factory CacheException.corrupted(String key) {
    return CacheException(
      message: 'Cached data for key "$key" is corrupted.',
      cacheKey: key,
      statusCode: 500,
    );
  }

  /// The cache key involved in the operation, if applicable.
  final String? cacheKey;

  @override
  String toString() =>
      'CacheException(message: $message, cacheKey: $cacheKey, statusCode: $statusCode)';
}

/// Exception thrown when network connectivity issues occur.
///
/// Used when the device has no internet connection, the network
/// request times out, or other connectivity-related issues.
///
/// Example usage:
/// ```dart
/// final connectivityResult = await Connectivity().checkConnectivity();
/// if (connectivityResult == ConnectivityResult.none) {
///   throw NetworkException.noConnection();
/// }
/// ```
class NetworkException extends AppException {
  /// Creates a new [NetworkException] instance.
  const NetworkException({
    required super.message,
    super.statusCode,
  });

  /// Creates a [NetworkException] for when there is no internet connection.
  factory NetworkException.noConnection() {
    return const NetworkException(
      message: 'No internet connection. Please check your network settings.',
      statusCode: 0,
    );
  }

  /// Creates a [NetworkException] for connection timeout.
  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'Connection timed out. Please check your internet connection.',
      statusCode: 408,
    );
  }

  /// Creates a [NetworkException] for when DNS resolution fails.
  factory NetworkException.dnsFailure() {
    return const NetworkException(
      message: 'Unable to resolve host. Please check your internet connection.',
      statusCode: 0,
    );
  }

  /// Creates a [NetworkException] for when connection is refused.
  factory NetworkException.connectionRefused() {
    return const NetworkException(
      message: 'Connection refused. The server may be unavailable.',
      statusCode: 0,
    );
  }
}

/// Exception thrown when authentication or authorization fails.
///
/// Used for 401 Unauthorized, 403 Forbidden responses, or when
/// tokens are expired/invalid.
///
/// Example usage:
/// ```dart
/// if (response.statusCode == 401) {
///   throw UnauthorizedException.sessionExpired();
/// }
/// if (response.statusCode == 403) {
///   throw UnauthorizedException.forbidden();
/// }
/// ```
class UnauthorizedException extends AppException {
  /// Creates a new [UnauthorizedException] instance.
  const UnauthorizedException({
    required super.message,
    super.statusCode,
  });

  /// Creates an [UnauthorizedException] for invalid credentials.
  factory UnauthorizedException.invalidCredentials() {
    return const UnauthorizedException(
      message: 'Invalid email or password.',
      statusCode: 401,
    );
  }

  /// Creates an [UnauthorizedException] for expired session/token.
  factory UnauthorizedException.sessionExpired() {
    return const UnauthorizedException(
      message: 'Your session has expired. Please log in again.',
      statusCode: 401,
    );
  }

  /// Creates an [UnauthorizedException] for invalid token.
  factory UnauthorizedException.invalidToken() {
    return const UnauthorizedException(
      message: 'Authentication token is invalid or malformed.',
      statusCode: 401,
    );
  }

  /// Creates an [UnauthorizedException] for forbidden access.
  factory UnauthorizedException.forbidden() {
    return const UnauthorizedException(
      message: 'You do not have permission to access this resource.',
      statusCode: 403,
    );
  }

  /// Creates an [UnauthorizedException] for account-related issues.
  factory UnauthorizedException.accountLocked() {
    return const UnauthorizedException(
      message: 'Your account has been locked. Please contact support.',
      statusCode: 403,
    );
  }
}

/// Exception thrown when a requested resource is not found.
///
/// Used for 404 Not Found responses or when querying for data
/// that doesn't exist.
///
/// Example usage:
/// ```dart
/// if (response.statusCode == 404) {
///   throw NotFoundException.resource('User', userId);
/// }
/// ```
class NotFoundException extends AppException {
  /// Creates a new [NotFoundException] instance.
  const NotFoundException({
    required super.message,
    super.statusCode = 404,
    this.resourceType,
    this.resourceId,
  });

  /// Creates a [NotFoundException] for a specific resource.
  factory NotFoundException.resource(String resourceType, String resourceId) {
    return NotFoundException(
      message: '$resourceType with ID "$resourceId" was not found.',
      resourceType: resourceType,
      resourceId: resourceId,
    );
  }

  /// Creates a [NotFoundException] for an endpoint.
  factory NotFoundException.endpoint(String endpoint) {
    return NotFoundException(
      message: 'The requested endpoint "$endpoint" was not found.',
    );
  }

  /// Creates a generic [NotFoundException].
  factory NotFoundException.generic() {
    return const NotFoundException(
      message: 'The requested resource was not found.',
    );
  }

  /// The type of resource that was not found.
  final String? resourceType;

  /// The identifier of the resource that was not found.
  final String? resourceId;

  @override
  String toString() =>
      'NotFoundException(message: $message, resourceType: $resourceType, resourceId: $resourceId)';
}
