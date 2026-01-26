import 'package:workmanager/workmanager.dart';

import '../utils/logger.dart';
import 'background_sync_service.dart';

/// Task name constant for health sync background task.
const String healthSyncTask = 'healthSyncTask';

/// Unique task name for the periodic health sync.
const String _periodicHealthSyncTask = 'com.apppasos.periodicHealthSync';

/// Service for managing background task scheduling using Workmanager.
///
/// This service provides methods to initialize the Workmanager,
/// register periodic background tasks for health data synchronization,
/// and cancel scheduled tasks.
///
/// Example usage:
/// ```dart
/// // Initialize in main() or app startup
/// await WorkmanagerService.instance.initialize();
///
/// // Register periodic sync every 15 minutes
/// await WorkmanagerService.instance.registerPeriodicSync(
///   const Duration(minutes: 15),
/// );
///
/// // Cancel all scheduled tasks
/// await WorkmanagerService.instance.cancelAllTasks();
/// ```
class WorkmanagerService {
  static WorkmanagerService? _instance;

  /// Singleton instance of [WorkmanagerService].
  static WorkmanagerService get instance {
    _instance ??= WorkmanagerService._();
    return _instance!;
  }

  WorkmanagerService._();

  bool _isInitialized = false;

  /// Returns true if the service has been initialized.
  bool get isInitialized => _isInitialized;

  /// Initializes the Workmanager with the callback dispatcher.
  ///
  /// Must be called before registering any background tasks.
  /// Typically called in main() after WidgetsFlutterBinding.ensureInitialized().
  ///
  /// Returns true if initialization was successful, false otherwise.
  Future<bool> initialize() async {
    if (_isInitialized) {
      AppLogger.debug('WorkmanagerService already initialized');
      return true;
    }

    try {
      AppLogger.info('Initializing WorkmanagerService');

      await Workmanager().initialize(
        BackgroundSyncService.callbackDispatcher,
        isInDebugMode: false,
      );

      _isInitialized = true;
      AppLogger.info('WorkmanagerService initialized successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize WorkmanagerService',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Registers a periodic background task for health data synchronization.
  ///
  /// [frequency] - The interval between task executions.
  /// Note: On Android, the minimum interval is 15 minutes.
  /// On iOS, the actual timing is managed by the system.
  ///
  /// Returns true if the task was registered successfully, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// // Register sync every 15 minutes
  /// await WorkmanagerService.instance.registerPeriodicSync(
  ///   const Duration(minutes: 15),
  /// );
  /// ```
  Future<bool> registerPeriodicSync(Duration frequency) async {
    if (!_isInitialized) {
      AppLogger.warning(
        'Cannot register periodic sync: WorkmanagerService not initialized',
      );
      return false;
    }

    try {
      AppLogger.info(
        'Registering periodic health sync with frequency: ${frequency.inMinutes} minutes',
      );

      await Workmanager().registerPeriodicTask(
        _periodicHealthSyncTask,
        healthSyncTask,
        frequency: frequency,
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 1),
      );

      AppLogger.info('Periodic health sync registered successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to register periodic health sync',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Registers a one-time background task for immediate health sync.
  ///
  /// Useful for triggering an immediate sync when the app goes to background.
  ///
  /// Returns true if the task was registered successfully, false otherwise.
  Future<bool> registerOneTimeSync() async {
    if (!_isInitialized) {
      AppLogger.warning(
        'Cannot register one-time sync: WorkmanagerService not initialized',
      );
      return false;
    }

    try {
      AppLogger.info('Registering one-time health sync');

      final uniqueId = 'healthSync_${DateTime.now().millisecondsSinceEpoch}';

      await Workmanager().registerOneOffTask(
        uniqueId,
        healthSyncTask,
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(seconds: 30),
      );

      AppLogger.info('One-time health sync registered successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to register one-time health sync',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Cancels all scheduled background tasks.
  ///
  /// Call this when disabling background sync or when user logs out.
  ///
  /// Returns true if cancellation was successful, false otherwise.
  Future<bool> cancelAllTasks() async {
    try {
      AppLogger.info('Cancelling all scheduled background tasks');

      await Workmanager().cancelAll();

      AppLogger.info('All background tasks cancelled successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to cancel background tasks',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Cancels only the periodic health sync task.
  ///
  /// Useful when you want to stop periodic sync but keep other tasks.
  ///
  /// Returns true if cancellation was successful, false otherwise.
  Future<bool> cancelPeriodicSync() async {
    try {
      AppLogger.info('Cancelling periodic health sync task');

      await Workmanager().cancelByUniqueName(_periodicHealthSyncTask);

      AppLogger.info('Periodic health sync task cancelled successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to cancel periodic health sync task',
        e,
        stackTrace,
      );
      return false;
    }
  }
}
