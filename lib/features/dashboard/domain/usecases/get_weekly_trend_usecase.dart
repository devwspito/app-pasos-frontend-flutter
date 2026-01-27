/// Get weekly trend use case.
///
/// This use case retrieves the weekly step trend data for charting.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/weekly_trend.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/repositories/steps_repository.dart';

/// Use case for getting weekly step trend data.
///
/// This follows the Single Responsibility Principle - it only handles
/// retrieving weekly trends. It also follows Dependency Inversion Principle
/// by depending on the StepsRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = GetWeeklyTrendUseCase(repository: stepsRepository);
/// final trends = await useCase();
/// for (final day in trends) {
///   print('${day.date}: ${day.total} steps');
/// }
/// ```
class GetWeeklyTrendUseCase {
  /// Creates a [GetWeeklyTrendUseCase] instance.
  ///
  /// [repository] - The steps repository interface.
  GetWeeklyTrendUseCase({required StepsRepository repository})
      : _repository = repository;

  final StepsRepository _repository;

  /// Executes the use case to get weekly trend data.
  ///
  /// Returns a list of [WeeklyTrend] objects for the last 7 days.
  /// The list is ordered from oldest to newest date.
  /// Throws exceptions from the repository on failure.
  Future<List<WeeklyTrend>> call() async {
    return _repository.getWeeklyTrend();
  }
}
