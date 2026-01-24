import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import 'platform_config.dart';

/// Health data permissions manager for App Pasos.
///
/// This class provides cross-platform utilities for requesting and checking
/// health data permissions on Android (Health Connect) and iOS (HealthKit).
///
/// **Platform Requirements:**
/// - Android: Health Connect app must be installed, Android 8.0+ (SDK 26+)
/// - iOS: HealthKit entitlement must be configured, iOS 13.0+
///
/// **Setup Required:**
/// - Add health and permission_handler packages to pubspec.yaml
/// - Configure native platform permissions (AndroidManifest.xml, Info.plist)
///
/// Example usage:
/// ```dart
/// // Check if health data is supported on this platform
/// if (PlatformConfig.supportsHealthData) {
///   // Request permissions
///   final granted = await HealthPermissions.requestPermissions();
///   if (granted) {
///     // Access health data
///     final permissions = await HealthPermissions.getGrantedPermissions();
///     print('Granted: $permissions');
///   }
/// }
/// ```
abstract final class HealthPermissions {
  /// Health instance for accessing health data.
  static final Health _health = Health();

  /// Default health data types to request permissions for.
  ///
  /// These are the primary data types used by App Pasos for step tracking
  /// and activity monitoring.
  static const List<HealthDataType> defaultDataTypes = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.WORKOUT,
  ];

  /// Requests health data permissions from the user.
  ///
  /// Returns `true` if all requested permissions were granted,
  /// `false` otherwise.
  ///
  /// [dataTypes] - Optional list of specific health data types to request.
  ///   Defaults to [defaultDataTypes] if not specified.
  ///
  /// Throws [HealthPermissionException] if an error occurs during the
  /// permission request process.
  ///
  /// Example:
  /// ```dart
  /// final granted = await HealthPermissions.requestPermissions();
  /// if (granted) {
  ///   print('Permissions granted!');
  /// }
  /// ```
  static Future<bool> requestPermissions({
    List<HealthDataType>? dataTypes,
  }) async {
    if (!PlatformConfig.supportsHealthData) {
      throw HealthPermissionException(
        'Health data is not supported on ${PlatformConfig.platformName}',
      );
    }

    final types = dataTypes ?? defaultDataTypes;

    try {
      // Request activity recognition permission on Android (required for Health Connect)
      if (PlatformConfig.isAndroid) {
        final activityStatus = await Permission.activityRecognition.request();
        if (!activityStatus.isGranted) {
          return false;
        }
      }

      // Configure the Health instance
      await _health.configure();

      // Request authorization for health data types
      // Using read-only permissions by default
      final permissions = types.map((_) => HealthDataAccess.READ).toList();

      final authorized = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      return authorized;
    } on HealthException catch (e) {
      throw HealthPermissionException(
        'Failed to request health permissions: ${e.cause}',
        originalException: e,
      );
    } catch (e) {
      throw HealthPermissionException(
        'Unexpected error requesting health permissions: $e',
      );
    }
  }

  /// Checks if the app currently has health data permissions.
  ///
  /// Returns `true` if the app has permissions to access health data,
  /// `false` otherwise.
  ///
  /// [dataTypes] - Optional list of specific health data types to check.
  ///   Defaults to [defaultDataTypes] if not specified.
  ///
  /// Example:
  /// ```dart
  /// final hasPermission = await HealthPermissions.hasPermissions();
  /// if (!hasPermission) {
  ///   await HealthPermissions.requestPermissions();
  /// }
  /// ```
  static Future<bool> hasPermissions({
    List<HealthDataType>? dataTypes,
  }) async {
    if (!PlatformConfig.supportsHealthData) {
      return false;
    }

    final types = dataTypes ?? defaultDataTypes;

    try {
      await _health.configure();

      // Check authorization status for each type
      for (final type in types) {
        final hasPermission = await _health.hasPermissions(
          [type],
          permissions: [HealthDataAccess.READ],
        );

        // If any permission is not granted, return false
        if (hasPermission != true) {
          return false;
        }
      }

      return true;
    } on HealthException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Gets the list of health data types that the app has permission to access.
  ///
  /// Returns a list of [HealthDataType] values that the user has granted
  /// permission for. Returns an empty list if no permissions are granted
  /// or if health data is not supported on the current platform.
  ///
  /// Example:
  /// ```dart
  /// final granted = await HealthPermissions.getGrantedPermissions();
  /// for (final type in granted) {
  ///   print('Can access: ${type.name}');
  /// }
  /// ```
  static Future<List<HealthDataType>> getGrantedPermissions() async {
    if (!PlatformConfig.supportsHealthData) {
      return [];
    }

    final grantedTypes = <HealthDataType>[];

    try {
      await _health.configure();

      for (final type in defaultDataTypes) {
        final hasPermission = await _health.hasPermissions(
          [type],
          permissions: [HealthDataAccess.READ],
        );

        if (hasPermission == true) {
          grantedTypes.add(type);
        }
      }
    } on HealthException {
      // Return whatever permissions we found before the error
    } catch (_) {
      // Return whatever permissions we found before the error
    }

    return grantedTypes;
  }

  /// Requests read and write permissions for specific health data types.
  ///
  /// Use this method when you need to both read and write health data.
  ///
  /// [dataTypes] - The list of health data types to request read/write access for.
  ///
  /// Returns `true` if all requested permissions were granted.
  ///
  /// Example:
  /// ```dart
  /// final granted = await HealthPermissions.requestReadWritePermissions(
  ///   dataTypes: [HealthDataType.STEPS, HealthDataType.WORKOUT],
  /// );
  /// ```
  static Future<bool> requestReadWritePermissions({
    required List<HealthDataType> dataTypes,
  }) async {
    if (!PlatformConfig.supportsHealthData) {
      throw HealthPermissionException(
        'Health data is not supported on ${PlatformConfig.platformName}',
      );
    }

    try {
      if (PlatformConfig.isAndroid) {
        final activityStatus = await Permission.activityRecognition.request();
        if (!activityStatus.isGranted) {
          return false;
        }
      }

      await _health.configure();

      final permissions = dataTypes
          .map((_) => HealthDataAccess.READ_WRITE)
          .toList();

      final authorized = await _health.requestAuthorization(
        dataTypes,
        permissions: permissions,
      );

      return authorized;
    } on HealthException catch (e) {
      throw HealthPermissionException(
        'Failed to request read/write permissions: ${e.cause}',
        originalException: e,
      );
    } catch (e) {
      throw HealthPermissionException(
        'Unexpected error requesting read/write permissions: $e',
      );
    }
  }

  /// Revokes all health data permissions (if supported by the platform).
  ///
  /// **Note:** This method may not fully revoke permissions on all platforms.
  /// Users may need to manually revoke permissions in system settings.
  ///
  /// Returns `true` if the revocation was successful or attempted.
  static Future<bool> revokePermissions() async {
    if (!PlatformConfig.supportsHealthData) {
      return false;
    }

    try {
      await _health.configure();
      await _health.revokePermissions();
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Exception thrown when health permission operations fail.
///
/// Contains details about the permission error and optionally the original
/// exception that caused the failure.
class HealthPermissionException implements Exception {
  /// Creates a new [HealthPermissionException] with the given [message].
  const HealthPermissionException(
    this.message, {
    this.originalException,
  });

  /// A human-readable description of the error.
  final String message;

  /// The original exception that caused this error, if any.
  final Exception? originalException;

  @override
  String toString() => 'HealthPermissionException: $message';
}
