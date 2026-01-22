import 'package:equatable/equatable.dart';

/// Domain entity representing a member's progress within a goal.
///
/// Contains the user's contribution details including steps,
/// display name, and ranking within the goal.
final class MemberProgress extends Equatable {
  final String userId;
  final String displayName;
  final int steps;
  final int rank;

  const MemberProgress({
    required this.userId,
    required this.displayName,
    required this.steps,
    required this.rank,
  });

  @override
  List<Object?> get props => [userId, displayName, steps, rank];

  /// Creates a copy of this MemberProgress with the given fields replaced
  MemberProgress copyWith({
    String? userId,
    String? displayName,
    int? steps,
    int? rank,
  }) {
    return MemberProgress(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      steps: steps ?? this.steps,
      rank: rank ?? this.rank,
    );
  }
}

/// Domain entity representing the overall progress of a goal.
///
/// Aggregates total steps, target, and individual member progress
/// to provide a complete view of goal advancement.
final class GoalProgress extends Equatable {
  final String goalId;
  final int totalSteps;
  final int targetSteps;
  final double percentComplete;
  final List<MemberProgress> memberProgress;

  const GoalProgress({
    required this.goalId,
    required this.totalSteps,
    required this.targetSteps,
    required this.percentComplete,
    required this.memberProgress,
  });

  @override
  List<Object?> get props => [
        goalId,
        totalSteps,
        targetSteps,
        percentComplete,
        memberProgress,
      ];

  /// Creates a copy of this GoalProgress with the given fields replaced
  GoalProgress copyWith({
    String? goalId,
    int? totalSteps,
    int? targetSteps,
    double? percentComplete,
    List<MemberProgress>? memberProgress,
  }) {
    return GoalProgress(
      goalId: goalId ?? this.goalId,
      totalSteps: totalSteps ?? this.totalSteps,
      targetSteps: targetSteps ?? this.targetSteps,
      percentComplete: percentComplete ?? this.percentComplete,
      memberProgress: memberProgress ?? this.memberProgress,
    );
  }

  /// Returns true if the goal has been completed
  bool get isComplete => totalSteps >= targetSteps;

  /// Returns the number of steps remaining to reach the goal
  int get stepsRemaining => (targetSteps - totalSteps).clamp(0, targetSteps);

  /// Returns the number of members contributing to this goal
  int get memberCount => memberProgress.length;
}
