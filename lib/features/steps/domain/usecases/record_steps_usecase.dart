import '../repositories/steps_repository.dart';

/// Parameters for recording steps.
///
/// This class encapsulates the input parameters for the
/// [RecordStepsUseCase], following the command pattern.
class RecordStepsParams {
  /// The number of steps to record.
  final int steps;

  /// The source of the step data (e.g., 'healthkit', 'google_fit', 'manual').
  final String source;

  /// Creates a new [RecordStepsParams] instance.
  const RecordStepsParams({
    required this.steps,
    required this.source,
  });

  /// Creates params for manually entered steps.
  factory RecordStepsParams.manual(int steps) {
    return RecordStepsParams(steps: steps, source: 'manual');
  }

  /// Creates params for HealthKit synced steps.
  factory RecordStepsParams.healthKit(int steps) {
    return RecordStepsParams(steps: steps, source: 'healthkit');
  }

  /// Creates params for Google Fit synced steps.
  factory RecordStepsParams.googleFit(int steps) {
    return RecordStepsParams(steps: steps, source: 'google_fit');
  }
}

/// Use case for recording step data.
///
/// This use case follows the single responsibility principle,
/// encapsulating the business logic for recording steps.
class RecordStepsUseCase {
  final StepsRepository _repository;

  /// Creates a new [RecordStepsUseCase] instance.
  ///
  /// [repository] - The steps repository to use for data access.
  RecordStepsUseCase(this._repository);

  /// Executes the use case to record steps.
  ///
  /// [params] - The parameters containing step count and source.
  ///
  /// Throws [ArgumentError] if steps is negative.
  Future<void> call(RecordStepsParams params) {
    if (params.steps < 0) {
      throw ArgumentError('Steps cannot be negative', 'params.steps');
    }
    return _repository.recordSteps(params.steps, params.source);
  }
}
