import '../entities/goal_progress.dart';
import '../repositories/goals_repository.dart';

/// Use case for fetching the progress of a specific goal.
///
/// Single responsibility: Retrieve progress data including total steps,
/// target, and individual member contributions for a goal.
///
/// Example:
/// ```dart
/// final useCase = GetGoalProgressUseCase(repository: goalsRepository);
/// final progress = await useCase('goal-123');
/// print('Progress: ${progress.percentComplete}%');
/// ```
final class GetGoalProgressUseCase {
  GetGoalProgressUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to fetch goal progress.
  ///
  /// [goalId] The unique identifier of the goal.
  ///
  /// Returns [GoalProgress] containing:
  /// - totalSteps: Combined steps from all members
  /// - targetSteps: The goal's target step count
  /// - percentComplete: Progress percentage (0-100+)
  /// - memberProgress: Individual member contributions with rankings
  ///
  /// Throws:
  /// - [ServerException] on API errors
  /// - [NetworkException] on connectivity issues
  /// - [CacheException] if offline and no cached data
  Future<GoalProgress> call(String goalId) {
    return _repository.getGoalProgress(goalId);
  }
}
