/// Background sync service implementation for periodic data synchronization.
///
/// This file provides the concrete implementation of [BackgroundSyncService]
/// using the workmanager package for platform-specific background task execution.
library;

import 'package:app_pasos_frontend/core/services/background_sync_service.dart';
import 'package:app_pasos_frontend/core/storage/secure_storage_service.dart';
import 'package:app_pasos_frontend/core/workers/step_sync_worker.dart';
import 'package:workmanager/workmanager.dart';

/// Storage keys for background sync state persistence.
///
/// These keys are used to store sync configuration in secure storage
/// to maintain state across app restarts.
class _BackgroundSyncStorageKeys {
  /// Key for storing whether background sync is enabled.
  static const String syncEnabled = 'background_sync_enabled';

  /// Key for storing the timestamp of the last successful sync.
  static const String lastSyncTime = 'background_sync_last_time';
}

/// Implementation of [BackgroundSyncService] using the workmanager package.
///
/// This implementation provides background sync capabilities through:
/// - Android: WorkManager for reliable background task scheduling
/// - iOS: BGTaskScheduler for background app refresh
///
/// The service persists its state using [SecureStorageService] to maintain
/// sync preferences and history across app restarts.
///
/// Example usage:
/// ```dart
/// final storage = SecureStorageServiceImpl();
/// final syncService = BackgroundSyncServiceImpl(storageService: storage);
/// await syncService.initialize();
/// await syncService.startPeriodicSync(interval: Duration(hours: 1));
///
/// // Check status
/// final isEnabled = await syncService.isSyncEnabled();
/// final lastSync = await syncService.getLastSyncTime();
/// print('Sync enabled: $isEnabled, last sync: $lastSync');
///
/// // Stop when no longer needed
/// await syncService.stopPeriodicSync();
/// ```
class BackgroundSyncServiceImpl implements BackgroundSyncService {
  /// Creates a [BackgroundSyncServiceImpl] instance.
  ///
  /// [workmanager] - Optional Workmanager instance for testing.
  /// [storageService] - Required [SecureStorageService] for state persistence.
  BackgroundSyncServiceImpl({
    Workmanager? workmanager,
    required SecureStorageService storageService,
  })  : _workmanager = workmanager ?? Workmanager(),
        _storageService = storageService;

  /// The underlying workmanager instance for scheduling background tasks.
  final Workmanager _workmanager;

  /// The secure storage service for persisting sync state.
  final SecureStorageService _storageService;

  /// Tracks whether the service has been initialized.
  bool _isInitialized = false;

  /// Minimum sync interval enforced by platform limitations.
  ///
  /// Both Android WorkManager and iOS BGTaskScheduler have minimum
  /// intervals of approximately 15 minutes for periodic tasks.
  static const Duration _minimumInterval = Duration(minutes: 15);

  // ============================================================
  // Initialization
  // ============================================================

  @override
  Future<void> initialize() async {
    // Idempotent - skip if already initialized
    if (_isInitialized) {
      return;
    }

    try {
      // Initialize workmanager with the callback dispatcher from step_sync_worker
      await _workmanager.initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );

      _isInitialized = true;
    } catch (e) {
      // Re-throw with more context for debugging
      throw Exception('Failed to initialize background sync service: $e');
    }
  }

  // ============================================================
  // Periodic Sync Management
  // ============================================================

  @override
  Future<void> startPeriodicSync({required Duration interval}) async {
    // Ensure service is initialized
    if (!_isInitialized) {
      throw StateError(
        'BackgroundSyncService must be initialized before starting sync. '
        'Call initialize() first.',
      );
    }

    // Enforce minimum interval
    final effectiveInterval = interval < _minimumInterval
        ? _minimumInterval
        : interval;

    try {
      // Cancel any existing task first to avoid duplicates
      await _workmanager.cancelByUniqueName(stepSyncTaskName);

      // Register periodic task with workmanager
      await _workmanager.registerPeriodicTask(
        stepSyncTaskName,
        stepSyncTaskName,
        frequency: effectiveInterval,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 1),
      );

      // Persist enabled state
      await _storageService.write(
        _BackgroundSyncStorageKeys.syncEnabled,
        'true',
      );
    } catch (e) {
      throw Exception('Failed to start periodic sync: $e');
    }
  }

  @override
  Future<void> stopPeriodicSync() async {
    try {
      // Cancel the registered task
      await _workmanager.cancelByUniqueName(stepSyncTaskName);

      // Update persisted state
      await _storageService.write(
        _BackgroundSyncStorageKeys.syncEnabled,
        'false',
      );
    } catch (e) {
      // Log but don't throw - stopping should be safe to call anytime
      // In production, use proper logging
    }
  }

  // ============================================================
  // Sync Status
  // ============================================================

  @override
  Future<bool> isSyncEnabled() async {
    try {
      final enabledStr = await _storageService.read(
        _BackgroundSyncStorageKeys.syncEnabled,
      );
      return enabledStr == 'true';
    } catch (e) {
      // If reading fails, assume sync is disabled
      return false;
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final timestampStr = await _storageService.read(
        _BackgroundSyncStorageKeys.lastSyncTime,
      );

      if (timestampStr == null || timestampStr.isEmpty) {
        return null;
      }

      // Parse the stored timestamp
      final timestamp = int.tryParse(timestampStr);
      if (timestamp == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      // If reading fails, return null
      return null;
    }
  }

  // ============================================================
  // Internal Helpers (for use by workers)
  // ============================================================

  /// Updates the last sync time to the current time.
  ///
  /// This method is intended to be called by the background worker
  /// after a successful sync operation.
  ///
  /// Note: This is a static method that accepts the storage service
  /// because background workers run in a separate isolate and need
  /// to reinitialize dependencies.
  static Future<void> updateLastSyncTime(
    SecureStorageService storageService,
  ) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch.toString();
      await storageService.write(
        _BackgroundSyncStorageKeys.lastSyncTime,
        now,
      );
    } catch (e) {
      // Log but don't throw - updating timestamp shouldn't break sync
    }
  }
}
