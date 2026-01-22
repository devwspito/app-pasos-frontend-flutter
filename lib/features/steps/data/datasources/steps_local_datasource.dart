import 'dart:convert';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/step_stats_model.dart';
import '../models/weekly_trend_model.dart';

/// Cache keys for steps local storage.
abstract final class StepsCacheKeys {
  static const String todayStats = 'steps_today_stats';
  static const String weeklyTrend = 'steps_weekly_trend';
  static const String todayStatsTimestamp = 'steps_today_stats_timestamp';
  static const String weeklyTrendTimestamp = 'steps_weekly_trend_timestamp';
}

/// Abstract interface for local steps data operations.
///
/// Handles caching of step data for offline-first support.
/// Throws [CacheException] on failure.
abstract interface class StepsLocalDataSource {
  /// Caches today's step statistics.
  ///
  /// [stats] The statistics to cache.
  /// Throws [CacheException] if caching fails.
  Future<void> cacheTodayStats(StepStatsModel stats);

  /// Retrieves cached today's step statistics.
  ///
  /// Returns [StepStatsModel] if cached data exists and is valid.
  /// Throws [CacheException] if no cached data or data is invalid.
  Future<StepStatsModel> getCachedTodayStats();

  /// Caches weekly step trend data.
  ///
  /// [trend] The trend data to cache.
  /// Throws [CacheException] if caching fails.
  Future<void> cacheWeeklyTrend(List<WeeklyTrendModel> trend);

  /// Retrieves cached weekly step trend data.
  ///
  /// Returns list of [WeeklyTrendModel] if cached data exists.
  /// Throws [CacheException] if no cached data or data is invalid.
  Future<List<WeeklyTrendModel>> getCachedWeeklyTrend();

  /// Clears all cached steps data.
  ///
  /// Should be called after successful sync or when user logs out.
  Future<void> clearCache();

  /// Checks if cached data exists and is not expired.
  bool hasCachedTodayStats();

  /// Checks if cached weekly trend exists and is not expired.
  bool hasCachedWeeklyTrend();
}

/// Implementation of [StepsLocalDataSource] using [LocalStorage].
///
/// Stores step data as JSON strings with timestamps for cache invalidation.
/// Cache expires after 1 hour for today stats and 6 hours for weekly trend.
final class StepsLocalDataSourceImpl implements StepsLocalDataSource {
  StepsLocalDataSourceImpl({
    required LocalStorage localStorage,
  }) : _localStorage = localStorage;

  final LocalStorage _localStorage;

  /// Cache duration for today's stats (1 hour).
  static const Duration _todayStatsCacheDuration = Duration(hours: 1);

  /// Cache duration for weekly trend (6 hours).
  static const Duration _weeklyTrendCacheDuration = Duration(hours: 6);

  @override
  Future<void> cacheTodayStats(StepStatsModel stats) async {
    try {
      final jsonString = jsonEncode(stats.toJson());
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await _localStorage.setString(StepsCacheKeys.todayStats, jsonString);
      await _localStorage.setInt(StepsCacheKeys.todayStatsTimestamp, timestamp);
    } catch (e) {
      throw CacheException.writeError(
        StepsCacheKeys.todayStats,
        'Failed to cache today stats: $e',
      );
    }
  }

  @override
  Future<StepStatsModel> getCachedTodayStats() async {
    try {
      final jsonString = _localStorage.getString(StepsCacheKeys.todayStats);

      if (jsonString == null || jsonString.isEmpty) {
        throw CacheException.notFound(StepsCacheKeys.todayStats);
      }

      // Check if cache is expired
      final timestamp = _localStorage.getInt(StepsCacheKeys.todayStatsTimestamp);
      if (timestamp != null) {
        final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cachedTime) > _todayStatsCacheDuration) {
          throw CacheException.expired(StepsCacheKeys.todayStats);
        }
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return StepStatsModel.fromJson(json);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException.invalidData(StepsCacheKeys.todayStats);
    }
  }

  @override
  Future<void> cacheWeeklyTrend(List<WeeklyTrendModel> trend) async {
    try {
      final jsonList = trend.map((t) => t.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await _localStorage.setString(StepsCacheKeys.weeklyTrend, jsonString);
      await _localStorage.setInt(StepsCacheKeys.weeklyTrendTimestamp, timestamp);
    } catch (e) {
      throw CacheException.writeError(
        StepsCacheKeys.weeklyTrend,
        'Failed to cache weekly trend: $e',
      );
    }
  }

  @override
  Future<List<WeeklyTrendModel>> getCachedWeeklyTrend() async {
    try {
      final jsonString = _localStorage.getString(StepsCacheKeys.weeklyTrend);

      if (jsonString == null || jsonString.isEmpty) {
        throw CacheException.notFound(StepsCacheKeys.weeklyTrend);
      }

      // Check if cache is expired
      final timestamp = _localStorage.getInt(StepsCacheKeys.weeklyTrendTimestamp);
      if (timestamp != null) {
        final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cachedTime) > _weeklyTrendCacheDuration) {
          throw CacheException.expired(StepsCacheKeys.weeklyTrend);
        }
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => WeeklyTrendModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException.invalidData(StepsCacheKeys.weeklyTrend);
    }
  }

  @override
  Future<void> clearCache() async {
    await _localStorage.remove(StepsCacheKeys.todayStats);
    await _localStorage.remove(StepsCacheKeys.todayStatsTimestamp);
    await _localStorage.remove(StepsCacheKeys.weeklyTrend);
    await _localStorage.remove(StepsCacheKeys.weeklyTrendTimestamp);
  }

  @override
  bool hasCachedTodayStats() {
    final jsonString = _localStorage.getString(StepsCacheKeys.todayStats);
    if (jsonString == null || jsonString.isEmpty) return false;

    final timestamp = _localStorage.getInt(StepsCacheKeys.todayStatsTimestamp);
    if (timestamp == null) return false;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cachedTime) <= _todayStatsCacheDuration;
  }

  @override
  bool hasCachedWeeklyTrend() {
    final jsonString = _localStorage.getString(StepsCacheKeys.weeklyTrend);
    if (jsonString == null || jsonString.isEmpty) return false;

    final timestamp = _localStorage.getInt(StepsCacheKeys.weeklyTrendTimestamp);
    if (timestamp == null) return false;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cachedTime) <= _weeklyTrendCacheDuration;
  }
}
