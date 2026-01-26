import 'package:health/health.dart' as health_pkg;

import '../utils/logger.dart';

/// Health data types supported by the application.
///
/// These types represent the health metrics that can be read from
/// the device's health data store (HealthKit on iOS, Health Connect on Android).
enum AppHealthDataType {
  /// Step count data.
  steps,

  /// Distance traveled (walking/running).
  distance,

  /// Active calories burned.
  calories,

  /// Heart rate measurements.
  heartRate,
}

/// Permission status for health data access.
///
/// Represents the current authorization status for accessing health data.
enum HealthPermissionStatus {
  /// Permission has been granted by the user.
  granted,

  /// Permission has been explicitly denied by the user.
  denied,

  /// Permission has not been requested yet.
  notDetermined,

  /// Permission is restricted by device policy or parental controls.
  restricted,
}

/// Abstract interface for health permissions management.
///
/// This interface provides methods to check and request permissions
/// for accessing health data on the device. It follows the same pattern
/// as [NetworkInfo] for consistency and testability.
///
/// Example:
/// ```dart
/// final permissionService = HealthPermissionServiceImpl();
///
/// // Check if we have permission for steps
/// final status = await permissionService.checkPermission(AppHealthDataType.steps);
///
/// if (status != HealthPermissionStatus.granted) {
///   // Request permissions for steps and distance
///   final granted = await permissionService.requestPermissions([
///     AppHealthDataType.steps,
///     AppHealthDataType.distance,
///   ]);
///
///   if (granted) {
///     print('Permissions granted!');
///   }
/// }
///
/// // Check if all required permissions are available
/// final hasAll = await permissionService.hasAllPermissions([
///   AppHealthDataType.steps,
///   AppHealthDataType.distance,
///   AppHealthDataType.calories,
/// ]);
/// ```
abstract class HealthPermissionService {
  /// Checks the current permission status for a specific health data type.
  ///
  /// Returns [HealthPermissionStatus] indicating the current authorization
  /// status for the requested data type.
  ///
  /// Note: On some platforms, this may trigger a permission dialog if
  /// permissions haven't been determined yet.
  Future<HealthPermissionStatus> checkPermission(AppHealthDataType type);

  /// Requests permissions for multiple health data types.
  ///
  /// [types] - List of health data types to request permission for.
  ///
  /// Returns true if all requested permissions were granted,
  /// false otherwise.
  ///
  /// This method will show the platform's health data permission dialog
  /// to the user if permissions haven't been granted yet.
  Future<bool> requestPermissions(List<AppHealthDataType> types);

  /// Checks if permissions are granted for all specified data types.
  ///
  /// [types] - List of health data types to check.
  ///
  /// Returns true only if all specified types have been granted
  /// permission, false otherwise.
  Future<bool> hasAllPermissions(List<AppHealthDataType> types);
}

/// Implementation of [HealthPermissionService] using the health package.
///
/// This class provides health data permission management functionality
/// using the health package, which integrates with HealthKit on iOS
/// and Health Connect on Android.
///
/// Example:
/// ```dart
/// // In production
/// final permissionService = HealthPermissionServiceImpl();
///
/// // In tests (with mock Health instance)
/// final mockHealth = MockHealth();
/// final permissionService = HealthPermissionServiceImpl(health: mockHealth);
/// ```
class HealthPermissionServiceImpl implements HealthPermissionService {
  final health_pkg.Health _health;

  /// Creates a new [HealthPermissionServiceImpl] instance.
  ///
  /// Optionally accepts a [Health] instance for testing purposes.
  /// If not provided, a default instance will be created.
  HealthPermissionServiceImpl({health_pkg.Health? health})
      : _health = health ?? health_pkg.Health();

  /// Maps app-specific health data types to the health package types.
  health_pkg.HealthDataType _mapToHealthType(AppHealthDataType type) {
    switch (type) {
      case AppHealthDataType.steps:
        return health_pkg.HealthDataType.STEPS;
      case AppHealthDataType.distance:
        return health_pkg.HealthDataType.DISTANCE_WALKING_RUNNING;
      case AppHealthDataType.calories:
        return health_pkg.HealthDataType.ACTIVE_ENERGY_BURNED;
      case AppHealthDataType.heartRate:
        return health_pkg.HealthDataType.HEART_RATE;
    }
  }

  /// Maps a list of app health data types to health package types.
  List<health_pkg.HealthDataType> _mapTypes(List<AppHealthDataType> types) {
    return types.map(_mapToHealthType).toList();
  }

  @override
  Future<HealthPermissionStatus> checkPermission(AppHealthDataType type) async {
    AppLogger.debug('Checking health permission for: ${type.name}');

    try {
      final healthType = _mapToHealthType(type);
      final hasPermission = await _health.hasPermissions(
        [healthType],
        permissions: [health_pkg.HealthDataAccess.READ],
      );

      final status = hasPermission == true
          ? HealthPermissionStatus.granted
          : HealthPermissionStatus.notDetermined;

      AppLogger.info(
        'Health permission check for ${type.name}: ${status.name}',
      );

      return status;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error checking health permission for ${type.name}',
        e,
        stackTrace,
      );
      return HealthPermissionStatus.denied;
    }
  }

  @override
  Future<bool> requestPermissions(List<AppHealthDataType> types) async {
    if (types.isEmpty) {
      AppLogger.warning('requestPermissions called with empty types list');
      return true;
    }

    final typeNames = types.map((t) => t.name).join(', ');
    AppLogger.debug('Requesting health permissions for: $typeNames');

    try {
      final healthTypes = _mapTypes(types);

      // Configure health for the specific platform
      await _health.configure();

      // Request authorization for the specified types
      final granted = await _health.requestAuthorization(
        healthTypes,
        permissions: List.filled(
          healthTypes.length,
          health_pkg.HealthDataAccess.READ,
        ),
      );

      if (granted) {
        AppLogger.info('Health permissions granted for: $typeNames');
      } else {
        AppLogger.warning('Health permissions denied for: $typeNames');
      }

      return granted;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error requesting health permissions for: $typeNames',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<bool> hasAllPermissions(List<AppHealthDataType> types) async {
    if (types.isEmpty) {
      AppLogger.debug('hasAllPermissions called with empty types list');
      return true;
    }

    final typeNames = types.map((t) => t.name).join(', ');
    AppLogger.debug('Checking all health permissions for: $typeNames');

    try {
      final healthTypes = _mapTypes(types);
      final hasPermission = await _health.hasPermissions(
        healthTypes,
        permissions: List.filled(
          healthTypes.length,
          health_pkg.HealthDataAccess.READ,
        ),
      );

      final result = hasPermission == true;

      AppLogger.info(
        'All health permissions check for [$typeNames]: ${result ? "granted" : "not granted"}',
      );

      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error checking all health permissions for: $typeNames',
        e,
        stackTrace,
      );
      return false;
    }
  }
}
