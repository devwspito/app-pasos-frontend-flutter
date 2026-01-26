import 'package:equatable/equatable.dart';

// TODO: Step entity will be created by Domain Layer story
// import '../../domain/entities/step.dart';

/// Data layer model for Step records.
///
/// This model handles JSON serialization/deserialization for step data
/// from various sources like HealthKit, Health Connect, or manual entry.
/// Extends [Equatable] for value equality comparison.
///
/// Example JSON:
/// ```json
/// {
///   "id": "step-123",
///   "userId": "user-456",
///   "stepCount": 8500,
///   "date": "2024-01-15T00:00:00Z",
///   "source": "healthkit",
///   "createdAt": "2024-01-15T10:30:00Z"
/// }
/// ```
class StepModel extends Equatable {
  /// Unique identifier for the step record.
  final String id;

  /// User ID who owns this step record.
  final String userId;

  /// Number of steps recorded.
  final int stepCount;

  /// Date when the steps were recorded.
  final DateTime date;

  /// Source of the step data (e.g., 'healthkit', 'manual', 'health_connect').
  final String source;

  /// Timestamp when this record was created.
  final DateTime createdAt;

  /// Creates a [StepModel] instance.
  const StepModel({
    required this.id,
    required this.userId,
    required this.stepCount,
    required this.date,
    required this.source,
    required this.createdAt,
  });

  /// Creates a [StepModel] from a JSON map.
  ///
  /// Handles null safety for all fields with appropriate defaults.
  /// Parses [date] and [createdAt] from ISO 8601 string format.
  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      stepCount: json['stepCount'] as int? ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      source: json['source'] as String? ?? 'manual',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// Serializes [date] and [createdAt] to ISO 8601 string format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'stepCount': stepCount,
      'date': date.toIso8601String(),
      'source': source,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Converts this data model to a domain [Step] entity.
  ///
  /// Note: Uncomment when Step entity is available in domain layer.
  // Step toEntity() {
  //   return Step(
  //     id: id,
  //     userId: userId,
  //     stepCount: stepCount,
  //     date: date,
  //     source: source,
  //     createdAt: createdAt,
  //   );
  // }

  /// Creates a copy of this model with optional field overrides.
  StepModel copyWith({
    String? id,
    String? userId,
    int? stepCount,
    DateTime? date,
    String? source,
    DateTime? createdAt,
  }) {
    return StepModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stepCount: stepCount ?? this.stepCount,
      date: date ?? this.date,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, stepCount, date, source, createdAt];

  @override
  String toString() {
    return 'StepModel(id: $id, userId: $userId, stepCount: $stepCount, '
        'date: $date, source: $source, createdAt: $createdAt)';
  }
}
