import 'package:equatable/equatable.dart';

/// Domain entity representing stats for a shared user (friend)
final class SharedUserStats extends Equatable {
  final String friendId;
  final String friendName;
  final String? friendAvatarUrl;
  final int todaySteps;
  final int goalSteps;
  final double percentComplete;
  final int weeklyAverage;
  final DateTime lastUpdated;

  const SharedUserStats({
    required this.friendId,
    required this.friendName,
    this.friendAvatarUrl,
    required this.todaySteps,
    required this.goalSteps,
    required this.percentComplete,
    required this.weeklyAverage,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        friendId,
        friendName,
        friendAvatarUrl,
        todaySteps,
        goalSteps,
        percentComplete,
        weeklyAverage,
        lastUpdated,
      ];

  /// Returns true if friend has achieved their daily goal
  bool get isGoalAchieved => todaySteps >= goalSteps;

  /// Returns the number of steps remaining to reach the goal
  int get stepsRemaining => (goalSteps - todaySteps).clamp(0, goalSteps);

  /// Creates a copy of this SharedUserStats with the given fields replaced
  SharedUserStats copyWith({
    String? friendId,
    String? friendName,
    String? friendAvatarUrl,
    int? todaySteps,
    int? goalSteps,
    double? percentComplete,
    int? weeklyAverage,
    DateTime? lastUpdated,
  }) {
    return SharedUserStats(
      friendId: friendId ?? this.friendId,
      friendName: friendName ?? this.friendName,
      friendAvatarUrl: friendAvatarUrl ?? this.friendAvatarUrl,
      todaySteps: todaySteps ?? this.todaySteps,
      goalSteps: goalSteps ?? this.goalSteps,
      percentComplete: percentComplete ?? this.percentComplete,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
