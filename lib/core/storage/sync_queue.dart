/// Sync queue for offline operation storage in App Pasos.
///
/// This file defines an abstract interface and implementation for a
/// queue that stores pending synchronization operations when offline.
/// Operations are persisted to Hive and processed in FIFO order
/// when connectivity is restored.
library;

import 'dart:async';

import 'package:app_pasos_frontend/core/storage/hive_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Types of operations that can be queued for synchronization.
///
/// Each type corresponds to a specific API operation that needs
/// to be synced with the backend when connectivity is available.
enum SyncOperationType {
  /// Create a new step record.
  createStep,

  /// Update an existing step record.
  updateStep,

  /// Create a new goal.
  createGoal,

  /// Update an existing goal.
  updateGoal,

  /// Update user profile information.
  updateProfile,
}

/// Status of a sync operation in the queue.
///
/// Operations progress through these states as they are processed.
enum SyncOperationStatus {
  /// Operation is waiting to be processed.
  pending,

  /// Operation is currently being synced.
  inProgress,

  /// Operation failed after retries.
  failed,

  /// Operation completed successfully.
  completed,
}

/// Represents a single synchronization operation.
///
/// Contains all information needed to replay the operation when
/// connectivity is restored, including retry tracking.
///
/// Example:
/// ```dart
/// final operation = SyncOperation(
///   id: 'op-123',
///   type: SyncOperationType.createStep,
///   payload: {'date': '2024-01-15', 'count': 5000},
///   timestamp: DateTime.now(),
/// );
/// ```
class SyncOperation {
  /// Creates a [SyncOperation] instance.
  ///
  /// [id] - Unique identifier for this operation.
  /// [type] - The type of operation to perform.
  /// [payload] - Data needed to perform the operation.
  /// [timestamp] - When the operation was created.
  /// [retryCount] - Number of failed retry attempts.
  /// [status] - Current status of the operation.
  SyncOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.timestamp,
    this.retryCount = 0,
    this.status = SyncOperationStatus.pending,
  });

  /// Creates a [SyncOperation] from a Hive storage Map.
  factory SyncOperation.fromMap(Map<dynamic, dynamic> map) {
    return SyncOperation(
      id: map['id'] as String,
      type: SyncOperationType.values[map['type'] as int],
      payload: Map<String, dynamic>.from(map['payload'] as Map),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      retryCount: map['retryCount'] as int? ?? 0,
      status: SyncOperationStatus.values[map['status'] as int? ?? 0],
    );
  }

  /// Unique identifier for this operation.
  final String id;

  /// The type of operation to perform.
  final SyncOperationType type;

  /// Data needed to perform the operation.
  ///
  /// The structure depends on the operation type:
  /// - createStep/updateStep: {date, count, distance, calories}
  /// - createGoal/updateGoal: {id, name, target, unit}
  /// - updateProfile: {name, email, settings}
  final Map<String, dynamic> payload;

  /// When the operation was originally created.
  ///
  /// Used for FIFO ordering - older operations are processed first.
  final DateTime timestamp;

  /// Number of times this operation has failed and been retried.
  int retryCount;

  /// Current status of the operation.
  SyncOperationStatus status;

  /// Converts the operation to a Map for Hive storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'payload': payload,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'retryCount': retryCount,
      'status': status.index,
    };
  }

  /// Creates a copy of this operation with optional modified fields.
  SyncOperation copyWith({
    String? id,
    SyncOperationType? type,
    Map<String, dynamic>? payload,
    DateTime? timestamp,
    int? retryCount,
    SyncOperationStatus? status,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'SyncOperation(id: $id, type: $type, status: $status, '
        'retryCount: $retryCount, timestamp: $timestamp)';
  }
}

/// Abstract interface for sync queue operations.
///
/// This interface enables dependency injection and testing by allowing
/// mock implementations. All sync queue operations should go through
/// this service.
///
/// The sync queue handles:
/// - Storing operations that failed due to offline status
/// - Retrieving operations in FIFO order for processing
/// - Tracking operation status and retry counts
/// - Persisting queue state across app restarts
///
/// Example usage:
/// ```dart
/// final queue = SyncQueueImpl();
/// await queue.initialize(hiveService);
///
/// // Queue an operation when offline
/// await queue.enqueue(SyncOperation(
///   id: 'op-${DateTime.now().millisecondsSinceEpoch}',
///   type: SyncOperationType.createStep,
///   payload: {'date': '2024-01-15', 'count': 5000},
///   timestamp: DateTime.now(),
/// ));
///
/// // Later, when online, process the queue
/// while (await queue.pendingCount > 0) {
///   final op = await queue.dequeue();
///   if (op != null) {
///     try {
///       await syncToServer(op);
///       await queue.markCompleted(op.id);
///     } catch (e) {
///       await queue.markFailed(op.id);
///     }
///   }
/// }
/// ```
abstract interface class SyncQueue {
  /// Initializes the sync queue with Hive storage.
  ///
  /// [hiveService] - The Hive service for box access.
  ///
  /// This method must be called before any other queue operations.
  /// It opens the dedicated sync queue box and loads existing operations.
  ///
  /// This method is idempotent - calling it multiple times has no
  /// additional effect after the first successful initialization.
  Future<void> initialize(HiveService hiveService);

