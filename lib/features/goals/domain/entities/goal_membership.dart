import 'package:equatable/equatable.dart';

/// Domain entity representing a user's membership in a goal.
///
/// This is an immutable entity that contains business logic methods
/// for managing goal memberships. Unlike data models, entities do NOT
/// contain JSON serialization logic.
///
/// Example usage:
/// ```dart
/// final membership = GoalMembership(
///   id: 'mem-123',
///   goalId: 'goal-456',
///   userId: 'user-789',
///   username: 'john_doe',
///   profileImageUrl: 'https://example.com/avatar.png',
///   role: 'member',
///   joinedAt: DateTime.now(),
///   status: 'accepted',
/// );
///
/// print(membership.isOwner); // false
/// print(membership.isAccepted); // true
/// print(membership.isPending); // false
/// ```
class GoalMembership extends Equatable {
  /// Unique identifier for this membership.
  final String id;

  /// ID of the goal this membership belongs to.
  final String goalId;

  /// ID of the user who is a member of the goal.
  final String userId;

  /// Username of the member.
  final String username;

  /// Profile image URL of the member. May be null if not set.
  final String? profileImageUrl;

  /// Role of the member in the goal.
  /// Possible values: 'owner', 'member'.
  final String role;

  /// Timestamp when the user joined or was invited to the goal.
  final DateTime joinedAt;

  /// Current status of the membership.
  /// Possible values: 'pending', 'accepted', 'rejected'.
  final String status;

  /// Creates a [GoalMembership] instance.
  ///
  /// All fields are required except [profileImageUrl] which can be null.
  const GoalMembership({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.role,
    required this.joinedAt,
    required this.status,
  });

  /// Returns true if the member is the owner of the goal.
  bool get isOwner => role == 'owner';

  /// Returns true if the member is a regular member (not owner).
  bool get isMember => role == 'member';

  /// Returns true if the membership status is 'pending'.
  bool get isPending => status == 'pending';

  /// Returns true if the membership status is 'accepted'.
  bool get isAccepted => status == 'accepted';

  /// Returns true if the membership status is 'rejected'.
  bool get isRejected => status == 'rejected';

  /// Returns the first 2 letters of the username as initials.
  String get initials {
    if (username.isEmpty) return '';
    if (username.length == 1) return username.toUpperCase();
    return username.substring(0, 2).toUpperCase();
  }

  /// Creates a copy of this membership with optional field overrides.
  GoalMembership copyWith({
    String? id,
    String? goalId,
    String? userId,
    String? username,
    String? profileImageUrl,
    String? role,
    DateTime? joinedAt,
    String? status,
  }) {
    return GoalMembership(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        goalId,
        userId,
        username,
        profileImageUrl,
        role,
        joinedAt,
        status,
      ];

  @override
  String toString() {
    return 'GoalMembership(id: $id, goalId: $goalId, userId: $userId, '
        'username: $username, profileImageUrl: $profileImageUrl, role: $role, '
        'joinedAt: $joinedAt, status: $status)';
  }
}
