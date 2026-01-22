import '../entities/step_record.dart';
import '../repositories/steps_repository.dart';

/// Use case for recording new steps to the server.
///
/// Single responsibility: Submit step data from various sources.
/// Sources include manual entry, HealthKit (iOS), or Google Fit (Android).
///
/// Example:
/// ```dart
/// final useCase = RecordStepsUseCase(repository: stepsRepository);
/// final record = await useCase(5000, 'healthKit');
/// print('Recorded ${record.stepCount} steps from ${record.source.name}');
/// ```
final class RecordStepsUseCase {
  RecordStepsUseCase({required StepsRepository repository})
      : _repository = repository;

  final StepsRepository _repository;

  /// Executes the use case to record steps.
  ///
  /// [stepCount] The number of steps to record. Must be positive.
  /// [source] The source of the step data:
  ///   - 'manual': User manually entered steps
  ///   - 'healthKit': Synced from Apple HealthKit
  ///   - 'googleFit': Synced from Google Fit
  ///
  /// Returns the created [StepRecord] with server-assigned ID.
  ///
  /// Note: Requires network connectivity. This operation cannot
  /// be performed offline.
  ///
  /// Throws:
  /// - [ServerException] on API errors (e.g., invalid data)
  /// - [NetworkException] on connectivity issues
  Future<StepRecord> call(int stepCount, String source) {
    return _repository.recordSteps(stepCount, source);
  }
}