  /// Adds an operation to the queue.
  ///
  /// [operation] - The operation to queue for later syncing.
  ///
  /// Operations are stored persistently and survive app restarts.
  /// Emits a queue change event via [onQueueChanged].
  Future<void> enqueue(SyncOperation operation);

  /// Removes and returns the next operation to process.
  ///
  /// Returns the oldest pending operation (FIFO order) and marks
  /// it as [SyncOperationStatus.inProgress].
  ///
  /// Returns `null` if the queue is empty or has no pending operations.
  Future<SyncOperation?> dequeue();

  /// Gets all pending operations without removing them.
  ///
  /// Returns operations in FIFO order (oldest first by timestamp).
  /// Includes operations with status [SyncOperationStatus.pending]
  /// or [SyncOperationStatus.inProgress].
  Future<List<SyncOperation>> getPendingOperations();

  /// Marks an operation as successfully completed.
  ///
  /// [operationId] - The ID of the operation to mark complete.
  ///
  /// Completed operations are removed from the queue.
  /// Emits a queue change event via [onQueueChanged].
  Future<void> markCompleted(String operationId);

  /// Marks an operation as failed.
  ///
  /// [operationId] - The ID of the operation that failed.
  ///
  /// Failed operations remain in the queue for potential retry
  /// unless they exceed the maximum retry count.
  /// Emits a queue change event via [onQueueChanged].
  Future<void> markFailed(String operationId);

  /// Increments the retry count for an operation.
  ///
  /// [operationId] - The ID of the operation being retried.
  ///
  /// Call this before retrying a failed operation.
  /// Resets the operation status to [SyncOperationStatus.pending].
  Future<void> incrementRetry(String operationId);

  /// Gets the number of pending operations in the queue.
  ///
  /// Includes operations with status [SyncOperationStatus.pending]
  /// or [SyncOperationStatus.inProgress].
  Future<int> get pendingCount;

  /// Stream that emits the queue count when operations are added or removed.
  ///
  /// The stream is broadcast, allowing multiple listeners.
  /// Emits the current pending count after each change.
  Stream<int> get onQueueChanged;

  /// Disposes resources used by the sync queue.
  ///
  /// Closes the stream controller. After calling this,
  /// the queue should not be used anymore.
  void dispose();
}

/// Implementation of [SyncQueue] using Hive for persistence.
///
/// This implementation stores sync operations in a dedicated Hive box,
/// allowing them to persist across app restarts. Operations are
/// processed in FIFO order based on their creation timestamp.
///
/// Example usage:
/// ```dart
/// final hiveService = HiveServiceImpl();
/// await hiveService.initialize();
///
/// final syncQueue = SyncQueueImpl();
/// await syncQueue.initialize(hiveService);
///
/// // Listen for queue changes
/// syncQueue.onQueueChanged.listen((count) {
///   print('Queue has $count pending operations');
/// });
///
/// // Add an operation
/// await syncQueue.enqueue(SyncOperation(
///   id: 'op-${DateTime.now().millisecondsSinceEpoch}',
///   type: SyncOperationType.updateStep,
///   payload: {'date': '2024-01-15', 'count': 6000},
///   timestamp: DateTime.now(),
/// ));
///
/// // Process when online
/// final op = await syncQueue.dequeue();
/// if (op != null) {
///   // Sync and mark complete or failed
///   await syncQueue.markCompleted(op.id);
/// }
/// ```
class SyncQueueImpl implements SyncQueue {
  /// Creates a [SyncQueueImpl] instance.
  SyncQueueImpl();

  /// Box name for the sync queue storage.
  static const String syncQueueBoxName = 'sync_queue';

  /// Maximum number of retries before giving up on an operation.
  static const int maxRetryCount = 5;

  /// The Hive box for storing sync operations.
  Box<Map<dynamic, dynamic>>? _box;

  /// Stream controller for broadcasting queue changes.
  final StreamController<int> _queueChangedController =
      StreamController<int>.broadcast();

  /// Whether the queue has been initialized.
  bool _isInitialized = false;

  // ============================================================
  // Stream Access
  // ============================================================

  @override
  Stream<int> get onQueueChanged => _queueChangedController.stream;

  // ============================================================
  // Initialization
  // ============================================================

  @override
  Future<void> initialize(HiveService hiveService) async {
    // Idempotent - skip if already initialized
    if (_isInitialized) {
      return;
    }

    try {
      // Ensure HiveService is initialized
      if (!hiveService.isInitialized) {
        await hiveService.initialize();
      }

      // Open the sync queue box
      if (!Hive.isBoxOpen(syncQueueBoxName)) {
        _box = await Hive.openBox<Map<dynamic, dynamic>>(syncQueueBoxName);
      } else {
        _box = Hive.box<Map<dynamic, dynamic>>(syncQueueBoxName);
      }

      _isInitialized = true;

      // Emit initial count
      _emitQueueCount();
    } catch (e) {
      throw Exception('Failed to initialize sync queue: $e');
    }
  }

