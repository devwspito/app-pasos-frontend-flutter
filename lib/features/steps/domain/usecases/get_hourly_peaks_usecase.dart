import '../entities/step_record.dart';
import '../repositories/steps_repository.dart';

/// Use case for fetching hourly step breakdown for a specific date.
///
/// Single responsibility: Retrieve hourly step data for activity analysis.
/// This data is used for identifying peak activity hours and patterns.
///
/// Example:
/// ```dart
/// final useCase = GetHourlyPeaksUseCase(repository: stepsRepository);
/// final hourlyData = await useCase(DateTime.now());
/// for (final record in hourlyData) {
///   print('Hour ${record.recordedAt.hour}: ${record.stepCount} steps');
/// }
/// ```
final class GetHourlyPeaksUseCase {
  GetHourlyPeaksUseCase({required StepsRepository repository})
      : _repository = repository;

  final StepsRepository _repository;

  /// Executes the use case to fetch hourly step breakdown.
  ///
  /// [date] The date to get hourly breakdown for.
  ///
  /// Returns list of [StepRecord] with hourly step data.
  /// Each record represents steps recorded during a specific hour.
  ///
  /// Note: This data is not cached as it's historical data.
  /// Requires network connectivity.
  ///
  /// Throws:
  /// - [ServerException] on API errors
  /// - [NetworkException] on connectivity issues
  Future<List<StepRecord>> call(DateTime date) {
    return _repository.getHourlyBreakdown(date);
  }
}
