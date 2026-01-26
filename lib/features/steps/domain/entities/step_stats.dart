/// Entity representing aggregated step statistics.
///
/// This entity provides summary statistics for step tracking,
/// including totals, averages, and goal progress.
class StepStats {
  /// Total steps recorded today.
  final int todaySteps;

  /// Daily step goal set by the user.
  final int dailyGoal;

  /// Average steps per day over the last 7 days.
  final double weeklyAverage;

  /// Total steps recorded this week (Sunday to Saturday).
  final int weeklyTotal;

  /// The user's longest streak of consecutive days meeting their goal.
  final int longestStreak;

  /// The user's current streak of consecutive days meeting their goal.
  final int currentStreak;

  /// Total distance walked today in meters.
  final double todayDistanceMeters;

  /// Total calories burned today from walking/running.
  final double todayCaloriesBurned;

  /// The date and time when these stats were last updated.
  final DateTime lastUpdated;

  /// Creates a new [StepStats] instance.
  const StepStats({
    required this.todaySteps,
    required this.dailyGoal,
    required this.weeklyAverage,
    required this.weeklyTotal,
    required this.longestStreak,
    required this.currentStreak,
    required this.todayDistanceMeters,
    required this.todayCaloriesBurned,
    required this.lastUpdated,
  });

  /// Percentage of daily goal completed (0.0 to 1.0+).
  double get goalProgress => dailyGoal > 0 ? todaySteps / dailyGoal : 0.0;

  /// Whether the daily goal has been met.
  bool get goalMet => todaySteps >= dailyGoal;

  /// Steps remaining to meet the daily goal (0 if goal met).
  int get stepsRemaining => goalMet ? 0 : dailyGoal - todaySteps;

  /// Creates a copy of this stats object with the given fields replaced.
  StepStats copyWith({
    int? todaySteps,
    int? dailyGoal,
    double? weeklyAverage,
    int? weeklyTotal,
    int? longestStreak,
    int? currentStreak,
    double? todayDistanceMeters,
    double? todayCaloriesBurned,
    DateTime? lastUpdated,
  }) {
    return StepStats(
      todaySteps: todaySteps ?? this.todaySteps,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      weeklyTotal: weeklyTotal ?? this.weeklyTotal,
      longestStreak: longestStreak ?? this.longestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      todayDistanceMeters: todayDistanceMeters ?? this.todayDistanceMeters,
      todayCaloriesBurned: todayCaloriesBurned ?? this.todayCaloriesBurned,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Creates a default/empty stats object.
  factory StepStats.empty() {
    return StepStats(
      todaySteps: 0,
      dailyGoal: 10000,
      weeklyAverage: 0.0,
      weeklyTotal: 0,
      longestStreak: 0,
      currentStreak: 0,
      todayDistanceMeters: 0.0,
      todayCaloriesBurned: 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StepStats &&
        other.todaySteps == todaySteps &&
        other.dailyGoal == dailyGoal &&
        other.weeklyAverage == weeklyAverage &&
        other.weeklyTotal == weeklyTotal &&
        other.longestStreak == longestStreak &&
        other.currentStreak == currentStreak &&
        other.todayDistanceMeters == todayDistanceMeters &&
        other.todayCaloriesBurned == todayCaloriesBurned &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      todaySteps,
      dailyGoal,
      weeklyAverage,
      weeklyTotal,
      longestStreak,
      currentStreak,
      todayDistanceMeters,
      todayCaloriesBurned,
      lastUpdated,
    );
  }

  @override
  String toString() {
    return 'StepStats(todaySteps: $todaySteps, dailyGoal: $dailyGoal, goalProgress: ${(goalProgress * 100).toStringAsFixed(1)}%)';
  }
}
