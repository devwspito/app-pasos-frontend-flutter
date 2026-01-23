import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// Exception thrown when there is no network connectivity.
///
/// This exception is used by [ConnectivityInterceptor] to signal
/// that a request cannot be made due to lack of network connection.
class NoConnectivityException extends DioException {
  NoConnectivityException({required super.requestOptions})
      : super(
          type: DioExceptionType.connectionError,
          message: 'No internet connection available',
        );

  @override
  String toString() => 'NoConnectivityException: No internet connection available';
}

/// Interceptor that checks network connectivity before making requests.
///
/// This interceptor uses [connectivity_plus] to verify that the device
/// has an active network connection before allowing requests to proceed.
///
/// If no connection is available, a [NoConnectivityException] is thrown,
/// allowing the calling code to handle offline scenarios gracefully.
///
/// Example handling:
/// ```dart
/// try {
///   final response = await apiClient.get('/data');
/// } on NoConnectivityException {
///   // Show offline message to user
///   showSnackBar('You are offline. Please check your connection.');
/// } on DioException catch (e) {
///   // Handle other network errors
/// }
/// ```
class ConnectivityInterceptor extends Interceptor {
  final Connectivity _connectivity;

  /// Creates a [ConnectivityInterceptor].
  ///
  /// If no [Connectivity] instance is provided, creates a new one.
  ConnectivityInterceptor([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  /// Checks network connectivity before allowing the request to proceed.
  ///
  /// If the device has no network connection (wifi, mobile, ethernet, vpn),
  /// rejects the request with a [NoConnectivityException].
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip connectivity check if explicitly requested
    if (options.extra['skipConnectivityCheck'] == true) {
      return handler.next(options);
    }

    final hasConnection = await _checkConnectivity();

    if (!hasConnection) {
      return handler.reject(
        NoConnectivityException(requestOptions: options),
      );
    }

    handler.next(options);
  }

  /// Checks if the device has an active network connection.
  ///
  /// Returns `true` if connected via wifi, mobile data, ethernet, or VPN.
  /// Returns `false` if no connection is available.
  Future<bool> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();

    // connectivity_plus returns a list of ConnectivityResult
    // Check if any connection type indicates connectivity
    return connectivityResult.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn);
  }
}
