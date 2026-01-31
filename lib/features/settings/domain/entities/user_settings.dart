/// User settings entity for the settings domain.
///
/// This is a pure domain entity representing user settings in the application.
/// It's independent of any data layer implementation details.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Theme preference options for the application.
///
/// - [light]: Light theme mode
/// - [dark]: Dark theme mode
/// - [system]: Follows system theme setting
enum ThemePreference {
  /// Light theme mode.
  light,

  /// Dark theme mode.
  dark,

  /// Follows system theme setting.
  system,
}

/// Represents user settings in the application.
///
/// This entity is the core domain representation of user settings, containing
/// notification preferences, reminder times, and theme preferences.
///
/// Example usage:
/// ```dart
/// final settings = UserSettings(
///   notificationsEnabled: true,
///   dailyGoalReminder: TimeOfDay(hour: 9, minute: 0),
///   themePreference: ThemePreference.system,
/// );
/// ```
class UserSettings extends Equatable {
  /// Creates a [UserSettings] instance.
  ///
  /// [notificationsEnabled] - Whether push notifications are enabled.
  /// [dailyGoalReminder] - Time of day for daily goal reminder (optional).
  /// [themePreference] - The user's preferred theme mode.
  const UserSettings({
    required this.notificationsEnabled,
    required this.themePreference,
    this.dailyGoalReminder,
  });

  /// Whether push notifications are enabled.
  final bool notificationsEnabled;

  /// Time of day for daily goal reminder.
  ///
  /// This may be null if no reminder is set.
  final TimeOfDay? dailyGoalReminder;

  /// The user's preferred theme mode.
  final ThemePreference themePreference;

  /// Creates default settings for new users.
  ///
  /// Useful for initializing state before settings are loaded.
  factory UserSettings.defaults() => const UserSettings(
        notificationsEnabled: true,
        themePreference: ThemePreference.system,
      );

  /// Creates a copy of this settings with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  UserSettings copyWith({
    bool? notificationsEnabled,
    TimeOfDay? dailyGoalReminder,
    ThemePreference? themePreference,
    bool clearDailyGoalReminder = false,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyGoalReminder: clearDailyGoalReminder
          ? null
          : (dailyGoalReminder ?? this.dailyGoalReminder),
      themePreference: themePreference ?? this.themePreference,
    );
  }

  @override
  List<Object?> get props => [
        notificationsEnabled,
        dailyGoalReminder?.hour,
        dailyGoalReminder?.minute,
        themePreference,
      ];

  @override
  String toString() {
    return 'UserSettings(notificationsEnabled: $notificationsEnabled, '
        'dailyGoalReminder: $dailyGoalReminder, '
        'themePreference: $themePreference)';
  }
}
