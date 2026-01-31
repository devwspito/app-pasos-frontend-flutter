/// Steps repository implementation with offline support.
///
/// This file implements the [StepsRepository] interface, coordinating
/// data operations through the remote datasource with Hive cache support
/// and offline operation queuing.
library;

import 'package:app_pasos_frontend/core/services/connectivity_service.dart';
import 'package:app_pasos_frontend/core/storage/boxes/steps_box.dart';
import 'package:app_pasos_frontend/core/storage/sync_queue.dart';
import 'package:app_pasos_frontend/features/dashboard/data/datasources/steps_remote_datasource.dart';
import 'package:app_pasos_frontend/features/dashboard/data/models/step_record_model.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/hourly_peak.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_record.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_stats.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/weekly_trend.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/repositories/steps_repository.dart';

/// Implementation of [StepsRepository] with offline-first capabilities.
///
/// This class implements the steps business logic with:
/// - Cache-first strategy: Read from Hive cache, then fetch from API
/// - Offline operation queuing: Queue write operations when offline
/// - Optimistic responses: Return local data when offline
///
/// Example usage:
/// ```dart
/// final repository = StepsRepositoryImpl(
///   datasource: stepsDatasource,
///   stepsBox: stepsBox,
///   syncQueue: syncQueue,
///   connectivity: connectivityService,
/// );
///
/// final record = await repository.recordSteps(
///   count: 1500,
///   source: StepSource.native,
/// );
/// ```
class StepsRepositoryImpl implements StepsRepository {
  /// Creates a [StepsRepositoryImpl] with the required dependencies.
  ///
  /// [datasource] - The remote datasource for API calls.
  /// [stepsBox] - The Hive box for caching step records.
  /// [syncQueue] - The queue for offline operations.
  /// [connectivity] - Service for monitoring network status.
  StepsRepositoryImpl({
    required StepsRemoteDatasource datasource,
    required StepsBox stepsBox,
    required SyncQueue syncQueue,
    required ConnectivityService connectivity,
  })  : _datasource = datasource,
        _stepsBox = stepsBox,
        _syncQueue = syncQueue,
        _connectivity = connectivity;

  /// The remote datasource for API operations.
  final StepsRemoteDatasource _datasource;

  /// The Hive box for caching step records.
  final StepsBox _stepsBox;

  /// The sync queue for offline operation queuing.
  final SyncQueue _syncQueue;

  /// The connectivity service for monitoring network status.
  final ConnectivityService _connectivity;

  /// Key for storing today's steps in cache.
  String get _todayDateKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<StepRecord> recordSteps({
    required int count,
    required StepSource source,
  }) async {
    final isOnline = await _connectivity.isConnected;

    if (isOnline) {
      try {
        // Online: send to API and cache the result
        final record = await _datasource.recordSteps(
          count: count,
          source: source,
        );
        await _cacheStepRecord(record);
        return record;
      } catch (e) {
        // If API call fails, fall back to offline behavior
        return _handleOfflineRecordSteps(count, source);
      }
    } else {
      // Offline: queue for sync and return optimistic result
      return _handleOfflineRecordSteps(count, source);
    }
  }

  /// Handles recording steps when offline by queuing the operation.
  Future<StepRecord> _handleOfflineRecordSteps(
    int count,
    StepSource source,
  ) async {
    final operationId = 'step-${DateTime.now().millisecondsSinceEpoch}';
    final operation = SyncOperation(
      id: operationId,
      type: SyncOperationType.createStep,
      payload: {
        'count': count,
        'source': _sourceToString(source),
      },
      timestamp: DateTime.now(),
      retryCount: 0,
      status: SyncOperationStatus.pending,
    );
    await _syncQueue.enqueue(operation);

    // Return optimistic local record
    return _createOptimisticRecord(count, source);
  }

  /// Creates an optimistic local record for offline scenarios.
  StepRecord _createOptimisticRecord(int count, StepSource source) {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return StepRecordModel(
      id: 'local-${now.millisecondsSinceEpoch}',
      userId: 'local-user',
      count: count,
      source: source,
      date: dateStr,
      hour: now.hour,
      timestamp: now,
    );
  }

