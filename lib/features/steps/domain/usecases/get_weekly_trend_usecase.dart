import '../../data/models/weekly_trend_model.dart';
import '../repositories/steps_repository.dart';

/// Use case for fetching weekly step trend data.
///
/// Single responsibility: Retrieve 7-day step trend from repository.
/// This data is used for weekly progress charts and comparisons.
///
/// Example:
/// ```dart
/// final useCase = GetWeeklyTrendUseCase(repository: stepsRepository);
/// final trend = await useCase();
/// for (final day in trend) {
///   print('${day.dayOfWeek}: ${day.steps} steps');
/// }
/// ```
final class GetWeeklyTrendUseCase {
  GetWeeklyTrendUseCase({required StepsRepository repository})
      : _repository = repository;

  final StepsRepository _repository;

  /// Executes the use case to fetch weekly step trend.
  ///
  /// Returns list of [WeeklyTrendModel] for the past 7 days, ordered
  /// from oldest to newest. Each entry contains:
  /// - dayOfWeek: Day name (e.g., "Mon", "Tue")
  /// - steps: Step count for that day
  /// - date: The actual date
  /// - isToday: Whether this entry is for today
  ///
  /// Returns empty list if offline and no cached data.
  Future<List<WeeklyTrendModel>> call() {
    return _repository.getWeeklyTrend();
  }
}
