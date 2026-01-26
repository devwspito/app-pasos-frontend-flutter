import 'package:equatable/equatable.dart';

/// Domain entity representing a single step record.
///
/// This is an immutable entity that contains business logic methods
/// for step-related calculations. Unlike data models, entities do NOT
/// contain JSON serialization logic.
///
/// Example usage:
/// ```dart
/// final record = StepRecord(
///   id: 'step-123',
///   userId: 'user-456',
///   stepCount: 8500,
///   date: DateTime.now(),
///   source: 'healthkit',
///   createdAt: DateTime.now(),
/// );
///
/// print(record.isFromHealthKit); // true
/// print(record.percentOfGoal(10000)); // 0.85
/// ```
class StepRecord extends Equatable {
  /// Unique identifier for the step record.
  final String id;

  /// ID of the user who owns this record.
  final String userId;

  /// Number of steps recorded.
  final int stepCount;

  /// Date when the steps were recorded.
  final DateTime date;

  /// Source of the step data (e.g., 'healthkit', 'health_connect', 'manual').
  final String source;

  /// Timestamp when this record was created.
  final DateTime createdAt;

  /// Creates a [StepRecord] instance.
  ///
  /// All fields are required and immutable.
  const StepRecord({
    required this.id,
    required this.userId,
    required this.stepCount,
    required this.date,
    required this.source,
    required this.createdAt,
  });

  /// Returns true if this step data came from Apple HealthKit.
  bool get isFromHealthKit => source.toLowerCase() == 'healthkit';

  /// Returns true if this step data came from Android Health Connect.
  bool get isFromHealthConnect => source.toLowerCase() == 'health_connect';

  /// Returns true if this step data was manually entered.
  bool get isManualEntry => source.toLowerCase() == 'manual';

  /// Returns true if the record's date is today.
  ///
  /// Compares only the year, month, and day components, ignoring time.
  bool get isToday {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  /// Calculates the percentage of a given goal achieved.
  ///
  /// Returns a value between 0.0 and 1.0 (clamped).
  /// A value of 1.0 means the goal has been reached or exceeded.
  ///
  /// Example:
  /// ```dart
  /// final record = StepRecord(..., stepCount: 7500);
  /// print(record.percentOfGoal(10000)); // 0.75
  /// print(record.percentOfGoal(5000)); // 1.0 (clamped)
  /// ```
  double percentOfGoal(int goal) {
    if (goal <= 0) return 0.0;
    return (stepCount / goal).clamp(0.0, 1.0);
  }

  /// Returns true if the step count meets or exceeds the given goal.
  bool hasReachedGoal(int goal) => stepCount >= goal;

  /// Returns the number of steps remaining to reach the goal.
  ///
  /// Returns 0 if the goal has already been reached.
  int stepsRemainingForGoal(int goal) {
    return (goal - stepCount).clamp(0, goal);
  }

  /// Creates a copy of this record with optional field overrides.
  StepRecord copyWith({
    String? id,
    String? userId,
    int? stepCount,
    DateTime? date,
    String? source,
    DateTime? createdAt,
  }) {
    return StepRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stepCount: stepCount ?? this.stepCount,
      date: date ?? this.date,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Helper method to check if two dates are the same day.
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  List<Object?> get props => [id, userId, stepCount, date, source, createdAt];

  @override
  String toString() {
    return 'StepRecord(id: $id, userId: $userId, stepCount: $stepCount, '
        'date: $date, source: $source, createdAt: $createdAt)';
  }
}
