import '../entities/step_record.dart';
import '../repositories/steps_repository.dart';

/// Use case for retrieving weekly step trend data.
///
/// This use case follows the single responsibility principle,
/// encapsulating the business logic for getting the weekly trend.
class GetWeeklyTrendUseCase {
  final StepsRepository _repository;

  /// Creates a new [GetWeeklyTrendUseCase] instance.
  ///
  /// [repository] - The steps repository to use for data access.
  GetWeeklyTrendUseCase(this._repository);

  /// Executes the use case to get the weekly step trend.
  ///
  /// Returns a list of [StepRecord] objects for the last 7 days,
  /// sorted by date in ascending order (oldest first).
  /// This data is useful for displaying trend charts and
  /// calculating weekly averages.
  Future<List<StepRecord>> call() => _repository.getWeeklyTrend();
}
