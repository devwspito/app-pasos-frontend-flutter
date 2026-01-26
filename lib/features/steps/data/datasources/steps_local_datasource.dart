import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/step_model.dart';
import '../models/step_stats_model.dart';

/// Abstract interface for local steps data caching operations.
///
/// Defines the contract for caching and retrieving step data locally.
/// Uses SharedPreferences for persistent storage.
abstract class StepsLocalDataSource {
  /// Retrieves cached today's step data.
  ///
  /// Returns [StepModel] if cached data exists and is valid, null otherwise.
  Future<StepModel?> getCachedTodaySteps();

  /// Caches today's step data locally.
  ///
  /// [steps] - The step data to cache.
  Future<void> cacheTodaySteps(StepModel steps);

  /// Retrieves cached weekly trend data.
  ///
  /// Returns a list of [StepModel] if cached data exists, null otherwise.
  Future<List<StepModel>?> getCachedWeeklyTrend();

  /// Caches weekly trend data locally.
  ///
  /// [steps] - The weekly step data to cache.
  Future<void> cacheWeeklyTrend(List<StepModel> steps);

  /// Retrieves cached step statistics.
  ///
  /// Returns [StepStatsModel] if cached data exists, null otherwise.
  Future<StepStatsModel?> getCachedStats();

  /// Caches step statistics locally.
  ///
  /// [stats] - The statistics to cache.
  Future<void> cacheStats(StepStatsModel stats);

  /// Gets the timestamp of the last cache update.
  ///
  /// Returns the [DateTime] of the last update, or null if never cached.
  Future<DateTime?> getLastCacheTime();

  /// Clears all cached step data.
  ///
  /// Use this when user logs out or when cache needs to be refreshed.
  Future<void> clearCache();
}

/// Implementation of [StepsLocalDataSource] using SharedPreferences.
///
/// Stores step data as JSON strings in SharedPreferences.
/// Includes cache timestamp for cache invalidation strategies.
class StepsLocalDataSourceImpl implements StepsLocalDataSource {
  final SharedPreferences _prefs;

  /// Cache key for today's steps data.
  static const String _todayKey = 'cached_today_steps';

  /// Cache key for weekly trend data.
  static const String _weeklyKey = 'cached_weekly_steps';

  /// Cache key for statistics data.
  static const String _statsKey = 'cached_steps_stats';

  /// Cache key for last update timestamp.
  static const String _lastCacheTimeKey = 'steps_last_cache_time';

  /// Creates a [StepsLocalDataSourceImpl] instance.
  ///
  /// [prefs] - The SharedPreferences instance for storage.
  StepsLocalDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<StepModel?> getCachedTodaySteps() async {
    final jsonString = _prefs.getString(_todayKey);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return StepModel.fromJson(json);
    } catch (e) {
      // If parsing fails, clear corrupted data
      await _prefs.remove(_todayKey);
      return null;
    }
  }

  @override
  Future<void> cacheTodaySteps(StepModel steps) async {
    final jsonString = jsonEncode(steps.toJson());
    await _prefs.setString(_todayKey, jsonString);
    await _updateCacheTime();
  }

  @override
  Future<List<StepModel>?> getCachedWeeklyTrend() async {
    final jsonString = _prefs.getString(_weeklyKey);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => StepModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, clear corrupted data
      await _prefs.remove(_weeklyKey);
      return null;
    }
  }

  @override
  Future<void> cacheWeeklyTrend(List<StepModel> steps) async {
    final jsonList = steps.map((step) => step.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs.setString(_weeklyKey, jsonString);
    await _updateCacheTime();
  }

  @override
  Future<StepStatsModel?> getCachedStats() async {
    final jsonString = _prefs.getString(_statsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return StepStatsModel.fromJson(json);
    } catch (e) {
      // If parsing fails, clear corrupted data
      await _prefs.remove(_statsKey);
      return null;
    }
  }

  @override
  Future<void> cacheStats(StepStatsModel stats) async {
    final jsonString = jsonEncode(stats.toJson());
    await _prefs.setString(_statsKey, jsonString);
    await _updateCacheTime();
  }

  @override
  Future<DateTime?> getLastCacheTime() async {
    final timestamp = _prefs.getString(_lastCacheTimeKey);

    if (timestamp == null || timestamp.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    await Future.wait([
      _prefs.remove(_todayKey),
      _prefs.remove(_weeklyKey),
      _prefs.remove(_statsKey),
      _prefs.remove(_lastCacheTimeKey),
    ]);
  }

  /// Updates the cache timestamp to current time.
  Future<void> _updateCacheTime() async {
    await _prefs.setString(
      _lastCacheTimeKey,
      DateTime.now().toIso8601String(),
    );
  }
}
