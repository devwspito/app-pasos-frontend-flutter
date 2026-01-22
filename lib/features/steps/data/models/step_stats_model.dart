import '../../domain/entities/step_stats.dart';

/// Data model for StepStats with JSON serialization
final class StepStatsModel extends StepStats {
  const StepStatsModel({
    required super.todaySteps,
    required super.goalSteps,
    required super.weeklyAverage,
    required super.percentComplete,
  });

  /// Creates a StepStatsModel from a JSON map
  factory StepStatsModel.fromJson(Map<String, dynamic> json) {
    return StepStatsModel(
      todaySteps: json['todaySteps'] as int,
      goalSteps: json['goalSteps'] as int,
      weeklyAverage: (json['weeklyAverage'] as num).toDouble(),
      percentComplete: (json['percentComplete'] as num).toDouble(),
    );
  }

  /// Creates a StepStatsModel from a StepStats entity
  factory StepStatsModel.fromEntity(StepStats entity) {
    return StepStatsModel(
      todaySteps: entity.todaySteps,
      goalSteps: entity.goalSteps,
      weeklyAverage: entity.weeklyAverage,
      percentComplete: entity.percentComplete,
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'todaySteps': todaySteps,
      'goalSteps': goalSteps,
      'weeklyAverage': weeklyAverage,
      'percentComplete': percentComplete,
    };
  }

  @override
  StepStatsModel copyWith({
    int? todaySteps,
    int? goalSteps,
    double? weeklyAverage,
    double? percentComplete,
  }) {
    return StepStatsModel(
      todaySteps: todaySteps ?? this.todaySteps,
      goalSteps: goalSteps ?? this.goalSteps,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      percentComplete: percentComplete ?? this.percentComplete,
    );
  }
}
