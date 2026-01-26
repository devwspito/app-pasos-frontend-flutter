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

import '../entities/goal_membership.dart';
import '../repositories/goals_repository.dart';

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
