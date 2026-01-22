import 'package:equatable/equatable.dart';

/// Enum representing the role of a member in a group goal
enum MemberRole {
  creator,
  admin,
  member,
}

/// Enum representing the status of a membership
enum MembershipStatus {
  pending,
  active,
  declined,
  removed,
}

/// Domain entity representing a user's membership in a goal.
///
/// This is a pure domain entity with no serialization logic.
/// Use [GoalMembershipModel] in the data layer for API serialization.
final class GoalMembership extends Equatable {
  const GoalMembership({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.username,
    required this.role,
    required this.status,
    required this.joinedAt,
    required this.totalSteps,
  });

  /// Unique identifier for the membership.
  final String id;

  /// ID of the goal this membership belongs to.
  final String goalId;

  /// ID of the user.
  final String userId;

  /// Username of the member.
  final String username;

  /// Role of the member in the goal.
  final MemberRole role;

  /// Current status of the membership.
  final MembershipStatus status;

  /// Timestamp when the user joined the goal.
  final DateTime joinedAt;

  /// Total steps contributed by this member.
  final int totalSteps;

  /// Returns true if this member is the creator.
  bool get isCreator => role == MemberRole.creator;

  /// Returns true if this member has admin privileges.
  bool get isAdmin => role == MemberRole.admin || role == MemberRole.creator;

  /// Returns true if the membership is active.
  bool get isActive => status == MembershipStatus.active;

  /// Creates a copy of this GoalMembership with the given fields replaced.
  GoalMembership copyWith({
    String? id,
    String? goalId,
    String? userId,
    String? username,
    MemberRole? role,
    MembershipStatus? status,
    DateTime? joinedAt,
    int? totalSteps,
  }) {
    return GoalMembership(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }

  @override
  List<Object?> get props => [
        id,
        goalId,
        userId,
        username,
        role,
        status,
        joinedAt,
        totalSteps,
      ];

  @override
  String toString() =>
      'GoalMembership(id: $id, userId: $userId, role: ${role.name})';
}
