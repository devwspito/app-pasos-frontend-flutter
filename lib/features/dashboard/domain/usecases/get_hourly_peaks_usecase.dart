/// Get hourly peaks use case.
///
/// This use case retrieves hourly step peaks for activity analysis.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/hourly_peak.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/repositories/steps_repository.dart';
import 'package:equatable/equatable.dart';

/// Parameters for getting hourly peaks.
///
/// Uses Equatable for value comparison in tests and state management.
class GetHourlyPeaksParams extends Equatable {
  /// Creates hourly peaks parameters.
  ///
  /// [date] - Optional date in YYYY-MM-DD format (defaults to today).
  const GetHourlyPeaksParams({
    this.date,
  });

  /// The date to get hourly peaks for (optional).
  ///
  /// If null, defaults to today's date.
  /// Format: YYYY-MM-DD
  final String? date;

  @override
  List<Object?> get props => [date];
}

/// Use case for getting hourly step peaks.
///
/// This follows the Single Responsibility Principle - it only handles
/// retrieving hourly peaks. It also follows Dependency Inversion Principle
/// by depending on the StepsRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = GetHourlyPeaksUseCase(repository: stepsRepository);
/// final peaks = await useCase(GetHourlyPeaksParams(date: '2024-01-15'));
/// for (final peak in peaks) {
///   print('Hour ${peak.hour}: ${peak.total} steps');
/// }
/// ```
class GetHourlyPeaksUseCase {
  /// Creates a [GetHourlyPeaksUseCase] instance.
  ///
  /// [repository] - The steps repository interface.
  GetHourlyPeaksUseCase({required StepsRepository repository})
      : _repository = repository;

  final StepsRepository _repository;

  /// Executes the use case to get hourly peaks.
  ///
  /// [params] - Optional parameters containing the date to query.
  ///
  /// Returns a list of [HourlyPeak] objects for each hour with activity.
  /// Throws exceptions from the repository on failure.
  Future<List<HourlyPeak>> call([GetHourlyPeaksParams? params]) async {
    return _repository.getHourlyPeaks(date: params?.date);
  }
}
