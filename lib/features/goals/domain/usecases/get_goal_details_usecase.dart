/// Get goal details use case.
///
/// This use case retrieves detailed information about a specific goal.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';
import 'package:app_pasos_frontend/features/goals/domain/repositories/goals_repository.dart';

/// Use case for getting detailed information about a specific goal.
///
/// This follows the Single Responsibility Principle - it only handles
/// retrieving goal details. It also follows Dependency Inversion Principle
/// by depending on the GoalsRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = GetGoalDetailsUseCase(repository: goalsRepository);
/// final goal = await useCase(goalId: 'goal123');
/// print('Goal: ${goal.name}, Status: ${goal.status}');
/// ```
class GetGoalDetailsUseCase {
  /// Creates a [GetGoalDetailsUseCase] instance.
  ///
  /// [repository] - The goals repository interface.
  GetGoalDetailsUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to get goal details.
  ///
  /// [goalId] - The ID of the goal to retrieve.
  ///
  /// Returns the [GroupGoal] with full details.
  /// Throws exceptions from the repository on failure.
  Future<GroupGoal> call({required String goalId}) async {
    return _repository.getGoalDetails(goalId: goalId);
  }
}
