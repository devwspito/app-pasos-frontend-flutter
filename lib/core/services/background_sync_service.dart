import 'package:health/health.dart' as health_pkg;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../utils/logger.dart';
import 'workmanager_service.dart';

/// Keys for storing sync state in SharedPreferences.
const String _syncedStepsCountKey = 'background_sync_steps_count';
const String _lastSyncTimestampKey = 'background_sync_last_timestamp';

/// Top-level callback dispatcher for Workmanager.
///
/// IMPORTANT: This MUST be a top-level function, NOT a class method.
/// This is a requirement of the workmanager package.
///
/// This function is called by the system when a background task is triggered.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // Initialize logger for background context if needed
      // Note: AppLogger may not be initialized in background context

      if (taskName == healthSyncTask) {
        final syncService = BackgroundSyncService();
        final result = await syncService.performSync();
        return result;
      }

      return true;
    } catch (e) {
      // Log error but don't crash the background task
      // In background context, we can't use AppLogger reliably
      return false;
    }
  });
}

/// Service for performing background health data synchronization.
///
/// This service reads step data from the device's health store
/// (HealthKit on iOS, Health Connect on Android) and stores
/// the sync state in SharedPreferences.
///
/// Example usage:
/// ```dart
/// final syncService = BackgroundSyncService();
///
/// // Perform a sync operation
/// final success = await syncService.performSync();
///
/// if (success) {
///   // Get the last synced data
///   final stepsCount = await BackgroundSyncService.getLastSyncedSteps();
///   final syncTime = await BackgroundSyncService.getLastSyncTimestamp();
///   print('Last sync: $stepsCount steps at $syncTime');
/// }
/// ```
class BackgroundSyncService {
  final health_pkg.Health _health;

  /// Creates a new [BackgroundSyncService] instance.
  ///
  /// Optionally accepts a [Health] instance for testing purposes.
  /// If not provided, a new instance will be created.
  BackgroundSyncService({health_pkg.Health? health})
      : _health = health ?? health_pkg.Health();

  /// Top-level callback dispatcher for Workmanager.
  ///
  /// IMPORTANT: This MUST be a top-level or static function.
  /// This is the entry point called by Workmanager when a background task runs.
  ///
  /// Do NOT use this directly - it's configured automatically during
  /// WorkmanagerService.initialize().
  static void callbackDispatcher() {
    // Delegate to the top-level function
    // This allows the class to provide a static reference while
    // keeping the actual implementation as a top-level function
    Workmanager().executeTask((taskName, inputData) async {
      try {
        if (taskName == healthSyncTask) {
          final syncService = BackgroundSyncService();
          return await syncService.performSync();
        }
        return true;
      } catch (e) {
        return false;
      }
    });
  }

  /// Performs the background health data synchronization.
  ///
  /// This method:
  /// 1. Configures the health API
  /// 2. Reads today's step count from the health store
  /// 3. Stores the step count in SharedPreferences
  /// 4. Stores the sync timestamp in SharedPreferences
  ///
  /// Returns true if sync was successful, false otherwise.
  ///
  /// Note: This method is designed to run in a background isolate,
  /// so it creates fresh instances of all dependencies.
  Future<bool> performSync() async {
    try {
      AppLogger.info('Starting background health sync');

      // Configure health API
      await _health.configure();

      // Check if we have permissions for step data
      final hasPermission = await _health.hasPermissions(
        [health_pkg.HealthDataType.STEPS],
        permissions: [health_pkg.HealthDataAccess.READ],
      );

      if (hasPermission != true) {
        AppLogger.warning(
          'Background sync: No permission to read step data',
        );
        return false;
      }

      // Get today's date range
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = now;

      // Fetch step data for today
      final healthData = await _health.getHealthDataFromTypes(
        types: [health_pkg.HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      // Calculate total steps
      int totalSteps = 0;
      for (final dataPoint in healthData) {
        if (dataPoint.type == health_pkg.HealthDataType.STEPS) {
          final value = dataPoint.value;
          if (value is health_pkg.NumericHealthValue) {
            totalSteps += value.numericValue.toInt();
          }
        }
      }

      // Remove duplicates if any (health package may return duplicates)
      final uniqueData = _health.removeDuplicates(healthData);
      totalSteps = 0;
      for (final dataPoint in uniqueData) {
        if (dataPoint.type == health_pkg.HealthDataType.STEPS) {
          final value = dataPoint.value;
          if (value is health_pkg.NumericHealthValue) {
            totalSteps += value.numericValue.toInt();
          }
        }
      }

      // Store sync results
      await _storeSyncResult(totalSteps, now);

      AppLogger.info(
        'Background health sync completed: $totalSteps steps synced',
      );

      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Background health sync failed',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Stores the sync result in SharedPreferences.
  Future<void> _storeSyncResult(int stepsCount, DateTime syncTime) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_syncedStepsCountKey, stepsCount);
    await prefs.setString(_lastSyncTimestampKey, syncTime.toIso8601String());

    AppLogger.debug(
      'Stored sync result: $stepsCount steps at ${syncTime.toIso8601String()}',
    );
  }

  /// Retrieves the last synced step count from SharedPreferences.
  ///
  /// Returns null if no sync has been performed yet.
  static Future<int?> getLastSyncedSteps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_syncedStepsCountKey);
  }

  /// Retrieves the last sync timestamp from SharedPreferences.
  ///
  /// Returns null if no sync has been performed yet.
  static Future<DateTime?> getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString(_lastSyncTimestampKey);

    if (timestampStr == null) return null;

    try {
      return DateTime.parse(timestampStr);
    } catch (e) {
      AppLogger.warning('Failed to parse last sync timestamp: $timestampStr');
      return null;
    }
  }

  /// Clears all stored sync data from SharedPreferences.
  ///
  /// Call this when user logs out or wants to reset sync state.
  static Future<void> clearSyncData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_syncedStepsCountKey);
    await prefs.remove(_lastSyncTimestampKey);
    AppLogger.info('Background sync data cleared');
  }

  /// Checks if a sync has been performed today.
  ///
  /// Returns true if the last sync timestamp is from today.
  static Future<bool> hasSyncedToday() async {
    final lastSync = await getLastSyncTimestamp();
    if (lastSync == null) return false;

    final now = DateTime.now();
    return lastSync.year == now.year &&
        lastSync.month == now.month &&
        lastSync.day == now.day;
  }

  /// Gets the sync state as a map for debugging or display purposes.
  static Future<Map<String, dynamic>> getSyncState() async {
    final steps = await getLastSyncedSteps();
    final timestamp = await getLastSyncTimestamp();
    final syncedToday = await hasSyncedToday();

    return {
      'lastSyncedSteps': steps,
      'lastSyncTimestamp': timestamp?.toIso8601String(),
      'hasSyncedToday': syncedToday,
    };
  }
}