  /// Caches a step record in Hive storage.
  Future<void> _cacheStepRecord(StepRecord record) async {
    await _stepsBox.saveStepRecord(_todayDateKey, {
      'id': record.id,
      'userId': record.userId,
      'count': record.count,
      'source': _sourceToString(record.source),
      'hour': record.hour,
      'timestamp': record.timestamp.toIso8601String(),
      'lastFetched': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<int> getTodaySteps() async {
    // 1. Try to get from Hive cache first
    final cached = _stepsBox.getStepRecord(_todayDateKey);
    if (cached != null) {
      final totalSteps = cached['totalSteps'] as int? ?? cached['count'] as int? ?? 0;

      // Fire and forget: refresh from API in background
      _refreshTodayStepsFromApi();

      return totalSteps;
    }

    // 2. If no cache, try to fetch from API
    final isOnline = await _connectivity.isConnected;
    if (isOnline) {
      try {
        final steps = await _datasource.getTodaySteps();
        // Cache the result
        await _stepsBox.saveStepRecord(_todayDateKey, {
          'totalSteps': steps,
          'lastFetched': DateTime.now().toIso8601String(),
        });
        return steps;
      } catch (e) {
        // API failed, return 0 as default
        return 0;
      }
    }

    // 3. Offline and no cache - return 0
    return 0;
  }

  /// Refreshes today's steps from API in the background (fire and forget).
  Future<void> _refreshTodayStepsFromApi() async {
    try {
      final isOnline = await _connectivity.isConnected;
      if (!isOnline) return;

      final steps = await _datasource.getTodaySteps();
      await _stepsBox.saveStepRecord(_todayDateKey, {
        'totalSteps': steps,
        'lastFetched': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silently fail - this is a background refresh
    }
  }

  @override
  Future<List<WeeklyTrend>> getWeeklyTrend() async {
    // For weekly trend, we prioritize fresh data from API
    // Cache is used as fallback when offline
    final isOnline = await _connectivity.isConnected;

    if (isOnline) {
      try {
        return await _datasource.getWeeklyTrend();
      } catch (e) {
        // Fallback to empty list on error
        return [];
      }
    }

    // Offline - return empty list (could implement caching later)
    return [];
  }

  @override
  Future<StepStats> getStats() async {
    // For stats, we prioritize fresh data from API
    // Cache is used as fallback when offline
    final isOnline = await _connectivity.isConnected;

    if (isOnline) {
      try {
        return await _datasource.getStats();
      } catch (e) {
        // Return default stats on error
        return _createDefaultStats();
      }
    }

    // Offline - return default stats
    return _createDefaultStats();
  }

  /// Creates default stats when offline or on error.
  StepStats _createDefaultStats() {
    return const _DefaultStepStats(
      today: 0,
      week: 0,
      month: 0,
      allTime: 0,
    );
  }

  @override
  Future<List<HourlyPeak>> getHourlyPeaks({String? date}) async {
    // For hourly peaks, we prioritize fresh data from API
    final isOnline = await _connectivity.isConnected;

    if (isOnline) {
      try {
        return await _datasource.getHourlyPeaks(date: date);
      } catch (e) {
        return [];
      }
    }

    // Offline - return empty list
    return [];
  }

  /// Converts a [StepSource] to its string representation.
  String _sourceToString(StepSource source) {
    return switch (source) {
      StepSource.native => 'native',
      StepSource.manual => 'manual',
      StepSource.web => 'web',
    };
  }
}

/// Default implementation of [StepStats] for offline scenarios.
class _DefaultStepStats implements StepStats {
  const _DefaultStepStats({
    required this.today,
    required this.week,
    required this.month,
    required this.allTime,
  });

  @override
  final int today;

  @override
  final int week;

  @override
  final int month;

  @override
  final int allTime;

  @override
  bool get isEmpty => today == 0 && week == 0 && month == 0 && allTime == 0;

  @override
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [today, week, month, allTime];

  @override
  bool? get stringify => true;
}
