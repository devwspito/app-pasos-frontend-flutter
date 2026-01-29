/// Goal detail events for the GoalDetailBloc.
///
/// This file defines all possible events that can be dispatched to the
/// GoalDetailBloc. Events are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/realtime_goal_update.dart';
import 'package:equatable/equatable.dart';

/// Base class for all goal detail events.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all event types are handled.
sealed class GoalDetailEvent extends Equatable {
  /// Creates a [GoalDetailEvent] instance.
  const GoalDetailEvent();
}

/// Event dispatched when the goal detail needs to be loaded.
///
/// This event triggers fetching of detailed information about a specific goal,
/// including its progress and members.
final class GoalDetailLoadRequested extends GoalDetailEvent {
  /// Creates a [GoalDetailLoadRequested] event.
  ///
  /// [goalId] - The ID of the goal to load details for.
  const GoalDetailLoadRequested({
    required this.goalId,
  });

  /// The ID of the goal to load details for.
  final String goalId;

  @override
  List<Object?> get props => [goalId];
}

/// Event dispatched when the user requests to refresh goal details.
///
/// This event is typically triggered by a pull-to-refresh gesture
/// and re-fetches the goal details from the server.
final class GoalDetailRefreshRequested extends GoalDetailEvent {
  /// Creates a [GoalDetailRefreshRequested] event.
  ///
  /// [goalId] - The ID of the goal to refresh.
  const GoalDetailRefreshRequested({
    required this.goalId,
  });

  /// The ID of the goal to refresh.
  final String goalId;

  @override
  List<Object?> get props => [goalId];
}

/// Event dispatched when the user wants to invite another user to the goal.
///
/// This event is used when the goal creator invites a friend to join
/// the group goal.
final class GoalDetailInviteUserRequested extends GoalDetailEvent {
  /// Creates a [GoalDetailInviteUserRequested] event.
  ///
  /// [goalId] - The ID of the goal to invite to.
  /// [userId] - The ID of the user to invite.
  const GoalDetailInviteUserRequested({
    required this.goalId,
    required this.userId,
  });

  /// The ID of the goal to invite to.
  final String goalId;

  /// The ID of the user to invite.
  final String userId;

  @override
  List<Object?> get props => [goalId, userId];
}

/// Event dispatched when the user wants to leave a goal.
///
/// This event is used when a member decides to leave a group goal
/// they are participating in.
///
/// Note: The goal creator cannot leave the goal.
final class GoalDetailLeaveRequested extends GoalDetailEvent {
  /// Creates a [GoalDetailLeaveRequested] event.
  ///
  /// [goalId] - The ID of the goal to leave.
  const GoalDetailLeaveRequested({
    required this.goalId,
  });

  /// The ID of the goal to leave.
  final String goalId;

  @override
  List<Object?> get props => [goalId];
}

/// Event dispatched when a real-time goal update is received via WebSocket.
///
/// This event is used to update the goal detail view when the backend
/// notifies about goal progress changes or membership updates in real-time.
final class GoalDetailRealtimeUpdateReceived extends GoalDetailEvent {
  /// Creates a [GoalDetailRealtimeUpdateReceived] event.
  ///
  /// [update] - The real-time goal update received from WebSocket.
  const GoalDetailRealtimeUpdateReceived({
    required this.update,
  });

  /// The real-time goal update data.
  final RealtimeGoalUpdate update;

  @override
  List<Object?> get props => [update];
}

/// Event dispatched when the user requests to edit the goal.
///
/// This event is used to signal navigation to the edit goal page.
/// The actual navigation is handled by the UI layer after listening
/// to this event.
final class GoalDetailEditRequested extends GoalDetailEvent {
  /// Creates a [GoalDetailEditRequested] event.
  ///
  /// [goalId] - The ID of the goal to edit.
  const GoalDetailEditRequested({
    required this.goalId,
  });

  /// The ID of the goal to edit.
  final String goalId;

  @override
  List<Object?> get props => [goalId];
}
