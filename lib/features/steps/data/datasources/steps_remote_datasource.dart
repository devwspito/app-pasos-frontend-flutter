import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/step_model.dart';
import '../models/step_stats_model.dart';
import '../models/weekly_trend_model.dart';

/// Abstract interface for remote step data operations.
///
/// Defines the contract for fetching step data from the API server.
abstract interface class StepsRemoteDataSource {
  /// Fetches today's step statistics.
  ///
  /// Returns [StepStatsModel] with current day's stats.
  /// Throws [ServerException] if the request fails.
  Future<StepStatsModel> getTodayStats();

  /// Fetches weekly step trend data.
  ///
  /// Returns a list of [WeeklyTrendModel] for the past 7 days.
  /// Throws [ServerException] if the request fails.
  Future<List<WeeklyTrendModel>> getWeeklyTrend();

  /// Fetches hourly step breakdown for a specific date.
  ///
  /// [date] The date to get hourly breakdown for.
  /// Returns a list of [StepModel] with hourly data.
  /// Throws [ServerException] if the request fails.
  Future<List<StepModel>> getHourlyBreakdown(DateTime date);

  /// Records new steps to the server.
  ///
  /// [stepCount] The number of steps to record.
  /// [source] The source of the step data (e.g., 'manual', 'healthKit').
  /// Returns the created [StepModel].
  /// Throws [ServerException] if the request fails.
  Future<StepModel> recordSteps(int stepCount, String source);
}

/// Implementation of [StepsRemoteDataSource] using [ApiClient].
///
/// Handles all HTTP requests to the steps API endpoints.
final class StepsRemoteDataSourceImpl implements StepsRemoteDataSource {
  StepsRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<StepStatsModel> getTodayStats() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.todayStats,
      );

      if (response.statusCode == 200 && response.data != null) {
        return StepStatsModel.fromJson(response.data!);
      }

      throw ServerException.fromStatusCode(
        response.statusCode ?? 500,
        endpoint: ApiEndpoints.todayStats,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch today stats: ${e.toString()}',
        endpoint: ApiEndpoints.todayStats,
      );
    }
  }

  @override
  Future<List<WeeklyTrendModel>> getWeeklyTrend() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.weeklyTrend,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final trends = data['trends'] as List<dynamic>? ?? data['data'] as List<dynamic>?;

        if (trends != null) {
          return trends
              .map((json) => WeeklyTrendModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        // If response is directly a list
        if (data is List) {
          return (data)
              .map((json) => WeeklyTrendModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        return [];
      }

      throw ServerException.fromStatusCode(
        response.statusCode ?? 500,
        endpoint: ApiEndpoints.weeklyTrend,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch weekly trend: ${e.toString()}',
        endpoint: ApiEndpoints.weeklyTrend,
      );
    }
  }

  @override
  Future<List<StepModel>> getHourlyBreakdown(DateTime date) async {
    try {
      final formattedDate = date.toIso8601String().split('T').first;
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.hourlyBreakdown,
        queryParameters: {'date': formattedDate},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final steps = data['steps'] as List<dynamic>? ?? data['data'] as List<dynamic>?;

        if (steps != null) {
          return steps
              .map((json) => StepModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        return [];
      }

      throw ServerException.fromStatusCode(
        response.statusCode ?? 500,
        endpoint: ApiEndpoints.hourlyBreakdown,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch hourly breakdown: ${e.toString()}',
        endpoint: ApiEndpoints.hourlyBreakdown,
      );
    }
  }

  @override
  Future<StepModel> recordSteps(int stepCount, String source) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.recordSteps,
        data: {
          'stepCount': stepCount,
          'source': source,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          return StepModel.fromJson(response.data!);
        }
      }

      throw ServerException.fromStatusCode(
        response.statusCode ?? 500,
        endpoint: ApiEndpoints.recordSteps,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to record steps: ${e.toString()}',
        endpoint: ApiEndpoints.recordSteps,
      );
    }
  }
}
