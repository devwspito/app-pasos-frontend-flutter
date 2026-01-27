/// Join goal use case.
///
/// This use case allows a user to join a group goal they've been invited to.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/goals/domain/repositories/goals_repository.dart';

/// Use case for joining a group goal.
///
/// This follows the Single Responsibility Principle - it only handles
/// joining goals. It also follows Dependency Inversion Principle
/// by depending on the GoalsRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = JoinGoalUseCase(repository: goalsRepository);
/// await useCase(goalId: 'goal123');
/// print('Successfully joined the goal');
/// ```
class JoinGoalUseCase {
  /// Creates a [JoinGoalUseCase] instance.
  ///
  /// [repository] - The goals repository interface.
  JoinGoalUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to join a group goal.
  ///
  /// [goalId] - The ID of the goal to join.
  ///
  /// Throws exceptions from the repository on failure.
  Future<void> call({required String goalId}) async {
    return _repository.joinGoal(goalId: goalId);
  }
}
