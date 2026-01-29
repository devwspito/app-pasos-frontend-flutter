/// WebSocket service implementation for real-time communication.
///
/// This file provides the concrete implementation of [WebSocketService] using
/// the web_socket_channel package for WebSocket connections with automatic
/// reconnection and authentication support.
library;

import 'dart:async';
import 'dart:convert';

import 'package:app_pasos_frontend/core/network/api_endpoints.dart';
import 'package:app_pasos_frontend/core/services/websocket_service.dart';
import 'package:app_pasos_frontend/core/storage/secure_storage_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Implementation of [WebSocketService] using web_socket_channel.
///
/// This implementation provides:
/// - Authenticated WebSocket connections using JWT tokens
/// - Automatic reconnection with exponential backoff
/// - JSON message parsing and serialization
/// - Stream-based message broadcasting
///
/// Example usage:
/// ```dart
/// final storageService = SecureStorageServiceImpl();
/// final wsService = WebSocketServiceImpl(storageService: storageService);
///
/// await wsService.connect();
///
/// wsService.messageStream.listen((message) {
///   print('Received: $message');
/// });
///
/// wsService.send({'type': 'ping'});
///
/// await wsService.disconnect();
/// ```
class WebSocketServiceImpl implements WebSocketService {
  /// Creates a [WebSocketServiceImpl] instance.
  ///
  /// [storageService] is required to retrieve the authentication token
  /// for establishing authenticated WebSocket connections.
  WebSocketServiceImpl({required SecureStorageService storageService})
      : _storageService = storageService;

  /// The secure storage service for retrieving auth tokens.
  final SecureStorageService _storageService;

  /// The underlying WebSocket channel.
  WebSocketChannel? _channel;

  /// Stream controller for broadcasting incoming messages.
  StreamController<Map<String, dynamic>>? _messageController;

  /// Subscription to the WebSocket channel stream.
  StreamSubscription<dynamic>? _channelSubscription;

  /// Current connection status.
  bool _isConnected = false;

  /// Current reconnection attempt count.
  int _reconnectAttempts = 0;

  /// Maximum number of reconnection attempts.
  static const int _maxReconnectAttempts = 3;

  /// Base delay for exponential backoff (in milliseconds).
  static const int _baseReconnectDelayMs = 1000;

  /// Flag to indicate if reconnection is in progress.
  bool _isReconnecting = false;

  /// Flag to indicate if disconnect was called intentionally.
  bool _intentionalDisconnect = false;

  // ============================================================
  // Connection Management
  // ============================================================

