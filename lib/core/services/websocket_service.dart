import 'dart:async';
import 'dart:io';
import 'dart:math';

import '../config/app_config.dart';
import '../utils/logger.dart';
import 'websocket_events.dart';

/// Connection states for WebSocket.
///
/// Represents the current state of the WebSocket connection lifecycle.
enum WebSocketConnectionState {
  /// WebSocket is not connected
  disconnected,

  /// WebSocket is attempting to connect
  connecting,

  /// WebSocket is connected and authenticated
  connected,

  /// WebSocket is attempting to reconnect after a disconnection
  reconnecting,

  /// WebSocket encountered an error
  error,
}

/// WebSocket service with authentication and automatic reconnection.
///
/// Provides real-time communication with the backend server including:
/// - Automatic connection management
/// - Token-based authentication
/// - Exponential backoff reconnection
/// - Event streaming for incoming messages
/// - Connection state monitoring
///
/// Example usage:
/// ```dart
/// final wsService = WebSocketService();
///
/// // Listen to connection state changes
/// wsService.connectionStateStream.listen((state) {
///   print('Connection state: $state');
/// });
///
/// // Listen to incoming events
/// wsService.eventStream.listen((event) {
///   print('Received event: ${event.type}');
/// });
///
/// // Connect with authentication token
/// await wsService.connect('user-auth-token');
///
/// // Send an event
/// wsService.send(WebSocketEvent(
///   type: WebSocketEventType.stepsUpdated,
///   data: {'steps': 5000},
/// ));
///
/// // Disconnect when done
/// wsService.disconnect();
/// ```
class WebSocketService {
  // Singleton pattern
  static WebSocketService? _instance;

  /// Returns the singleton instance of [WebSocketService].
  factory WebSocketService() => _instance ??= WebSocketService._internal();

  WebSocketService._internal();

