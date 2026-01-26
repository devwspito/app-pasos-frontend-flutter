import 'package:equatable/equatable.dart';

/// Domain entity representing a step record.
///
/// This is a clean architecture entity used in the domain layer.
/// It represents a single step record for a user on a specific date.
class StepRecord extends Equatable {
  /// Unique identifier for the step record.
  final String id;

  /// User ID who owns this step record.
  final String userId;

  /// Total number of steps recorded.
  final int stepCount;

  /// Date for which this step record applies.
  final DateTime date;

  /// Source of the step data (e.g., 'health_kit', 'google_fit', 'manual').
  final String source;

  /// Timestamp when this record was created.
  final DateTime createdAt;

  /// Daily step goal for this record.
  final int? dailyGoal;

  /// Creates a [StepRecord] instance.
  const StepRecord({
    required this.id,
    required this.userId,
    required this.stepCount,
    required this.date,
    required this.source,
    required this.createdAt,
    this.dailyGoal,
  });

  /// Calculates the percentage of daily goal achieved.
  /// Returns 0 if no daily goal is set.
  double get goalProgress {
    if (dailyGoal == null || dailyGoal == 0) return 0;
    return (stepCount / dailyGoal!) * 100;
  }

  /// Returns true if the daily goal has been achieved.
  bool get goalAchieved {
    if (dailyGoal == null) return false;
    return stepCount >= dailyGoal!;
  }

  /// Creates a copy of this record with optional field overrides.
  StepRecord copyWith({
    String? id,
    String? userId,
    int? stepCount,
    DateTime? date,
    String? source,
    DateTime? createdAt,
    int? dailyGoal,
  }) {
    return StepRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stepCount: stepCount ?? this.stepCount,
      date: date ?? this.date,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        stepCount,
        date,
        source,
        createdAt,
        dailyGoal,
      ];

  @override
  String toString() {
    return 'StepRecord(id: $id, userId: $userId, stepCount: $stepCount, '
        'date: $date, source: $source, createdAt: $createdAt, dailyGoal: $dailyGoal)';
  }
}