  // ============================================================
  // Queue Operations
  // ============================================================

  @override
  Future<void> enqueue(SyncOperation operation) async {
    _ensureInitialized();

    try {
      // Store the operation using its ID as key
      await _box!.put(operation.id, operation.toMap());
      _emitQueueCount();
    } catch (e) {
      throw Exception('Failed to enqueue operation: $e');
    }
  }

  @override
  Future<SyncOperation?> dequeue() async {
    _ensureInitialized();

    try {
      // Get all pending operations sorted by timestamp
      final pendingOps = await _getPendingOperationsSorted();

      if (pendingOps.isEmpty) {
        return null;
      }

      // Get the oldest operation (first in queue)
      final operation = pendingOps.first;

      // Mark as in progress
      final updatedOp = operation.copyWith(
        status: SyncOperationStatus.inProgress,
      );
      await _box!.put(updatedOp.id, updatedOp.toMap());

      return updatedOp;
    } catch (e) {
      throw Exception('Failed to dequeue operation: $e');
    }
  }

  @override
  Future<List<SyncOperation>> getPendingOperations() async {
    _ensureInitialized();

    try {
      return _getPendingOperationsSorted();
    } catch (e) {
      throw Exception('Failed to get pending operations: $e');
    }
  }

  @override
  Future<void> markCompleted(String operationId) async {
    _ensureInitialized();

    try {
      // Remove the completed operation from the queue
      await _box!.delete(operationId);
      _emitQueueCount();
    } catch (e) {
      throw Exception('Failed to mark operation as completed: $e');
    }
  }

  @override
  Future<void> markFailed(String operationId) async {
    _ensureInitialized();

    try {
      final data = _box!.get(operationId);
      if (data == null) {
        return;
      }

      final operation = SyncOperation.fromMap(data);
      final updatedOp = operation.copyWith(
        status: SyncOperationStatus.failed,
      );
      await _box!.put(operationId, updatedOp.toMap());
      _emitQueueCount();
    } catch (e) {
      throw Exception('Failed to mark operation as failed: $e');
    }
  }

  @override
  Future<void> incrementRetry(String operationId) async {
    _ensureInitialized();

    try {
      final data = _box!.get(operationId);
      if (data == null) {
        return;
      }

      final operation = SyncOperation.fromMap(data);

      // Check if max retries exceeded
      if (operation.retryCount >= maxRetryCount) {
        // Mark as permanently failed
        final failedOp = operation.copyWith(
          status: SyncOperationStatus.failed,
        );
        await _box!.put(operationId, failedOp.toMap());
      } else {
        // Increment retry and reset to pending
        final updatedOp = operation.copyWith(
          retryCount: operation.retryCount + 1,
          status: SyncOperationStatus.pending,
        );
        await _box!.put(operationId, updatedOp.toMap());
      }

      _emitQueueCount();
    } catch (e) {
      throw Exception('Failed to increment retry count: $e');
    }
  }

  @override
  Future<int> get pendingCount async {
    _ensureInitialized();

    try {
      var count = 0;
      for (final key in _box!.keys) {
        final data = _box!.get(key);
        if (data != null) {
          final operation = SyncOperation.fromMap(data);
          if (operation.status == SyncOperationStatus.pending ||
              operation.status == SyncOperationStatus.inProgress) {
            count++;
          }
        }
      }
      return count;
    } catch (e) {
      return 0;
    }
  }

  // ============================================================
  // Disposal
  // ============================================================

  @override
  void dispose() {
    _queueChangedController.close();
    _isInitialized = false;
  }

  // ============================================================
  // Private Methods
  // ============================================================

  /// Ensures the queue has been initialized before operations.
  void _ensureInitialized() {
    if (!_isInitialized || _box == null) {
      throw StateError(
        'SyncQueue must be initialized before use. Call initialize() first.',
      );
    }
  }

  /// Gets all pending/in-progress operations sorted by timestamp.
  Future<List<SyncOperation>> _getPendingOperationsSorted() async {
    final operations = <SyncOperation>[];

    for (final key in _box!.keys) {
      final data = _box!.get(key);
      if (data != null) {
        final operation = SyncOperation.fromMap(data);
        if (operation.status == SyncOperationStatus.pending ||
            operation.status == SyncOperationStatus.inProgress) {
          operations.add(operation);
        }
      }
    }

    // Sort by timestamp (oldest first for FIFO)
    operations.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return operations;
  }

  /// Emits the current pending count to listeners.
  void _emitQueueCount() {
    if (!_queueChangedController.isClosed) {
      pendingCount.then((count) {
        if (!_queueChangedController.isClosed) {
          _queueChangedController.add(count);
        }
      });
    }
  }
}
