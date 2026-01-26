import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/step_model.dart';

/// Remote data source for steps data from the API.
///
/// Handles all HTTP communication for step records.
/// Uses [DioClient] for network requests.
abstract class StepsRemoteDataSource {
  /// Fetches today's step record from the API.
  ///
  /// Returns [StepModel] if found, or null if no record exists.
  /// Throws [DioException] on network errors.
  Future<StepModel?> getTodaySteps();

  /// Fetches step records for a date range from the API.
  ///
  /// [startDate] - Start of the date range (inclusive).
  /// [endDate] - End of the date range (inclusive).
  ///
  /// Returns a list of [StepModel] sorted by date descending.
  /// Throws [DioException] on network errors.
  Future<List<StepModel>> getStepsInRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Fetches weekly step records from the API.
  ///
  /// Returns step records for the last 7 days.
  /// Throws [DioException] on network errors.
  Future<List<StepModel>> getWeeklySteps();

  /// Fetches monthly step records from the API.
  ///
  /// Returns step records for the last 30 days.
  /// Throws [DioException] on network errors.
  Future<List<StepModel>> getMonthlySteps();

  /// Saves a step record to the API.
  ///
  /// [stepModel] - The step record to save.
  ///
  /// Returns the saved [StepModel] with server-generated fields.
  /// Throws [DioException] on network errors.
  Future<StepModel> saveStepRecord(StepModel stepModel);

  /// Syncs multiple pending step records to the API.
  ///
  /// [records] - List of step records to sync.
  ///
  /// Returns the number of records successfully synced.
  /// Throws [DioException] on network errors.
  Future<int> syncRecords(List<StepModel> records);
}

/// Implementation of [StepsRemoteDataSource] using Dio HTTP client.
class StepsRemoteDataSourceImpl implements StepsRemoteDataSource {
  final DioClient _client;

  /// API endpoint paths for steps.
  static const String _stepsEndpoint = '/steps';
  static const String _todayEndpoint = '/steps/today';
  static const String _weeklyEndpoint = '/steps/weekly';
  static const String _monthlyEndpoint = '/steps/monthly';
  static const String _syncEndpoint = '/steps/sync';

  /// Creates a [StepsRemoteDataSourceImpl] instance.
  ///
  /// Optionally accepts a [DioClient] for testing purposes.
  /// If not provided, uses the default singleton instance.
  StepsRemoteDataSourceImpl({DioClient? client})
      : _client = client ?? DioClient();

  @override
  Future<StepModel?> getTodaySteps() async {
    try {
      final response = await _client.get(_todayEndpoint);

      if (response.statusCode == 200 && response.data != null) {
        // Handle case where no record exists
        if (response.data is Map && (response.data as Map).isEmpty) {
          return null;
        }
        return StepModel.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      // Return null for 404 (no record found)
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<List<StepModel>> getStepsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _client.get(
      _stepsEndpoint,
      queryParameters: {
        'startDate': startDate.toIso8601String().split('T').first,
        'endDate': endDate.toIso8601String().split('T').first,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList
          .map((json) => StepModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<List<StepModel>> getWeeklySteps() async {
    final response = await _client.get(_weeklyEndpoint);

    if (response.statusCode == 200 && response.data != null) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList
          .map((json) => StepModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<List<StepModel>> getMonthlySteps() async {
    final response = await _client.get(_monthlyEndpoint);

    if (response.statusCode == 200 && response.data != null) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList
          .map((json) => StepModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<StepModel> saveStepRecord(StepModel stepModel) async {
    final response = await _client.post(
      _stepsEndpoint,
      data: stepModel.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return StepModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw DioException(
      requestOptions: RequestOptions(path: _stepsEndpoint),
      message: 'Failed to save step record',
    );
  }

  @override
  Future<int> syncRecords(List<StepModel> records) async {
    if (records.isEmpty) return 0;

    final response = await _client.post(
      _syncEndpoint,
      data: {
        'records': records.map((r) => r.toJson()).toList(),
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      return response.data['syncedCount'] as int? ?? records.length;
    }

    return 0;
  }
}
