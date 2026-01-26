import 'package:equatable/equatable.dart';

/// Domain entity representing a group goal.
///
/// This is an immutable entity that contains business logic methods
/// for managing group goals. Unlike data models, entities do NOT
/// contain JSON serialization logic.
///
/// Example usage:
/// ```dart
/// final goal = Goal(
///   id: 'goal-123',
///   name: '10K Steps Challenge',
///   description: 'Walk 10,000 steps daily for a month',
///   targetSteps: 10000,
///   startDate: DateTime(2024, 1, 1),
///   endDate: DateTime(2024, 1, 31),
///   creatorId: 'user-456',
///   creatorUsername: 'john_doe',
///   status: 'active',
///   createdAt: DateTime.now(),
/// );
///
/// print(goal.isActive); // true
/// print(goal.daysRemaining); // depends on current date
/// print(goal.totalDays); // 31
/// ```
class Goal extends Equatable {
  /// Unique identifier for the goal.
  final String id;

  /// Name of the goal.
  final String name;

  /// Optional description of the goal.
  final String? description;

  /// Daily step target for this goal.
  final int targetSteps;

  /// Start date of the goal.
  final DateTime startDate;

  /// End date of the goal.
  final DateTime endDate;

  /// ID of the user who created this goal.
  final String creatorId;

  /// Username of the creator.
  final String creatorUsername;

  /// Current status of the goal.
  /// Possible values: 'active', 'completed', 'cancelled'.
  final String status;

  /// Timestamp when this goal was created.
  final DateTime createdAt;

  /// Creates a [Goal] instance.
  ///
  /// All fields are required except [description] which can be null.
  const Goal({
    required this.id,
    required this.name,
    this.description,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
    required this.creatorId,
    required this.creatorUsername,
    required this.status,
    required this.createdAt,
  });

  /// Returns true if the goal status is 'active'.
  bool get isActive => status == 'active';

  /// Returns true if the goal status is 'completed'.
  bool get isCompleted => status == 'completed';

  /// Returns true if the goal status is 'cancelled'.
  bool get isCancelled => status == 'cancelled';

  /// Returns the number of days remaining until the goal ends.
  ///
  /// Returns 0 if the goal has already ended.
  int get daysRemaining {
    final now = DateTime.now();
    final remaining = endDate.difference(now).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  /// Returns the total number of days for this goal.
  int get totalDays {
    return endDate.difference(startDate).inDays;
  }

  /// Returns true if the goal has started.
  bool get hasStarted {
    final now = DateTime.now();
    return !now.isBefore(startDate);
  }

  /// Returns true if the goal has ended.
  bool get hasEnded {
    final now = DateTime.now();
    return now.isAfter(endDate);
  }

  /// Returns the number of days elapsed since the goal started.
  int get daysElapsed {
    if (!hasStarted) return 0;
    final now = DateTime.now();
    final elapsed = now.difference(startDate).inDays;
    return elapsed > totalDays ? totalDays : elapsed;
  }

  /// Creates a copy of this goal with optional field overrides.
  Goal copyWith({
    String? id,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? startDate,
    DateTime? endDate,
    String? creatorId,
    String? creatorUsername,
    String? status,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetSteps: targetSteps ?? this.targetSteps,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      creatorId: creatorId ?? this.creatorId,
      creatorUsername: creatorUsername ?? this.creatorUsername,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
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
        creatorId,
        creatorUsername,
        status,
        createdAt,
      ];

  @override
  String toString() {
    return 'Goal(id: $id, name: $name, description: $description, '
        'targetSteps: $targetSteps, startDate: $startDate, endDate: $endDate, '
        'creatorId: $creatorId, creatorUsername: $creatorUsername, '
        'status: $status, createdAt: $createdAt)';
  }
}
