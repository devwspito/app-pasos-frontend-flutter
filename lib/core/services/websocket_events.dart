import 'dart:convert';

/// Event types matching backend socket/types.ts
///
/// These event types define the different categories of real-time
/// messages that can be sent or received through the WebSocket connection.
enum WebSocketEventType {
  // Steps events
  /// Emitted when step count is updated
  stepsUpdated,

  /// Emitted when goal progress changes
  goalProgress,

  // Sharing events
  /// Emitted when a friend request is received
  friendRequestReceived,

  /// Emitted when a friend request is accepted
  friendRequestAccepted,

  /// Emitted when a friend's step count is updated
  friendStepsUpdated,

  // Goals events
  /// Emitted when a goal invite is received
  goalInviteReceived,

  /// Emitted when a member joins a shared goal
  goalMemberJoined,

  /// Emitted when a goal is completed
  goalCompleted,

  // System events
  /// Emitted when connection is established
  connected,

  /// Emitted when connection is closed
  disconnected,

  /// Emitted when an error occurs
  error,

  /// Unknown event type for forward compatibility
  unknown,
}

/// Extension to convert event type to/from string
extension WebSocketEventTypeExtension on WebSocketEventType {
  /// Converts the event type to a string for serialization
  String toJson() {
    switch (this) {
      case WebSocketEventType.stepsUpdated:
        return 'steps_updated';
      case WebSocketEventType.goalProgress:
        return 'goal_progress';
      case WebSocketEventType.friendRequestReceived:
        return 'friend_request_received';
      case WebSocketEventType.friendRequestAccepted:
        return 'friend_request_accepted';
      case WebSocketEventType.friendStepsUpdated:
        return 'friend_steps_updated';
      case WebSocketEventType.goalInviteReceived:
        return 'goal_invite_received';
      case WebSocketEventType.goalMemberJoined:
        return 'goal_member_joined';
      case WebSocketEventType.goalCompleted:
        return 'goal_completed';
      case WebSocketEventType.connected:
        return 'connected';
      case WebSocketEventType.disconnected:
        return 'disconnected';
      case WebSocketEventType.error:
        return 'error';
      case WebSocketEventType.unknown:
        return 'unknown';
    }
  }

  /// Creates an event type from a string
  static WebSocketEventType fromJson(String value) {
    switch (value) {
      case 'steps_updated':
        return WebSocketEventType.stepsUpdated;
      case 'goal_progress':
        return WebSocketEventType.goalProgress;
      case 'friend_request_received':
        return WebSocketEventType.friendRequestReceived;
      case 'friend_request_accepted':
        return WebSocketEventType.friendRequestAccepted;
      case 'friend_steps_updated':
        return WebSocketEventType.friendStepsUpdated;
      case 'goal_invite_received':
        return WebSocketEventType.goalInviteReceived;
      case 'goal_member_joined':
        return WebSocketEventType.goalMemberJoined;
      case 'goal_completed':
        return WebSocketEventType.goalCompleted;
      case 'connected':
        return WebSocketEventType.connected;
      case 'disconnected':
        return WebSocketEventType.disconnected;
      case 'error':
        return WebSocketEventType.error;
      default:
        return WebSocketEventType.unknown;
    }
  }
}

/// Base event class for WebSocket communication.
///
/// Represents a message that can be sent to or received from
/// the WebSocket server.
///
/// Example:
/// ```dart
/// // Create an event to send
/// final event = WebSocketEvent(
///   type: WebSocketEventType.stepsUpdated,
///   data: {'steps': 5000, 'date': '2024-01-15'},
/// );
///
/// // Serialize for sending
/// final json = event.toJson();
///
/// // Parse received message
/// final received = WebSocketEvent.fromJson(jsonString);
/// ```
class WebSocketEvent {
  /// The type of this event
  final WebSocketEventType type;

  /// The event payload data
  final Map<String, dynamic> data;

  /// Timestamp when the event was created
  final DateTime timestamp;

  /// Creates a new WebSocket event.
  ///
  /// If [timestamp] is not provided, the current time is used.
  WebSocketEvent({
    required this.type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
  })  : data = data ?? const {},
        timestamp = timestamp ?? DateTime.now();

  /// Creates a WebSocket event from a JSON map.
  ///
  /// Expected format:
  /// ```json
  /// {
  ///   "type": "steps_updated",
  ///   "data": { ... },
  ///   "timestamp": "2024-01-15T10:30:00Z"
  /// }
  /// ```
  factory WebSocketEvent.fromMap(Map<String, dynamic> map) {
    final typeString = map['type'] as String? ?? 'unknown';
    final data = map['data'] as Map<String, dynamic>? ?? {};
    final timestampString = map['timestamp'] as String?;

    DateTime timestamp;
    if (timestampString != null) {
      try {
        timestamp = DateTime.parse(timestampString);
      } catch (_) {
        timestamp = DateTime.now();
      }
    } else {
      timestamp = DateTime.now();
    }

    return WebSocketEvent(
      type: WebSocketEventTypeExtension.fromJson(typeString),
      data: data,
      timestamp: timestamp,
    );
  }

  /// Creates a WebSocket event from a JSON string.
  ///
  /// Returns null if the JSON string is invalid.
  static WebSocketEvent? fromJson(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return WebSocketEvent.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  /// Converts this event to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'type': type.toJson(),
      'data': data,
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
  }

  /// Converts this event to a JSON string for sending over WebSocket.
  String toJson() {
    return jsonEncode(toMap());
  }

  /// Creates a connected system event.
  factory WebSocketEvent.connected({Map<String, dynamic>? data}) {
    return WebSocketEvent(
      type: WebSocketEventType.connected,
      data: data,
    );
  }

  /// Creates a disconnected system event.
  factory WebSocketEvent.disconnected({String? reason}) {
    return WebSocketEvent(
      type: WebSocketEventType.disconnected,
      data: reason != null ? {'reason': reason} : null,
    );
  }

  /// Creates an error system event.
  factory WebSocketEvent.error({
    required String message,
    String? code,
  }) {
    return WebSocketEvent(
      type: WebSocketEventType.error,
      data: {
        'message': message,
        if (code != null) 'code': code,
      },
    );
  }

  @override
  String toString() {
    return 'WebSocketEvent(type: ${type.toJson()}, data: $data, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebSocketEvent &&
        other.type == type &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => type.hashCode ^ timestamp.hashCode;
}
