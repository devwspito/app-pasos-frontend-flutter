/// Realtime goal update entity for WebSocket messages.
///
/// This is a pure domain entity representing a real-time goal update
/// received via WebSocket. It's independent of any data layer implementation.
library;

import 'package:equatable/equatable.dart';

/// Represents a real-time goal update from WebSocket.
///
/// A realtime goal update contains information about goal progress
/// or membership changes, typically used to show live goal updates.
///
/// Example usage:
/// ```dart
/// final update = RealtimeGoalUpdate(
///   eventType: 'goal_progress',
///   goalId: 'goal123',
///   userId: 'user456',
///   currentProgress: 75000,
///   targetSteps: 100000,
///   timestamp: DateTime.now(),
/// );
/// ```
class RealtimeGoalUpdate extends Equatable {
  /// Creates a [RealtimeGoalUpdate] instance.
  ///
  /// [eventType] - Type of event (e.g., 'goal_progress', 'member_joined').
  /// [goalId] - The ID of the affected goal.
  /// [userId] - The ID of the user who triggered the update (optional).
  /// [currentProgress] - Updated progress value (optional).
  /// [targetSteps] - Goal target (optional).
  /// [timestamp] - When the event occurred.
  const RealtimeGoalUpdate({
    required this.eventType,
    required this.goalId,
    this.userId,
    this.currentProgress,
    this.targetSteps,
    required this.timestamp,
  });

  /// Creates a [RealtimeGoalUpdate] from a JSON map.
  ///
  /// This factory constructor parses WebSocket message data.
  /// Handles null values gracefully for optional fields.
  ///
  /// [json] - The JSON map from WebSocket message.
  factory RealtimeGoalUpdate.fromJson(Map<String, dynamic> json) {
    return RealtimeGoalUpdate(
      eventType: json['eventType'] as String? ?? '',
      goalId: json['goalId'] as String? ?? '',
      userId: json['userId'] as String?,
      currentProgress: json['currentProgress'] as int?,
      targetSteps: json['targetSteps'] as int?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Creates an empty update for use in initial states.
  ///
  /// Useful for initializing state before update data is received.
  factory RealtimeGoalUpdate.empty() => RealtimeGoalUpdate(
        eventType: '',
        goalId: '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// Type of event (e.g., 'goal_progress', 'member_joined').
  final String eventType;

  /// The ID of the affected goal.
  final String goalId;

  /// The ID of the user who triggered the update.
  ///
  /// This is null if the update is not user-specific.
  final String? userId;

  /// Updated progress value.
  ///
  /// This is null if the update doesn't include progress changes.
  final int? currentProgress;

  /// Goal target steps.
  ///
  /// This is null if the update doesn't include target information.
  final int? targetSteps;

  /// When the event occurred.
  final DateTime timestamp;

  /// Whether this is an empty/uninitialized update.
  bool get isEmpty => eventType.isEmpty && goalId.isEmpty;

  /// Whether this is a valid update with data.
  bool get isNotEmpty => !isEmpty;

  /// Whether this is a goal progress event.
  bool get isGoalProgress => eventType == 'goal_progress';

  /// Whether this is a member joined event.
  bool get isMemberJoined => eventType == 'member_joined';

  /// Whether this update includes progress information.
  bool get hasProgress => currentProgress != null;

  /// Whether this update includes target information.
  bool get hasTarget => targetSteps != null;

  /// Calculates the progress percentage if both values are available.
  ///
  /// Returns null if either currentProgress or targetSteps is null.
  /// Returns 0.0 if targetSteps is 0 to avoid division by zero.
  double? get progressPercentage {
    if (currentProgress == null || targetSteps == null) return null;
    if (targetSteps == 0) return 0.0;
    return (currentProgress! / targetSteps! * 100).clamp(0.0, 100.0);
  }

  @override
  List<Object?> get props => [
        eventType,
        goalId,
        userId,
        currentProgress,
        targetSteps,
        timestamp,
      ];

  @override
  String toString() {
    return 'RealtimeGoalUpdate(eventType: $eventType, goalId: $goalId, '
        'userId: $userId, currentProgress: $currentProgress, '
        'targetSteps: $targetSteps, timestamp: $timestamp)';
  }
}
