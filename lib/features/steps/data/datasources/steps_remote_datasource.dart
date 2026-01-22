import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/step_stats_model.dart';
import '../models/weekly_trend_model.dart';

/// Abstract interface for remote step tracking data operations.
///
/// Defines the contract for fetching and recording step data from the server.
abstract interface class StepsRemoteDataSource {
  /// Gets today's step statistics.
  ///
  /// Throws [ServerException] if the request fails.
  /// Throws [NetworkException] if there's no connection.
  Future<StepStatsModel> getTodayStats();

  /// Gets the weekly step trend data.
  ///
  /// Returns a list of [WeeklyTrendModel] for the past 7 days.
  /// Throws [ServerException] if the request fails.
  /// Throws [NetworkException] if there's no connection.
  Future<List<WeeklyTrendModel>> getWeeklyTrend();

  /// Gets hourly step breakdown for a specific date.
  ///
  /// [date] should be in ISO 8601 format (YYYY-MM-DD).
  /// Returns a map of hour (0-23) to step count.
  /// Throws [ServerException] if the request fails.
  /// Throws [NetworkException] if there's no connection.
  Future<Map<int, int>> getHourlyBreakdown(String date);

  /// Records steps from a source.
  ///
  /// [count] is the number of steps to record.
  /// [source] identifies the data source (e.g., 'healthkit', 'manual', 'google_fit').
  /// Returns the updated [StepStatsModel] after recording.
  /// Throws [ServerException] if the request fails.
  /// Throws [NetworkException] if there's no connection.
  Future<StepStatsModel> recordSteps({
    required int count,
    required String source,
  });

  /// Syncs local step data with the server.
  ///
  /// [stepRecords] is a list of step records to sync.
  /// Returns true if sync was successful.
  /// Throws [ServerException] if the request fails.
  /// Throws [NetworkException] if there's no connection.
  Future<bool> syncSteps(List<Map<String, dynamic>> stepRecords);
}

/// Implementation of [StepsRemoteDataSource] using [ApiClient].
///
/// Handles all HTTP communication with the steps API endpoints.
final class StepsRemoteDataSourceImpl implements StepsRemoteDataSource {
  const StepsRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<StepStatsModel> getTodayStats() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.stepsToday,
      );

      if (response.statusCode == 200 && response.data != null) {
        return StepStatsModel.fromJson(response.data!);
      }

      throw ServerException.fromStatusCode(
        response.statusCode ?? 500,
        endpoint: ApiEndpoints.stepsToday,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, ApiEndpoints.stepsToday);
    }
  }

  @override
  Future<List<WeeklyTrendModel>> getWeeklyTrend() async {
    try {
      final response = await apiClient.get<List<dynamic>>(
        ApiEndpoints.stepsWeekly,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map((json) => WeeklyTrendModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException.fromStatusCode(
        response.statusCode ?? 500,
        endpoint: ApiEndpoints.stepsWeekly,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, ApiEndpoints.stepsWeekly);
    }
  }

  @override
  Future<Map<int, int>> getHourlyBreakdown(String date) async {
    final endpoint = ApiEndpoints.stepsHourly(date);
    try {
      final response = await apiClient.get<Map<String, dynamic>>(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        final Map<int, int> hourlyData = {};
        final data = response.data!;

        // Parse the response which has hour keys as strings
        for (final entry in data.entries) {
          final hour = int.tryParse(entry.key);
          if (hour != null && entry.value is int) {
            hourlyData[hour] = entry.value as int;
          }
        }

        return hourlyData;
      }

      throw ServerException.fromStatusCode(
        response.statusCode ?? 500,
        endpoint: endpoint,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, endpoint);
    }
  }

  @override
  Future<StepStatsModel> recordSteps({
    required int count,
    required String source,
  }) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.stepsRecord,
        data: {
          'count': count,
          'source': source,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          return StepStatsModel.fromJson(response.data!);
        }
      }

      throw ServerException.fromStatusCode(
        response.statusCode ?? 500,
        endpoint: ApiEndpoints.stepsRecord,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, ApiEndpoints.stepsRecord);
    }
  }

  @override
  Future<bool> syncSteps(List<Map<String, dynamic>> stepRecords) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.stepsSync,
        data: {
          'records': stepRecords,
          'syncedAt': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      throw ServerException.fromStatusCode(
        response.statusCode ?? 500,
        endpoint: ApiEndpoints.stepsSync,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, ApiEndpoints.stepsSync);
    }
  }

  /// Handles Dio exceptions and converts them to appropriate app exceptions.
  AppException _handleDioException(DioException e, String endpoint) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout();
      case DioExceptionType.connectionError:
        return NetworkException.noConnection();
      case DioExceptionType.badResponse:
        return ServerException.fromStatusCode(
          e.response?.statusCode ?? 500,
          endpoint: endpoint,
        );
      case DioExceptionType.cancel:
        return const ServerException(
          message: 'Request was cancelled',
          endpoint: null,
        );
      case DioExceptionType.badCertificate:
        return NetworkException.sslError();
      case DioExceptionType.unknown:
      default:
        if (e.error != null && e.error.toString().contains('SocketException')) {
          return NetworkException.noConnection();
        }
        return ServerException(
          message: e.message ?? 'Unknown error occurred',
          endpoint: endpoint,
        );
    }
  }
}
