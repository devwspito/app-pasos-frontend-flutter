/// Background sync service for periodic data synchronization in App Pasos.
///
/// This file defines an abstract interface for background sync operations.
/// Implementations will provide platform-specific integrations for
/// scheduling and executing background data synchronization tasks.
library;

/// Abstract interface for background sync operations.
///
/// This interface enables dependency injection and testing by allowing
/// mock implementations. All background synchronization logic should go
/// through this service.
///
/// The background sync service handles:
/// - Periodic synchronization of health data with the backend
/// - Managing sync intervals and schedules
/// - Tracking sync status and history
///
/// Example usage:
/// ```dart
/// final syncService = BackgroundSyncServiceImpl();
/// await syncService.initialize();
/// await syncService.startPeriodicSync(interval: Duration(hours: 1));
///
/// // Later, check status
/// final isEnabled = await syncService.isSyncEnabled();
/// final lastSync = await syncService.getLastSyncTime();
/// print('Sync enabled: $isEnabled, last sync: $lastSync');
///
/// // Stop when no longer needed
/// await syncService.stopPeriodicSync();
/// ```
abstract interface class BackgroundSyncService {
  /// Initializes the background sync system.
  ///
  /// This method must be called before any other sync operations.
  /// It sets up the necessary platform-specific infrastructure for
  /// background task execution.
  ///
  /// Initialization includes:
  /// - Registering background task handlers
  /// - Loading persisted sync preferences
  /// - Setting up platform-specific work managers
  ///
  /// This method is idempotent - calling it multiple times has no
  /// additional effect after the first successful initialization.
  ///
  /// Throws an exception if initialization fails due to platform
  /// limitations or missing permissions.
  Future<void> initialize();

  /// Starts periodic background synchronization with the specified interval.
  ///
  /// [interval] - The duration between sync operations. Must be at least
  /// 15 minutes due to platform limitations on background task frequency.
  ///
  /// When started, the service will automatically sync health data
  /// with the backend at the specified interval, even when the app
  /// is in the background or terminated.
  ///
  /// If periodic sync is already running, calling this method will
  /// update the interval and restart the sync schedule.
  ///
  /// Note: The actual sync timing may vary slightly due to platform
  /// battery optimization and scheduling constraints.
  ///
  /// Example:
  /// ```dart
  /// // Sync every hour
  /// await syncService.startPeriodicSync(interval: Duration(hours: 1));
  ///
  /// // Sync every 30 minutes
  /// await syncService.startPeriodicSync(interval: Duration(minutes: 30));
  /// ```
  ///
  /// Throws an exception if [initialize] has not been called first,
  /// or if the interval is less than the minimum allowed duration.
  Future<void> startPeriodicSync({required Duration interval});

  /// Stops periodic background synchronization.
  ///
  /// Cancels any scheduled sync tasks and stops the background sync
  /// service. No more automatic syncs will occur until
  /// [startPeriodicSync] is called again.
  ///
  /// This method is safe to call even if sync is not currently running.
  /// Calling it multiple times has no additional effect.
  ///
  /// Note: Any sync operation currently in progress will complete,
  /// but no new syncs will be scheduled.
  Future<void> stopPeriodicSync();

  /// Checks if periodic sync is currently enabled.
  ///
  /// Returns `true` if background sync has been started and is
  /// actively scheduling sync operations.
  ///
  /// Returns `false` if:
  /// - Sync has never been started
  /// - Sync was stopped via [stopPeriodicSync]
  /// - The service has not been initialized
  ///
  /// Example:
  /// ```dart
  /// final isEnabled = await syncService.isSyncEnabled();
  /// if (!isEnabled) {
  ///   await syncService.startPeriodicSync(interval: Duration(hours: 1));
  /// }
  /// ```
  Future<bool> isSyncEnabled();

  /// Gets the timestamp of the last successful synchronization.
  ///
  /// Returns the [DateTime] when the most recent sync operation
  /// completed successfully, or `null` if:
  /// - No sync has ever been performed
  /// - The last sync attempt failed
  /// - The sync history has been cleared
  ///
  /// The returned time is in the local timezone.
  ///
  /// Example:
  /// ```dart
  /// final lastSync = await syncService.getLastSyncTime();
  /// if (lastSync != null) {
  ///   final timeSinceSync = DateTime.now().difference(lastSync);
  ///   print('Last synced ${timeSinceSync.inMinutes} minutes ago');
  /// } else {
  ///   print('Never synced');
  /// }
  /// ```
  Future<DateTime?> getLastSyncTime();
}
