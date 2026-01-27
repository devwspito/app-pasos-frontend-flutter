/// Group goal entity for the goals domain.
///
/// This is a pure domain entity representing a group goal where multiple
/// users can collaborate to achieve a shared step target.
/// It's independent of any data layer implementation details.
library;

import 'package:equatable/equatable.dart';

/// Represents a group goal in the application.
///
/// A group goal allows multiple users to work together towards a common
/// step target within a specified time period. The goal has different
/// statuses: active, completed, or cancelled.
///
/// Example usage:
/// ```dart
/// final goal = GroupGoal(
///   id: '123',
///   name: 'Summer Challenge',
///   description: 'Walk 100k steps together!',
///   targetSteps: 100000,
///   startDate: DateTime(2024, 6, 1),
///   endDate: DateTime(2024, 6, 30),
///   creatorId: 'user123',
///   status: 'active',
///   createdAt: DateTime.now(),
/// );
/// ```
class GroupGoal extends Equatable {
  /// Creates a [GroupGoal] instance.
  ///
  /// [id] - The unique identifier for the goal.
  /// [name] - The name of the goal.
  /// [description] - An optional description of the goal.
  /// [targetSteps] - The total step target for the group.
  /// [startDate] - When the goal period starts.
  /// [endDate] - When the goal period ends.
  /// [creatorId] - The ID of the user who created the goal.
  /// [status] - The current status: 'active', 'completed', or 'cancelled'.
  /// [createdAt] - When the goal was created.
  const GroupGoal({
    required this.id,
    required this.name,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
    required this.creatorId,
    required this.status,
    required this.createdAt,
    this.description,
  });

  /// Creates an empty goal for use in initial states.
  ///
  /// Useful for initializing state before goal data is loaded.
  factory GroupGoal.empty() => GroupGoal(
        id: '',
        name: '',
        targetSteps: 0,
        startDate: DateTime.fromMillisecondsSinceEpoch(0),
        endDate: DateTime.fromMillisecondsSinceEpoch(0),
        creatorId: '',
        status: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// The unique identifier for the goal.
  final String id;

  /// The name of the goal.
  final String name;

  /// An optional description of the goal.
  ///
  /// This may be null if no description was provided.
  final String? description;

  /// The total step target for the group to achieve.
  final int targetSteps;

  /// When the goal period starts.
  final DateTime startDate;

  /// When the goal period ends.
  final DateTime endDate;

  /// The ID of the user who created the goal.
  final String creatorId;

  /// The current status of the goal.
  ///
  /// Possible values: 'active', 'completed', 'cancelled'.
  final String status;

  /// When the goal was created.
  final DateTime createdAt;

  /// Whether this is an empty/uninitialized goal.
  bool get isEmpty => id.isEmpty;

  /// Whether this is a valid goal with data.
  bool get isNotEmpty => !isEmpty;

  /// Whether this goal is currently active.
  bool get isActive => status == 'active';

  /// Whether this goal has been completed.
  bool get isCompleted => status == 'completed';

  /// Whether this goal has been cancelled.
  bool get isCancelled => status == 'cancelled';

  /// Whether the goal has a description.
  bool get hasDescription => description != null && description!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        targetSteps,
        startDate,
        endDate,
        creatorId,
        status,
        createdAt,
      ];

  @override
  String toString() {
    return 'GroupGoal(id: $id, name: $name, description: $description, '
        'targetSteps: $targetSteps, startDate: $startDate, endDate: $endDate, '
        'creatorId: $creatorId, status: $status, createdAt: $createdAt)';
  }
}
