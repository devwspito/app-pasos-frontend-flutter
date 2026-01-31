/// Sync service for processing offline operations when online.
///
/// This file provides the interface and implementation for synchronizing
/// queued operations with the backend. Uses exponential backoff for retries
/// and server-timestamp-wins strategy for conflict resolution.
library;

import 'dart:async';

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/core/network/api_client.dart';
import 'package:app_pasos_frontend/core/network/api_endpoints.dart';
import 'package:app_pasos_frontend/core/services/connectivity_service.dart';
import 'package:app_pasos_frontend/core/storage/sync_queue.dart';

/// Status of the sync service.
///
/// Represents the current synchronization state.
enum SyncStatus {
  /// No sync operation in progress.
  idle,

  /// Currently syncing operations with the backend.
  syncing,

  /// An error occurred during sync.
  error,

  /// Device is offline, sync cannot proceed.
  offline,
}

/// Abstract interface for sync service operations.
///
/// This interface enables dependency injection and testing by allowing
/// mock implementations. All sync orchestration should go through
/// this service.
///
/// The sync service handles:
/// - Listening for connectivity changes
/// - Processing queued operations when online
/// - Retry logic with exponential backoff
/// - Conflict resolution using server-timestamp-wins strategy
///
/// Example usage:
/// ```dart
/// final syncService = SyncServiceImpl(
///   syncQueue: syncQueue,
///   connectivityService: connectivityService,
///   apiClient: apiClient,
/// );
/// await syncService.initialize();
///
/// // Listen for status changes
/// syncService.onSyncStatusChanged.listen((status) {
///   print('Sync status: $status');
/// });
///
/// // Listen for user messages
/// syncService.onSyncMessage.listen((message) {
///   showSnackBar(message);
/// });
///
/// // Manually trigger sync if needed
/// await syncService.startSync();
///
/// // Later, when no longer needed
/// syncService.dispose();
/// ```
abstract interface class SyncService {
  /// Initializes the sync service.
  ///
  /// This method must be called before any other sync operations.
  /// It sets up connectivity listeners and checks initial state.
  ///
  /// This method is idempotent - calling it multiple times has no
  /// additional effect after the first successful initialization.
  Future<void> initialize();

  /// Starts processing the sync queue.
  ///
  /// Processes all pending operations in the queue, syncing them
  /// with the backend. Uses exponential backoff for failed operations.
  ///
  /// This method is safe to call even if a sync is already in progress;
  /// it will simply return without starting a new sync.
  ///
  /// Throws no exceptions - errors are reported via [onSyncMessage]
  /// and [onSyncStatusChanged].
  Future<void> startSync();

  /// Stops the current sync operation.
  ///
  /// If a sync is in progress, it will be stopped after the current
  /// operation completes. Already completed operations are not rolled back.
  ///
  /// This method is safe to call even if no sync is in progress.
  Future<void> stopSync();

  /// Stream of sync status changes.
  ///
  /// Emits a new [SyncStatus] whenever the sync state changes.
  /// The stream is broadcast, allowing multiple listeners.
  ///
  /// Typical status flow:
  /// 1. [SyncStatus.idle] → Initial state
  /// 2. [SyncStatus.syncing] → When sync starts
  /// 3. [SyncStatus.idle] → When sync completes successfully
  /// Or: [SyncStatus.error] → When sync fails after all retries
  /// Or: [SyncStatus.offline] → When connectivity is lost
  Stream<SyncStatus> get onSyncStatusChanged;

  /// Stream of user-friendly sync messages.
  ///
  /// Emits messages that can be displayed to the user, such as:
  /// - 'Syncing...'
  /// - 'Sync complete'
  /// - 'Sync failed: reason'
  /// - '3 operations synced'
  ///
  /// The stream is broadcast, allowing multiple listeners.
  Stream<String> get onSyncMessage;

  /// Gets the current sync status.
  ///
  /// Returns the most recent [SyncStatus].
  SyncStatus get currentStatus;

  /// Whether a sync operation is currently in progress.
  ///
  /// Returns `true` if [currentStatus] is [SyncStatus.syncing].
  bool get isSyncing;

  /// Disposes resources used by the sync service.
  ///
  /// Stops any ongoing sync, cancels the connectivity subscription,
  /// and closes stream controllers. After calling this, the service
  /// should not be used anymore.
  void dispose();
}

