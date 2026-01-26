/// Use case for inviting a user to join a goal.
///
/// This use case follows the single responsibility principle - it has only
/// one method [call] that invites a user via the repository.
///
/// Example usage:
/// ```dart
/// final useCase = InviteUserUseCase(goalsRepository);
/// final membership = await useCase('goal-123', 'user-456');
/// print('Invited ${membership.username}, status: ${membership.status}');
/// ```
library;

// =============================================================================
// TEMPORARY INLINE DEFINITIONS
// TODO: Replace with imports when entity/repository files are created by their
// respective epic stories:
// - lib/features/goals/domain/entities/goal_membership.dart
// - lib/features/goals/domain/repositories/goals_repository.dart
// =============================================================================

/// Entity representing a user's membership in a goal.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/entities/goal_membership.dart
class GoalMembership {
  /// Unique identifier for the membership.
  final String id;

  /// ID of the goal this membership belongs to.
  final String goalId;

  /// ID of the user who is a member.
  final String userId;

  /// Username of the member.
  final String username;

  /// Profile image URL of the member.
  final String? profileImageUrl;

  /// Role in the goal: 'owner', 'admin', 'member'.
  final String role;

  /// Status of the membership: 'pending', 'accepted', 'rejected'.
  final String status;

  /// When the membership was created/invited.
  final DateTime createdAt;

  /// When the membership status was last updated.
  final DateTime? updatedAt;

  /// Creates a new GoalMembership instance.
  const GoalMembership({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.role,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a GoalMembership from a JSON map.
  factory GoalMembership.fromJson(Map<String, dynamic> json) {
    return GoalMembership(
      id: json['id']?.toString() ?? '',
      goalId: json['goalId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profileImageUrl: json['profileImageUrl']?.toString(),
      role: json['role']?.toString() ?? 'member',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Converts this GoalMembership to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'userId': userId,
      'username': username,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'role': role,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Returns true if the membership is pending acceptance.
  bool get isPending => status == 'pending';

  /// Returns true if the membership is accepted.
  bool get isAccepted => status == 'accepted';

  /// Returns true if the membership was rejected.
  bool get isRejected => status == 'rejected';

  /// Returns true if the user is the owner of the goal.
  bool get isOwner => role == 'owner';

  /// Returns true if the user is an admin of the goal.
  bool get isAdmin => role == 'admin' || role == 'owner';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalMembership &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'GoalMembership(id: $id, username: $username, role: $role, status: $status)';
}

/// Abstract interface for GoalsRepository (partial - only what this use case needs).
///
/// TODO: Will be replaced with import from lib/features/goals/domain/repositories/goals_repository.dart
abstract class GoalsRepository {
  /// Invites a user to join a goal.
  Future<GoalMembership> inviteUser(String goalId, String userId);
}

// =============================================================================
// USE CASE IMPLEMENTATION
// =============================================================================

/// Use case for inviting a user to join a goal.
///
/// Follows the single responsibility principle with a single [call] method.
/// Inject [GoalsRepository] via constructor for dependency injection.
///
/// The invited user will receive a pending membership that they can accept
/// or reject.
///
/// Example:
/// ```dart
/// final useCase = InviteUserUseCase(repository);
///
/// // Invite a friend to the goal
/// final membership = await useCase('goal-123', 'friend-user-id');
///
/// if (membership.isPending) {
///   print('Invitation sent to ${membership.username}');
/// }
/// ```
class InviteUserUseCase {
  /// The repository used to invite users to goals.
  final GoalsRepository _repository;

  /// Creates a new [InviteUserUseCase] with the given repository.
  ///
  /// [repository] - The goals repository implementation to use.
  InviteUserUseCase(this._repository);

  /// Invites a user to join the specified goal.
  ///
  /// [goalId] - The unique identifier of the goal.
  /// [userId] - The unique identifier of the user to invite.
  ///
  /// Returns a [Future] that completes with a [GoalMembership] entity
  /// representing the invitation (with status 'pending').
  ///
  /// Throws an [Exception] if:
  /// - The network request fails
  /// - The goal is not found
  /// - The user is not the goal owner
  /// - The target user is already a member
  /// - The target user is not found
  Future<GoalMembership> call(String goalId, String userId) =>
      _repository.inviteUser(goalId, userId);
}
