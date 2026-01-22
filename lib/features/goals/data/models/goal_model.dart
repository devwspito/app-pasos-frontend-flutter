import '../../domain/entities/goal.dart';

/// Data model for Goal entity.
///
/// Handles JSON serialization/deserialization for API communication.
class GoalModel extends Goal {
  const GoalModel({
    required super.id,
    required super.name,
    required super.description,
    required super.targetSteps,
    required super.startDate,
    required super.endDate,
    required super.type,
    required super.status,
    required super.createdBy,
    super.inviteCode,
    super.memberCount,
    super.currentSteps,
  });

  /// Creates a [GoalModel] from JSON map.
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetSteps: json['targetSteps'] as int? ?? 0,
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      type: _parseGoalType(json['type']),
      status: _parseGoalStatus(json['status']),
      createdBy: json['createdBy'] as String? ?? '',
      inviteCode: json['inviteCode'] as String?,
      memberCount: json['memberCount'] as int? ?? 1,
      currentSteps: json['currentSteps'] as int? ?? 0,
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
      'type': type == GoalType.group ? 'group' : 'individual',
      'status': _statusToString(status),
      'createdBy': createdBy,
      if (inviteCode != null) 'inviteCode': inviteCode,
      'memberCount': memberCount,
      'currentSteps': currentSteps,
    };
  }

  /// Converts a [Goal] entity to a [GoalModel].
  factory GoalModel.fromEntity(Goal goal) {
    return GoalModel(
      id: goal.id,
      name: goal.name,
      description: goal.description,
      targetSteps: goal.targetSteps,
      startDate: goal.startDate,
      endDate: goal.endDate,
      type: goal.type,
      status: goal.status,
      createdBy: goal.createdBy,
      inviteCode: goal.inviteCode,
      memberCount: goal.memberCount,
      currentSteps: goal.currentSteps,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static GoalType _parseGoalType(dynamic value) {
    if (value == 'group') return GoalType.group;
    return GoalType.individual;
  }

  static GoalStatus _parseGoalStatus(dynamic value) {
    switch (value) {
      case 'completed':
        return GoalStatus.completed;
      case 'cancelled':
        return GoalStatus.cancelled;
      case 'expired':
        return GoalStatus.expired;
      default:
        return GoalStatus.active;
    }
  }

  static String _statusToString(GoalStatus status) {
    switch (status) {
      case GoalStatus.active:
        return 'active';
      case GoalStatus.completed:
        return 'completed';
      case GoalStatus.cancelled:
        return 'cancelled';
      case GoalStatus.expired:
        return 'expired';
    }
  }
}
