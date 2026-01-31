/// Settings repository interface for managing application settings.
///
/// This file defines the abstract interface for settings operations,
/// following the Repository pattern from Clean Architecture.
library;

import 'package:app_pasos_frontend/features/settings/domain/entities/app_settings.dart';

/// Abstract interface for settings repository operations.
///
/// This interface defines the contract for settings persistence,
/// enabling dependency injection and testing through mock implementations.
///
/// Example usage:
/// ```dart
/// final repository = SettingsRepositoryImpl(storage: secureStorage);
/// final settings = await repository.getSettings();
/// await repository.updateThemeMode(AppThemeMode.dark);
/// ```
abstract interface class SettingsRepository {
  /// Retrieves the current application settings.
  ///
  /// Returns the stored [AppSettings] or default values if none exist.
  /// This operation reads from secure storage and parses the values.
  ///
  /// Returns an [AppSettings] instance with the current settings.
  Future<AppSettings> getSettings();

  /// Saves the complete application settings.
  ///
  /// [settings] - The [AppSettings] instance to persist.
  ///
  /// This operation writes all settings values to secure storage.
  Future<void> saveSettings(AppSettings settings);

  /// Updates only the notifications enabled setting.
  ///
  /// [enabled] - Whether notifications should be enabled.
  ///
  /// This is a convenience method for updating just the notification setting
  /// without affecting other settings.
  Future<void> updateNotificationsEnabled({required bool enabled});

  /// Updates only the theme mode setting.
  ///
  /// [mode] - The [AppThemeMode] to set.
  ///
  /// This is a convenience method for updating just the theme mode
  /// without affecting other settings.
  Future<void> updateThemeMode(AppThemeMode mode);
}
