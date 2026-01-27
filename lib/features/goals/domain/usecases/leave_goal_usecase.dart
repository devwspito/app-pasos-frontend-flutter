/// Leave goal use case.
///
/// This use case allows a user to leave a group goal they are a member of.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/goals/domain/repositories/goals_repository.dart';

/// Use case for leaving a group goal.
///
/// This follows the Single Responsibility Principle - it only handles
/// leaving goals. It also follows Dependency Inversion Principle
/// by depending on the GoalsRepository interface rather than a concrete
/// implementation.
///
/// Note: The goal creator cannot leave the goal.
///
/// Example usage:
/// ```dart
/// final useCase = LeaveGoalUseCase(repository: goalsRepository);
/// await useCase(goalId: 'goal123');
/// print('Successfully left the goal');
/// ```
class LeaveGoalUseCase {
  /// Creates a [LeaveGoalUseCase] instance.
  ///
  /// [repository] - The goals repository interface.
  LeaveGoalUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to leave a group goal.
  ///
  /// [goalId] - The ID of the goal to leave.
  ///
  /// Note: The goal creator cannot leave the goal.
  /// Throws exceptions from the repository on failure.
  Future<void> call({required String goalId}) async {
    return _repository.leaveGoal(goalId: goalId);
  }
}
