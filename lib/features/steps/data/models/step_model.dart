import 'package:equatable/equatable.dart';

import '../../domain/entities/step_record.dart';

/// Data layer model for step records.
///
/// This model handles JSON serialization/deserialization for API responses
/// and local storage. Extends [Equatable] for value equality comparison.
///
/// Example JSON:
/// ```json
/// {
///   "id": "step-123",
///   "userId": "user-456",
///   "stepCount": 8500,
///   "date": "2024-01-15",
///   "source": "health_kit",
///   "createdAt": "2024-01-15T10:30:00Z",
///   "dailyGoal": 10000
/// }
/// ```
class StepModel extends Equatable {
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

  /// Whether this record is pending sync to the server.
  final bool pendingSync;

  /// Creates a [StepModel] instance.
  const StepModel({
    required this.id,
    required this.userId,
    required this.stepCount,
    required this.date,
    required this.source,
    required this.createdAt,
    this.dailyGoal,
    this.pendingSync = false,
  });

  /// Creates a [StepModel] from a JSON map.
  ///
  /// Handles null safety for all fields with appropriate defaults.
  /// Parses date fields from ISO 8601 string format.
  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      stepCount: json['stepCount'] as int? ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      source: json['source'] as String? ?? 'unknown',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      dailyGoal: json['dailyGoal'] as int?,
      pendingSync: json['pendingSync'] as bool? ?? false,
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// Serializes date fields to ISO 8601 string format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'stepCount': stepCount,
      'date': date.toIso8601String().split('T').first,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      if (dailyGoal != null) 'dailyGoal': dailyGoal,
      'pendingSync': pendingSync,
    };
  }

  /// Converts this data model to a domain [StepRecord] entity.
  StepRecord toEntity() {
    return StepRecord(
      id: id,
      userId: userId,
      stepCount: stepCount,
      date: date,
      source: source,
      createdAt: createdAt,
      dailyGoal: dailyGoal,
    );
  }

  /// Creates a [StepModel] from a domain [StepRecord] entity.
  factory StepModel.fromEntity(StepRecord entity, {bool pendingSync = false}) {
    return StepModel(
      id: entity.id,
      userId: entity.userId,
      stepCount: entity.stepCount,
      date: entity.date,
      source: entity.source,
      createdAt: entity.createdAt,
      dailyGoal: entity.dailyGoal,
      pendingSync: pendingSync,
    );
  }

  /// Creates a copy of this model with optional field overrides.
  StepModel copyWith({
    String? id,
    String? userId,
    int? stepCount,
    DateTime? date,
    String? source,
    DateTime? createdAt,
    int? dailyGoal,
    bool? pendingSync,
  }) {
    return StepModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stepCount: stepCount ?? this.stepCount,
      date: date ?? this.date,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      pendingSync: pendingSync ?? this.pendingSync,
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
        pendingSync,
      ];

  @override
  String toString() {
    return 'StepModel(id: $id, userId: $userId, stepCount: $stepCount, '
        'date: $date, source: $source, createdAt: $createdAt, '
        'dailyGoal: $dailyGoal, pendingSync: $pendingSync)';
  }
}
