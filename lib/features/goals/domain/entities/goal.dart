import 'package:equatable/equatable.dart';

/// Enum representing the type of goal
enum GoalType {
  individual,
  group,
}

/// Enum representing the status of a goal
enum GoalStatus {
  active,
  completed,
  cancelled,
}

/// Domain entity representing a goal.
///
/// This is a pure domain entity with no serialization logic.
/// Use [GoalModel] in the data layer for API serialization.
final class Goal extends Equatable {
  const Goal({
    required this.id,
    required this.name,
    required this.description,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.status,
    required this.creatorId,
    required this.createdAt,
    this.inviteCode,
  });

  /// Unique identifier for the goal.
  final String id;

  /// Name of the goal.
  final String name;

  /// Description of the goal.
  final String description;

  /// Target number of steps to achieve.
  final int targetSteps;

  /// Start date of the goal period.
  final DateTime startDate;

  /// End date of the goal period.
  final DateTime endDate;

  /// Type of goal (individual or group).
  final GoalType type;

  /// Current status of the goal.
  final GoalStatus status;

  /// ID of the user who created the goal.
  final String creatorId;

  /// Timestamp when the goal was created.
  final DateTime createdAt;

  /// Invite code for group goals (null for individual goals).
  final String? inviteCode;

  /// Returns true if this is a group goal.
  bool get isGroupGoal => type == GoalType.group;

  /// Returns true if the goal is currently active.
  bool get isActive => status == GoalStatus.active;

  /// Returns the duration of the goal in days.
  int get durationDays => endDate.difference(startDate).inDays;

  /// Creates a copy of this Goal with the given fields replaced.
  Goal copyWith({
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
    return Goal(
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

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        targetSteps,
        startDate,
        endDate,
        type,
        status,
        creatorId,
        createdAt,
        inviteCode,
      ];

  @override
  String toString() =>
      'Goal(id: $id, name: $name, type: ${type.name}, status: ${status.name})';
}
