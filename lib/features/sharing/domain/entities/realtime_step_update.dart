/// Realtime step update entity for WebSocket messages.
///
/// This is a pure domain entity representing a real-time step update
/// received via WebSocket. It's independent of any data layer implementation.
library;

import 'package:equatable/equatable.dart';

/// Represents a real-time step update from WebSocket.
///
/// A realtime step update contains information about step activity
/// from a user, typically used to show friend activity in real-time.
///
/// Example usage:
/// ```dart
/// final update = RealtimeStepUpdate(
///   eventType: 'step_update',
///   userId: 'user123',
///   userName: 'John Doe',
///   stepCount: 1500,
///   timestamp: DateTime.now(),
/// );
/// ```
class RealtimeStepUpdate extends Equatable {
  /// Creates a [RealtimeStepUpdate] instance.
  ///
  /// [eventType] - Type of event (e.g., 'step_update', 'friend_activity').
  /// [userId] - The ID of the user who generated the update.
  /// [userName] - Display name of the user (optional).
  /// [stepCount] - Number of steps in this update.
  /// [timestamp] - When the event occurred.
  const RealtimeStepUpdate({
    required this.eventType,
    required this.userId,
    this.userName,
    required this.stepCount,
    required this.timestamp,
  });

  /// Creates a [RealtimeStepUpdate] from a JSON map.
  ///
  /// This factory constructor parses WebSocket message data.
  /// Handles null values gracefully for optional fields.
  ///
  /// [json] - The JSON map from WebSocket message.
  factory RealtimeStepUpdate.fromJson(Map<String, dynamic> json) {
    return RealtimeStepUpdate(
      eventType: json['eventType'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String?,
      stepCount: json['stepCount'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Creates an empty update for use in initial states.
  ///
  /// Useful for initializing state before update data is received.
  factory RealtimeStepUpdate.empty() => RealtimeStepUpdate(
        eventType: '',
        userId: '',
        stepCount: 0,
        timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// Type of event (e.g., 'step_update', 'friend_activity').
  final String eventType;

  /// The ID of the user who generated the update.
  final String userId;

  /// Display name of the user.
  ///
  /// This is null if the user name is not available.
  final String? userName;

  /// Number of steps in this update.
  final int stepCount;

  /// When the event occurred.
  final DateTime timestamp;

  /// Whether this is an empty/uninitialized update.
  bool get isEmpty => eventType.isEmpty && userId.isEmpty;

  /// Whether this is a valid update with data.
  bool get isNotEmpty => !isEmpty;

  /// Whether this is a step update event.
  bool get isStepUpdate => eventType == 'step_update';

  /// Whether this is a friend activity event.
  bool get isFriendActivity => eventType == 'friend_activity';

  /// Whether step count is significant (greater than zero).
  bool get hasSteps => stepCount > 0;

  @override
  List<Object?> get props => [
        eventType,
        userId,
        userName,
        stepCount,
        timestamp,
      ];

  @override
  String toString() {
    return 'RealtimeStepUpdate(eventType: $eventType, userId: $userId, '
        'userName: $userName, stepCount: $stepCount, timestamp: $timestamp)';
  }
}
