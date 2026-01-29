/// Update goal use case.
///
/// This use case updates an existing group goal.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';
import 'package:app_pasos_frontend/features/goals/domain/repositories/goals_repository.dart';

/// Use case for updating an existing group goal.
///
/// This follows the Single Responsibility Principle - it only handles
/// updating a goal. It also follows Dependency Inversion Principle
/// by depending on the GoalsRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = UpdateGoalUseCase(repository: goalsRepository);
/// final updatedGoal = await useCase(
///   goalId: 'goal-123',
///   name: 'Updated Challenge Name',
///   targetSteps: 150000,
/// );
/// print('Updated goal: ${updatedGoal.name}');
/// ```
class UpdateGoalUseCase {
  /// Creates an [UpdateGoalUseCase] instance.
  ///
  /// [repository] - The goals repository interface.
  UpdateGoalUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to update an existing group goal.
  ///
  /// [goalId] - The ID of the goal to update (required).
  /// [name] - The new name of the goal (optional).
  /// [description] - The new description of the goal (optional).
  /// [targetSteps] - The new total step target for the group (optional).
  /// [startDate] - The new start date for the goal period (optional).
  /// [endDate] - The new end date for the goal period (optional).
  ///
  /// Only provided fields will be updated (partial update).
  /// Returns the updated [GroupGoal].
  /// Throws exceptions from the repository on failure.
  Future<GroupGoal> call({
    required String goalId,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _repository.updateGoal(
      goalId: goalId,
      name: name,
      description: description,
      targetSteps: targetSteps,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
