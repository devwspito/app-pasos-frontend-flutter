/// API response wrapper matching the backend contract.
///
/// This file contains classes for deserializing API responses
/// from the backend, providing type-safe access to response data.

/// Metadata for paginated API responses.
///
/// Contains pagination information such as total count,
/// current page, and items per page.
///
/// Example:
/// ```dart
/// final response = await apiClient.get<List<User>>('/users');
/// if (response.meta != null) {
///   print('Page ${response.meta!.page} of ${response.meta!.totalPages}');
/// }
/// ```
class ApiMeta {
  /// Total number of items across all pages
  final int? total;

  /// Current page number (1-based)
  final int? page;

  /// Number of items per page
  final int? limit;

  /// Creates an [ApiMeta] instance.
  const ApiMeta({
    this.total,
    this.page,
    this.limit,
  });

  /// Creates an [ApiMeta] from a JSON map.
  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      total: json['total'] as int?,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
    );
  }

  /// Converts this [ApiMeta] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (total != null) 'total': total,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };
  }

  /// Calculates the total number of pages.
  ///
  /// Returns null if total or limit is not available.
  int? get totalPages {
    if (total == null || limit == null || limit == 0) return null;
    return (total! / limit!).ceil();
  }

  /// Whether there is a next page available.
  ///
  /// Returns null if pagination info is incomplete.
  bool? get hasNextPage {
    final pages = totalPages;
    if (pages == null || page == null) return null;
    return page! < pages;
  }

  /// Whether there is a previous page available.
  ///
  /// Returns null if page info is not available.
  bool? get hasPreviousPage {
    if (page == null) return null;
    return page! > 1;
  }

  @override
  String toString() {
    return 'ApiMeta(total: $total, page: $page, limit: $limit)';
  }
}

/// Generic API response wrapper matching the backend contract.
///
/// All API responses from the backend follow this structure:
/// - `success`: Boolean indicating operation success
/// - `message`: Optional human-readable message
/// - `data`: The actual response payload (generic type T)
/// - `meta`: Optional pagination metadata
///
/// Example:
/// ```dart
/// final response = ApiResponse<User>.fromJson(
///   json,
///   (data) => User.fromJson(data as Map<String, dynamic>),
/// );
///
/// if (response.success && response.data != null) {
///   final user = response.data!;
///   print('Hello, ${user.name}!');
/// }
/// ```
class ApiResponse<T> {
  /// Whether the API operation was successful
  final bool success;

  /// Optional message from the server
  final String? message;

  /// The response data payload
  final T? data;

  /// Optional pagination metadata
  final ApiMeta? meta;

  /// Creates an [ApiResponse] instance.
  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.meta,
  });

  /// Creates an [ApiResponse] from a JSON map.
  ///
  /// The [fromJsonT] function is used to deserialize the `data` field
  /// into the appropriate type T.
  ///
  /// Example:
  /// ```dart
  /// final response = ApiResponse<User>.fromJson(
  ///   jsonMap,
  ///   (json) => User.fromJson(json as Map<String, dynamic>),
  /// );
  /// ```
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      meta: json['meta'] != null
          ? ApiMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Creates a success [ApiResponse] with data.
  ///
  /// Useful for testing or creating mock responses.
  factory ApiResponse.success({
    T? data,
    String? message,
    ApiMeta? meta,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      meta: meta,
    );
  }

  /// Creates a failure [ApiResponse] with a message.
  ///
  /// Useful for testing or creating error responses.
  factory ApiResponse.failure({
    required String message,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
    );
  }

  /// Converts this [ApiResponse] to a JSON map.
  ///
  /// The [toJsonT] function is used to serialize the data field.
  /// If not provided, the data will be included as-is.
  Map<String, dynamic> toJson([Object? Function(T value)? toJsonT]) {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null)
        'data': toJsonT != null ? toJsonT(data as T) : data,
      if (meta != null) 'meta': meta!.toJson(),
    };
  }

  /// Returns true if the response was successful and contains data.
  bool get hasData => success && data != null;

  /// Returns true if the response was successful but contains no data.
  bool get isEmpty => success && data == null;

  /// Returns true if the response was a failure.
  bool get isFailure => !success;

  /// Returns true if the response has pagination metadata.
  bool get hasMeta => meta != null;

  /// Maps the data to a new type using the provided [mapper] function.
  ///
  /// Example:
  /// ```dart
  /// final userResponse = apiResponse.map((user) => UserViewModel(user));
  /// ```
  ApiResponse<R> map<R>(R Function(T data) mapper) {
    return ApiResponse<R>(
      success: success,
      message: message,
      data: data != null ? mapper(data as T) : null,
      meta: meta,
    );
  }

  /// Executes [onSuccess] if the response is successful with data,
  /// otherwise executes [onFailure].
  ///
  /// Example:
  /// ```dart
  /// response.when(
  ///   onSuccess: (user) => print('Welcome, ${user.name}!'),
  ///   onFailure: (message) => print('Error: $message'),
  /// );
  /// ```
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(String? message) onFailure,
  }) {
    if (success && data != null) {
      return onSuccess(data as T);
    }
    return onFailure(message);
  }

  /// Executes [onSuccess] if the response is successful with data,
  /// otherwise returns null.
  ///
  /// Example:
  /// ```dart
  /// final userName = response.whenOrNull(
  ///   onSuccess: (user) => user.name,
  /// );
  /// ```
  R? whenOrNull<R>({
    R Function(T data)? onSuccess,
    R Function(String? message)? onFailure,
  }) {
    if (success && data != null && onSuccess != null) {
      return onSuccess(data as T);
    }
    if (!success && onFailure != null) {
      return onFailure(message);
    }
    return null;
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, '
        'data: $data, meta: $meta)';
  }
}

/// Extension methods for [ApiResponse] containing a List.
extension ApiResponseListExtension<T> on ApiResponse<List<T>> {
  /// Returns true if the data list is empty.
  bool get isListEmpty => data?.isEmpty ?? true;

  /// Returns true if the data list is not empty.
  bool get isListNotEmpty => data?.isNotEmpty ?? false;

  /// Returns the number of items in the data list.
  int get itemCount => data?.length ?? 0;
}
