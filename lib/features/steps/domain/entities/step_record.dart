/// Entity representing a step record for a specific time period.
///
/// This is a domain entity that represents step count data captured
/// from health tracking sources like HealthKit or Google Fit.
class StepRecord {
  /// Unique identifier for this step record.
  final String id;

  /// The number of steps recorded in this period.
  final int steps;

  /// The start time of the recording period.
  final DateTime startTime;

  /// The end time of the recording period.
  final DateTime endTime;

  /// The source of the step data (e.g., 'healthkit', 'google_fit', 'manual').
  final String source;

  /// The date this record belongs to (normalized to midnight).
  final DateTime date;

  /// Distance walked/run in meters (optional, may not be available from all sources).
  final double? distanceMeters;

  /// Calories burned during this period (optional).
  final double? caloriesBurned;

  /// Creates a new [StepRecord] instance.
  const StepRecord({
    required this.id,
    required this.steps,
    required this.startTime,
    required this.endTime,
    required this.source,
    required this.date,
    this.distanceMeters,
    this.caloriesBurned,
  });

  /// Creates a copy of this record with the given fields replaced.
  StepRecord copyWith({
    String? id,
    int? steps,
    DateTime? startTime,
    DateTime? endTime,
    String? source,
    DateTime? date,
    double? distanceMeters,
    double? caloriesBurned,
  }) {
    return StepRecord(
      id: id ?? this.id,
      steps: steps ?? this.steps,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      source: source ?? this.source,
      date: date ?? this.date,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StepRecord &&
        other.id == id &&
        other.steps == steps &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.source == source &&
        other.date == date &&
        other.distanceMeters == distanceMeters &&
        other.caloriesBurned == caloriesBurned;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      steps,
      startTime,
      endTime,
      source,
      date,
      distanceMeters,
      caloriesBurned,
    );
  }

  @override
  String toString() {
    return 'StepRecord(id: $id, steps: $steps, date: $date, source: $source)';
  }
}
