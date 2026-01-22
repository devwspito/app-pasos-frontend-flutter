import '../entities/goal.dart';
import '../repositories/goals_repository.dart';

/// Use case for joining a goal using an invitation code.
///
/// Single responsibility: Process an invitation code and add the
/// current user as a member of the associated goal.
///
/// Example:
/// ```dart
/// final useCase = JoinGoalUseCase(repository: goalsRepository);
/// final goal = await useCase('ABC123');
/// print('Joined goal: ${goal.name}');
/// ```
final class JoinGoalUseCase {
  JoinGoalUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to join a goal via invitation code.
  ///
  /// [inviteCode] The invitation code received via email or shared link.
  ///
  /// Returns the joined [Goal] entity with full details.
  ///
  /// The invitation code is validated server-side to:
  /// - Verify it hasn't expired
  /// - Verify the goal still exists
  /// - Verify the user isn't already a member
  ///
  /// Note: Requires network connectivity. This operation cannot
  /// be performed offline.
  ///
  /// Throws:
  /// - [ServerException] on API errors (e.g., invalid/expired code)
  /// - [NetworkException] on connectivity issues
  Future<Goal> call(String inviteCode) {
    return _repository.joinGoal(inviteCode);
  }
}
