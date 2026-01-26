/// Use case for creating a new group goal.
///
/// This use case follows the single responsibility principle - it has only
/// one method [call] that creates a new goal via the repository.
///
/// Example usage:
/// ```dart
/// final useCase = CreateGoalUseCase(goalsRepository);
/// final goal = await useCase(
///   name: 'Summer Challenge',
///   description: 'Walk 10k steps daily',
///   targetSteps: 10000,
///   startDate: DateTime.now(),
///   endDate: DateTime.now().add(Duration(days: 30)),
/// );
/// ```
library;

import '../entities/goal.dart';
import '../repositories/goals_repository.dart';

/// Use case for creating a new group goal.
///
/// Follows the single responsibility principle with a single [call] method.
/// Inject [GoalsRepository] via constructor for dependency injection.
///
/// The created goal will have the current user as the owner/creator.
///
/// Example:
/// ```dart
/// final useCase = CreateGoalUseCase(repository);
/// final newGoal = await useCase(
///   name: 'Monthly Fitness Goal',
///   description: 'Let\'s hit 10k steps every day!',
///   targetSteps: 10000,
///   startDate: DateTime(2024, 1, 1),
///   endDate: DateTime(2024, 1, 31),
/// );
/// print('Created goal: ${newGoal.id}');
/// ```
class CreateGoalUseCase {
  /// The repository used to create goals.
  final GoalsRepository _repository;

  /// Creates a new [CreateGoalUseCase] with the given repository.
  ///
  /// [repository] - The goals repository implementation to use.
  CreateGoalUseCase(this._repository);

  /// Creates a new goal with the specified parameters.
  ///
  /// [name] - Required name for the goal.
  /// [description] - Optional description providing more details.
  /// [targetSteps] - Required daily step target for the goal.
  /// [startDate] - Required start date for the goal.
  /// [endDate] - Required end date for the goal.
  ///
  /// Returns a [Future] that completes with the created [Goal] entity.
  ///
  /// Throws an [Exception] if:
  /// - The network request fails
  /// - Validation fails (e.g., endDate before startDate)
  /// - The user is not authenticated
  Future<Goal> call({
    required String name,
    String? description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
  }) =>
      _repository.createGoal(
        name: name,
        description: description,
        targetSteps: targetSteps,
        startDate: startDate,
        endDate: endDate,
      );
}
