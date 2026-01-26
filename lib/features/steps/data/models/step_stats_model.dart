import 'package:equatable/equatable.dart';

// TODO: StepStats entity will be created by Domain Layer story
// import '../../domain/entities/step_stats.dart';

/// Data layer model for Step Statistics.
///
/// This model handles JSON serialization/deserialization for step statistics
/// including totals, averages, goals, and streaks.
/// Extends [Equatable] for value equality comparison.
///
/// Example JSON:
/// ```json
/// {
///   "totalSteps": 85000,
///   "averageSteps": 8500.0,
///   "goalSteps": 10000,
///   "goalProgress": 0.85,
///   "streak": 5,
///   "bestDay": "2024-01-12T00:00:00Z",
///   "bestDaySteps": 15000
/// }
/// ```
class StepStatsModel extends Equatable {
  /// Total steps accumulated over the period.
  final int totalSteps;

  /// Average steps per day.
  final double averageSteps;

  /// Daily step goal target.
  final int goalSteps;

  /// Progress towards daily goal (0.0 to 1.0).
  final double goalProgress;

  /// Number of consecutive days meeting the goal.
  final int streak;

  /// Date of the best day (highest steps). Can be null if no data.
  final DateTime? bestDay;

  /// Number of steps on the best day.
  final int bestDaySteps;

  /// Creates a [StepStatsModel] instance.
  const StepStatsModel({
    required this.totalSteps,
    required this.averageSteps,
    required this.goalSteps,
    required this.goalProgress,
    required this.streak,
    this.bestDay,
    required this.bestDaySteps,
  });

  /// Creates a [StepStatsModel] from a JSON map.
  ///
  /// Handles null safety for all fields with appropriate defaults.
  /// Parses [bestDay] from ISO 8601 string format if present.
  factory StepStatsModel.fromJson(Map<String, dynamic> json) {
    return StepStatsModel(
      totalSteps: json['totalSteps'] as int? ?? 0,
      averageSteps: (json['averageSteps'] as num?)?.toDouble() ?? 0.0,
      goalSteps: json['goalSteps'] as int? ?? 10000,
      goalProgress: (json['goalProgress'] as num?)?.toDouble() ?? 0.0,
      streak: json['streak'] as int? ?? 0,
      bestDay: json['bestDay'] != null
          ? DateTime.parse(json['bestDay'] as String)
          : null,
      bestDaySteps: json['bestDaySteps'] as int? ?? 0,
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// Serializes [bestDay] to ISO 8601 string format if present.
  Map<String, dynamic> toJson() {
    return {
      'totalSteps': totalSteps,
      'averageSteps': averageSteps,
      'goalSteps': goalSteps,
      'goalProgress': goalProgress,
      'streak': streak,
      'bestDay': bestDay?.toIso8601String(),
      'bestDaySteps': bestDaySteps,
    };
  }

  /// Converts this data model to a domain [StepStats] entity.
  ///
  /// Note: Uncomment when StepStats entity is available in domain layer.
  // StepStats toEntity() {
  //   return StepStats(
  //     totalSteps: totalSteps,
  //     averageSteps: averageSteps,
  //     goalSteps: goalSteps,
  //     goalProgress: goalProgress,
  //     streak: streak,
  //     bestDay: bestDay,
  //     bestDaySteps: bestDaySteps,
  //   );
  // }

  /// Creates a copy of this model with optional field overrides.
  StepStatsModel copyWith({
    int? totalSteps,
    double? averageSteps,
    int? goalSteps,
    double? goalProgress,
    int? streak,
    DateTime? bestDay,
    int? bestDaySteps,
  }) {
    return StepStatsModel(
      totalSteps: totalSteps ?? this.totalSteps,
      averageSteps: averageSteps ?? this.averageSteps,
      goalSteps: goalSteps ?? this.goalSteps,
      goalProgress: goalProgress ?? this.goalProgress,
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
        goalProgress,
        streak,
        bestDay,
        bestDaySteps,
      ];

  @override
  String toString() {
    return 'StepStatsModel(totalSteps: $totalSteps, averageSteps: $averageSteps, '
        'goalSteps: $goalSteps, goalProgress: $goalProgress, streak: $streak, '
        'bestDay: $bestDay, bestDaySteps: $bestDaySteps)';
  }
}