/// Implementation of [SyncService] with backoff and conflict resolution.
///
/// This implementation:
/// - Listens to [ConnectivityService.onConnectivityChanged]
/// - Automatically starts sync when connectivity is restored
/// - Processes operations from [SyncQueue] in FIFO order
/// - Uses exponential backoff delays: 1s, 2s, 4s
/// - Max 3 retries before marking operation as permanently failed
/// - Server-timestamp-wins conflict resolution (409 or newer server data)
///
/// Example usage:
/// ```dart
/// final syncService = SyncServiceImpl(
///   syncQueue: syncQueue,
///   connectivityService: connectivityService,
///   apiClient: apiClient,
/// );
/// await syncService.initialize();
///
/// // Sync will start automatically when connectivity is detected
/// // Or manually trigger:
/// await syncService.startSync();
///
/// // Listen for updates
/// syncService.onSyncMessage.listen((msg) => showSnackBar(msg));
/// syncService.onSyncStatusChanged.listen((status) => updateUI(status));
/// ```
class SyncServiceImpl implements SyncService {
  /// Creates a [SyncServiceImpl] instance.
  ///
  /// [syncQueue] - Queue of pending operations to sync.
  /// [connectivityService] - Service for monitoring connectivity.
  /// [apiClient] - Client for making API requests.
  SyncServiceImpl({
    required SyncQueue syncQueue,
    required ConnectivityService connectivityService,
    required ApiClient apiClient,
  })  : _syncQueue = syncQueue,
        _connectivityService = connectivityService,
        _apiClient = apiClient;

  /// The sync queue containing pending operations.
  final SyncQueue _syncQueue;

  /// The connectivity service for monitoring network status.
  final ConnectivityService _connectivityService;

  /// The API client for making network requests.
  final ApiClient _apiClient;

  /// Subscription to connectivity changes.
  StreamSubscription<bool>? _connectivitySubscription;

  /// Stream controller for sync status changes.
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  /// Stream controller for user-friendly messages.
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  /// Current sync status.
  SyncStatus _currentStatus = SyncStatus.idle;

  /// Whether the service has been initialized.
  bool _isInitialized = false;

  /// Flag to stop ongoing sync.
  bool _shouldStopSync = false;

  /// Maximum number of retries per operation.
  static const int _maxRetries = 3;

  /// Exponential backoff delays in seconds.
  static const List<int> _backoffDelays = [1, 2, 4];

  // ============================================================
  // Stream Access
  // ============================================================

  @override
  Stream<SyncStatus> get onSyncStatusChanged => _statusController.stream;

  @override
  Stream<String> get onSyncMessage => _messageController.stream;

  @override
  SyncStatus get currentStatus => _currentStatus;

  @override
  bool get isSyncing => _currentStatus == SyncStatus.syncing;

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
      // Check initial connectivity status
      final isConnected = await _connectivityService.isConnected;

      if (!isConnected) {
        _updateStatus(SyncStatus.offline);
      }

