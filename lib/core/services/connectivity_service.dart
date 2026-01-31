/// Connectivity monitoring service for App Pasos.
///
/// This file defines an abstract interface and implementation for network
/// connectivity monitoring. Uses dart:io for DNS lookups to determine
/// actual network availability without external dependencies.
library;

import 'dart:async';
import 'dart:io';

/// Abstract interface for connectivity monitoring operations.
///
/// This interface enables dependency injection and testing by allowing
/// mock implementations. All connectivity checks should go through
/// this service.
///
/// The connectivity service handles:
/// - Monitoring network connectivity changes
/// - Checking if the device is currently connected
/// - Emitting connectivity change events via stream
///
/// Example usage:
/// ```dart
/// final connectivityService = ConnectivityServiceImpl();
/// await connectivityService.initialize();
///
/// // Listen for connectivity changes
/// connectivityService.onConnectivityChanged.listen((isConnected) {
///   print('Connectivity changed: $isConnected');
/// });
///
/// // Check current status
/// final connected = await connectivityService.isConnected;
/// print('Currently connected: $connected');
///
/// // Later, when no longer needed
/// connectivityService.dispose();
/// ```
abstract interface class ConnectivityService {
  /// Stream that emits connectivity status changes.
  ///
  /// Emits `true` when connectivity is established and `false` when lost.
  /// The stream is broadcast, allowing multiple listeners.
  ///
  /// Note: Changes are detected via periodic polling (every 5 seconds)
  /// due to platform limitations with passive network monitoring.
  Stream<bool> get onConnectivityChanged;

  /// Checks if the device is currently connected to the internet.
  ///
  /// Returns `true` if a DNS lookup succeeds, indicating network access.
  /// Returns `false` if the lookup fails or times out.
  ///
  /// This performs an actual network check by attempting to resolve
  /// a well-known hostname (google.com by default).
  Future<bool> get isConnected;

  /// Initializes the connectivity monitoring system.
  ///
  /// This method must be called before using other methods.
  /// It starts the periodic connectivity check timer.
  ///
  /// This method is idempotent - calling it multiple times has no
  /// additional effect after the first successful initialization.
  Future<void> initialize();

  /// Disposes resources used by the connectivity service.
  ///
  /// Stops the periodic check timer and closes the stream controller.
  /// After calling this, the service should not be used anymore.
  void dispose();
}

/// Implementation of [ConnectivityService] using dart:io DNS lookups.
///
/// This implementation checks connectivity by attempting to resolve
/// a hostname via DNS. This approach works without requiring any
/// external packages and provides reliable connectivity detection.
///
/// Connectivity is checked:
/// - On demand via [isConnected]
/// - Periodically every 5 seconds when initialized
///
/// Example usage:
/// ```dart
/// final service = ConnectivityServiceImpl();
/// await service.initialize();
///
/// // Listen for changes
/// service.onConnectivityChanged.listen((connected) {
///   if (connected) {
///     print('Back online - sync pending operations');
///   } else {
///     print('Offline - queue operations locally');
///   }
/// });
///
/// // Check current status
/// if (await service.isConnected) {
///   await performNetworkOperation();
/// }
///
/// // Cleanup when done
/// service.dispose();
/// ```
class ConnectivityServiceImpl implements ConnectivityService {
  /// Creates a [ConnectivityServiceImpl] instance.
  ///
  /// [checkHost] - The hostname to use for connectivity checks.
  /// Defaults to 'google.com' which is generally highly available.
  ///
  /// [checkInterval] - How often to poll for connectivity changes.
  /// Defaults to 5 seconds for responsive detection without excessive
  /// battery drain.
  ConnectivityServiceImpl({
    String checkHost = 'google.com',
    Duration checkInterval = const Duration(seconds: 5),
  })  : _checkHost = checkHost,
        _checkInterval = checkInterval;

  /// The hostname to resolve for connectivity checks.
  final String _checkHost;

  /// The interval between periodic connectivity checks.
  final Duration _checkInterval;

  /// Stream controller for broadcasting connectivity changes.
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  /// Timer for periodic connectivity checks.
  Timer? _checkTimer;

  /// The last known connectivity status.
  bool? _lastKnownStatus;

  /// Whether the service has been initialized.
  bool _isInitialized = false;

  /// Timeout duration for DNS lookups.
  static const Duration _lookupTimeout = Duration(seconds: 3);

  // ============================================================
  // Stream Access
  // ============================================================

  @override
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  // ============================================================
  // Connectivity Status
  // ============================================================

  @override
  Future<bool> get isConnected async {
    return _checkConnectivity();
  }

  // ============================================================
  // Initialization
  // ============================================================

  @override
  Future<void> initialize() async {
    // Idempotent - skip if already initialized
    if (_isInitialized) {
      return;
    }

    try {
      // Perform initial connectivity check
      _lastKnownStatus = await _checkConnectivity();

      // Emit initial status
      _connectivityController.add(_lastKnownStatus!);

      // Start periodic checks
      _startPeriodicCheck();

      _isInitialized = true;
    } catch (e) {
      // If initial check fails, assume offline and continue
      _lastKnownStatus = false;
      _connectivityController.add(false);
      _startPeriodicCheck();
      _isInitialized = true;
    }
  }

  // ============================================================
  // Disposal
  // ============================================================

  @override
  void dispose() {
    _checkTimer?.cancel();
    _checkTimer = null;
    _connectivityController.close();
    _isInitialized = false;
  }

  // ============================================================
  // Private Methods
  // ============================================================

  /// Performs a DNS lookup to check connectivity.
  ///
  /// Returns `true` if the lookup succeeds within the timeout,
  /// `false` otherwise.
  Future<bool> _checkConnectivity() async {
    try {
      // Attempt DNS lookup with timeout
      final results = await InternetAddress.lookup(_checkHost)
          .timeout(_lookupTimeout);

      // Check if we got valid results with IP addresses
      return results.isNotEmpty && results.first.rawAddress.isNotEmpty;
    } on SocketException {
      // No internet connection
      return false;
    } on TimeoutException {
      // Lookup timed out - consider as disconnected
      return false;
    } catch (e) {
      // Any other error - assume disconnected
      return false;
    }
  }

  /// Starts the periodic connectivity check timer.
  void _startPeriodicCheck() {
    // Cancel any existing timer
    _checkTimer?.cancel();

    // Start new periodic check
    _checkTimer = Timer.periodic(_checkInterval, (_) async {
      await _performPeriodicCheck();
    });
  }

  /// Performs a single periodic connectivity check.
  ///
  /// Compares the current status with the last known status
  /// and emits an event if there's a change.
  Future<void> _performPeriodicCheck() async {
    final currentStatus = await _checkConnectivity();

    // Only emit if status changed
    if (currentStatus != _lastKnownStatus) {
      _lastKnownStatus = currentStatus;
      _connectivityController.add(currentStatus);
    }
  }
}
