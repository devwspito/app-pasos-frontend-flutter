import 'package:equatable/equatable.dart';

/// Represents the type of goal
enum GoalType {
  /// Individual goal (solo challenge)
  individual,

  /// Group goal (shared with others)
  group,
}

/// Represents the status of a goal
enum GoalStatus {
  /// Goal is active and in progress
  active,

  /// Goal has been completed successfully
  completed,

  /// Goal was cancelled or abandoned
  cancelled,

  /// Goal period has expired
  expired,
}

/// Domain entity representing a goal.
///
/// A goal can be either individual or group-based, with defined
/// step targets and time periods.
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
    required this.createdBy,
    this.inviteCode,
    this.memberCount = 1,
    this.currentSteps = 0,
  });

  /// Unique identifier for the goal
  final String id;

  /// Name/title of the goal
  final String name;

  /// Detailed description of the goal
  final String description;

  /// Target number of steps to achieve
  final int targetSteps;

  /// Start date of the goal period
  final DateTime startDate;

  /// End date of the goal period
  final DateTime endDate;

  /// Type of goal (individual or group)
  final GoalType type;

  /// Current status of the goal
  final GoalStatus status;

  /// User ID of the goal creator
  final String createdBy;

  /// Invite code for group goals (null for individual)
  final String? inviteCode;

  /// Number of members participating (1 for individual)
  final int memberCount;

  /// Current total steps accumulated
  final int currentSteps;

  /// Whether this is a group goal
  bool get isGroup => type == GoalType.group;

  /// Whether the goal is still active
  bool get isActive => status == GoalStatus.active;

  /// Progress percentage (0-100+)
  double get progressPercent => targetSteps > 0
      ? (currentSteps / targetSteps) * 100
      : 0;

  /// Whether the target has been achieved
  bool get isAchieved => currentSteps >= targetSteps;

  /// Days remaining until goal ends
  int get daysRemaining {
    final now = DateTime.now();
    final diff = endDate.difference(now).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Creates a copy with updated fields
  Goal copyWith({
    String? id,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? startDate,
    DateTime? endDate,
    GoalType? type,
    GoalStatus? status,
    String? createdBy,
    String? inviteCode,
    int? memberCount,
    int? currentSteps,
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
      createdBy: createdBy ?? this.createdBy,
      inviteCode: inviteCode ?? this.inviteCode,
      memberCount: memberCount ?? this.memberCount,
      currentSteps: currentSteps ?? this.currentSteps,
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
        createdBy,
        inviteCode,
        memberCount,
        currentSteps,
      ];

  @override
  String toString() {
    return 'Goal(id: $id, name: $name, type: $type, status: $status, '
        'progress: ${progressPercent.toStringAsFixed(1)}%)';
  }
}
