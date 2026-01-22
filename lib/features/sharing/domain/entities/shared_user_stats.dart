import 'package:equatable/equatable.dart';

/// Domain entity representing shared statistics of a friend
final class SharedUserStats extends Equatable {
  final String userId;
  final String userName;
  final int todaySteps;
  final int goalSteps;
  final double weeklyAverage;
  final double percentComplete;
  final DateTime lastUpdated;

  const SharedUserStats({
    required this.userId,
    required this.userName,
    required this.todaySteps,
    required this.goalSteps,
    required this.weeklyAverage,
    required this.percentComplete,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        userId,
        userName,
        todaySteps,
        goalSteps,
        weeklyAverage,
        percentComplete,
        lastUpdated,
      ];

  /// Creates a copy of this SharedUserStats with the given fields replaced
  SharedUserStats copyWith({
    String? userId,
    String? userName,
    int? todaySteps,
    int? goalSteps,
    double? weeklyAverage,
    double? percentComplete,
    DateTime? lastUpdated,
  }) {
    return SharedUserStats(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      todaySteps: todaySteps ?? this.todaySteps,
      goalSteps: goalSteps ?? this.goalSteps,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      percentComplete: percentComplete ?? this.percentComplete,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Returns true if the user has achieved their daily goal
  bool get isGoalAchieved => todaySteps >= goalSteps;

  /// Returns the number of steps remaining to reach the goal
  int get stepsRemaining => (goalSteps - todaySteps).clamp(0, goalSteps);

  /// Returns true if the stats were updated recently (within last hour)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inHours < 1;
  }
}
