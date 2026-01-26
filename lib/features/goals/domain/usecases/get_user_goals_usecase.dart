/// Use case for retrieving all goals belonging to the current user.
///
/// This use case follows the single responsibility principle - it has only
/// one method [call] that fetches the user's goals from the repository.
///
/// Example usage:
/// ```dart
/// final useCase = GetUserGoalsUseCase(goalsRepository);
/// final goals = await useCase();
/// ```
library;

import '../entities/goal.dart';
import '../repositories/goals_repository.dart';

/// Use case for retrieving all goals belonging to the current user.
///
/// Follows the single responsibility principle with a single [call] method.
/// Inject [GoalsRepository] via constructor for dependency injection.
///
/// Example:
/// ```dart
/// final useCase = GetUserGoalsUseCase(repository);
/// final goals = await useCase();
/// for (final goal in goals) {
///   print('${goal.name}: ${goal.daysRemaining} days remaining');
/// }
/// ```
class GetUserGoalsUseCase {
  /// The repository used to fetch goals data.
  final GoalsRepository _repository;

  /// Creates a new [GetUserGoalsUseCase] with the given repository.
  ///
  /// [repository] - The goals repository implementation to use.
  GetUserGoalsUseCase(this._repository);

  /// Fetches all goals belonging to the current user.
  ///
  /// Returns a [Future] that completes with a list of [Goal] entities.
  /// The list may be empty if the user has no goals.
  ///
  /// Throws an [Exception] if the network request fails.
  Future<List<Goal>> call() => _repository.getUserGoals();
}
