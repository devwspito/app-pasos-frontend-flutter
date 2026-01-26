import 'dart:async';

import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/step_record.dart';
import '../../domain/repositories/steps_repository.dart';
import '../datasources/steps_local_datasource.dart';
import '../datasources/steps_remote_datasource.dart';
import '../models/step_model.dart';

/// Implementation of [StepsRepository] with API integration, caching, and error handling.
///
/// This repository implements a cache-first strategy with network fallback.
/// When online, it fetches from the API and caches the response.
/// When offline or on error, it falls back to cached data.
///
/// Features:
/// - Cache-first strategy for optimal performance
/// - Automatic network fallback on errors
/// - Offline support with pending sync queue
/// - Real-time updates via streams
///
/// Example usage:
/// ```dart
/// final repo = StepsRepositoryImpl(
///   remoteDataSource: StepsRemoteDataSourceImpl(),
///   localDataSource: StepsLocalDataSourceImpl(prefs: prefs),
///   networkInfo: NetworkInfoImpl(),
/// );
///
/// // Get today's steps (cache-first)
/// final steps = await repo.getTodaySteps();
///
/// // Watch for real-time updates
/// repo.watchSteps().listen((records) => print(records));
/// ```
class StepsRepositoryImpl implements StepsRepository {
  final StepsRemoteDataSource _remoteDataSource;
  final StepsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  /// Cache keys for step data
  static const String _weeklyKey = 'cached_weekly_steps';
  static const String _monthlyKey = 'cached_monthly_steps';

  /// Creates a [StepsRepositoryImpl] instance.
  ///
  /// All parameters are required:
  /// - [remoteDataSource] - Handles API communication
  /// - [localDataSource] - Handles local caching
  /// - [networkInfo] - Provides network connectivity status
  StepsRepositoryImpl({
    required StepsRemoteDataSource remoteDataSource,
    required StepsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<StepRecord?> getTodaySteps() async {
    try {
      // Check network connectivity
      if (await _networkInfo.isConnected) {
        try {
          // Fetch from API
          final model = await _remoteDataSource.getTodaySteps();
          if (model != null) {
            // Cache successful response
            await _localDataSource.cacheTodaySteps(model);
            return model.toEntity();
          }
        } catch (e) {
          // Log error and fall through to cache
          Logger.error('Failed to fetch today steps from API', error: e);
        }
      }

      // Fallback to cache (offline or API error)
      final cached = await _localDataSource.getCachedTodaySteps();
      return cached?.toEntity();
    } catch (e) {
      // Last resort: try to return cached data
      Logger.error('Error getting today steps', error: e);
      try {
        final cached = await _localDataSource.getCachedTodaySteps();
        return cached?.toEntity();
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<List<StepRecord>> getStepsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Generate cache key based on date range
      final cacheKey =
          'steps_range_${startDate.toIso8601String().split('T').first}_${endDate.toIso8601String().split('T').first}';

      if (await _networkInfo.isConnected) {
        try {
          final models = await _remoteDataSource.getStepsInRange(
            startDate: startDate,
            endDate: endDate,
          );

          // Cache the response
          if (models.isNotEmpty) {
            await _localDataSource.cacheSteps(models, cacheKey);
          }

          return models.map((m) => m.toEntity()).toList();
        } catch (e) {
          Logger.error('Failed to fetch steps range from API', error: e);
        }
      }

      // Fallback to cache
      final cached = await _localDataSource.getCachedSteps(cacheKey);
      return cached.map((m) => m.toEntity()).toList();
    } catch (e) {
      Logger.error('Error getting steps in range', error: e);
      return [];
    }
  }

  @override
  Future<List<StepRecord>> getWeeklySteps() async {
    try {
      if (await _networkInfo.isConnected) {
        try {
          final models = await _remoteDataSource.getWeeklySteps();

          // Cache the response
          if (models.isNotEmpty) {
            await _localDataSource.cacheSteps(models, _weeklyKey);
          }

          return models.map((m) => m.toEntity()).toList();
        } catch (e) {
          Logger.error('Failed to fetch weekly steps from API', error: e);
        }
      }

      // Fallback to cache
      final cached = await _localDataSource.getCachedSteps(_weeklyKey);
      return cached.map((m) => m.toEntity()).toList();
    } catch (e) {
      Logger.error('Error getting weekly steps', error: e);
      return [];
    }
  }

  @override
  Future<List<StepRecord>> getMonthlySteps() async {
    try {
      if (await _networkInfo.isConnected) {
        try {
          final models = await _remoteDataSource.getMonthlySteps();

          // Cache the response
          if (models.isNotEmpty) {
            await _localDataSource.cacheSteps(models, _monthlyKey);
          }

          return models.map((m) => m.toEntity()).toList();
        } catch (e) {
          Logger.error('Failed to fetch monthly steps from API', error: e);
        }
      }

      // Fallback to cache
      final cached = await _localDataSource.getCachedSteps(_monthlyKey);
      return cached.map((m) => m.toEntity()).toList();
    } catch (e) {
      Logger.error('Error getting monthly steps', error: e);
      return [];
    }
  }

  @override
  Future<StepRecord> saveStepRecord(StepRecord stepRecord) async {
    final model = StepModel.fromEntity(stepRecord);

    try {
      if (await _networkInfo.isConnected) {
        try {
          // Save to API
          final savedModel = await _remoteDataSource.saveStepRecord(model);

          // Cache the response
          await _localDataSource.cacheTodaySteps(savedModel);

          return savedModel.toEntity();
        } catch (e) {
          Logger.error('Failed to save step record to API, saving locally',
              error: e);
        }
      }

      // Offline or API error: save locally with pending sync flag
      final localModel = await _localDataSource.saveLocalStepRecord(model);
      return localModel.toEntity();
    } catch (e) {
      Logger.error('Error saving step record', error: e);

      // Last resort: save locally
      final localModel = await _localDataSource.saveLocalStepRecord(model);
      return localModel.toEntity();
    }
  }

  @override
  Future<int> syncPendingRecords() async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        Logger.info('Cannot sync: no network connection');
        return 0;
      }

      // Get pending records
      final pendingRecords = await _localDataSource.getPendingSyncRecords();
      if (pendingRecords.isEmpty) {
        Logger.info('No pending records to sync');
        return 0;
      }

      // Sync to server
      final syncedCount = await _remoteDataSource.syncRecords(pendingRecords);

      // Mark records as synced
      if (syncedCount > 0) {
        final syncedIds = pendingRecords.take(syncedCount).map((r) => r.id).toList();
        await _localDataSource.markRecordsAsSynced(syncedIds);
        Logger.info('Successfully synced $syncedCount records');
      }

      return syncedCount;
    } catch (e) {
      Logger.error('Error syncing pending records', error: e);
      return 0;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _localDataSource.clearCache();
      Logger.info('Step cache cleared');
    } catch (e) {
      Logger.error('Error clearing cache', error: e);
    }
  }

  @override
  Stream<List<StepRecord>> watchSteps() {
    return _localDataSource.watchLocalSteps().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }
}
