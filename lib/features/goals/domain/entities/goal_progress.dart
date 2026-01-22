import 'package:equatable/equatable.dart';

/// Represents a member's contribution to a goal
final class MemberProgress extends Equatable {
  const MemberProgress({
    required this.userId,
    required this.userName,
    required this.steps,
    required this.contributionPercent,
  });

  /// User ID of the member
  final String userId;

  /// Display name of the member
  final String userName;

  /// Total steps contributed
  final int steps;

  /// Percentage contribution to total goal progress
  final double contributionPercent;

  @override
  List<Object?> get props => [userId, userName, steps, contributionPercent];
}

/// Domain entity representing detailed progress of a goal.
///
/// Contains aggregated progress data including individual
/// member contributions for group goals.
final class GoalProgress extends Equatable {
  const GoalProgress({
    required this.goalId,
    required this.totalSteps,
    required this.targetSteps,
    required this.progressPercent,
    required this.isCompleted,
    required this.daysRemaining,
    this.memberProgress = const [],
    this.dailyAverage = 0,
    this.projectedCompletion,
  });

  /// Goal ID this progress belongs to
  final String goalId;

  /// Total steps accumulated
  final int totalSteps;

  /// Target steps for the goal
  final int targetSteps;

  /// Progress percentage (0-100+)
  final double progressPercent;

  /// Whether the goal has been completed
  final bool isCompleted;

  /// Days remaining until goal ends
  final int daysRemaining;

  /// Progress breakdown by member (for group goals)
  final List<MemberProgress> memberProgress;

  /// Average daily steps toward this goal
  final int dailyAverage;

  /// Projected completion date based on current pace
  final DateTime? projectedCompletion;

  /// Steps remaining to complete the goal
  int get stepsRemaining => (targetSteps - totalSteps).clamp(0, targetSteps);

  /// Whether on track to complete based on daily average
  bool get isOnTrack {
    if (isCompleted || daysRemaining == 0) return isCompleted;
    final requiredDaily = stepsRemaining / daysRemaining;
    return dailyAverage >= requiredDaily;
  }

  /// Creates a copy with updated fields
  GoalProgress copyWith({
    String? goalId,
    int? totalSteps,
    int? targetSteps,
    double? progressPercent,
    bool? isCompleted,
    int? daysRemaining,
    List<MemberProgress>? memberProgress,
    int? dailyAverage,
    DateTime? projectedCompletion,
  }) {
    return GoalProgress(
      goalId: goalId ?? this.goalId,
      totalSteps: totalSteps ?? this.totalSteps,
      targetSteps: targetSteps ?? this.targetSteps,
      progressPercent: progressPercent ?? this.progressPercent,
      isCompleted: isCompleted ?? this.isCompleted,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      memberProgress: memberProgress ?? this.memberProgress,
      dailyAverage: dailyAverage ?? this.dailyAverage,
      projectedCompletion: projectedCompletion ?? this.projectedCompletion,
    );
  }

  @override
  List<Object?> get props => [
        goalId,
        totalSteps,
        targetSteps,
        progressPercent,
        isCompleted,
        daysRemaining,
        memberProgress,
        dailyAverage,
        projectedCompletion,
      ];

  @override
  String toString() {
    return 'GoalProgress(goalId: $goalId, '
        'progress: ${progressPercent.toStringAsFixed(1)}%, '
        'isCompleted: $isCompleted)';
  }
}
