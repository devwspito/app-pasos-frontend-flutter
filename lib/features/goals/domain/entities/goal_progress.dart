/// Goal progress entity for the goals domain.
///
/// This is a pure domain entity representing the overall progress of a
/// group goal. It's independent of any data layer implementation details.
library;

import 'package:equatable/equatable.dart';

/// Represents the overall progress of a group goal.
///
/// Goal progress tracks the collective step count towards the target,
/// providing real-time information about how close the group is to
/// achieving their goal.
///
/// Example usage:
/// ```dart
/// final progress = GoalProgress(
///   id: '123',
///   goalId: 'goal456',
///   currentSteps: 75000,
///   targetSteps: 100000,
///   progressPercentage: 75.0,
///   lastUpdated: DateTime.now(),
/// );
/// ```
class GoalProgress extends Equatable {
  /// Creates a [GoalProgress] instance.
  ///
  /// [id] - The unique identifier for the progress record.
  /// [goalId] - The ID of the goal this progress belongs to.
  /// [currentSteps] - The current total steps achieved by the group.
  /// [targetSteps] - The target steps to achieve.
  /// [progressPercentage] - The percentage of progress (0-100).
  /// [lastUpdated] - When the progress was last updated.
  const GoalProgress({
    required this.id,
    required this.goalId,
    required this.currentSteps,
    required this.targetSteps,
    required this.progressPercentage,
    required this.lastUpdated,
  });

  /// Creates an empty progress for use in initial states.
  ///
  /// Useful for initializing state before progress data is loaded.
  factory GoalProgress.empty() => GoalProgress(
        id: '',
        goalId: '',
        currentSteps: 0,
        targetSteps: 0,
        progressPercentage: 0,
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// The unique identifier for the progress record.
  final String id;

  /// The ID of the goal this progress belongs to.
  final String goalId;

  /// The current total steps achieved by the group.
  final int currentSteps;

  /// The target steps to achieve for the goal.
  final int targetSteps;

  /// The percentage of progress towards the goal (0-100).
  final double progressPercentage;

  /// When the progress was last updated.
  final DateTime lastUpdated;

  /// Whether this is an empty/uninitialized progress.
  bool get isEmpty => id.isEmpty;

  /// Whether this is valid progress with data.
  bool get isNotEmpty => !isEmpty;

  /// Whether the goal has been completed (current >= target).
  bool get isCompleted => currentSteps >= targetSteps;

  /// The progress as a ratio (0.0 to 1.0).
  ///
  /// This is calculated from currentSteps and targetSteps.
  /// Returns 0.0 if targetSteps is 0 to avoid division by zero.
  double get progressRatio =>
      targetSteps > 0 ? (currentSteps / targetSteps).clamp(0.0, 1.0) : 0.0;

  /// The remaining steps needed to complete the goal.
  ///
  /// Returns 0 if the goal is already completed.
  int get remainingSteps =>
      isCompleted ? 0 : targetSteps - currentSteps;

  /// Whether any progress has been made.
  bool get hasProgress => currentSteps > 0;

  @override
  List<Object?> get props => [
        id,
        goalId,
        currentSteps,
        targetSteps,
        progressPercentage,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'GoalProgress(id: $id, goalId: $goalId, '
        'currentSteps: $currentSteps, targetSteps: $targetSteps, '
        'progressPercentage: $progressPercentage, lastUpdated: $lastUpdated)';
  }
}
