import 'package:equatable/equatable.dart';

/// Domain entity representing a goal in the goals feature.
///
/// This is an immutable entity that contains business logic methods
/// for managing goals. Unlike data models, entities do NOT contain
/// JSON serialization logic.
///
/// TODO: This is a stub entity file. Full implementation will be added
/// by a future story that creates the complete Goals domain layer.
///
/// Example usage:
/// ```dart
/// final goal = Goal(
///   id: 'goal-123',
///   name: 'Daily Steps Challenge',
///   description: 'Walk 10,000 steps daily',
///   targetSteps: 10000,
///   startDate: DateTime.now(),
///   endDate: DateTime.now().add(Duration(days: 30)),
///   creatorId: 'user-456',
///   creatorUsername: 'john_doe',
///   status: 'active',
///   createdAt: DateTime.now(),
/// );
///
/// print(goal.isActive); // true
/// print(goal.daysRemaining); // ~30
/// ```
class Goal extends Equatable {
  /// Unique identifier for the goal.
  final String id;

  /// Display name of the goal.
  final String name;

  /// Optional description providing more details about the goal.
  final String? description;

  /// Target number of steps to achieve.
  final int targetSteps;

  /// When the goal tracking should begin.
  final DateTime startDate;

  /// When the goal tracking should end.
  final DateTime endDate;

  /// ID of the user who created this goal.
  final String creatorId;

  /// Username of the goal creator.
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
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  /// Returns the total duration of the goal in days.
  int get totalDays => endDate.difference(startDate).inDays;

  /// Returns true if the goal has started (start date is in the past).
  bool get hasStarted => DateTime.now().isAfter(startDate);

  /// Returns true if the goal has ended (end date is in the past).
  bool get hasEnded => DateTime.now().isAfter(endDate);

  /// Returns the progress percentage based on time elapsed.
  ///
  /// Returns a value between 0.0 and 1.0.
  double get timeProgress {
    if (!hasStarted) return 0.0;
    if (hasEnded) return 1.0;
    final total = endDate.difference(startDate).inMilliseconds;
    final elapsed = DateTime.now().difference(startDate).inMilliseconds;
    return (elapsed / total).clamp(0.0, 1.0);
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
