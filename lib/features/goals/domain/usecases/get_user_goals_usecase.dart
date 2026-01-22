import '../entities/goal.dart';
import '../repositories/goals_repository.dart';

/// Use case for fetching all goals for the current user.
///
/// Single responsibility: Retrieve all goals the user participates in.
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

  /// Executes the use case to fetch all user goals.
  ///
  /// Returns a list of [Goal] entities including both
  /// individual and group goals.
  ///
  /// Throws:
  /// - [ServerException] on API errors
  /// - [NetworkException] on connectivity issues
  Future<List<Goal>> call() {
    return _repository.getUserGoals();
  }
}
