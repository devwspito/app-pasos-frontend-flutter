import 'package:equatable/equatable.dart';

/// Model representing aggregated step statistics.
///
/// Contains computed values like totals, averages, and streaks
/// from the step data.
class StepStatsModel extends Equatable {
  /// Total steps accumulated over the tracked period.
  final int totalSteps;

  /// Average steps per day.
  final double averageSteps;

  /// Daily step goal (default: 10,000).
  final int goalSteps;

  /// Progress towards daily goal as a percentage (0.0 to 1.0+).
  final double goalProgress;

  /// Current streak of consecutive days meeting the goal.
  final int streak;

  /// Highest step count achieved in a single day.
  final int bestDaySteps;

  /// Date of the best day (optional).
  final DateTime? bestDayDate;

  /// Total number of days with recorded steps.
  final int? totalDays;

  /// Creates a [StepStatsModel] instance.
  const StepStatsModel({
    required this.totalSteps,
    required this.averageSteps,
    required this.goalSteps,
    required this.goalProgress,
    required this.streak,
    required this.bestDaySteps,
    this.bestDayDate,
    this.totalDays,
  });

  /// Creates a [StepStatsModel] from JSON data.
  ///
  /// Handles null safety and type conversion from API response.
  factory StepStatsModel.fromJson(Map<String, dynamic> json) {
    return StepStatsModel(
      totalSteps: (json['totalSteps'] as num?)?.toInt() ??
                  (json['total_steps'] as num?)?.toInt() ?? 0,
      averageSteps: (json['averageSteps'] as num?)?.toDouble() ??
                    (json['average_steps'] as num?)?.toDouble() ?? 0.0,
      goalSteps: (json['goalSteps'] as num?)?.toInt() ??
                 (json['goal_steps'] as num?)?.toInt() ?? 10000,
      goalProgress: (json['goalProgress'] as num?)?.toDouble() ??
                    (json['goal_progress'] as num?)?.toDouble() ?? 0.0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      bestDaySteps: (json['bestDaySteps'] as num?)?.toInt() ??
                    (json['best_day_steps'] as num?)?.toInt() ?? 0,
      bestDayDate: json['bestDayDate'] != null
          ? DateTime.parse(json['bestDayDate'] as String)
          : json['best_day_date'] != null
              ? DateTime.parse(json['best_day_date'] as String)
              : null,
      totalDays: (json['totalDays'] as num?)?.toInt() ??
                 (json['total_days'] as num?)?.toInt(),
    );
  }

  /// Converts the model to JSON for caching.
  Map<String, dynamic> toJson() {
    return {
      'totalSteps': totalSteps,
      'averageSteps': averageSteps,
      'goalSteps': goalSteps,
      'goalProgress': goalProgress,
      'streak': streak,
      'bestDaySteps': bestDaySteps,
      if (bestDayDate != null) 'bestDayDate': bestDayDate!.toIso8601String(),
      if (totalDays != null) 'totalDays': totalDays,
    };
  }

  /// Creates a copy of this model with the given fields replaced.
  StepStatsModel copyWith({
    int? totalSteps,
    double? averageSteps,
    int? goalSteps,
    double? goalProgress,
    int? streak,
    int? bestDaySteps,
    DateTime? bestDayDate,
    int? totalDays,
  }) {
    return StepStatsModel(
      totalSteps: totalSteps ?? this.totalSteps,
      averageSteps: averageSteps ?? this.averageSteps,
      goalSteps: goalSteps ?? this.goalSteps,
      goalProgress: goalProgress ?? this.goalProgress,
      streak: streak ?? this.streak,
      bestDaySteps: bestDaySteps ?? this.bestDaySteps,
      bestDayDate: bestDayDate ?? this.bestDayDate,
      totalDays: totalDays ?? this.totalDays,
    );
  }

  @override
  List<Object?> get props => [
        totalSteps,
        averageSteps,
        goalSteps,
        goalProgress,
        streak,
        bestDaySteps,
        bestDayDate,
        totalDays,
      ];

  @override
  String toString() {
    return 'StepStatsModel(totalSteps: $totalSteps, averageSteps: $averageSteps, goalSteps: $goalSteps, goalProgress: $goalProgress, streak: $streak, bestDaySteps: $bestDaySteps)';
  }
}
