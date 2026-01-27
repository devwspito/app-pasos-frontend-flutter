/// Get stats use case.
///
/// This use case retrieves aggregated step statistics.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_stats.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/repositories/steps_repository.dart';

/// Use case for getting aggregated step statistics.
///
/// This follows the Single Responsibility Principle - it only handles
/// retrieving step statistics. It also follows Dependency Inversion Principle
/// by depending on the StepsRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = GetStatsUseCase(repository: stepsRepository);
/// final stats = await useCase();
/// print('Today: ${stats.today}, Week: ${stats.week}');
/// ```
class GetStatsUseCase {
  /// Creates a [GetStatsUseCase] instance.
  ///
  /// [repository] - The steps repository interface.
  GetStatsUseCase({required StepsRepository repository})
      : _repository = repository;

  final StepsRepository _repository;

  /// Executes the use case to get step statistics.
  ///
  /// Returns [StepStats] containing today, week, month, and all-time totals.
  /// Throws exceptions from the repository on failure.
  Future<StepStats> call() async {
    return _repository.getStats();
  }
}