      // Subscribe to connectivity changes
      _connectivitySubscription = _connectivityService.onConnectivityChanged
          .listen(_onConnectivityChanged);

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize sync service: $e');
    }
  }

  // ============================================================
  // Sync Control
  // ============================================================

  @override
  Future<void> startSync() async {
    // Don't start if already syncing
    if (isSyncing) {
      return;
    }

    // Check connectivity first
    final isConnected = await _connectivityService.isConnected;
    if (!isConnected) {
      _updateStatus(SyncStatus.offline);
      _emitMessage('Cannot sync: offline');
      return;
    }

    _shouldStopSync = false;
    await _processQueue();
  }

  @override
  Future<void> stopSync() async {
    _shouldStopSync = true;
  }

  @override
  void dispose() {
    _shouldStopSync = true;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _statusController.close();
    _messageController.close();
    _isInitialized = false;
  }

  // ============================================================
  // Connectivity Handling
  // ============================================================

  /// Handles connectivity changes from the connectivity service.
  void _onConnectivityChanged(bool isConnected) {
    if (isConnected) {
      // Connectivity restored - start sync automatically
      _updateStatus(SyncStatus.idle);
      startSync();
    } else {
      // Connectivity lost - update status
      _shouldStopSync = true;
      _updateStatus(SyncStatus.offline);
      _emitMessage('Offline - changes will sync when online');
    }
  }

  // ============================================================
  // Queue Processing
  // ============================================================

  /// Processes all pending operations in the queue.
  Future<void> _processQueue() async {
    _updateStatus(SyncStatus.syncing);
    _emitMessage('Syncing...');

    var syncedCount = 0;
    var failedCount = 0;

    while (!_shouldStopSync) {
      // Check connectivity before each operation
      final isConnected = await _connectivityService.isConnected;
      if (!isConnected) {
        _updateStatus(SyncStatus.offline);
        _emitMessage('Sync paused: offline');
        return;
      }

      // Get next operation from queue
      final operation = await _syncQueue.dequeue();
      if (operation == null) {
        // Queue is empty
        break;
      }

      // Process the operation with retries
      final success = await _processOperationWithRetry(operation);

      if (success) {
        syncedCount++;
      } else {
        failedCount++;
      }
    }

    // Update final status
    if (_shouldStopSync) {
      _updateStatus(SyncStatus.idle);
      _emitMessage('Sync stopped');
    } else if (failedCount > 0) {
      _updateStatus(SyncStatus.error);
      _emitMessage('Sync complete with errors: $failedCount failed');
    } else if (syncedCount > 0) {
      _updateStatus(SyncStatus.idle);
      _emitMessage('Sync complete: $syncedCount synced');
    } else {
      _updateStatus(SyncStatus.idle);
      _emitMessage('Nothing to sync');
    }
  }

  /// Processes a single operation with exponential backoff retry.
  ///
  /// Returns `true` if operation succeeded, `false` if it failed permanently.
  Future<bool> _processOperationWithRetry(SyncOperation operation) async {
    var currentRetry = operation.retryCount;

    while (currentRetry < _maxRetries) {
      try {
        // Attempt to sync the operation
        final result = await _syncOperation(operation);

        if (result.isSuccess) {
          // Mark as completed and remove from queue
          await _syncQueue.markCompleted(operation.id);
          return true;
        }

        if (result.isConflict) {
          // Server has newer data - discard local change
          await _syncQueue.markCompleted(operation.id);
          _emitMessage('Conflict resolved: server data kept');
          return true;
        }

        // Transient error - increment retry and apply backoff
        currentRetry++;
        await _syncQueue.incrementRetry(operation.id);

        if (currentRetry < _maxRetries) {
          // Wait with exponential backoff
          final delaySeconds = _backoffDelays[currentRetry - 1];
          await Future<void>.delayed(Duration(seconds: delaySeconds));
        }
      } on NetworkException {
        // Network error - stop retrying, will resume when online
        return false;
      } catch (e) {
        // Unknown error - increment retry
        currentRetry++;
        await _syncQueue.incrementRetry(operation.id);

        if (currentRetry < _maxRetries) {
          final delaySeconds = _backoffDelays[currentRetry - 1];
          await Future<void>.delayed(Duration(seconds: delaySeconds));
        }
      }
    }

    // Exceeded max retries - mark as permanently failed
    await _syncQueue.markFailed(operation.id);
    return false;
  }

  /// Syncs a single operation with the backend.
  ///
  /// Returns a [_SyncResult] indicating success, failure, or conflict.
  Future<_SyncResult> _syncOperation(SyncOperation operation) async {
    try {
      switch (operation.type) {
        case SyncOperationType.createStep:
          return _syncCreateStep(operation);

        case SyncOperationType.updateStep:
          return _syncUpdateStep(operation);

        case SyncOperationType.createGoal:
          return _syncCreateGoal(operation);

        case SyncOperationType.updateGoal:
          return _syncUpdateGoal(operation);

        case SyncOperationType.updateProfile:
          return _syncUpdateProfile(operation);
      }
    } on ServerException catch (e) {
      // Check for conflict (409)
      if (e.statusCode == 409) {
        return _SyncResult.conflict();
      }
      return _SyncResult.failure(e.message);
    } on AppException catch (e) {
      return _SyncResult.failure(e.message);
    }
  }

  /// Syncs a create step operation.
  Future<_SyncResult> _syncCreateStep(SyncOperation operation) async {
    final payload = operation.payload;

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.stepsRecord,
      data: {
        'count': payload['count'],
        'source': payload['source'] ?? 'native',
      },
    );

    // Check for conflict via server timestamp
    if (_hasServerConflict(operation, response.data)) {
      return _SyncResult.conflict();
    }

    return _SyncResult.success();
  }

  /// Syncs an update step operation.
  Future<_SyncResult> _syncUpdateStep(SyncOperation operation) async {
    final payload = operation.payload;
    final stepId = payload['id'] as String?;

    if (stepId == null) {
      return _SyncResult.failure('Missing step ID');
    }

    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiEndpoints.step}/$stepId',
      data: {
        'count': payload['count'],
        if (payload.containsKey('distance')) 'distance': payload['distance'],
        if (payload.containsKey('calories')) 'calories': payload['calories'],
      },
    );

    // Check for conflict via server timestamp
    if (_hasServerConflict(operation, response.data)) {
      return _SyncResult.conflict();
    }

    return _SyncResult.success();
  }

  /// Syncs a create goal operation.
  Future<_SyncResult> _syncCreateGoal(SyncOperation operation) async {
    final payload = operation.payload;

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.goals,
      data: {
        'name': payload['name'],
        'target': payload['target'],
        if (payload.containsKey('unit')) 'unit': payload['unit'],
        if (payload.containsKey('startDate')) 'startDate': payload['startDate'],
        if (payload.containsKey('endDate')) 'endDate': payload['endDate'],
      },
    );

    // Check for conflict via server timestamp
    if (_hasServerConflict(operation, response.data)) {
      return _SyncResult.conflict();
    }

    return _SyncResult.success();
  }

  /// Syncs an update goal operation.
  Future<_SyncResult> _syncUpdateGoal(SyncOperation operation) async {
    final payload = operation.payload;
    final goalId = payload['id'] as String?;

    if (goalId == null) {
      return _SyncResult.failure('Missing goal ID');
    }

    final endpoint = ApiEndpoints.withParams(
      ApiEndpoints.goalDetails,
      {'id': goalId},
    );

    final response = await _apiClient.put<Map<String, dynamic>>(
      endpoint,
      data: {
        if (payload.containsKey('name')) 'name': payload['name'],
        if (payload.containsKey('target')) 'target': payload['target'],
        if (payload.containsKey('unit')) 'unit': payload['unit'],
      },
    );

    // Check for conflict via server timestamp
    if (_hasServerConflict(operation, response.data)) {
      return _SyncResult.conflict();
    }

    return _SyncResult.success();
  }

  /// Syncs an update profile operation.
  Future<_SyncResult> _syncUpdateProfile(SyncOperation operation) async {
    final payload = operation.payload;

    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateProfile,
      data: {
        if (payload.containsKey('name')) 'name': payload['name'],
        if (payload.containsKey('email')) 'email': payload['email'],
        if (payload.containsKey('settings')) 'settings': payload['settings'],
      },
    );

    // Check for conflict via server timestamp
    if (_hasServerConflict(operation, response.data)) {
      return _SyncResult.conflict();
    }

    return _SyncResult.success();
  }

  /// Checks if there's a conflict based on server timestamp.
  ///
  /// Server-timestamp-wins strategy:
  /// If server's `updatedAt` is newer than local `timestamp`, discard local.
  bool _hasServerConflict(
    SyncOperation operation,
    Map<String, dynamic>? responseData,
  ) {
    if (responseData == null) {
      return false;
    }

    // Extract server timestamp from response
    // Handle both nested and flat response formats
    final data = responseData['data'] as Map<String, dynamic>? ??
        responseData['step'] as Map<String, dynamic>? ??
        responseData['goal'] as Map<String, dynamic>? ??
        responseData['user'] as Map<String, dynamic>? ??
        responseData;

    final serverUpdatedAt = data['updatedAt'] as String?;
    if (serverUpdatedAt == null) {
      return false;
    }

    try {
      final serverTime = DateTime.parse(serverUpdatedAt);
      final localTime = operation.timestamp;

      // Server wins if its timestamp is newer
      return serverTime.isAfter(localTime);
    } catch (e) {
      // If we can't parse the timestamp, assume no conflict
      return false;
    }
  }

  // ============================================================
  // Status & Message Helpers
  // ============================================================

  /// Updates the current status and emits to stream.
  void _updateStatus(SyncStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      if (!_statusController.isClosed) {
        _statusController.add(status);
      }
    }
  }

  /// Emits a user-friendly message to the stream.
  void _emitMessage(String message) {
    if (!_messageController.isClosed) {
      _messageController.add(message);
    }
  }
}

/// Internal class representing the result of a sync operation.
class _SyncResult {
  /// Creates a [_SyncResult] instance.
  const _SyncResult._({
    required this.isSuccess,
    required this.isConflict,
    this.errorMessage,
  });

  /// Creates a successful sync result.
  factory _SyncResult.success() {
    return const _SyncResult._(
      isSuccess: true,
      isConflict: false,
    );
  }

  /// Creates a conflict sync result.
  factory _SyncResult.conflict() {
    return const _SyncResult._(
      isSuccess: false,
      isConflict: true,
    );
  }

  /// Creates a failure sync result.
  factory _SyncResult.failure(String message) {
    return _SyncResult._(
      isSuccess: false,
      isConflict: false,
      errorMessage: message,
    );
  }

  /// Whether the sync succeeded.
  final bool isSuccess;

  /// Whether a conflict was detected (server has newer data).
  final bool isConflict;

  /// Error message if the sync failed.
  final String? errorMessage;
}
