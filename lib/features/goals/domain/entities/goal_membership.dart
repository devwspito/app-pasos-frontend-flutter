import 'package:equatable/equatable.dart';

/// Domain entity representing a user's membership in a goal.
///
/// Tracks the relationship between a user and a goal, including
/// their role, when they joined, and how many steps they've contributed.
final class GoalMembership extends Equatable {
  final String id;
  final String goalId;
  final String ownerId;
  final String role;
  final DateTime joinedAt;
  final int contributedSteps;

  const GoalMembership({
    required this.id,
    required this.goalId,
    required this.ownerId,
    required this.role,
    required this.joinedAt,
    required this.contributedSteps,
  });

  @override
  List<Object?> get props => [
        id,
        goalId,
        ownerId,
        role,
        joinedAt,
        contributedSteps,
      ];

  /// Creates a copy of this GoalMembership with the given fields replaced
  GoalMembership copyWith({
    String? id,
    String? goalId,
    String? ownerId,
    String? role,
    DateTime? joinedAt,
    int? contributedSteps,
  }) {
    return GoalMembership(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      ownerId: ownerId ?? this.ownerId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      contributedSteps: contributedSteps ?? this.contributedSteps,
    );
  }

  /// Returns true if this membership has admin role
  bool get isAdmin => role == 'admin' || role == 'owner';

  /// Returns true if this membership has owner role
  bool get isOwner => role == 'owner';
}
