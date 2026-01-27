/// Get user goals use case.
///
/// This use case retrieves all group goals for the current user.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';
import 'package:app_pasos_frontend/features/goals/domain/repositories/goals_repository.dart';

/// Use case for getting all group goals for the current user.
///
/// This follows the Single Responsibility Principle - it only handles
/// retrieving goals. It also follows Dependency Inversion Principle
/// by depending on the GoalsRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = GetUserGoalsUseCase(repository: goalsRepository);
/// final goals = await useCase();
/// for (final goal in goals) {
///   print('Goal: ${goal.name}, Target: ${goal.targetSteps}');
/// }
/// ```
class GetUserGoalsUseCase {
  /// Creates a [GetUserGoalsUseCase] instance.
  ///
  /// [repository] - The goals repository interface.
  GetUserGoalsUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to get all group goals.
  ///
  /// Returns a list of [GroupGoal] containing both created and joined goals.
  /// Throws exceptions from the repository on failure.
  Future<List<GroupGoal>> call() async {
    return _repository.getUserGoals();
  }
}
