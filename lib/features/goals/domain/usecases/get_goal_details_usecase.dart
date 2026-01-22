import '../entities/goal.dart';
import '../entities/goal_progress.dart';
import '../repositories/goals_repository.dart';

/// Result of fetching goal details including progress.
final class GoalDetails {
  const GoalDetails({
    required this.goal,
    required this.progress,
  });

  final Goal goal;
  final GoalProgress progress;
}

/// Use case for fetching detailed goal information with progress.
///
/// Single responsibility: Retrieve a goal and its progress details.
///
/// Example:
/// ```dart
/// final useCase = GetGoalDetailsUseCase(repository: goalsRepository);
/// final details = await useCase('goal-123');
/// print('Progress: ${details.progress.progressPercent}%');
/// ```
final class GetGoalDetailsUseCase {
  GetGoalDetailsUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to fetch goal details.
  ///
  /// [goalId] The unique identifier of the goal.
  ///
  /// Returns [GoalDetails] containing both the goal
  /// and its progress information.
  ///
  /// Throws:
  /// - [ServerException] on API errors
  /// - [NetworkException] on connectivity issues
  Future<GoalDetails> call(String goalId) async {
    final results = await Future.wait([
      _repository.getGoalById(goalId),
      _repository.getGoalProgress(goalId),
    ]);

    return GoalDetails(
      goal: results[0] as Goal,
      progress: results[1] as GoalProgress,
    );
  }
}
