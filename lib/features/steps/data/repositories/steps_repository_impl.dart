import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/step_record.dart';
import '../../domain/entities/step_stats.dart';
import '../../domain/repositories/steps_repository.dart';
import '../datasources/steps_local_datasource.dart';
import '../datasources/steps_remote_datasource.dart';
import '../models/step_model.dart';
import '../models/step_stats_model.dart';
import '../models/weekly_trend_model.dart';

/// Implementation of [StepsRepository] with offline-first strategy.
///
/// Prioritizes remote data but falls back to local cache when
/// network is unavailable. All fetched data is cached locally
/// for offline access.
///
/// Dependency injection pattern:
/// - [remoteDataSource]: Handles API requests
/// - [localDataSource]: Handles local caching
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
      // 1. Try to fetch from remote
      final statsModel = await _remoteDataSource.getTodayStats();

      // 2. Cache locally on success
      await _cacheStatsQuietly(statsModel);

      // 3. Return domain entity
      return statsModel;
    } on NetworkException {
      // 4. On network failure, return cached data
      return _getCachedStatsOrThrow();
    } on ServerException catch (e) {
      // Check if it's a connectivity-related error (timeout, etc.)
      if (_isConnectivityError(e)) {
        return _getCachedStatsOrThrow();
      }
      rethrow;
    }
  }

  @override
  Future<List<WeeklyTrendModel>> getWeeklyTrend() async {
    try {
      // 1. Try to fetch from remote
      final trends = await _remoteDataSource.getWeeklyTrend();

      // 2. Cache locally on success
      await _cacheWeeklyTrendQuietly(trends);

      // 3. Return data
      return trends;
    } on NetworkException {
      // 4. On network failure, return cached data
      return _getCachedWeeklyTrendOrEmpty();
    } on ServerException catch (e) {
      // Check if it's a connectivity-related error
      if (_isConnectivityError(e)) {
        return _getCachedWeeklyTrendOrEmpty();
      }
      rethrow;
    }
  }

  @override
  Future<List<StepRecord>> getHourlyBreakdown(DateTime date) async {
    // Hourly breakdown is not cached - always fetch from remote
    // If offline, this will throw an appropriate exception
    final models = await _remoteDataSource.getHourlyBreakdown(date);

    // Convert models to domain entities
    return models.map((model) => _toStepRecord(model)).toList();
  }

  @override
  Future<StepRecord> recordSteps(int stepCount, String source) async {
    // Recording steps requires network connectivity
    // If offline, this will throw an appropriate exception
    final model = await _remoteDataSource.recordSteps(stepCount, source);

    // Invalidate cache since data has changed
    await _localDataSource.clearCache();

    // Return domain entity
    return _toStepRecord(model);
  }

  @override
  Future<void> syncSteps() async {
    try {
      // Fetch fresh data from remote to update cache
      final stats = await _remoteDataSource.getTodayStats();
      final trends = await _remoteDataSource.getWeeklyTrend();

      // Clear old cache and store fresh data
      await _localDataSource.clearCache();
      await _localDataSource.cacheStats(stats);
      await _localDataSource.cacheWeeklyTrend(trends);
    } on NetworkException {
      // If offline, sync fails silently
      // The next sync attempt will succeed when online
      return;
    } on ServerException {
      // If server error, sync fails silently
      // Don't clear cache on failure
      return;
    }
  }

  // ============================================
  // Private Helper Methods
  // ============================================

  /// Caches stats without throwing on failure.
  Future<void> _cacheStatsQuietly(StepStatsModel stats) async {
    try {
      await _localDataSource.cacheStats(stats);
    } catch (_) {
      // Ignore cache errors - don't fail the request
    }
  }

  /// Caches weekly trend without throwing on failure.
  Future<void> _cacheWeeklyTrendQuietly(List<WeeklyTrendModel> trends) async {
    try {
      await _localDataSource.cacheWeeklyTrend(trends);
    } catch (_) {
      // Ignore cache errors - don't fail the request
    }
  }

  /// Gets cached stats or throws [CacheException] if not available.
  Future<StepStats> _getCachedStatsOrThrow() async {
    final cachedStats = await _localDataSource.getCachedStats();
    if (cachedStats != null) {
      return cachedStats;
    }

    // No cached data available
    throw const CacheException(
      message: 'No step statistics available offline',
      operation: CacheOperation.read,
    );
  }

  /// Gets cached weekly trend or returns empty list.
  Future<List<WeeklyTrendModel>> _getCachedWeeklyTrendOrEmpty() async {
    final cachedTrend = await _localDataSource.getCachedWeeklyTrend();
    return cachedTrend ?? [];
  }

  /// Converts [StepModel] to domain entity [StepRecord].
  StepRecord _toStepRecord(StepModel model) {
    return StepRecord(
      id: model.id,
      userId: model.userId,
      stepCount: model.stepCount,
      recordedAt: model.recordedAt,
      source: model.source,
    );
  }

  /// Checks if the server exception is connectivity-related.
  bool _isConnectivityError(ServerException exception) {
    final statusCode = exception.statusCode;
    if (statusCode == null) return true; // No status = likely network issue

    // Consider timeout and gateway errors as connectivity issues
    return statusCode == 408 || // Request Timeout
        statusCode == 502 || // Bad Gateway
        statusCode == 503 || // Service Unavailable
        statusCode == 504; // Gateway Timeout
  }
}
