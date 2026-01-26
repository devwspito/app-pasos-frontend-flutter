import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'step_model.g.dart';

/// Source types for step data.
/// Matches backend StepSource type.
enum StepSource {
  /// From device health APIs (Apple HealthKit, Google Fit)
  @JsonValue('native')
  native,

  /// Manually entered by user
  @JsonValue('manual')
  manual,

  /// Entered through web interface
  @JsonValue('web')
  web,
}

/// Step model representing a single step record.
/// Maps to backend IStep interface.
@JsonSerializable()
class StepModel extends Equatable {
  /// Unique step record identifier (maps from backend _id)
  @JsonKey(name: '_id')
  final String id;

  /// Reference to the user who owns this step record
  final String userId;

  /// Number of steps recorded (must be >= 0)
  final int count;

  /// Timestamp when the steps were recorded
  final DateTime timestamp;

  /// Source of the step data
  final StepSource source;

  /// Hour of the day (0-23) for hourly aggregation
  final int hour;

  /// Date string in YYYY-MM-DD format for daily aggregation
  final String date;

  /// Document creation timestamp
  final DateTime createdAt;

  /// Document update timestamp
  final DateTime updatedAt;

  const StepModel({
    required this.id,
    required this.userId,
    required this.count,
    required this.timestamp,
    required this.source,
    required this.hour,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a StepModel from JSON map
  factory StepModel.fromJson(Map<String, dynamic> json) =>
      _$StepModelFromJson(json);

  /// Converts StepModel to JSON map
  Map<String, dynamic> toJson() => _$StepModelToJson(this);

  /// Creates a copy of StepModel with optional field updates
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
  List<Object?> get props => [
        id,
        userId,
        count,
        timestamp,
        source,
        hour,
        date,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;
}
