import 'package:equatable/equatable.dart';

/// Domain entity representing a user's membership in a goal.
///
/// This is an immutable entity that contains business logic methods
/// for managing goal memberships. Unlike data models, entities do NOT
/// contain JSON serialization logic.
///
/// TODO: This is a stub entity file. Full implementation will be added
/// by a future story that creates the complete Goals domain layer.
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
///   status: 'accepted',
///   joinedAt: DateTime.now(),
/// );
///
/// print(membership.isOwner); // false
/// print(membership.isPending); // false
/// print(membership.isAccepted); // true
/// ```
class GoalMembership extends Equatable {
  /// Unique identifier for the membership.
  final String id;

  /// ID of the goal this membership belongs to.
  final String goalId;

  /// ID of the user who is a member.
  final String userId;

  /// Username of the member.
  final String username;

  /// Profile image URL of the member. May be null if not set.
  final String? profileImageUrl;

  /// Role of the member in the goal.
  /// Possible values: 'owner', 'member'.
  final String role;

  /// Current status of the membership.
  /// Possible values: 'pending', 'accepted', 'rejected'.
  final String status;

  /// Timestamp when the user joined (or was invited to) the goal.
  final DateTime joinedAt;

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
    required this.status,
    required this.joinedAt,
  });

  /// Returns true if the member has the 'owner' role.
  bool get isOwner => role == 'owner';

  /// Returns true if the member has the 'member' role.
  bool get isMember => role == 'member';

  /// Returns true if the membership status is 'pending'.
  bool get isPending => status == 'pending';

  /// Returns true if the membership status is 'accepted'.
  bool get isAccepted => status == 'accepted';

  /// Returns true if the membership status is 'rejected'.
  bool get isRejected => status == 'rejected';

  /// Returns the first 2 letters of the username as initials.
  ///
  /// Returns uppercase initials. If the username is empty, returns an empty string.
  /// If the username has only 1 character, returns that character uppercase.
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
    String? status,
    DateTime? joinedAt,
  }) {
    return GoalMembership(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
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
        status,
        joinedAt,
      ];

  @override
  String toString() {
    return 'GoalMembership(id: $id, goalId: $goalId, userId: $userId, '
        'username: $username, profileImageUrl: $profileImageUrl, role: $role, '
        'status: $status, joinedAt: $joinedAt)';
  }
}
