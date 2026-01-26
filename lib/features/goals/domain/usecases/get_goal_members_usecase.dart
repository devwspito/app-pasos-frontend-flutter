/// Use case for retrieving all members of a specific goal.
///
/// This use case follows the single responsibility principle - it has only
/// one method [call] that fetches goal members from the repository.
///
/// Example usage:
/// ```dart
/// final useCase = GetGoalMembersUseCase(goalsRepository);
/// final members = await useCase('goal-123');
/// for (final member in members) {
///   print('${member.username}: ${member.role}');
/// }
/// ```
library;

import '../entities/goal_membership.dart';
import '../repositories/goals_repository.dart';

/// Use case for retrieving all members of a specific goal.
///
/// Follows the single responsibility principle with a single [call] method.
/// Inject [GoalsRepository] via constructor for dependency injection.
///
/// Returns a list of [GoalMembership] entities representing goal participants
/// including the owner and all invited/accepted members.
///
/// Example:
/// ```dart
/// final useCase = GetGoalMembersUseCase(repository);
/// final members = await useCase('goal-123');
///
/// // Find the owner
/// final owner = members.firstWhere((m) => m.isOwner);
/// print('Goal owner: ${owner.username}');
///
/// // Count accepted members
/// final acceptedCount = members.where((m) => m.isAccepted).length;
/// print('Active members: $acceptedCount');
/// ```
class GetGoalMembersUseCase {
  /// The repository used to fetch goal members data.
  final GoalsRepository _repository;

  /// Creates a new [GetGoalMembersUseCase] with the given repository.
  ///
  /// [repository] - The goals repository implementation to use.
  GetGoalMembersUseCase(this._repository);

  /// Fetches all members of the specified goal.
  ///
  /// [goalId] - The unique identifier of the goal.
  ///
  /// Returns a [Future] that completes with a list of [GoalMembership] entities.
  /// The list includes the owner and all members regardless of status
  /// (pending, accepted, rejected).
  ///
  /// Throws an [Exception] if:
  /// - The network request fails
  /// - The goal is not found
  /// - The user doesn't have access to view members
  Future<List<GoalMembership>> call(String goalId) =>
      _repository.getGoalMembers(goalId);
}
