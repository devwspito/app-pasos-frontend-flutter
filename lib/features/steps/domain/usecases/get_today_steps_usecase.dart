import '../entities/step_record.dart';
import '../repositories/steps_repository.dart';

/// Use case for retrieving today's step record.
///
/// This use case follows the single responsibility principle,
/// encapsulating the business logic for getting today's steps.
class GetTodayStepsUseCase {
  final StepsRepository _repository;

  /// Creates a new [GetTodayStepsUseCase] instance.
  ///
  /// [repository] - The steps repository to use for data access.
  GetTodayStepsUseCase(this._repository);

  /// Executes the use case to get today's step record.
  ///
  /// Returns a [StepRecord] for today, or null if no steps
  /// have been recorded yet today.
  Future<StepRecord?> call() => _repository.getTodaySteps();
}
