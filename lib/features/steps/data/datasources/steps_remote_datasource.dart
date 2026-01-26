import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/step_model.dart';
import '../models/step_stats_model.dart';

/// Abstract interface for remote steps data operations.
///
/// Defines the contract for fetching and recording step data from the backend API.
/// Implementations should handle network errors and data transformation.
abstract class StepsRemoteDataSource {
  /// Fetches today's step data from the API.
  ///
  /// Returns [StepModel] if data exists, null otherwise.
  /// Throws [DioException] on network errors.
  Future<StepModel?> getTodaySteps();

  /// Fetches the weekly step trend from the API.
  ///
  /// Returns a list of [StepModel] for the past 7 days.
  /// May return an empty list if no data is available.
  Future<List<StepModel>> getWeeklyTrend();

  /// Fetches hourly step breakdown for a specific date.
  ///
  /// [date] - The date to fetch hourly data for.
  /// Returns a list of [StepModel] with hourly granularity.
  Future<List<StepModel>> getHourlySteps(DateTime date);

  /// Fetches aggregated step statistics from the API.
  ///
  /// Returns [StepStatsModel] containing totals, averages, and streaks.
  Future<StepStatsModel> getStats();

  /// Records new step data to the API.
  ///
  /// [steps] - The number of steps to record.
  /// [source] - The source of the step data (e.g., 'pedometer', 'manual').
  Future<void> recordSteps(int steps, String source);
}

/// Implementation of [StepsRemoteDataSource] using DioClient.
///
/// Uses the singleton [DioClient] for all HTTP operations.
/// Handles JSON parsing and error transformation.
class StepsRemoteDataSourceImpl implements StepsRemoteDataSource {
  final DioClient _dioClient;

  /// Creates a [StepsRemoteDataSourceImpl] instance.
  ///
  /// [dioClient] - Optional DioClient instance. Uses singleton if not provided.
  StepsRemoteDataSourceImpl({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  @override
  Future<StepModel?> getTodaySteps() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        ApiEndpoints.stepsToday,
      );

      if (response.data == null) {
        return null;
      }

      return StepModel.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<List<StepModel>> getWeeklyTrend() async {
    final response = await _dioClient.get<List<dynamic>>(
      ApiEndpoints.stepsWeekly,
    );

    if (response.data == null) {
      return [];
    }

    return response.data!
        .map((json) => StepModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<StepModel>> getHourlySteps(DateTime date) async {
    final formattedDate = date.toIso8601String().split('T')[0];

    final response = await _dioClient.get<List<dynamic>>(
      ApiEndpoints.stepsHourly,
      queryParameters: {'date': formattedDate},
    );

    if (response.data == null) {
      return [];
    }

    return response.data!
        .map((json) => StepModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StepStatsModel> getStats() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiEndpoints.stepsStats,
    );

    if (response.data == null) {
      return const StepStatsModel(
        totalSteps: 0,
        averageSteps: 0.0,
        goalSteps: 10000,
        goalProgress: 0.0,
        streak: 0,
        bestDaySteps: 0,
      );
    }

    return StepStatsModel.fromJson(response.data!);
  }

  @override
  Future<void> recordSteps(int steps, String source) async {
    await _dioClient.post<void>(
      ApiEndpoints.steps,
      data: {
        'stepCount': steps,
        'source': source,
        'date': DateTime.now().toIso8601String(),
      },
    );
  }
}
