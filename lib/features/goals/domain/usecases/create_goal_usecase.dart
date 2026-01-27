/// Create goal use case.
///
/// This use case creates a new group goal.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';
import 'package:app_pasos_frontend/features/goals/domain/repositories/goals_repository.dart';

/// Use case for creating a new group goal.
///
/// This follows the Single Responsibility Principle - it only handles
/// creating a goal. It also follows Dependency Inversion Principle
/// by depending on the GoalsRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = CreateGoalUseCase(repository: goalsRepository);
/// final goal = await useCase(
///   name: 'Summer Challenge',
///   targetSteps: 100000,
///   startDate: DateTime(2024, 6, 1),
///   endDate: DateTime(2024, 6, 30),
///   description: 'Walk 100k steps together!',
/// );
/// print('Created goal: ${goal.id}');
/// ```
class CreateGoalUseCase {
  /// Creates a [CreateGoalUseCase] instance.
  ///
  /// [repository] - The goals repository interface.
  CreateGoalUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to create a new group goal.
  ///
  /// [name] - The name of the goal.
  /// [targetSteps] - The total step target for the group.
  /// [startDate] - When the goal period starts.
  /// [endDate] - When the goal period ends.
  /// [description] - An optional description of the goal.
  ///
  /// Returns the created [GroupGoal] with 'active' status.
  /// Throws exceptions from the repository on failure.
  Future<GroupGoal> call({
    required String name,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) async {
    return _repository.createGoal(
      name: name,
      targetSteps: targetSteps,
      startDate: startDate,
      endDate: endDate,
      description: description,
    );
  }
}
