/// Steps repository implementation.
///
/// This file implements the [StepsRepository] interface, coordinating
/// data operations through the remote datasource.
library;

import 'package:app_pasos_frontend/features/dashboard/data/datasources/steps_remote_datasource.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/hourly_peak.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_record.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_stats.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/weekly_trend.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/repositories/steps_repository.dart';

/// Implementation of [StepsRepository] using the remote datasource.
///
/// This class implements the steps business logic, making API calls
/// through the datasource and returning domain entities.
///
/// Example usage:
/// ```dart
/// final repository = StepsRepositoryImpl(
///   datasource: stepsDatasource,
/// );
///
/// final record = await repository.recordSteps(
///   count: 1500,
///   source: StepSource.native,
/// );
/// ```
class StepsRepositoryImpl implements StepsRepository {
  /// Creates a [StepsRepositoryImpl] with the required dependencies.
  ///
  /// [datasource] - The remote datasource for API calls.
  StepsRepositoryImpl({
    required StepsRemoteDatasource datasource,
  }) : _datasource = datasource;

  /// The remote datasource for API operations.
  final StepsRemoteDatasource _datasource;

  @override
  Future<StepRecord> recordSteps({
    required int count,
    required StepSource source,
  }) async {
    // The datasource returns a StepRecordModel which extends StepRecord
    return _datasource.recordSteps(
      count: count,
      source: source,
    );
  }

  @override
  Future<int> getTodaySteps() async {
    return _datasource.getTodaySteps();
  }

  @override
  Future<List<WeeklyTrend>> getWeeklyTrend() async {
    // The datasource returns List<WeeklyTrendModel> which extends WeeklyTrend
    return _datasource.getWeeklyTrend();
  }

  @override
  Future<StepStats> getStats() async {
    // The datasource returns StepStatsModel which extends StepStats
    return _datasource.getStats();
  }

  @override
  Future<List<HourlyPeak>> getHourlyPeaks({String? date}) async {
    // Pass the date query parameter to the datasource
    return _datasource.getHourlyPeaks(date: date);
  }
}
