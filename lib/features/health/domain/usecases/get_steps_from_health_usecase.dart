/// Use case for retrieving step count data from the health data store.
///
/// This use case follows the single responsibility principle - it has only
/// one method [call] that fetches step count data for a specified date range
/// from the repository.
///
/// Example usage:
/// ```dart
/// final useCase = GetStepsFromHealthUseCase(healthRepository);
/// final steps = await useCase(
///   DateTime.now().subtract(Duration(days: 7)),
///   DateTime.now(),
/// );
/// for (final record in steps) {
///   print('${record.startTime}: ${record.value} steps');
/// }
/// ```
library;

import '../repositories/health_repository.dart';

/// Use case for retrieving step count data from the health data store.
///
/// Follows the single responsibility principle with a single [call] method.
/// Inject [HealthRepository] via constructor for dependency injection.
///
/// This use case abstracts the health data retrieval logic, allowing the
/// presentation layer to request step data without knowing about the
/// underlying health platform (HealthKit or Health Connect).
///
/// Example:
/// ```dart
/// final useCase = GetStepsFromHealthUseCase(repository);
///
/// // Get last 7 days of step data
/// final now = DateTime.now();
/// final weekAgo = now.subtract(Duration(days: 7));
/// final steps = await useCase(weekAgo, now);
///
/// // Calculate total steps
/// final totalSteps = steps.fold<double>(
///   0,
///   (sum, record) => sum + record.value,
/// );
/// print('Total steps this week: $totalSteps');
/// ```
class GetStepsFromHealthUseCase {
  /// The repository used to fetch health data.
  final HealthRepository _repository;

  /// Creates a new [GetStepsFromHealthUseCase] with the given repository.
  ///
  /// [repository] - The health repository implementation to use.
  GetStepsFromHealthUseCase(this._repository);

  /// Fetches step count data for the specified date range.
  ///
  /// [start] - The start date/time for the range (inclusive).
  /// [end] - The end date/time for the range (inclusive).
  ///
  /// Returns a [Future] that completes with a list of [HealthData] entities
  /// representing step count records within the specified range.
  /// The list may be empty if no step data exists for the range.
  ///
  /// Throws an [Exception] if:
  /// - Permissions have not been granted for health data access
  /// - The platform health service is unavailable
  /// - There is an error reading from the health data store
  Future<List<HealthData>> call(DateTime start, DateTime end) =>
      _repository.getStepsForDateRange(start, end);
}
