import '../entities/goal.dart';
import '../repositories/goals_repository.dart';

/// Use case for joining a group goal via invite code.
///
/// Single responsibility: Join an existing group goal.
///
/// Example:
/// ```dart
/// final useCase = JoinGoalUseCase(repository: goalsRepository);
/// final goal = await useCase('ABC123');
/// print('Joined: ${goal.name}');
/// ```
final class JoinGoalUseCase {
  JoinGoalUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to join a goal.
  ///
  /// [inviteCode] The invitation code for the goal.
  ///
  /// Returns the [Goal] that was joined.
  ///
  /// Throws:
  /// - [ServerException] on API errors
  /// - [NetworkException] on connectivity issues
  /// - [NotFoundException] if invite code is invalid
  /// - [ValidationException] if code is expired
  Future<Goal> call(String inviteCode) {
    return _repository.joinGoal(inviteCode);
  }
}
