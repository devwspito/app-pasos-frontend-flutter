import 'package:equatable/equatable.dart';

/// Model representing step data from the API.
///
/// Contains the step count and metadata for a specific time period.
/// Used for daily, weekly, and hourly step data.
class StepModel extends Equatable {
  /// Unique identifier for the step record.
  final String? id;

  /// The number of steps recorded.
  final int stepCount;

  /// The date of the step record.
  final DateTime date;

  /// Optional hour for hourly granularity (0-23).
  final int? hour;

  /// The source of the step data (e.g., 'pedometer', 'manual', 'healthkit').
  final String? source;

  /// Creates a [StepModel] instance.
  const StepModel({
    this.id,
    required this.stepCount,
    required this.date,
    this.hour,
    this.source,
  });

  /// Creates a [StepModel] from JSON data.
  ///
  /// Handles null safety and type conversion from API response.
  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      id: json['id'] as String?,
      stepCount: (json['stepCount'] as num?)?.toInt() ??
                 (json['step_count'] as num?)?.toInt() ??
                 (json['steps'] as num?)?.toInt() ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      hour: (json['hour'] as num?)?.toInt(),
      source: json['source'] as String?,
    );
  }

  /// Converts the model to JSON for API requests and caching.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'stepCount': stepCount,
      'date': date.toIso8601String(),
      if (hour != null) 'hour': hour,
      if (source != null) 'source': source,
    };
  }

  /// Creates a copy of this model with the given fields replaced.
  StepModel copyWith({
    String? id,
    int? stepCount,
    DateTime? date,
    int? hour,
    String? source,
  }) {
    return StepModel(
      id: id ?? this.id,
      stepCount: stepCount ?? this.stepCount,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [id, stepCount, date, hour, source];

  @override
  String toString() {
    return 'StepModel(id: $id, stepCount: $stepCount, date: $date, hour: $hour, source: $source)';
  }
}
