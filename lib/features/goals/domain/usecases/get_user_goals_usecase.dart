import '../entities/goal.dart';
import '../repositories/goals_repository.dart';

/// Use case for fetching all goals for the current user.
///
/// Single responsibility: Retrieve all goals where the user
/// is either the owner or a member.
///
/// Example:
/// ```dart
/// final useCase = GetUserGoalsUseCase(repository: goalsRepository);
/// final goals = await useCase();
/// print('Found ${goals.length} goals');
/// ```
final class GetUserGoalsUseCase {
  GetUserGoalsUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to fetch user's goals.
  ///
  /// Returns list of [Goal] entities containing:
  /// - Goals owned by the user
  /// - Goals where the user is a member
  ///
  /// Throws:
  /// - [ServerException] on API errors
  /// - [NetworkException] on connectivity issues
  /// - [CacheException] if offline and no cached data
  Future<List<Goal>> call() {
    return _repository.getUserGoals();
  }
}
