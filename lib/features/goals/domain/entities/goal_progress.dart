import 'package:equatable/equatable.dart';

/// Domain entity representing an individual member's progress in a goal.
final class MemberProgress extends Equatable {
  const MemberProgress({
    required this.userId,
    required this.username,
    required this.totalSteps,
    required this.percentComplete,
  });

  /// ID of the user.
  final String userId;

  /// Username of the member.
  final String username;

  /// Total steps contributed by this member.
  final int totalSteps;

  /// Percentage of goal completion for this member.
  final double percentComplete;

  /// Returns true if this member has completed the goal.
  bool get hasCompleted => percentComplete >= 100.0;

  /// Creates a copy of this MemberProgress with the given fields replaced.
  MemberProgress copyWith({
    String? userId,
    String? username,
    int? totalSteps,
    double? percentComplete,
  }) {
    return MemberProgress(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      totalSteps: totalSteps ?? this.totalSteps,
      percentComplete: percentComplete ?? this.percentComplete,
    );
  }

  @override
  List<Object?> get props => [userId, username, totalSteps, percentComplete];

  @override
  String toString() =>
      'MemberProgress(userId: $userId, steps: $totalSteps, percent: $percentComplete)';
}

/// Domain entity representing the overall progress of a goal.
///
/// This is a pure domain entity with no serialization logic.
/// Use [GoalProgressModel] in the data layer for API serialization.
final class GoalProgress extends Equatable {
  const GoalProgress({
    required this.goalId,
    required this.totalSteps,
    required this.targetSteps,
    required this.percentComplete,
    required this.memberProgress,
    required this.lastUpdated,
  });

  /// ID of the goal this progress belongs to.
  final String goalId;

  /// Total steps contributed by all members.
  final int totalSteps;

  /// Target steps for the goal.
  final int targetSteps;

  /// Overall percentage of goal completion.
  final double percentComplete;

  /// Progress of individual members.
  final List<MemberProgress> memberProgress;

  /// Timestamp when the progress was last updated.
  final DateTime lastUpdated;

  /// Returns true if the goal has been completed.
  bool get isCompleted => percentComplete >= 100.0;

  /// Returns the number of steps remaining to reach the goal.
  int get stepsRemaining => (targetSteps - totalSteps).clamp(0, targetSteps);

  /// Returns the number of active members contributing to the goal.
  int get activeMemberCount => memberProgress.length;

  /// Creates a copy of this GoalProgress with the given fields replaced.
  GoalProgress copyWith({
    String? goalId,
    int? totalSteps,
    int? targetSteps,
    double? percentComplete,
    List<MemberProgress>? memberProgress,
    DateTime? lastUpdated,
  }) {
    return GoalProgress(
      goalId: goalId ?? this.goalId,
      totalSteps: totalSteps ?? this.totalSteps,
      targetSteps: targetSteps ?? this.targetSteps,
      percentComplete: percentComplete ?? this.percentComplete,
      memberProgress: memberProgress ?? this.memberProgress,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        goalId,
        totalSteps,
        targetSteps,
        percentComplete,
        memberProgress,
        lastUpdated,
      ];

  @override
  String toString() =>
      'GoalProgress(goalId: $goalId, progress: $percentComplete%, members: ${memberProgress.length})';
}
