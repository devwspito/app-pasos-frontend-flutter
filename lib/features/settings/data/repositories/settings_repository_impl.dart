/// Implementation of the settings repository using secure storage.
///
/// This file provides the concrete implementation of [SettingsRepository]
/// using [SecureStorageService] for data persistence.
library;

import 'package:app_pasos_frontend/core/storage/secure_storage_service.dart';
import 'package:app_pasos_frontend/features/settings/domain/entities/app_settings.dart';
import 'package:app_pasos_frontend/features/settings/domain/repositories/settings_repository.dart';

/// Implementation of [SettingsRepository] using [SecureStorageService].
///
/// This class persists settings to secure storage using string keys
/// and handles serialization/deserialization of settings values.
///
/// Example usage:
/// ```dart
/// final repository = SettingsRepositoryImpl(storage: secureStorageService);
/// final settings = await repository.getSettings();
/// await repository.updateThemeMode(AppThemeMode.dark);
/// ```
class SettingsRepositoryImpl implements SettingsRepository {
  /// Creates a [SettingsRepositoryImpl] instance.
  ///
  /// [storage] - The [SecureStorageService] instance for data persistence.
  SettingsRepositoryImpl({required SecureStorageService storage})
      : _storage = storage;

  /// The secure storage service for persisting settings.
  final SecureStorageService _storage;

  /// Storage key for the notifications enabled setting.
  static const _notificationsKey = 'settings_notifications_enabled';

  /// Storage key for the theme mode setting.
  static const _themeModeKey = 'settings_theme_mode';

  @override
  Future<AppSettings> getSettings() async {
    final notificationsStr = await _storage.read(_notificationsKey);
    final themeModeStr = await _storage.read(_themeModeKey);

    return AppSettings(
      notificationsEnabled: _parseNotificationsEnabled(notificationsStr),
      themeMode: _parseThemeMode(themeModeStr),
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await Future.wait([
      _storage.write(
        _notificationsKey,
        settings.notificationsEnabled.toString(),
      ),
      _storage.write(
        _themeModeKey,
        _themeModeToString(settings.themeMode),
      ),
    ]);
  }

  @override
  Future<void> updateNotificationsEnabled({required bool enabled}) async {
    await _storage.write(_notificationsKey, enabled.toString());
  }

  @override
  Future<void> updateThemeMode(AppThemeMode mode) async {
    await _storage.write(_themeModeKey, _themeModeToString(mode));
  }

  /// Parses the notifications enabled string to a boolean.
  ///
  /// Returns `true` if the value is not explicitly 'false'.
  /// This ensures notifications are enabled by default.
  bool _parseNotificationsEnabled(String? value) {
    if (value == null) return true;
    return value.toLowerCase() != 'false';
  }

  /// Parses a string value to [AppThemeMode].
  ///
  /// Returns [AppThemeMode.system] for null or unrecognized values.
  AppThemeMode _parseThemeMode(String? value) {
    if (value == null) return AppThemeMode.system;

    return switch (value.toLowerCase()) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      'system' => AppThemeMode.system,
      _ => AppThemeMode.system,
    };
  }

  /// Converts [AppThemeMode] to a string for storage.
  String _themeModeToString(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.light => 'light',
      AppThemeMode.dark => 'dark',
      AppThemeMode.system => 'system',
    };
  }
}
