import 'package:equatable/equatable.dart';

/// Domain entity representing step statistics
final class StepStats extends Equatable {
  final int todaySteps;
  final int goalSteps;
  final double weeklyAverage;
  final double percentComplete;

  const StepStats({
    required this.todaySteps,
    required this.goalSteps,
    required this.weeklyAverage,
    required this.percentComplete,
  });

  @override
  List<Object?> get props => [todaySteps, goalSteps, weeklyAverage, percentComplete];

  /// Creates a copy of this StepStats with the given fields replaced
  StepStats copyWith({
    int? todaySteps,
    int? goalSteps,
    double? weeklyAverage,
    double? percentComplete,
  }) {
    return StepStats(
      todaySteps: todaySteps ?? this.todaySteps,
      goalSteps: goalSteps ?? this.goalSteps,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      percentComplete: percentComplete ?? this.percentComplete,
    );
  }

  /// Returns true if daily goal is achieved
  bool get isGoalAchieved => todaySteps >= goalSteps;

  /// Returns the number of steps remaining to reach the goal
  int get stepsRemaining => (goalSteps - todaySteps).clamp(0, goalSteps);
}
