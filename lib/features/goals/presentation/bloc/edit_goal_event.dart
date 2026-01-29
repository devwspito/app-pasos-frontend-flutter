/// Edit goal events for the EditGoalBloc.
///
/// This file defines all possible events that can be dispatched to the
/// EditGoalBloc. Events are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:equatable/equatable.dart';

/// Base class for all edit goal events.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all event types are handled.
sealed class EditGoalEvent extends Equatable {
  /// Creates an [EditGoalEvent] instance.
  const EditGoalEvent();
}

/// Event dispatched to load existing goal data for editing.
///
/// This event triggers loading the goal details from the API
/// to pre-populate the edit form.
final class EditGoalLoadRequested extends EditGoalEvent {
  /// Creates an [EditGoalLoadRequested] event.
  ///
  /// [goalId] - The ID of the goal to load for editing.
  const EditGoalLoadRequested({required this.goalId});

  /// The ID of the goal to load.
  final String goalId;

  @override
  List<Object?> get props => [goalId];
}

/// Event dispatched when the user submits updated goal data.
///
/// This event triggers updating the goal with the new values.
final class EditGoalSubmitted extends EditGoalEvent {
  /// Creates an [EditGoalSubmitted] event.
  ///
  /// [goalId] - The ID of the goal being updated.
  /// [name] - The updated name of the goal.
  /// [description] - The updated description of the goal (optional).
  /// [targetSteps] - The updated total step target.
  /// [startDate] - The updated start date for the goal period.
  /// [endDate] - The updated end date for the goal period.
  const EditGoalSubmitted({
    required this.goalId,
    required this.name,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
    this.description,
  });

  /// The ID of the goal being updated.
  final String goalId;

  /// The updated name of the goal.
  final String name;

  /// The updated description of the goal (optional).
  final String? description;

  /// The updated total step target for the group.
  final int targetSteps;

  /// The updated start date for the goal period.
  final DateTime startDate;

  /// The updated end date for the goal period.
  final DateTime endDate;

  @override
  List<Object?> get props => [
        goalId,
        name,
        description,
        targetSteps,
        startDate,
        endDate,
      ];
}

/// Event dispatched when the user wants to reset the edit goal form.
///
/// This event resets the BLoC state back to its initial state,
/// clearing any error or success states.
final class EditGoalReset extends EditGoalEvent {
  /// Creates an [EditGoalReset] event.
  const EditGoalReset();

  @override
  List<Object?> get props => [];
}
