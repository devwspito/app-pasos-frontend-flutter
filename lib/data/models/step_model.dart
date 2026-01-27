import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'step_model.g.dart';

/// Enum representing the source of step data.
///
/// - [native]: Steps recorded from device health APIs (HealthKit, Google Fit)
/// - [manual]: Steps manually entered by the user
/// - [web]: Steps entered through the web interface
enum StepSource {
  @JsonValue('native')
  native,
  @JsonValue('manual')
  manual,
  @JsonValue('web')
  web,
}

/// Data model representing a step record from the backend API.
///
/// Maps to the MongoDB Step schema with JSON serialization support.
/// Contains step count data with timestamp and source information.
@JsonSerializable()
class StepModel extends Equatable {
  /// MongoDB document ID (optional for new records)
  @JsonKey(name: '_id')
  final String? id;

  /// ID of the user who owns this step record
  final String userId;

  /// Number of steps recorded
  final int count;

  /// Timestamp when the steps were recorded
  final DateTime timestamp;

  /// Source of the step data (native, manual, or web)
  final StepSource source;

  /// Hour of the day when steps were recorded (0-23)
  final int hour;

  /// Date string in YYYY-MM-DD format
  final String date;

  /// Timestamp when the record was created
  final DateTime? createdAt;

  /// Timestamp when the record was last updated
  final DateTime? updatedAt;

  const StepModel({
    this.id,
    required this.userId,
    required this.count,
    required this.timestamp,
    required this.source,
    required this.hour,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [StepModel] from a JSON map.
  factory StepModel.fromJson(Map<String, dynamic> json) =>
      _$StepModelFromJson(json);

  /// Converts this [StepModel] to a JSON map.
  Map<String, dynamic> toJson() => _$StepModelToJson(this);

  @override
  List<Object?> get props =>
      [id, userId, count, timestamp, source, hour, date, createdAt, updatedAt];

  /// Factory constructor to create a new step record for recording.
  ///
  /// Automatically calculates [hour] and [date] from the provided or current timestamp.
  factory StepModel.create({
    required String userId,
    required int count,
    required StepSource source,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    return StepModel(
      userId: userId,
      count: count,
      timestamp: now,
      source: source,
      hour: now.hour,
      date:
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
    );
  }

  /// Creates a copy of this [StepModel] with the given fields replaced.
  StepModel copyWith({
    String? id,
    String? userId,
    int? count,
    DateTime? timestamp,
    StepSource? source,
    int? hour,
    String? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StepModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      count: count ?? this.count,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
      hour: hour ?? this.hour,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'StepModel(id: $id, userId: $userId, count: $count, date: $date, source: $source)';
}

/// Response model for today's steps API endpoint.
///
/// Contains aggregated step count for the current day.
@JsonSerializable()
class TodayStepsResponse extends Equatable {
  /// Total number of steps recorded today
  final int totalSteps;

  /// Date string in YYYY-MM-DD format
  final String date;

  const TodayStepsResponse({
    required this.totalSteps,
    required this.date,
  });

  /// Creates a [TodayStepsResponse] from a JSON map.
  factory TodayStepsResponse.fromJson(Map<String, dynamic> json) =>
      _$TodayStepsResponseFromJson(json);

  /// Converts this [TodayStepsResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$TodayStepsResponseToJson(this);

  @override
  List<Object?> get props => [totalSteps, date];

  @override
  String toString() =>
      'TodayStepsResponse(totalSteps: $totalSteps, date: $date)';
}

/// Response model for weekly trend API endpoint.
///
/// Contains daily step data for the past week with aggregated statistics.
@JsonSerializable()
class WeeklyTrendResponse extends Equatable {
  /// List of daily step records for the week
  final List<DailySteps> days;

  /// Total steps across all days in the week
  final int totalSteps;

  /// Average steps per day
  final double averageSteps;

  const WeeklyTrendResponse({
    required this.days,
    required this.totalSteps,
    required this.averageSteps,
  });

  /// Creates a [WeeklyTrendResponse] from a JSON map.
  factory WeeklyTrendResponse.fromJson(Map<String, dynamic> json) =>
      _$WeeklyTrendResponseFromJson(json);

  /// Converts this [WeeklyTrendResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$WeeklyTrendResponseToJson(this);

  @override
  List<Object?> get props => [days, totalSteps, averageSteps];

  @override
  String toString() =>
      'WeeklyTrendResponse(totalSteps: $totalSteps, averageSteps: $averageSteps, days: ${days.length})';
}

/// Model representing daily step aggregation.
///
/// Used within [WeeklyTrendResponse] to represent each day's total.
@JsonSerializable()
class DailySteps extends Equatable {
  /// Date string in YYYY-MM-DD format
  final String date;

  /// Total steps recorded on this day
  final int totalSteps;

  const DailySteps({
    required this.date,
    required this.totalSteps,
  });

  /// Creates a [DailySteps] from a JSON map.
  factory DailySteps.fromJson(Map<String, dynamic> json) =>
      _$DailyStepsFromJson(json);

  /// Converts this [DailySteps] to a JSON map.
  Map<String, dynamic> toJson() => _$DailyStepsToJson(this);

  @override
  List<Object?> get props => [date, totalSteps];

  @override
  String toString() => 'DailySteps(date: $date, totalSteps: $totalSteps)';
}
