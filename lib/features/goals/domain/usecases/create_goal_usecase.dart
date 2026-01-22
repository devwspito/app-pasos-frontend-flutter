import '../entities/goal.dart';
import '../repositories/goals_repository.dart';

/// Use case for creating a new goal.
///
/// Single responsibility: Create a new goal with the specified parameters.
/// The current user will be set as the owner automatically.
///
/// Example:
/// ```dart
/// final useCase = CreateGoalUseCase(repository: goalsRepository);
/// final goal = await useCase(
///   name: 'Summer Challenge',
///   description: 'Walk 100k steps this month',
///   targetSteps: 100000,
///   startDate: DateTime.now(),
///   endDate: DateTime.now().add(Duration(days: 30)),
///   isPublic: true,
/// );
/// print('Created goal: ${goal.name}');
/// ```
final class CreateGoalUseCase {
  CreateGoalUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to create a new goal.
  ///
  /// [name] The name of the goal.
  /// [description] A description of what the goal is about.
  /// [targetSteps] The target number of steps to achieve.
  /// [startDate] When the goal period begins.
  /// [endDate] When the goal period ends.
  /// [isPublic] Whether the goal is publicly visible to other users.
  ///
  /// Returns the created [Goal] with server-assigned ID.
  ///
  /// Note: Requires network connectivity. This operation cannot
  /// be performed offline.
  ///
  /// Throws:
  /// - [ServerException] on API errors (e.g., invalid data)
  /// - [NetworkException] on connectivity issues
  Future<Goal> call({
    required String name,
    required String description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
    required bool isPublic,
  }) {
    return _repository.createGoal(
      name: name,
      description: description,
      targetSteps: targetSteps,
      startDate: startDate,
      endDate: endDate,
      isPublic: isPublic,
    );
  }
}