  /// Resets the singleton instance (useful for testing).
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }

  // WebSocket connection
  WebSocket? _socket;
  String? _authToken;

  // Connection state management
  WebSocketConnectionState _connectionState = WebSocketConnectionState.disconnected;
  final _connectionStateController = StreamController<WebSocketConnectionState>.broadcast();

  // Event stream management
  final _eventController = StreamController<WebSocketEvent>.broadcast();

  // Reconnection configuration
  static const int _maxReconnectAttempts = 10;
  static const int _maxReconnectDelaySeconds = 30;
  static const int _initialReconnectDelaySeconds = 1;

  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool _intentionalDisconnect = false;

  /// Stream of connection state changes.
  ///
  /// Subscribe to this stream to monitor the WebSocket connection status
  /// and update UI accordingly.
  Stream<WebSocketConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// Stream of incoming WebSocket events.
  ///
  /// Subscribe to this stream to receive real-time events from the server.
  Stream<WebSocketEvent> get eventStream => _eventController.stream;

  /// Returns true if the WebSocket is currently connected.
  bool get isConnected => _connectionState == WebSocketConnectionState.connected;

  /// Returns the current connection state.
  WebSocketConnectionState get connectionState => _connectionState;

  /// Updates the connection state and notifies listeners.
  void _setConnectionState(WebSocketConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      _connectionStateController.add(state);
      AppLogger.debug('WebSocket connection state changed to: $state');
    }
  }

  /// Connects to the WebSocket server with authentication.
  ///
  /// [authToken] is the JWT token used for authentication.
  /// The token is passed as a query parameter during connection.
  ///
  /// Throws an exception if connection fails and reconnection is exhausted.
  Future<void> connect(String authToken) async {
    if (_connectionState == WebSocketConnectionState.connected ||
        _connectionState == WebSocketConnectionState.connecting) {
      AppLogger.warning('WebSocket already connected or connecting');
      return;
    }

    _authToken = authToken;
    _intentionalDisconnect = false;
    _reconnectAttempts = 0;

    await _establishConnection();
  }

  /// Establishes the WebSocket connection.
  Future<void> _establishConnection() async {
    _setConnectionState(WebSocketConnectionState.connecting);

    try {
      final wsUrl = _buildWebSocketUrl();
      AppLogger.info('Connecting to WebSocket: $wsUrl');

      _socket = await WebSocket.connect(
        wsUrl,
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('WebSocket connection timed out');
        },
      );

      _setConnectionState(WebSocketConnectionState.connected);
      _reconnectAttempts = 0;

      // Emit connected event
      _eventController.add(WebSocketEvent.connected());

      AppLogger.info('WebSocket connected successfully');

      // Listen for incoming messages
      _socket!.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } on SocketException catch (e, stackTrace) {
      AppLogger.error('WebSocket connection failed: Socket error', e, stackTrace);
      _handleConnectionFailure();
    } on TimeoutException catch (e, stackTrace) {
      AppLogger.error('WebSocket connection failed: Timeout', e, stackTrace);
      _handleConnectionFailure();
    } on WebSocketException catch (e, stackTrace) {
      AppLogger.error('WebSocket connection failed: WebSocket error', e, stackTrace);
      _handleConnectionFailure();
    } catch (e, stackTrace) {
      AppLogger.error('WebSocket connection failed: Unknown error', e, stackTrace);
      _handleConnectionFailure();
    }
  }

  /// Builds the WebSocket URL with authentication token.
  String _buildWebSocketUrl() {
    final baseWsUrl = AppConfig.wsUrl;
    // Append token as query parameter for servers that don't support headers
    final uri = Uri.parse(baseWsUrl);
    final wsUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'token': _authToken,
      },
    );
    return wsUri.toString();
  }

  /// Handles incoming WebSocket messages.
  void _onMessage(dynamic data) {
    try {
      if (data is String) {
        final event = WebSocketEvent.fromJson(data);
        if (event != null) {
          AppLogger.debug('Received WebSocket event: ${event.type}');
          _eventController.add(event);
        } else {
          AppLogger.warning('Failed to parse WebSocket message: $data');
        }
      } else {
        AppLogger.warning('Received non-string WebSocket data: ${data.runtimeType}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error processing WebSocket message', e, stackTrace);
    }
  }

  /// Handles WebSocket errors.
  void _onError(dynamic error, [StackTrace? stackTrace]) {
    AppLogger.error('WebSocket error', error, stackTrace);
    _setConnectionState(WebSocketConnectionState.error);
    _eventController.add(WebSocketEvent.error(
      message: error.toString(),
    ));
  }

  /// Handles WebSocket connection close.
  void _onDone() {
    AppLogger.info('WebSocket connection closed');

    _socket = null;

    if (_intentionalDisconnect) {
      _setConnectionState(WebSocketConnectionState.disconnected);
      _eventController.add(WebSocketEvent.disconnected(reason: 'User initiated'));
    } else {
      _eventController.add(WebSocketEvent.disconnected(reason: 'Connection lost'));
      _attemptReconnect();
    }
  }

  /// Handles connection failure and initiates reconnection if appropriate.
  void _handleConnectionFailure() {
    _socket = null;
    _setConnectionState(WebSocketConnectionState.error);

    if (!_intentionalDisconnect) {
      _attemptReconnect();
    }
  }

  /// Attempts to reconnect with exponential backoff.
  void _attemptReconnect() {
    if (_intentionalDisconnect || _authToken == null) {
      AppLogger.debug('Reconnection skipped: intentional disconnect or no auth token');
      return;
    }

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      AppLogger.error('Max reconnection attempts reached ($_maxReconnectAttempts)');
      _setConnectionState(WebSocketConnectionState.error);
      _eventController.add(WebSocketEvent.error(
        message: 'Max reconnection attempts exceeded',
        code: 'MAX_RECONNECT_EXCEEDED',
      ));
      return;
    }

    _reconnectAttempts++;
    _setConnectionState(WebSocketConnectionState.reconnecting);

    // Calculate exponential backoff delay
    final delaySeconds = _calculateBackoffDelay();
    AppLogger.info(
      'Attempting reconnection $_reconnectAttempts/$_maxReconnectAttempts '
      'in ${delaySeconds}s',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      Duration(seconds: delaySeconds),
      () async {
        if (!_intentionalDisconnect && _authToken != null) {
          await _establishConnection();
        }
      },
    );
  }

  /// Calculates the backoff delay using exponential backoff algorithm.
  ///
  /// Formula: min(maxDelay, initialDelay * 2^(attempts-1))
  /// With jitter to prevent thundering herd.
  int _calculateBackoffDelay() {
    final exponentialDelay = _initialReconnectDelaySeconds *
        pow(2, _reconnectAttempts - 1).toInt();
    final cappedDelay = min(exponentialDelay, _maxReconnectDelaySeconds);

    // Add random jitter (±20%)
    final jitter = (cappedDelay * 0.2 * (Random().nextDouble() - 0.5)).toInt();
    return max(1, cappedDelay + jitter);
  }

  /// Disconnects from the WebSocket server.
  ///
  /// This is an intentional disconnect and will not trigger reconnection.
  void disconnect() {
    AppLogger.info('Disconnecting WebSocket');
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_socket != null) {
      _socket!.close(WebSocketStatus.normalClosure, 'Client disconnect');
      _socket = null;
    }

    _setConnectionState(WebSocketConnectionState.disconnected);
    _authToken = null;
    _reconnectAttempts = 0;
  }

  /// Sends a WebSocket event to the server.
  ///
  /// Returns true if the event was sent successfully, false otherwise.
  bool send(WebSocketEvent event) {
    if (_socket == null || _connectionState != WebSocketConnectionState.connected) {
      AppLogger.warning('Cannot send event: WebSocket not connected');
      return false;
    }

    try {
      final jsonString = event.toJson();
      _socket!.add(jsonString);
      AppLogger.debug('Sent WebSocket event: ${event.type}');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send WebSocket event', e, stackTrace);
      return false;
    }
  }

  /// Sends raw data to the WebSocket server.
  ///
  /// Use [send] instead for type-safe event sending.
  bool sendRaw(String data) {
    if (_socket == null || _connectionState != WebSocketConnectionState.connected) {
      AppLogger.warning('Cannot send raw data: WebSocket not connected');
      return false;
    }

    try {
      _socket!.add(data);
      AppLogger.debug('Sent raw WebSocket data');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send raw WebSocket data', e, stackTrace);
      return false;
    }
  }

  /// Forces a reconnection attempt.
  ///
  /// Useful when the app comes back to foreground or network changes.
  Future<void> reconnect() async {
    if (_authToken == null) {
      AppLogger.warning('Cannot reconnect: No auth token available');
      return;
    }

    AppLogger.info('Forcing reconnection');
    _intentionalDisconnect = false;
    _reconnectAttempts = 0;

    // Close existing connection if any
    if (_socket != null) {
      await _socket!.close(WebSocketStatus.goingAway, 'Reconnecting');
      _socket = null;
    }

    await _establishConnection();
  }

  /// Disposes the WebSocket service and releases resources.
  ///
  /// Call this when the service is no longer needed.
  void dispose() {
    AppLogger.debug('Disposing WebSocket service');
    disconnect();
    _connectionStateController.close();
    _eventController.close();
  }

  /// Returns the number of reconnection attempts made.
  int get reconnectAttempts => _reconnectAttempts;

  /// Returns whether the service is attempting to reconnect.
  bool get isReconnecting =>
      _connectionState == WebSocketConnectionState.reconnecting;
}
