import '../entities/step_stats.dart';
import '../repositories/steps_repository.dart';

/// Use case for fetching today's step statistics.
///
/// Single responsibility: Retrieve current day's step data from repository.
/// This use case implements the offline-first strategy via the repository.
///
/// Example:
/// ```dart
/// final useCase = GetTodayStepsUseCase(repository: stepsRepository);
/// final stats = await useCase();
/// print('Today: ${stats.todaySteps} steps');
/// ```
final class GetTodayStepsUseCase {
  GetTodayStepsUseCase({required StepsRepository repository})
      : _repository = repository;

  final StepsRepository _repository;

  /// Executes the use case to fetch today's step statistics.
  ///
  /// Returns [StepStats] containing:
  /// - todaySteps: Number of steps taken today
  /// - goalSteps: Daily step goal
  /// - weeklyAverage: Average steps over the past week
  /// - percentComplete: Progress toward daily goal (0-100+)
  ///
  /// Throws:
  /// - [ServerException] on API errors
  /// - [NetworkException] on connectivity issues
  /// - [CacheException] if offline and no cached data
  Future<StepStats> call() {
    return _repository.getTodayStats();
  }
}
