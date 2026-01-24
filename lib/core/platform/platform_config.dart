import 'dart:io' show Platform;

/// Platform-specific configuration for App Pasos.
///
/// This class provides utilities for detecting the current platform
/// and checking platform-specific capabilities, particularly for
/// health data integration.
///
/// Example usage:
/// ```dart
/// if (PlatformConfig.supportsHealthData) {
///   // Initialize health services
/// }
/// if (PlatformConfig.isAndroid) {
///   // Android-specific logic
/// }
/// ```
abstract final class PlatformConfig {
  /// Minimum Android SDK version required for Health Connect API.
  ///
  /// Health Connect requires Android API level 26 (Android 8.0 Oreo) or higher.
  static const int minAndroidSdk = 26;

  /// Minimum iOS version required for HealthKit.
  ///
  /// HealthKit requires iOS 13.0 or higher for full functionality.
  static const double minIOSVersion = 13.0;

  /// Whether the current platform is Android.
  static bool get isAndroid {
    try {
      return Platform.isAndroid;
    } catch (_) {
      // Platform detection may fail on web or during testing
      return false;
    }
  }

  /// Whether the current platform is iOS.
  static bool get isIOS {
    try {
      return Platform.isIOS;
    } catch (_) {
      // Platform detection may fail on web or during testing
      return false;
    }
  }

  /// Whether the current platform is macOS.
  static bool get isMacOS {
    try {
      return Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  /// Whether the current platform is a mobile platform (Android or iOS).
  static bool get isMobile => isAndroid || isIOS;

  /// Whether the current platform supports health data APIs.
  ///
  /// Returns true for Android (Health Connect) and iOS (HealthKit).
  /// Returns false for other platforms like web, Windows, Linux, etc.
  static bool get supportsHealthData => isAndroid || isIOS;

  /// The name of the health API for the current platform.
  ///
  /// Returns 'Health Connect' for Android, 'HealthKit' for iOS,
  /// or 'Unsupported' for other platforms.
  static String get healthApiName {
    if (isAndroid) return 'Health Connect';
    if (isIOS) return 'HealthKit';
    return 'Unsupported';
  }

  /// The current platform name as a string.
  ///
  /// Returns 'Android', 'iOS', 'macOS', 'Windows', 'Linux', or 'Unknown'.
  static String get platformName {
    try {
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isWindows) return 'Windows';
      if (Platform.isLinux) return 'Linux';
      if (Platform.isFuchsia) return 'Fuchsia';
    } catch (_) {
      // Platform detection may fail on web
    }
    return 'Unknown';
  }
}
