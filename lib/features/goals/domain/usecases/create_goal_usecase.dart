import '../entities/goal.dart';
import '../repositories/goals_repository.dart';

/// Parameters for creating a new goal.
final class CreateGoalParams {
  const CreateGoalParams({
    required this.name,
    required this.description,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  final String name;
  final String description;
  final int targetSteps;
  final DateTime startDate;
  final DateTime endDate;
  final GoalType type;
}

/// Use case for creating a new goal.
///
/// Single responsibility: Create a new individual or group goal.
///
/// Example:
/// ```dart
/// final useCase = CreateGoalUseCase(repository: goalsRepository);
/// final goal = await useCase(CreateGoalParams(
///   name: '10K Steps Challenge',
///   description: 'Walk 10,000 steps every day',
///   targetSteps: 70000,
///   startDate: DateTime.now(),
///   endDate: DateTime.now().add(Duration(days: 7)),
///   type: GoalType.individual,
/// ));
/// ```
final class CreateGoalUseCase {
  CreateGoalUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to create a new goal.
  ///
  /// [params] The goal creation parameters.
  ///
  /// Returns the created [Goal] entity.
  ///
  /// Throws:
  /// - [ServerException] on API errors
  /// - [NetworkException] on connectivity issues
  /// - [ValidationException] if parameters are invalid
  Future<Goal> call(CreateGoalParams params) {
    return _repository.createGoal(
      name: params.name,
      description: params.description,
      targetSteps: params.targetSteps,
      startDate: params.startDate,
      endDate: params.endDate,
      type: params.type,
    );
  }
}
