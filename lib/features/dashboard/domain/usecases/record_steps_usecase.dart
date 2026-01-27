/// Record steps use case.
///
/// This use case handles recording new steps for the current user.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_record.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/repositories/steps_repository.dart';
import 'package:equatable/equatable.dart';

/// Parameters required for recording steps.
///
/// Uses Equatable for value comparison in tests and state management.
class RecordStepsParams extends Equatable {
  /// Creates record steps parameters.
  ///
  /// [count] - The number of steps to record.
  /// [source] - The source of the steps (native, manual, web).
  const RecordStepsParams({
    required this.count,
    required this.source,
  });

  /// The number of steps to record.
  final int count;

  /// The source of the steps.
  final StepSource source;

  @override
  List<Object?> get props => [count, source];
}

/// Use case for recording steps for the current user.
///
/// This follows the Single Responsibility Principle - it only handles
/// recording steps. It also follows Dependency Inversion Principle
/// by depending on the StepsRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = RecordStepsUseCase(repository: stepsRepository);
/// final record = await useCase(
///   RecordStepsParams(count: 1500, source: StepSource.native),
/// );
/// print('Recorded ${record.count} steps with ID: ${record.id}');
/// ```
class RecordStepsUseCase {
  /// Creates a [RecordStepsUseCase] instance.
  ///
  /// [repository] - The steps repository interface.
  RecordStepsUseCase({required StepsRepository repository})
      : _repository = repository;

  final StepsRepository _repository;

  /// Executes the use case to record steps.
  ///
  /// [params] - The parameters containing count and source.
  ///
  /// Returns the created [StepRecord] on success.
  /// Throws exceptions from the repository on failure.
  Future<StepRecord> call(RecordStepsParams params) async {
    return _repository.recordSteps(
      count: params.count,
      source: params.source,
    );
  }
}
