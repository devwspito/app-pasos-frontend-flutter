/// Get goal progress use case.
///
/// This use case retrieves the progress information for a specific goal.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/goal_progress.dart';
import 'package:app_pasos_frontend/features/goals/domain/repositories/goals_repository.dart';

/// Use case for getting progress information for a specific goal.
///
/// This follows the Single Responsibility Principle - it only handles
/// retrieving goal progress. It also follows Dependency Inversion Principle
/// by depending on the GoalsRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = GetGoalProgressUseCase(repository: goalsRepository);
/// final progress = await useCase(goalId: 'goal123');
/// print('Progress: ${progress.currentSteps}/${progress.targetSteps}');
/// print('Percentage: ${progress.progressPercentage}%');
/// ```
class GetGoalProgressUseCase {
  /// Creates a [GetGoalProgressUseCase] instance.
  ///
  /// [repository] - The goals repository interface.
  GetGoalProgressUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to get goal progress.
  ///
  /// [goalId] - The ID of the goal to get progress for.
  ///
  /// Returns [GoalProgress] containing current steps, target steps,
  /// and percentage progress.
  /// Throws exceptions from the repository on failure.
  Future<GoalProgress> call({required String goalId}) async {
    return _repository.getGoalProgress(goalId: goalId);
  }
}
