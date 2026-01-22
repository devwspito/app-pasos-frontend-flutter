import 'dart:convert';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/step_stats_model.dart';
import '../models/weekly_trend_model.dart';

/// Storage keys for step caching.
abstract final class StepsCacheKeys {
  /// Key for cached today's stats.
  static const String todayStats = 'steps_today_stats';

  /// Key for cached weekly trend data.
  static const String weeklyTrend = 'steps_weekly_trend';

  /// Key for cached stats timestamp.
  static const String statsTimestamp = 'steps_stats_timestamp';

  /// Key for cached trend timestamp.
  static const String trendTimestamp = 'steps_trend_timestamp';
}

/// Abstract interface for local step data caching operations.
///
/// Provides methods for caching and retrieving step data locally.
abstract interface class StepsLocalDataSource {
  /// Gets cached today's step statistics.
  ///
  /// Returns [StepStatsModel] if cached data exists and is valid.
  /// Returns null if no cached data is available.
  Future<StepStatsModel?> getCachedStats();

  /// Caches today's step statistics.
  ///
  /// [stats] The step statistics to cache.
  /// Throws [CacheException] if caching fails.
  Future<void> cacheStats(StepStatsModel stats);

  /// Gets cached weekly trend data.
  ///
  /// Returns a list of [WeeklyTrendModel] if cached data exists.
  /// Returns null if no cached data is available.
  Future<List<WeeklyTrendModel>?> getCachedWeeklyTrend();

  /// Caches weekly trend data.
  ///
  /// [trend] The weekly trend data to cache.
  /// Throws [CacheException] if caching fails.
  Future<void> cacheWeeklyTrend(List<WeeklyTrendModel> trend);

  /// Clears all cached step data.
  ///
  /// Throws [CacheException] if clearing fails.
  Future<void> clearCache();

  /// Checks if cached stats are still valid (not expired).
  ///
  /// Returns true if cache exists and is less than [maxAgeMinutes] old.
  bool isCacheValid({int maxAgeMinutes = 5});
}

/// Implementation of [StepsLocalDataSource] using [LocalStorage].
///
/// Stores step data as JSON strings in local storage with timestamp tracking.
final class StepsLocalDataSourceImpl implements StepsLocalDataSource {
  StepsLocalDataSourceImpl({required LocalStorage localStorage})
      : _localStorage = localStorage;

  final LocalStorage _localStorage;

  @override
  Future<StepStatsModel?> getCachedStats() async {
    try {
      final jsonString = _localStorage.getString(StepsCacheKeys.todayStats);
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return StepStatsModel.fromJson(json);
    } catch (e) {
      // Return null on parse errors - cache is invalid
      return null;
    }
  }

  @override
  Future<void> cacheStats(StepStatsModel stats) async {
    try {
      final jsonString = jsonEncode(stats.toJson());
      final success = await _localStorage.setString(
        StepsCacheKeys.todayStats,
        jsonString,
      );

      if (!success) {
        throw CacheException.writeError(
          StepsCacheKeys.todayStats,
          'Failed to write stats to cache',
        );
      }

      // Store timestamp for cache validity checking
      await _localStorage.setInt(
        StepsCacheKeys.statsTimestamp,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException.writeError(
        StepsCacheKeys.todayStats,
        e.toString(),
      );
    }
  }

  @override
  Future<List<WeeklyTrendModel>?> getCachedWeeklyTrend() async {
    try {
      final jsonString = _localStorage.getString(StepsCacheKeys.weeklyTrend);
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => WeeklyTrendModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return null on parse errors - cache is invalid
      return null;
    }
  }

  @override
  Future<void> cacheWeeklyTrend(List<WeeklyTrendModel> trend) async {
    try {
      final jsonList = trend.map((t) => t.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      final success = await _localStorage.setString(
        StepsCacheKeys.weeklyTrend,
        jsonString,
      );

      if (!success) {
        throw CacheException.writeError(
          StepsCacheKeys.weeklyTrend,
          'Failed to write weekly trend to cache',
        );
      }

      // Store timestamp for cache validity checking
      await _localStorage.setInt(
        StepsCacheKeys.trendTimestamp,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException.writeError(
        StepsCacheKeys.weeklyTrend,
        e.toString(),
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await Future.wait([
        _localStorage.remove(StepsCacheKeys.todayStats),
        _localStorage.remove(StepsCacheKeys.weeklyTrend),
        _localStorage.remove(StepsCacheKeys.statsTimestamp),
        _localStorage.remove(StepsCacheKeys.trendTimestamp),
      ]);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear step cache',
        operation: CacheOperation.clear,
      );
    }
  }

  @override
  bool isCacheValid({int maxAgeMinutes = 5}) {
    final timestamp = _localStorage.getInt(StepsCacheKeys.statsTimestamp);
    if (timestamp == null) {
      return false;
    }

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final age = DateTime.now().difference(cachedTime);
    return age.inMinutes < maxAgeMinutes;
  }
}
