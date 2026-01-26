import 'dart:io' show Platform;

/// Abstract interface for platform detection utilities.
///
/// This interface provides methods to detect the current platform
/// the application is running on. It follows the same pattern as
/// [NetworkInfo] for consistency and testability.
///
/// Example:
/// ```dart
/// final platformInfo = PlatformInfoImpl();
///
/// if (platformInfo.isAndroid) {
///   print('Running on Android');
/// } else if (platformInfo.isIOS) {
///   print('Running on iOS');
/// }
///
/// print('Platform: ${platformInfo.platformName}');
/// ```
abstract class PlatformInfo {
  /// Returns true if the application is running on Android.
  bool get isAndroid;

  /// Returns true if the application is running on iOS.
  bool get isIOS;

  /// Returns true if the application is running on a mobile platform
  /// (Android or iOS).
  bool get isMobile;

  /// Returns the platform operating system name as a string.
  ///
  /// Returns values like 'android', 'ios', 'linux', 'macos', 'windows'.
  String get platformName;
}

/// Implementation of [PlatformInfo] using dart:io Platform.
///
/// This class provides platform detection functionality for the application.
/// It wraps the dart:io [Platform] class to provide a clean interface
/// that can be mocked for testing purposes.
///
/// Example:
/// ```dart
/// // In production
/// final platformInfo = PlatformInfoImpl();
///
/// // In tests (with mock)
/// final mockPlatformInfo = MockPlatformInfo();
/// when(mockPlatformInfo.isAndroid).thenReturn(true);
/// ```
class PlatformInfoImpl implements PlatformInfo {
  /// Creates a new [PlatformInfoImpl] instance.
  const PlatformInfoImpl();

  @override
  bool get isAndroid => Platform.isAndroid;

  @override
  bool get isIOS => Platform.isIOS;

  @override
  bool get isMobile => Platform.isAndroid || Platform.isIOS;

  @override
  String get platformName => Platform.operatingSystem;
}
