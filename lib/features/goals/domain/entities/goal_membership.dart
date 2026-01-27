/// Goal membership entity for the goals domain.
///
/// This is a pure domain entity representing a user's membership in a
/// group goal. It's independent of any data layer implementation details.
library;

import 'package:equatable/equatable.dart';

/// Represents a user's membership in a group goal.
///
/// A goal membership tracks which users are participating in a goal,
/// their role (creator, admin, or member), and their current status
/// (active, invited, or left).
///
/// Example usage:
/// ```dart
/// final membership = GoalMembership(
///   id: '123',
///   goalId: 'goal456',
///   userId: 'user789',
///   role: 'member',
///   joinedAt: DateTime.now(),
///   status: 'active',
/// );
/// ```
class GoalMembership extends Equatable {
  /// Creates a [GoalMembership] instance.
  ///
  /// [id] - The unique identifier for the membership.
  /// [goalId] - The ID of the goal.
  /// [userId] - The ID of the user.
  /// [role] - The user's role: 'creator', 'admin', or 'member'.
  /// [joinedAt] - When the user joined the goal.
  /// [status] - The membership status: 'active', 'invited', or 'left'.
  const GoalMembership({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.status,
  });

  /// Creates an empty membership for use in initial states.
  ///
  /// Useful for initializing state before membership data is loaded.
  factory GoalMembership.empty() => GoalMembership(
        id: '',
        goalId: '',
        userId: '',
        role: '',
        joinedAt: DateTime.fromMillisecondsSinceEpoch(0),
        status: '',
      );

  /// The unique identifier for the membership.
  final String id;

  /// The ID of the goal this membership belongs to.
  final String goalId;

  /// The ID of the user who is a member.
  final String userId;

  /// The user's role in the goal.
  ///
  /// Possible values: 'creator', 'admin', 'member'.
  final String role;

  /// When the user joined the goal.
  final DateTime joinedAt;

  /// The current status of the membership.
  ///
  /// Possible values: 'active', 'invited', 'left'.
  final String status;

  /// Whether this is an empty/uninitialized membership.
  bool get isEmpty => id.isEmpty;

  /// Whether this is a valid membership with data.
  bool get isNotEmpty => !isEmpty;

  /// Whether this user is the creator of the goal.
  bool get isCreator => role == 'creator';

  /// Whether this user is an admin of the goal.
  bool get isAdmin => role == 'admin';

  /// Whether this user is a regular member of the goal.
  bool get isMember => role == 'member';

  /// Whether this membership is currently active.
  bool get isActive => status == 'active';

  /// Whether this user has been invited but not yet joined.
  bool get isInvited => status == 'invited';

  /// Whether this user has left the goal.
  bool get hasLeft => status == 'left';

  /// Whether this user can manage the goal (creator or admin).
  bool get canManage => isCreator || isAdmin;

  @override
  List<Object?> get props => [
        id,
        goalId,
        userId,
        role,
        joinedAt,
        status,
      ];

  @override
  String toString() {
    return 'GoalMembership(id: $id, goalId: $goalId, userId: $userId, '
        'role: $role, joinedAt: $joinedAt, status: $status)';
  }
}
