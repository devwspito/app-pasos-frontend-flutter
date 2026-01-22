import 'dart:convert';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/step_stats_model.dart';
import '../models/weekly_trend_model.dart';

/// Cache keys for step data.
abstract final class StepsCacheKeys {
  static const String todayStats = 'steps_today_stats';
  static const String weeklyTrend = 'steps_weekly_trend';
  static const String lastCacheTime = 'steps_last_cache_time';
  static const String pendingSyncRecords = 'steps_pending_sync';
}

/// Abstract interface for local step data caching operations.
///
/// Defines the contract for caching step data locally.
abstract interface class StepsLocalDataSource {
  /// Caches today's step statistics.
  ///
  /// Throws [CacheException] if caching fails.
  Future<void> cacheTodayStats(StepStatsModel stats);

  /// Gets cached today's step statistics.
  ///
  /// Returns null if no cached data exists.
  /// Throws [CacheException] if reading cache fails or data is corrupted.
  StepStatsModel? getCachedTodayStats();

  /// Caches the weekly step trend data.
  ///
  /// Throws [CacheException] if caching fails.
  Future<void> cacheWeeklyTrend(List<WeeklyTrendModel> trend);

  /// Gets cached weekly step trend data.
  ///
  /// Returns null if no cached data exists.
  /// Throws [CacheException] if reading cache fails or data is corrupted.
  List<WeeklyTrendModel>? getCachedWeeklyTrend();

  /// Clears all step-related cache data.
  ///
  /// Throws [CacheException] if clearing cache fails.
  Future<void> clearCache();

  /// Checks if cache is valid (not expired).
  ///
  /// [maxAgeMinutes] is the maximum age of cache in minutes.
  /// Returns true if cache is still valid.
  bool isCacheValid({int maxAgeMinutes = 5});

  /// Adds a step record to pending sync queue.
  ///
  /// Records are stored locally until synced with server.
  /// Throws [CacheException] if adding fails.
  Future<void> addPendingSyncRecord(Map<String, dynamic> record);

  /// Gets all pending sync records.
  ///
  /// Returns an empty list if no pending records.
  /// Throws [CacheException] if reading fails.
  List<Map<String, dynamic>> getPendingSyncRecords();

  /// Clears pending sync records after successful sync.
  ///
  /// Throws [CacheException] if clearing fails.
  Future<void> clearPendingSyncRecords();
}

/// Implementation of [StepsLocalDataSource] using [LocalStorage].
///
/// Handles all local caching operations for step data.
final class StepsLocalDataSourceImpl implements StepsLocalDataSource {
  const StepsLocalDataSourceImpl({required this.localStorage});

  final LocalStorage localStorage;

  @override
  Future<void> cacheTodayStats(StepStatsModel stats) async {
    try {
      final jsonString = jsonEncode(stats.toJson());
      final success = await localStorage.setString(
        StepsCacheKeys.todayStats,
        jsonString,
      );

      if (!success) {
        throw CacheException.writeError(StepsCacheKeys.todayStats);
      }

      // Update cache timestamp
      await _updateCacheTime();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException.writeError(
        StepsCacheKeys.todayStats,
        e.toString(),
      );
    }
  }

  @override
  StepStatsModel? getCachedTodayStats() {
    try {
      final jsonString = localStorage.getString(StepsCacheKeys.todayStats);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return StepStatsModel.fromJson(json);
    } catch (e) {
      throw CacheException.invalidData(StepsCacheKeys.todayStats);
    }
  }

  @override
  Future<void> cacheWeeklyTrend(List<WeeklyTrendModel> trend) async {
    try {
      final jsonList = trend.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      final success = await localStorage.setString(
        StepsCacheKeys.weeklyTrend,
        jsonString,
      );

      if (!success) {
        throw CacheException.writeError(StepsCacheKeys.weeklyTrend);
      }

      // Update cache timestamp
      await _updateCacheTime();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException.writeError(
        StepsCacheKeys.weeklyTrend,
        e.toString(),
      );
    }
  }

  @override
  List<WeeklyTrendModel>? getCachedWeeklyTrend() {
    try {
      final jsonString = localStorage.getString(StepsCacheKeys.weeklyTrend);
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => WeeklyTrendModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException.invalidData(StepsCacheKeys.weeklyTrend);
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await localStorage.remove(StepsCacheKeys.todayStats);
      await localStorage.remove(StepsCacheKeys.weeklyTrend);
      await localStorage.remove(StepsCacheKeys.lastCacheTime);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear step cache',
        operation: CacheOperation.clear,
      );
    }
  }

  @override
  bool isCacheValid({int maxAgeMinutes = 5}) {
    final cacheTimeMs = localStorage.getInt(StepsCacheKeys.lastCacheTime);
    if (cacheTimeMs == null) return false;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(cacheTimeMs);
    final now = DateTime.now();
    final difference = now.difference(cacheTime);

    return difference.inMinutes < maxAgeMinutes;
  }

  @override
  Future<void> addPendingSyncRecord(Map<String, dynamic> record) async {
    try {
      final existingRecords = getPendingSyncRecords();
      existingRecords.add(record);

      final jsonString = jsonEncode(existingRecords);
      final success = await localStorage.setString(
        StepsCacheKeys.pendingSyncRecords,
        jsonString,
      );

      if (!success) {
        throw CacheException.writeError(StepsCacheKeys.pendingSyncRecords);
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException.writeError(
        StepsCacheKeys.pendingSyncRecords,
        e.toString(),
      );
    }
  }

  @override
  List<Map<String, dynamic>> getPendingSyncRecords() {
    try {
      final jsonString = localStorage.getString(StepsCacheKeys.pendingSyncRecords);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      // Return empty list if cache is invalid/corrupted
      return [];
    }
  }

  @override
  Future<void> clearPendingSyncRecords() async {
    try {
      await localStorage.remove(StepsCacheKeys.pendingSyncRecords);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear pending sync records',
        key: StepsCacheKeys.pendingSyncRecords,
        operation: CacheOperation.clear,
      );
    }
  }

  /// Updates the cache timestamp to current time.
  Future<void> _updateCacheTime() async {
    await localStorage.setInt(
      StepsCacheKeys.lastCacheTime,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
