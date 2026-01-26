import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for network connectivity information.
///
/// This interface provides methods to check current network connectivity
/// and listen to connectivity changes.
abstract class NetworkInfo {
  /// Returns true if the device is currently connected to a network.
  Future<bool> get isConnected;

  /// Stream that emits connectivity status changes.
  /// Emits true when connected, false when disconnected.
  Stream<bool> get onConnectivityChanged;
}

/// Implementation of [NetworkInfo] using connectivity_plus package.
///
/// This class provides network connectivity detection functionality
/// for the application. It wraps the connectivity_plus plugin to provide
/// a clean interface for checking network status.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  /// Creates a new [NetworkInfoImpl] instance.
  ///
  /// Optionally accepts a [Connectivity] instance for testing purposes.
  /// If not provided, a default instance will be created.
  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) => !results.contains(ConnectivityResult.none),
    );
  }
}
