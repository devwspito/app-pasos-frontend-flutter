/// WebSocket service for real-time communication in App Pasos.
///
/// This file defines an abstract interface for WebSocket operations.
/// Implementations will provide platform-specific integrations for
/// establishing and managing WebSocket connections with the backend.
library;

/// Abstract interface for WebSocket operations.
///
/// This interface enables dependency injection and testing by allowing
/// mock implementations. All real-time communication should go through
/// this service.
///
/// The WebSocket service handles:
/// - Establishing authenticated connections to the backend
/// - Sending and receiving messages in real-time
/// - Managing connection state and reconnection logic
///
/// Example usage:
/// ```dart
/// final wsService = WebSocketServiceImpl(storageService);
/// await wsService.connect();
///
/// // Listen for incoming messages
/// wsService.messageStream.listen((message) {
///   print('Received: $message');
/// });
///
/// // Send a message
/// wsService.send({'type': 'ping'});
///
/// // Check connection status
/// if (wsService.isConnected) {
///   print('WebSocket is connected');
/// }
///
/// // Disconnect when done
/// await wsService.disconnect();
/// ```
abstract interface class WebSocketService {
  /// Establishes a WebSocket connection with the backend.
  ///
  /// This method retrieves the authentication token from secure storage
  /// and establishes a WebSocket connection with the token as a query
  /// parameter for authentication.
  ///
  /// Connection includes:
  /// - Retrieving JWT token from secure storage
  /// - Appending token as query parameter: `ws://host?token=JWT`
  /// - Establishing the WebSocket connection
  /// - Setting up automatic reconnection on failure
  ///
  /// Throws an exception if:
  /// - No authentication token is available
  /// - The connection cannot be established
  /// - The server rejects the connection
  ///
  /// If already connected, this method does nothing.
  Future<void> connect();

  /// Closes the WebSocket connection gracefully.
  ///
  /// This method performs a clean shutdown of the WebSocket connection:
  /// - Sends a close frame to the server
  /// - Closes the underlying channel
  /// - Clears the message stream controller
  /// - Resets connection state
  ///
  /// This method is safe to call even if not currently connected.
  /// Calling it multiple times has no additional effect.
  ///
  /// Note: Any pending messages will be discarded after disconnection.
  Future<void> disconnect();

  /// Returns whether the WebSocket connection is currently active.
  ///
  /// Returns `true` if:
  /// - A connection has been established via [connect]
  /// - The connection has not been closed
  /// - The connection has not been interrupted
  ///
  /// Returns `false` if:
  /// - [connect] has never been called
  /// - [disconnect] was called
  /// - The connection was lost due to network issues
  ///
  /// Example:
  /// ```dart
  /// if (!wsService.isConnected) {
  ///   await wsService.connect();
  /// }
  /// ```
  bool get isConnected;

  /// A stream of incoming messages from the WebSocket server.
  ///
  /// Each message is parsed from JSON and emitted as a
  /// `Map<String, dynamic>`. The stream remains active as long as
  /// the connection is open.
  ///
  /// Messages are broadcast to all listeners. New listeners will
  /// only receive messages that arrive after they start listening.
  ///
  /// The stream will emit an error if:
  /// - A message cannot be parsed as JSON
  /// - The connection is unexpectedly closed
  ///
  /// Example:
  /// ```dart
  /// final subscription = wsService.messageStream.listen(
  ///   (message) {
  ///     final type = message['type'] as String;
  ///     print('Received message of type: $type');
  ///   },
  ///   onError: (error) {
  ///     print('Stream error: $error');
  ///   },
  ///   onDone: () {
  ///     print('Stream closed');
  ///   },
  /// );
  ///
  /// // Later, cancel the subscription
  /// await subscription.cancel();
  /// ```
  Stream<Map<String, dynamic>> get messageStream;

  /// Sends a message to the WebSocket server.
  ///
  /// [message] - The message to send, which will be serialized to JSON.
  ///
  /// The message is sent immediately if the connection is active.
  /// If the connection is not active, the message may be queued or
  /// discarded depending on the implementation.
  ///
  /// Example:
  /// ```dart
  /// // Send a simple message
  /// wsService.send({'type': 'ping'});
  ///
  /// // Send a message with data
  /// wsService.send({
  ///   'type': 'step_update',
  ///   'data': {'steps': 1500, 'timestamp': DateTime.now().toIso8601String()},
  /// });
  /// ```
  ///
  /// Throws an exception if the message cannot be serialized to JSON.
  void send(Map<String, dynamic> message);
}
