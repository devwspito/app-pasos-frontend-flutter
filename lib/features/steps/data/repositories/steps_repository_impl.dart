import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/step_record.dart';
import '../../domain/entities/step_stats.dart';
import '../../domain/repositories/steps_repository.dart';
import '../datasources/steps_local_datasource.dart';
import '../datasources/steps_remote_datasource.dart';
import '../models/step_stats_model.dart';
import '../models/weekly_trend_model.dart';

/// Implementation of [StepsRepository] with offline-first strategy.
///
/// Orchestrates between remote and local data sources:
/// 1. Attempts to fetch from remote server
/// 2. On success, caches locally and returns data
/// 3. On network failure, falls back to cached data
/// 4. Throws exception if no data is available
final class StepsRepositoryImpl implements StepsRepository {
  StepsRepositoryImpl({
    required StepsRemoteDataSource remoteDataSource,
    required StepsLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final StepsRemoteDataSource _remoteDataSource;
  final StepsLocalDataSource _localDataSource;

  @override
  Future<StepStats> getTodayStats() async {
    try {
      // Try to fetch from remote
      final stats = await _remoteDataSource.getTodayStats();

      // Cache on success
      await _localDataSource.cacheTodayStats(stats);

      return stats;
    } on ServerException {
      // On server error, try cache
      return _getCachedTodayStatsOrThrow();
    } on NetworkException {
      // On network error, try cache
      return _getCachedTodayStatsOrThrow();
    } catch (e) {
      // On any other error, try cache
      return _getCachedTodayStatsOrThrow();
    }
  }

  /// Gets cached today stats or throws the appropriate exception.
  Future<StepStats> _getCachedTodayStatsOrThrow() async {
    try {
      return await _localDataSource.getCachedTodayStats();
    } on CacheException catch (e) {
      // Re-throw as a more user-friendly exception
      throw ServerException(
        message: 'Unable to load step statistics. Please check your connection.',
        details: {'cacheError': e.message},
      );
    }
  }

  @override
  Future<List<WeeklyTrendModel>> getWeeklyTrend() async {
    try {
      // Try to fetch from remote
      final trend = await _remoteDataSource.getWeeklyTrend();

      // Cache on success
      await _localDataSource.cacheWeeklyTrend(trend);

      return trend;
    } on ServerException {
      // On server error, try cache
      return _getCachedWeeklyTrendOrEmpty();
    } on NetworkException {
      // On network error, try cache
      return _getCachedWeeklyTrendOrEmpty();
    } catch (e) {
      // On any other error, try cache
      return _getCachedWeeklyTrendOrEmpty();
    }
  }

  /// Gets cached weekly trend or returns empty list.
  Future<List<WeeklyTrendModel>> _getCachedWeeklyTrendOrEmpty() async {
    try {
      return await _localDataSource.getCachedWeeklyTrend();
    } on CacheException {
      // Return empty list if no cached data
      return [];
    }
  }

  @override
  Future<List<StepRecord>> getHourlyBreakdown(DateTime date) async {
    // Hourly data is not cached as it's historical data
    try {
      return await _remoteDataSource.getHourlyBreakdown(date);
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to load hourly breakdown: $e',
      );
    }
  }

  @override
  Future<StepRecord> recordSteps(int stepCount, String source) async {
    // Recording requires network connectivity
    try {
      final record = await _remoteDataSource.recordSteps(stepCount, source);

      // Invalidate today stats cache to force refresh
      // (don't clear weekly trend as it might still be valid)
      try {
        // We don't have a method to clear just today stats, but the cache will be
        // refreshed on the next getTodayStats() call anyway
      } catch (_) {
        // Ignore cache errors on record
      }

      return record;
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to record steps: $e',
      );
    }
  }

  @override
  Future<void> syncSteps() async {
    try {
      await _remoteDataSource.syncSteps();

      // Clear local cache after successful sync
      await _localDataSource.clearCache();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to sync steps: $e',
      );
    }
  }
}
