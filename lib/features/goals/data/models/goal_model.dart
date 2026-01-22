import '../../domain/entities/goal.dart';

/// Data model for Goal with JSON serialization.
final class GoalModel extends Goal {
  const GoalModel({
    required super.id,
    required super.name,
    required super.description,
    required super.targetSteps,
    required super.startDate,
    required super.endDate,
    required super.type,
    required super.status,
    required super.creatorId,
    required super.createdAt,
    super.inviteCode,
  });

  /// Creates a GoalModel from a JSON map.
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      targetSteps: json['targetSteps'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      type: _parseGoalType(json['type'] as String),
      status: _parseGoalStatus(json['status'] as String),
      creatorId: json['creatorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      inviteCode: json['inviteCode'] as String?,
    );
  }

  /// Creates a GoalModel from a Goal entity.
  factory GoalModel.fromEntity(Goal entity) {
    return GoalModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      targetSteps: entity.targetSteps,
      startDate: entity.startDate,
      endDate: entity.endDate,
      type: entity.type,
      status: entity.status,
      creatorId: entity.creatorId,
      createdAt: entity.createdAt,
      inviteCode: entity.inviteCode,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetSteps': targetSteps,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'type': type.name,
      'status': status.name,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      if (inviteCode != null) 'inviteCode': inviteCode,
    };
  }

  /// Parses a string to GoalType enum.
  static GoalType _parseGoalType(String value) {
    return GoalType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GoalType.individual,
    );
  }

  /// Parses a string to GoalStatus enum.
  static GoalStatus _parseGoalStatus(String value) {
    return GoalStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GoalStatus.active,
    );
  }

  @override
  GoalModel copyWith({
    String? id,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? startDate,
    DateTime? endDate,
    GoalType? type,
    GoalStatus? status,
    String? creatorId,
    DateTime? createdAt,
    String? inviteCode,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetSteps: targetSteps ?? this.targetSteps,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      status: status ?? this.status,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}
