import '../../domain/entities/step_record.dart';

/// Data model for StepRecord with JSON serialization
final class StepModel extends StepRecord {
  const StepModel({
    required super.id,
    required super.userId,
    required super.stepCount,
    required super.recordedAt,
    required super.source,
  });

  /// Creates a StepModel from a JSON map
  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      stepCount: json['stepCount'] as int,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      source: _parseStepSource(json['source'] as String),
    );
  }

  /// Creates a StepModel from a StepRecord entity
  factory StepModel.fromEntity(StepRecord entity) {
    return StepModel(
      id: entity.id,
      userId: entity.userId,
      stepCount: entity.stepCount,
      recordedAt: entity.recordedAt,
      source: entity.source,
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'stepCount': stepCount,
      'recordedAt': recordedAt.toIso8601String(),
      'source': source.name,
    };
  }

  /// Parses a string to StepSource enum
  static StepSource _parseStepSource(String value) {
    return StepSource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StepSource.manual,
    );
  }

  @override
  StepModel copyWith({
    String? id,
    String? userId,
    int? stepCount,
    DateTime? recordedAt,
    StepSource? source,
  }) {
    return StepModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stepCount: stepCount ?? this.stepCount,
      recordedAt: recordedAt ?? this.recordedAt,
      source: source ?? this.source,
    );
  }
}
