import 'package:equatable/equatable.dart';

/// Domain entity representing aggregated step statistics.
///
/// This is an immutable entity that contains business logic methods
/// for calculating step-related statistics and progress. Unlike data models,
/// entities do NOT contain JSON serialization logic.
///
/// Example usage:
/// ```dart
/// final stats = StepStats(
///   totalSteps: 45000,
///   averageSteps: 7500.0,
///   goalSteps: 10000,
///   streak: 5,
///   bestDay: DateTime(2024, 1, 15),
///   bestDaySteps: 12500,
/// );
///
/// print(stats.goalProgress); // 4.5 (for total) - use dailyGoalProgress for daily
/// print(stats.goalReached); // false (daily goal comparison)
/// print(stats.stepsToGoal); // 2500
/// ```
class StepStats extends Equatable {
  /// Total number of steps in the tracked period.
  final int totalSteps;

  /// Average steps per day in the tracked period.
  final double averageSteps;

  /// Daily step goal.
  final int goalSteps;

  /// Current streak of consecutive days meeting the goal.
  final int streak;

  /// Date of the best step count (most steps in a single day).
  /// Null if no records exist.
  final DateTime? bestDay;

  /// Step count on the best day.
  final int bestDaySteps;

  /// Creates a [StepStats] instance.
  ///
  /// All fields are required except [bestDay] which can be null.
  const StepStats({
    required this.totalSteps,
    required this.averageSteps,
    required this.goalSteps,
    required this.streak,
    this.bestDay,
    required this.bestDaySteps,
  });

  /// Factory constructor for creating empty stats.
  ///
  /// Useful when no step data is available yet.
  factory StepStats.empty({int goalSteps = 10000}) {
    return StepStats(
      totalSteps: 0,
      averageSteps: 0.0,
      goalSteps: goalSteps,
      streak: 0,
      bestDay: null,
      bestDaySteps: 0,
    );
  }

  /// Returns the progress towards the daily goal based on average steps.
  ///
  /// Value is clamped between 0.0 and 1.0.
  /// Use this for progress indicators.
  double get goalProgress {
    if (goalSteps <= 0) return 0.0;
    return (averageSteps / goalSteps).clamp(0.0, 1.0);
  }

  /// Returns true if the average steps meet or exceed the daily goal.
  bool get goalReached => averageSteps >= goalSteps;

  /// Returns the number of steps needed (on average) to reach the daily goal.
  ///
  /// Returns 0 if the goal has already been reached.
  int get stepsToGoal {
    final remaining = goalSteps - averageSteps.round();
    return remaining.clamp(0, goalSteps);
  }

  /// Returns true if there is an active streak.
  bool get hasStreak => streak > 0;

  /// Returns true if there is a recorded best day.
  bool get hasBestDay => bestDay != null && bestDaySteps > 0;

  /// Returns the percentage that the best day exceeded the goal.
  ///
  /// Returns 0.0 if no goal is set or best day steps is 0.
  /// Value can exceed 1.0 if best day exceeded goal.
  double get bestDayGoalMultiple {
    if (goalSteps <= 0 || bestDaySteps <= 0) return 0.0;
    return bestDaySteps / goalSteps;
  }

  /// Returns true if the best day exceeded the goal.
  bool get bestDayExceededGoal => bestDaySteps >= goalSteps;

  /// Returns how many extra steps were taken on the best day beyond the goal.
  ///
  /// Returns 0 if the goal wasn't reached on the best day.
  int get bestDayBonusSteps {
    return (bestDaySteps - goalSteps).clamp(0, bestDaySteps);
  }

  /// Creates a copy of this stats object with optional field overrides.
  StepStats copyWith({
    int? totalSteps,
    double? averageSteps,
    int? goalSteps,
    int? streak,
    DateTime? bestDay,
    int? bestDaySteps,
  }) {
    return StepStats(
      totalSteps: totalSteps ?? this.totalSteps,
      averageSteps: averageSteps ?? this.averageSteps,
      goalSteps: goalSteps ?? this.goalSteps,
      streak: streak ?? this.streak,
      bestDay: bestDay ?? this.bestDay,
      bestDaySteps: bestDaySteps ?? this.bestDaySteps,
    );
  }

  @override
  List<Object?> get props => [
        totalSteps,
        averageSteps,
        goalSteps,
        streak,
        bestDay,
        bestDaySteps,
      ];

  @override
  String toString() {
    return 'StepStats(totalSteps: $totalSteps, averageSteps: $averageSteps, '
        'goalSteps: $goalSteps, streak: $streak, bestDay: $bestDay, '
        'bestDaySteps: $bestDaySteps)';
  }
}
