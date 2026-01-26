import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';

/// Represents the current status of health data operations.
///
/// - [initial]: Provider just created, no operations performed
/// - [loading]: Checking permissions or preparing operation
/// - [syncing]: Actively syncing steps from health data
/// - [synced]: Steps successfully synced from health
/// - [permissionDenied]: Health permissions were denied
/// - [error]: An error occurred during operation
enum HealthStatus {
  initial,
  loading,
  syncing,
  synced,
  permissionDenied,
  error,
}

/// Abstract interface for GetStepsFromHealthUseCase.
///
/// TODO: Will be replaced with import from lib/features/health/domain/usecases/get_steps_from_health_usecase.dart
abstract class GetStepsFromHealthUseCase {
  /// Fetches today's steps from health data source.
  ///
  /// Returns the number of steps or 0 if no data available.
  Future<int> call();
}

/// Abstract interface for RequestHealthPermissionsUseCase.
///
/// TODO: Will be replaced with import from lib/features/health/domain/usecases/request_health_permissions_usecase.dart
abstract class RequestHealthPermissionsUseCase {
  /// Requests health data permissions from the user.
  ///
  /// Returns true if permissions were granted, false otherwise.
  Future<bool> call();
}

/// Abstract interface for CheckHealthPermissionsUseCase.
///
/// TODO: Will be replaced with import from lib/features/health/domain/usecases/check_health_permissions_usecase.dart
abstract class CheckHealthPermissionsUseCase {
  /// Checks if health data permissions are granted.
  ///
  /// Returns true if permissions are granted, false otherwise.
  Future<bool> call();
}

/// Health state management provider using ChangeNotifier.
///
/// Manages health data permissions and step syncing from the device's
/// health data source. Implements [ChangeNotifier] for use with Provider.
///
/// Usage:
/// ```dart
/// final healthProvider = context.watch<HealthProvider>();
/// if (healthProvider.status == HealthStatus.synced) {
///   print('Synced steps: ${healthProvider.syncedSteps}');
///   print('Last sync: ${healthProvider.lastSyncTime}');
/// }
/// ```
///
/// Features:
/// - Health permission management
/// - Step data syncing from health source
/// - Last sync time tracking
/// - Error handling with user-friendly messages
class HealthProvider extends ChangeNotifier {
  /// Use case for fetching steps from health data.
  final GetStepsFromHealthUseCase _getStepsFromHealth;

  /// Use case for requesting health permissions.
  final RequestHealthPermissionsUseCase _requestHealthPermissions;

  /// Use case for checking health permissions.
  final CheckHealthPermissionsUseCase _checkHealthPermissions;

  /// Current operation status.
  HealthStatus _status = HealthStatus.initial;

  /// Whether health permissions are granted.
  bool _permissionGranted = false;

  /// Last successful sync time.
  DateTime? _lastSyncTime;

  /// Number of steps synced from health data.
  int _syncedSteps = 0;

  /// Error message from the last failed operation.
  String? _errorMessage;

  /// Creates a new HealthProvider instance.
  ///
  /// [getStepsFromHealth] - Use case for fetching steps from health
  /// [requestHealthPermissions] - Use case for requesting permissions
  /// [checkHealthPermissions] - Use case for checking permissions
  HealthProvider({
    required GetStepsFromHealthUseCase getStepsFromHealth,
    required RequestHealthPermissionsUseCase requestHealthPermissions,
    required CheckHealthPermissionsUseCase checkHealthPermissions,
  })  : _getStepsFromHealth = getStepsFromHealth,
        _requestHealthPermissions = requestHealthPermissions,
        _checkHealthPermissions = checkHealthPermissions;

  // =========================================================================
  // GETTERS
  // =========================================================================

  /// Returns the current operation status.
  HealthStatus get status => _status;

  /// Returns whether health permissions are granted.
  bool get permissionGranted => _permissionGranted;

  /// Returns the last successful sync time, or null if never synced.
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Returns the number of steps synced from health data.
  int get syncedSteps => _syncedSteps;

  /// Returns the error message from the last failed operation, or null if no error.
  String? get errorMessage => _errorMessage;

  /// Returns true if data is currently being loaded.
  bool get isLoading => _status == HealthStatus.loading;

  /// Returns true if sync is in progress.
  bool get isSyncing => _status == HealthStatus.syncing;

  /// Returns true if there's an error.
  bool get hasError => _status == HealthStatus.error;

  /// Returns true if permission was denied.
  bool get isPermissionDenied => _status == HealthStatus.permissionDenied;

  /// Returns true if steps have been synced at least once.
  bool get hasSyncedData => _lastSyncTime != null;

  /// Returns a human-readable string for the last sync time.
  String get lastSyncTimeFormatted {
    if (_lastSyncTime == null) return 'Never synced';

    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
  }

  // =========================================================================
  // STATE MANAGEMENT
  // =========================================================================