  @override
  Future<void> connect() async {
    // If already connected, do nothing
    if (_isConnected) {
      return;
    }

    // Reset intentional disconnect flag
    _intentionalDisconnect = false;

    // Get authentication token
    final token = await _storageService.getAuthToken();
    if (token == null || token.isEmpty) {
      throw WebSocketException('No authentication token available');
    }

    // Build WebSocket URL with token as query parameter
    final wsUrl = _buildWebSocketUrl(token);

    try {
      // Establish WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Initialize message stream controller
      _messageController = StreamController<Map<String, dynamic>>.broadcast();

      // Set up channel stream listener
      _channelSubscription = _channel!.stream.listen(
        _handleIncomingMessage,
        onError: _handleConnectionError,
        onDone: _handleConnectionClosed,
      );

      // Mark as connected
      _isConnected = true;
      _reconnectAttempts = 0;
    } catch (e) {
      _isConnected = false;
      throw WebSocketException('Failed to connect: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    // Mark as intentional disconnect to prevent reconnection
    _intentionalDisconnect = true;
    _isConnected = false;

    // Cancel channel subscription
    await _channelSubscription?.cancel();
    _channelSubscription = null;

    // Close WebSocket channel
    await _channel?.sink.close();
    _channel = null;

    // Close message stream controller
    await _messageController?.close();
    _messageController = null;

    // Reset reconnection state
    _reconnectAttempts = 0;
    _isReconnecting = false;
  }

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<Map<String, dynamic>> get messageStream {
    if (_messageController == null) {
      // Return an empty stream if not connected
      return const Stream<Map<String, dynamic>>.empty();
    }
    return _messageController!.stream;
  }

  @override
  void send(Map<String, dynamic> message) {
    if (!_isConnected || _channel == null) {
      throw WebSocketException('WebSocket is not connected');
    }

    try {
      final jsonString = jsonEncode(message);
      _channel!.sink.add(jsonString);
    } catch (e) {
      throw WebSocketException('Failed to send message: $e');
    }
  }

  // ============================================================
  // Private Helper Methods
  // ============================================================

  /// Builds the WebSocket URL with authentication token.
  ///
  /// Converts the HTTP base URL to WebSocket protocol (ws/wss)
  /// and appends the token as a query parameter.
  String _buildWebSocketUrl(String token) {
    // Get base URL and convert to WebSocket URL
    final httpUrl = ApiEndpoints.baseUrl;

    // Replace http:// with ws:// and https:// with wss://
    String wsUrl;
    if (httpUrl.startsWith('https://')) {
      wsUrl = httpUrl.replaceFirst('https://', 'wss://');
    } else if (httpUrl.startsWith('http://')) {
      wsUrl = httpUrl.replaceFirst('http://', 'ws://');
    } else {
      wsUrl = 'ws://$httpUrl';
    }

    // Remove /api suffix and add /ws path
    if (wsUrl.endsWith('/api')) {
      wsUrl = wsUrl.substring(0, wsUrl.length - 4);
    }
    wsUrl = '$wsUrl/ws';

    // Append token as query parameter
    return '$wsUrl?token=${Uri.encodeComponent(token)}';
  }

  /// Handles incoming messages from the WebSocket channel.
  void _handleIncomingMessage(dynamic data) {
    if (_messageController == null || _messageController!.isClosed) {
      return;
    }

    try {
      // Parse JSON string to Map
      if (data is String) {
        final message = jsonDecode(data) as Map<String, dynamic>;
        _messageController!.add(message);
      } else if (data is Map<String, dynamic>) {
        _messageController!.add(data);
      } else {
        // Attempt to convert other types
        final jsonString = data.toString();
        final message = jsonDecode(jsonString) as Map<String, dynamic>;
        _messageController!.add(message);
      }
    } catch (e) {
      // Add error to stream for malformed messages
      _messageController!.addError(
        WebSocketException('Failed to parse message: $e'),
      );
    }
  }

  /// Handles connection errors from the WebSocket channel.
  void _handleConnectionError(Object error) {
    _isConnected = false;

    // Add error to message stream
    if (_messageController != null && !_messageController!.isClosed) {
      _messageController!.addError(
        WebSocketException('Connection error: $error'),
      );
    }

    // Attempt reconnection if not intentional disconnect
    if (!_intentionalDisconnect) {
      _attemptReconnection();
    }
  }

  /// Handles when the WebSocket connection is closed.
  void _handleConnectionClosed() {
    _isConnected = false;

    // Attempt reconnection if not intentional disconnect
    if (!_intentionalDisconnect) {
      _attemptReconnection();
    }
  }

  /// Attempts to reconnect with exponential backoff.
  Future<void> _attemptReconnection() async {
    // Prevent multiple simultaneous reconnection attempts
    if (_isReconnecting || _intentionalDisconnect) {
      return;
    }

    // Check if we've exceeded max attempts
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      if (_messageController != null && !_messageController!.isClosed) {
        _messageController!.addError(
          WebSocketException(
            'Max reconnection attempts ($_maxReconnectAttempts) exceeded',
          ),
        );
      }
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;

    // Calculate delay with exponential backoff
    final delayMs = _baseReconnectDelayMs * (1 << (_reconnectAttempts - 1));

    // Wait before attempting reconnection
    await Future<void>.delayed(Duration(milliseconds: delayMs));

    // Attempt reconnection
    try {
      // Clean up existing resources
      await _channelSubscription?.cancel();
      _channelSubscription = null;
      await _channel?.sink.close();
      _channel = null;

      // Get fresh token and reconnect
      final token = await _storageService.getAuthToken();
      if (token == null || token.isEmpty) {
        _isReconnecting = false;
        return;
      }

      final wsUrl = _buildWebSocketUrl(token);
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Set up new channel stream listener
      _channelSubscription = _channel!.stream.listen(
        _handleIncomingMessage,
        onError: _handleConnectionError,
        onDone: _handleConnectionClosed,
      );

      _isConnected = true;
      _reconnectAttempts = 0;
    } catch (e) {
      // Reconnection failed, will be retried via _handleConnectionError
    } finally {
      _isReconnecting = false;
    }
  }
}

/// Exception thrown for WebSocket-related errors.
///
/// This exception provides detailed error information for WebSocket
/// operations including connection, message parsing, and sending.
class WebSocketException implements Exception {
  /// Creates a [WebSocketException] with the given message.
  const WebSocketException(this.message);

  /// The error message describing what went wrong.
  final String message;

  @override
  String toString() => 'WebSocketException: $message';
}
