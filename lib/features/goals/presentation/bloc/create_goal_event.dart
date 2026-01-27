/// Create goal events for the CreateGoalBloc.
///
/// This file defines all possible events that can be dispatched to the
/// CreateGoalBloc. Events are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:equatable/equatable.dart';

/// Base class for all create goal events.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all event types are handled.
sealed class CreateGoalEvent extends Equatable {
  /// Creates a [CreateGoalEvent] instance.
  const CreateGoalEvent();
}

/// Event dispatched when the user submits a new goal for creation.
///
/// This event triggers the creation of a new group goal with the
/// provided details.
final class CreateGoalSubmitted extends CreateGoalEvent {
  /// Creates a [CreateGoalSubmitted] event.
  ///
  /// [name] - The name of the goal.
  /// [description] - An optional description of the goal.
  /// [targetSteps] - The total step target for the group.
  /// [startDate] - When the goal period starts.
  /// [endDate] - When the goal period ends.
  const CreateGoalSubmitted({
    required this.name,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
    this.description,
  });

  /// The name of the goal.
  final String name;

  /// An optional description of the goal.
  final String? description;

  /// The total step target for the group.
  final int targetSteps;

  /// When the goal period starts.
  final DateTime startDate;

  /// When the goal period ends.
  final DateTime endDate;

  @override
  List<Object?> get props => [
        name,
        description,
        targetSteps,
        startDate,
        endDate,
      ];
}

/// Event dispatched when the user wants to reset the create goal form.
///
/// This event resets the BLoC state back to its initial state,
/// clearing any error or success states.
final class CreateGoalReset extends CreateGoalEvent {
  /// Creates a [CreateGoalReset] event.
  const CreateGoalReset();

  @override
  List<Object?> get props => [];
}
