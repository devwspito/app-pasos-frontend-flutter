/// User settings model for the data layer.
///
/// This file contains the data model for UserSettings, extending the domain
/// entity and adding JSON serialization capabilities.
library;

import 'package:app_pasos_frontend/features/settings/domain/entities/user_settings.dart';
import 'package:flutter/material.dart';

/// Data model extending [UserSettings] with JSON serialization.
///
/// This class serves as a bridge between the API response and the domain
/// entity, providing methods to convert to/from JSON.
///
/// Example usage:
/// ```dart
/// // From API response
/// final json = {
///   'notificationsEnabled': true,
///   'dailyGoalReminder': '09:00',
///   'themePreference': 'system'
/// };
/// final settingsModel = UserSettingsModel.fromJson(json);
///
/// // To JSON for requests
/// final requestBody = settingsModel.toJson();
/// ```
class UserSettingsModel extends UserSettings {
  /// Creates a [UserSettingsModel] instance.
  const UserSettingsModel({
    required super.notificationsEnabled,
    required super.themePreference,
    super.dailyGoalReminder,
  });

  /// Creates a [UserSettingsModel] from a JSON map.
  ///
  /// [json] - The JSON map from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "notificationsEnabled": true,
  ///   "dailyGoalReminder": "09:00",
  ///   "themePreference": "system"
  /// }
  /// ```
  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      dailyGoalReminder: _parseTimeOfDay(json['dailyGoalReminder'] as String?),
      themePreference: _parseThemePreference(json['themePreference'] as String?),
    );
  }

  /// Creates a [UserSettingsModel] from a domain [UserSettings] entity.
  ///
  /// Useful when you need to convert a domain entity back to a model
  /// for data operations.
  factory UserSettingsModel.fromEntity(UserSettings settings) {
    return UserSettingsModel(
      notificationsEnabled: settings.notificationsEnabled,
      dailyGoalReminder: settings.dailyGoalReminder,
      themePreference: settings.themePreference,
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded for API requests.
  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      if (dailyGoalReminder != null)
        'dailyGoalReminder': _formatTimeOfDay(dailyGoalReminder!),
      'themePreference': themePreference.name,
    };
  }

  /// Creates a copy of this model with updated fields.
  ///
  /// Any parameter that is not provided will retain its current value.
  @override
  UserSettingsModel copyWith({
    bool? notificationsEnabled,
    TimeOfDay? dailyGoalReminder,
    ThemePreference? themePreference,
    bool clearDailyGoalReminder = false,
  }) {
    return UserSettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyGoalReminder: clearDailyGoalReminder
          ? null
          : (dailyGoalReminder ?? this.dailyGoalReminder),
      themePreference: themePreference ?? this.themePreference,
    );
  }

  /// Parses a time string (HH:mm) to [TimeOfDay].
  static TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return null;
    }
    final parts = timeString.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Formats [TimeOfDay] to a time string (HH:mm).
  static String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Parses a theme preference string to [ThemePreference].
  static ThemePreference _parseThemePreference(String? value) {
    return switch (value?.toLowerCase()) {
      'light' => ThemePreference.light,
      'dark' => ThemePreference.dark,
      'system' => ThemePreference.system,
      _ => ThemePreference.system,
    };
  }
}
