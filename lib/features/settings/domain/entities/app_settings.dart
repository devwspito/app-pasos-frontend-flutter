/// Application settings entity for managing user preferences.
///
/// This entity represents the user's application settings including
/// notification preferences and theme mode selection.
library;

import 'package:equatable/equatable.dart';

/// Theme mode options for the application.
///
/// This enum defines the available theme modes that users can select.
/// - [light]: Forces light theme regardless of system setting
/// - [dark]: Forces dark theme regardless of system setting
/// - [system]: Follows the system theme setting
enum AppThemeMode {
  /// Light theme mode.
  light,

  /// Dark theme mode.
  dark,

  /// System-determined theme mode.
  system,
}

/// Entity representing the application settings.
///
/// This immutable class holds user preferences for the application
/// including notification settings and theme preferences.
///
/// Example usage:
/// ```dart
/// const settings = AppSettings(
///   notificationsEnabled: true,
///   themeMode: AppThemeMode.system,
/// );
///
/// final updatedSettings = settings.copyWith(
///   notificationsEnabled: false,
/// );
/// ```
class AppSettings extends Equatable {
  /// Creates an [AppSettings] instance.
  ///
  /// All parameters have default values:
  /// - [notificationsEnabled] defaults to `true`
  /// - [themeMode] defaults to [AppThemeMode.system]
  const AppSettings({
    this.notificationsEnabled = true,
    this.themeMode = AppThemeMode.system,
  });

  /// Whether push notifications are enabled.
  ///
  /// When `true`, the app can send push notifications to the user.
  /// When `false`, notifications are disabled.
  final bool notificationsEnabled;

  /// The selected theme mode for the application.
  ///
  /// Determines whether the app uses light, dark, or system theme.
  final AppThemeMode themeMode;

  /// Creates a copy of this [AppSettings] with the given fields replaced.
  ///
  /// If a field is not provided, the current value is retained.
  ///
  /// Example:
  /// ```dart
  /// final settings = AppSettings();
  /// final darkSettings = settings.copyWith(themeMode: AppThemeMode.dark);
  /// ```
  AppSettings copyWith({
    bool? notificationsEnabled,
    AppThemeMode? themeMode,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [notificationsEnabled, themeMode];
}
