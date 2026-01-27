/// Remote data source for steps operations.
///
/// This file defines the interface and implementation for steps
/// API calls using the ApiClient.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/core/network/api_client.dart';
import 'package:app_pasos_frontend/core/network/api_endpoints.dart';
import 'package:app_pasos_frontend/features/dashboard/data/models/hourly_peak_model.dart';
import 'package:app_pasos_frontend/features/dashboard/data/models/step_record_model.dart';
import 'package:app_pasos_frontend/features/dashboard/data/models/step_stats_model.dart';
import 'package:app_pasos_frontend/features/dashboard/data/models/weekly_trend_model.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_record.dart';

/// Abstract interface for steps remote data operations.
///
/// This interface defines all step-related API calls.
/// Implementations should use the [ApiClient] for network requests.
abstract interface class StepsRemoteDatasource {
  /// Records steps for the current user.
  ///
  /// [count] - The number of steps to record.
  /// [source] - The source of the steps (native, manual, web).
  ///
  /// Returns [StepRecordModel] containing the created step record.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ValidationException] if count is invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<StepRecordModel> recordSteps({
    required int count,
    required StepSource source,
  });

  /// Gets the total steps recorded today.
  ///
  /// Returns the total step count for today.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<int> getTodaySteps();

  /// Gets the weekly trend data (last 7 days).
  ///
  /// Returns a list of [WeeklyTrendModel] objects, one per day.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<List<WeeklyTrendModel>> getWeeklyTrend();

  /// Gets aggregated step statistics.
  ///
  /// Returns [StepStatsModel] containing today, week, month, and all-time totals.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<StepStatsModel> getStats();

  /// Gets hourly peak data for activity analysis.
  ///
  /// [date] - Optional date to get peaks for (defaults to today).
  ///          Format: YYYY-MM-DD
  ///
  /// Returns a list of [HourlyPeakModel] objects for each hour with activity.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ValidationException] if date format is invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<List<HourlyPeakModel>> getHourlyPeaks({String? date});
}

/// Implementation of [StepsRemoteDatasource] using [ApiClient].
///
/// This class handles all steps API calls, converting
/// responses to models and handling errors appropriately.
///
/// Example usage:
/// ```dart
/// final datasource = StepsRemoteDatasourceImpl(client: apiClient);
/// final todaySteps = await datasource.getTodaySteps();
/// ```
class StepsRemoteDatasourceImpl implements StepsRemoteDatasource {
  /// Creates a [StepsRemoteDatasourceImpl] with the given [ApiClient].
  ///
  /// [client] - The API client for making HTTP requests.
  StepsRemoteDatasourceImpl({required ApiClient client}) : _client = client;

  /// The API client for making HTTP requests.
  final ApiClient _client;

  @override
  Future<StepRecordModel> recordSteps({
    required int count,
    required StepSource source,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.stepsRecord,
      data: {
        'count': count,
        'source': _sourceToString(source),
      },
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle both wrapped and unwrapped responses
    final stepData = data['step'] as Map<String, dynamic>? ?? data;
    return StepRecordModel.fromJson(stepData);
  }

  @override
  Future<int> getTodaySteps() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.stepsToday,
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle various response formats
    final today = data['today'];
    if (today is int) return today;
    if (today is double) return today.toInt();
    if (today is String) return int.tryParse(today) ?? 0;

    return 0;
  }

  @override
  Future<List<WeeklyTrendModel>> getWeeklyTrend() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.stepsWeekly,
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle { trend: [...] } response format
    final trendList = data['trend'] ?? data['data'] ?? [];
    return WeeklyTrendModel.fromJsonList(trendList);
  }

  @override
  Future<StepStatsModel> getStats() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.stepsStats,
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle both wrapped and unwrapped responses
    final statsData = data['stats'] as Map<String, dynamic>? ?? data;
    return StepStatsModel.fromJson(statsData);
  }

  @override
  Future<List<HourlyPeakModel>> getHourlyPeaks({String? date}) async {
    final queryParams = <String, dynamic>{};
    if (date != null && date.isNotEmpty) {
      queryParams['date'] = date;
    }

    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.stepsHourlyPeaks,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle { peaks: [...] } response format
    final peaksList = data['peaks'] ?? data['data'] ?? [];
    return HourlyPeakModel.fromJsonList(peaksList);
  }

  /// Converts a [StepSource] to its string representation for API requests.
  String _sourceToString(StepSource source) {
    return switch (source) {
      StepSource.native => 'native',
      StepSource.manual => 'manual',
      StepSource.web => 'web',
    };
  }
}
