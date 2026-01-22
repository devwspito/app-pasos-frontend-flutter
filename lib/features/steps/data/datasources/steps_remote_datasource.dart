import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/step_model.dart';
import '../models/step_stats_model.dart';
import '../models/weekly_trend_model.dart';

/// Abstract interface for remote steps data operations.
///
/// Handles all API calls related to step tracking data.
/// Throws [ServerException] or [NetworkException] on failure.
abstract interface class StepsRemoteDataSource {
  /// Fetches today's step statistics from the server.
  ///
  /// Returns [StepStatsModel] with current day's statistics.
  /// Throws [ServerException] on API errors.
  Future<StepStatsModel> getTodayStats();

  /// Fetches weekly step trend data from the server.
  ///
  /// Returns list of [WeeklyTrendModel] for the past 7 days.
  /// Throws [ServerException] on API errors.
  Future<List<WeeklyTrendModel>> getWeeklyTrend();

  /// Fetches hourly step breakdown for a specific date.
  ///
  /// [date] The date to get hourly breakdown for.
  ///
  /// Returns list of [StepModel] with hourly step data.
  /// Throws [ServerException] on API errors.
  Future<List<StepModel>> getHourlyBreakdown(DateTime date);

  /// Records new steps to the server.
  ///
  /// [stepCount] The number of steps to record.
  /// [source] The source of the step data.
  ///
  /// Returns the created [StepModel].
  /// Throws [ServerException] on API errors.
  Future<StepModel> recordSteps(int stepCount, String source);

  /// Synchronizes local step data with the server.
  ///
  /// Throws [ServerException] on API errors.
  Future<void> syncSteps();
}

/// Implementation of [StepsRemoteDataSource] using [ApiClient].
///
/// Handles all HTTP requests to the steps API endpoints.
final class StepsRemoteDataSourceImpl implements StepsRemoteDataSource {
  StepsRemoteDataSourceImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<StepStatsModel> getTodayStats() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.stepsTodayStats,
      );

      if (response.statusCode == 200 && response.data != null) {
        return StepStatsModel.fromJson(response.data!);
      }

      throw ServerException.fromStatusCode(
        response.statusCode ?? 500,
        endpoint: ApiEndpoints.stepsTodayStats,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch today stats: $e',
        endpoint: ApiEndpoints.stepsTodayStats,
      );
    }
  }

  @override
  Future<List<WeeklyTrendModel>> getWeeklyTrend() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.stepsWeeklyTrend,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data!['data'] ?? [];
        return data
            .map((json) => WeeklyTrendModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException.fromStatusCode(
        response.statusCode ?? 500,
        endpoint: ApiEndpoints.stepsWeeklyTrend,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch weekly trend: $e',
        endpoint: ApiEndpoints.stepsWeeklyTrend,
      );
    }
  }

  @override
  Future<List<StepModel>> getHourlyBreakdown(DateTime date) async {
    try {
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.stepsHourlyBreakdown,
        queryParameters: {'date': dateString},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data!['data'] ?? [];
        return data
            .map((json) => StepModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException.fromStatusCode(
        response.statusCode ?? 500,
        endpoint: ApiEndpoints.stepsHourlyBreakdown,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch hourly breakdown: $e',
        endpoint: ApiEndpoints.stepsHourlyBreakdown,
      );
    }
  }

  @override
  Future<StepModel> recordSteps(int stepCount, String source) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.stepsRecord,
        data: {
          'stepCount': stepCount,
          'source': source,
        },
      );

      if (response.statusCode == 201 && response.data != null) {
        return StepModel.fromJson(response.data!);
      }

      throw ServerException.fromStatusCode(
        response.statusCode ?? 500,
        endpoint: ApiEndpoints.stepsRecord,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to record steps: $e',
        endpoint: ApiEndpoints.stepsRecord,
      );
    }
  }

  @override
  Future<void> syncSteps() async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.stepsSync,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException.fromStatusCode(
          response.statusCode ?? 500,
          endpoint: ApiEndpoints.stepsSync,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to sync steps: $e',
        endpoint: ApiEndpoints.stepsSync,
      );
    }
  }
}
