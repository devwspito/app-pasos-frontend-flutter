/// Get today's steps use case.
///
/// This use case retrieves the total steps recorded today.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/repositories/steps_repository.dart';

/// Use case for getting today's total step count.
///
/// This follows the Single Responsibility Principle - it only handles
/// retrieving today's steps. It also follows Dependency Inversion Principle
/// by depending on the StepsRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = GetTodayStepsUseCase(repository: stepsRepository);
/// final todaySteps = await useCase();
/// print('You have walked $todaySteps steps today!');
/// ```
class GetTodayStepsUseCase {
  /// Creates a [GetTodayStepsUseCase] instance.
  ///
  /// [repository] - The steps repository interface.
  GetTodayStepsUseCase({required StepsRepository repository})
      : _repository = repository;

  final StepsRepository _repository;

  /// Executes the use case to get today's step count.
  ///
  /// Returns the total number of steps recorded today.
  /// Throws exceptions from the repository on failure.
  Future<int> call() async {
    return _repository.getTodaySteps();
  }
}
