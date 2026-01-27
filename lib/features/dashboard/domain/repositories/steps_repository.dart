/// Steps repository interface for the domain layer.
///
/// This file defines the contract for step-related operations.
/// Implementations should handle all step data operations.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/hourly_peak.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_record.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_stats.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/weekly_trend.dart';

/// Abstract interface defining step-related operations.
///
/// This interface follows the Clean Architecture pattern, allowing the domain
/// layer to define what operations are needed without knowing implementation
/// details. The data layer provides the concrete implementation.
///
/// Example usage:
/// ```dart
/// class RecordStepsUseCase {
///   final StepsRepository repository;
///
///   RecordStepsUseCase(this.repository);
///
///   Future<StepRecord> execute(int count, StepSource source) {
///     return repository.recordSteps(count: count, source: source);
///   }
/// }
/// ```
abstract interface class StepsRepository {
  /// Records steps for the current user.
  ///
  /// [count] - The number of steps to record.
  /// [source] - The source of the steps (native, manual, web).
  ///
  /// Returns the created [StepRecord] on success.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [ValidationException] if count is invalid (negative).
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<StepRecord> recordSteps({
    required int count,
    required StepSource source,
  });

  /// Gets the total steps recorded today.
  ///
  /// Returns the total step count for today.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<int> getTodaySteps();

  /// Gets the weekly trend data (last 7 days).
  ///
  /// Returns a list of [WeeklyTrend] objects, one per day.
  /// The list is ordered from oldest to newest date.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<List<WeeklyTrend>> getWeeklyTrend();

  /// Gets aggregated step statistics.
  ///
  /// Returns [StepStats] containing today, week, month, and all-time totals.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<StepStats> getStats();

  /// Gets hourly peak data for activity analysis.
  ///
  /// [date] - Optional date to get peaks for (defaults to today).
  ///          Format: YYYY-MM-DD
  ///
  /// Returns a list of [HourlyPeak] objects for each hour with activity.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [ValidationException] if date format is invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<List<HourlyPeak>> getHourlyPeaks({String? date});
}