  /// Updates the internal state and notifies listeners.
  ///
  /// This helper method consolidates state changes to prevent multiple
  /// notifyListeners() calls and ensures consistent state updates.
  void _updateState({
    HealthStatus? status,
    bool? permissionGranted,
    DateTime? lastSyncTime,
    int? syncedSteps,
    String? error,
    bool clearLastSyncTime = false,
    bool clearError = false,
  }) {
    if (status != null) _status = status;

    if (permissionGranted != null) _permissionGranted = permissionGranted;

    if (clearLastSyncTime) {
      _lastSyncTime = null;
    } else if (lastSyncTime != null) {
      _lastSyncTime = lastSyncTime;
    }

    if (syncedSteps != null) _syncedSteps = syncedSteps;

    if (clearError) {
      _errorMessage = null;
    } else if (error != null) {
      _errorMessage = error;
    }

    notifyListeners();
  }

  // =========================================================================
  // PERMISSION MANAGEMENT
  // =========================================================================

  /// Checks if health permissions are granted.
  ///
  /// Updates [permissionGranted] with the result.
  /// Does not change status if already synced/syncing.
  Future<void> checkPermissions() async {
    _updateState(status: HealthStatus.loading, clearError: true);

    try {
      final granted = await _checkHealthPermissions.call();

      AppLogger.info('Health permissions check: ${granted ? 'granted' : 'denied'}');

      _updateState(
        status: granted ? HealthStatus.initial : HealthStatus.permissionDenied,
        permissionGranted: granted,
        clearError: true,
      );
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to check health permissions', e);
      _updateState(
        status: HealthStatus.error,
        error: errorMsg,
      );
    }
  }

  /// Requests health data permissions from the user.
  ///
  /// Updates [permissionGranted] with the result.
  /// Sets [status] to [HealthStatus.permissionDenied] if user denies,
  /// or [HealthStatus.initial] if granted.
  Future<bool> requestPermissions() async {
    _updateState(status: HealthStatus.loading, clearError: true);

    try {
      final granted = await _requestHealthPermissions.call();

      AppLogger.info('Health permissions request: ${granted ? 'granted' : 'denied'}');

      _updateState(
        status: granted ? HealthStatus.initial : HealthStatus.permissionDenied,
        permissionGranted: granted,
        clearError: true,
      );

      return granted;
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to request health permissions', e);
      _updateState(
        status: HealthStatus.error,
        error: errorMsg,
      );
      return false;
    }
  }

  // =========================================================================
  // STEP SYNCING
  // =========================================================================

  /// Syncs today's steps from the health data source.
  ///
  /// Requires permissions to be granted first.
  /// Updates [syncedSteps] and [lastSyncTime] on success.
  /// Sets [status] to [HealthStatus.synced] on success,
  /// or [HealthStatus.error] with [errorMessage] on failure.
  Future<void> syncTodaySteps() async {
    // Check if we have permission first
    if (!_permissionGranted) {
      AppLogger.warning('Cannot sync steps: permissions not granted');
      _updateState(
        status: HealthStatus.permissionDenied,
        error: 'Health permissions are required to sync steps',
      );
      return;
    }

    _updateState(status: HealthStatus.syncing, clearError: true);

    try {
      final steps = await _getStepsFromHealth.call();

      AppLogger.info('Steps synced from health: $steps');

      _updateState(
        status: HealthStatus.synced,
        syncedSteps: steps,
        lastSyncTime: DateTime.now(),
        clearError: true,
      );
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to sync steps from health', e);
      _updateState(
        status: HealthStatus.error,
        error: errorMsg,
      );
    }
  }

  // =========================================================================
  // ERROR HANDLING
  // =========================================================================

  /// Clears the current error message.
  ///
  /// Call this when displaying errors to reset the error state.
  void clearError() {
    _updateState(clearError: true);
  }

  /// Resets all data to initial state.
  ///
  /// Use this when logging out or switching users.
  void reset() {
    _updateState(
      status: HealthStatus.initial,
      permissionGranted: false,
      syncedSteps: 0,
      clearLastSyncTime: true,
      clearError: true,
    );
    AppLogger.info('Health provider reset');
  }

  // =========================================================================
  // PRIVATE HELPERS
  // =========================================================================

  /// Parses error response into a user-friendly message.
  String _parseError(dynamic error) {
    if (error is Exception) {
      final errorStr = error.toString();

      // Check for common error patterns
      if (errorStr.contains('permission') || errorStr.contains('denied')) {
        return 'Health permissions are required to access step data';
      }
      if (errorStr.contains('unavailable') || errorStr.contains('not supported')) {
        return 'Health data is not available on this device';
      }
      if (errorStr.contains('timeout')) {
        return 'Request timed out. Please try again';
      }
      if (errorStr.contains('SocketException') ||
          errorStr.contains('Connection refused')) {
        return 'Unable to connect. Please check your internet connection';
      }
    }
    return 'An unexpected error occurred. Please try again';
  }

  @override
  void dispose() {
    AppLogger.info('HealthProvider disposed');
    super.dispose();
  }
}
