/// Use case for retrieving progress data for all members of a goal.
///
/// This use case follows the single responsibility principle - it has only
/// one method [call] that fetches member progress from the repository.
///
/// Example usage:
/// ```dart
/// final useCase = GetGoalProgressUseCase(goalsRepository);
/// final progressList = await useCase('goal-123');
/// for (final progress in progressList) {
///   print('${progress.username}: ${progress.totalSteps} total steps');
/// }
/// ```
library;

import '../entities/goal_progress.dart';
import '../repositories/goals_repository.dart';

/// Use case for retrieving progress data for all members of a goal.
///
/// Follows the single responsibility principle with a single [call] method.
/// Inject [GoalsRepository] via constructor for dependency injection.
///
/// Returns a list of [GoalProgress] entities with member progress data.
///
/// Example:
/// ```dart
/// final useCase = GetGoalProgressUseCase(repository);
/// final progressList = await useCase('goal-123');
///
/// // Display leaderboard
/// for (final progress in progressList) {
///   print('${progress.username}: ${progress.totalSteps} total steps');
///   print('  Daily average: ${progress.dailyAverage.toStringAsFixed(0)}');
///   print('  Current streak: ${progress.currentStreak} days');
/// }
/// ```
class GetGoalProgressUseCase {
  /// The repository used to fetch goal progress data.
  final GoalsRepository _repository;

  /// Creates a new [GetGoalProgressUseCase] with the given repository.
  ///
  /// [repository] - The goals repository implementation to use.
  GetGoalProgressUseCase(this._repository);

  /// Fetches progress data for all members of the specified goal.
  ///
  /// [goalId] - The unique identifier of the goal.
  ///
  /// Returns a [Future] that completes with a list of [GoalProgress] entities.
  /// The list may be empty if no progress has been recorded.
  ///
  /// Throws an [Exception] if:
  /// - The network request fails
  /// - The goal is not found
  /// - The user doesn't have access to the goal
  Future<List<GoalProgress>> call(String goalId) =>
      _repository.getGoalProgress(goalId);
}
