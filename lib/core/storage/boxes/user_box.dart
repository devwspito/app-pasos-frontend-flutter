/// User box for offline storage of user data in App Pasos.
///
/// This file provides a typed wrapper around a Hive box for storing
/// user profile and settings data. Uses predefined keys: 'profile'
/// and 'settings'.
library;

import 'package:hive_flutter/hive_flutter.dart';

/// Wrapper class for the user Hive box.
///
/// Provides typed methods for storing and retrieving user profile
/// and settings data. Data is stored as Map<String, dynamic>.
///
/// Example usage:
/// ```dart
/// final userBox = UserBox();
///
/// // Save user profile
/// await userBox.saveProfile({
///   'id': 'user-123',
///   'email': 'john@example.com',
///   'name': 'John Doe',
///   'createdAt': '2024-01-01T00:00:00.000Z',
/// });
///
/// // Save settings
/// await userBox.saveSettings({
///   'darkMode': true,
///   'notifications': true,
///   'dailyGoal': 10000,
/// });
///
/// // Retrieve data
/// final profile = userBox.getProfile();
/// final settings = userBox.getSettings();
/// ```
class UserBox {
  /// The name of this box in Hive storage.
  static const String boxName = 'user_box';

  /// Key for storing user profile data.
  static const String profileKey = 'profile';

  /// Key for storing user settings.
  static const String settingsKey = 'settings';

  /// Key for storing the last sync timestamp.
  static const String _lastSyncKey = '_user_last_sync_timestamp';

  // ============================================================
  // Box Access
  // ============================================================

  /// Gets the underlying Hive box.
  ///
  /// Throws `HiveError` if the box is not open.
  /// Ensure `HiveService.initialize()` has been called first.
  Box<Map<dynamic, dynamic>> get _box {
    if (!Hive.isBoxOpen(boxName)) {
      throw HiveError(
        'UserBox is not open. Call HiveService.initialize() first.',
      );
    }
    return Hive.box<Map<dynamic, dynamic>>(boxName);
  }

  // ============================================================
  // Profile Operations
  // ============================================================

  /// Saves the user profile.
  ///
  /// [profile] - The user profile data as a Map.
  ///
  /// Expected profile structure:
  /// ```json
  /// {
  ///   "id": "string",
  ///   "email": "string",
  ///   "name": "string",
  ///   "createdAt": "string (ISO8601)"
  /// }
  /// ```
  ///
  /// Example:
  /// ```dart
  /// await userBox.saveProfile({
  ///   'id': 'user-123',
  ///   'email': 'john@example.com',
  ///   'name': 'John Doe',
  /// });
  /// ```
  Future<void> saveProfile(Map<String, dynamic> profile) async {
    // Convert to Map<dynamic, dynamic> for Hive compatibility
    final hiveMap = Map<dynamic, dynamic>.from(profile);
    await _box.put(profileKey, hiveMap);
  }

  /// Gets the user profile.
  ///
  /// Returns the profile as a Map, or `null` if no profile is stored.
  ///
  /// Example:
  /// ```dart
  /// final profile = userBox.getProfile();
  /// if (profile != null) {
  ///   print('User: ${profile['name']}');
  /// }
  /// ```
  Map<String, dynamic>? getProfile() {
    final hiveMap = _box.get(profileKey);
    if (hiveMap == null) {
      return null;
    }
    // Convert back to Map<String, dynamic>
    return _convertToStringDynamicMap(hiveMap);
  }

  /// Deletes the user profile.
  ///
  /// This method is safe to call even if no profile is stored.
  ///
  /// Example:
  /// ```dart
  /// await userBox.deleteProfile();
  /// ```
  Future<void> deleteProfile() async {
    await _box.delete(profileKey);
  }

  // ============================================================
  // Settings Operations
  // ============================================================

  /// Saves user settings.
  ///
  /// [settings] - The user settings data as a Map.
  ///
  /// Settings can contain any key-value pairs needed by the app.
  ///
  /// Example:
  /// ```dart
  /// await userBox.saveSettings({
  ///   'darkMode': true,
  ///   'notifications': true,
  ///   'dailyGoal': 10000,
  ///   'language': 'en',
  /// });
  /// ```
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    // Convert to Map<dynamic, dynamic> for Hive compatibility
    final hiveMap = Map<dynamic, dynamic>.from(settings);
    await _box.put(settingsKey, hiveMap);
  }

  /// Gets user settings.
  ///
  /// Returns the settings as a Map, or `null` if no settings are stored.
  ///
  /// Example:
  /// ```dart
  /// final settings = userBox.getSettings();
  /// if (settings != null) {
  ///   final darkMode = settings['darkMode'] as bool? ?? false;
  ///   print('Dark mode: $darkMode');
  /// }
  /// ```
  Map<String, dynamic>? getSettings() {
    final hiveMap = _box.get(settingsKey);
    if (hiveMap == null) {
      return null;
    }
    // Convert back to Map<String, dynamic>
    return _convertToStringDynamicMap(hiveMap);
  }

  /// Deletes user settings.
  ///
  /// This method is safe to call even if no settings are stored.
  ///
  /// Example:
  /// ```dart
  /// await userBox.deleteSettings();
  /// ```
  Future<void> deleteSettings() async {
    await _box.delete(settingsKey);
  }

  // ============================================================
  // Generic Operations
  // ============================================================

  /// Saves data with a custom key.
  ///
  /// [key] - The storage key.
  /// [data] - The data to store as a Map.
  ///
  /// Use this for storing additional user-related data beyond
  /// profile and settings.
  ///
  /// Example:
  /// ```dart
  /// await userBox.save('preferences', {'theme': 'dark'});
  /// ```
  Future<void> save(String key, Map<String, dynamic> data) async {
    final hiveMap = Map<dynamic, dynamic>.from(data);
    await _box.put(key, hiveMap);
  }

  /// Gets data by key.
  ///
  /// [key] - The storage key.
  ///
  /// Returns the data as a Map, or `null` if the key doesn't exist.
  ///
  /// Example:
  /// ```dart
  /// final prefs = userBox.get('preferences');
  /// ```
  Map<String, dynamic>? get(String key) {
    final hiveMap = _box.get(key);
    if (hiveMap == null) {
      return null;
    }
    return _convertToStringDynamicMap(hiveMap);
  }

  /// Deletes data by key.
  ///
  /// [key] - The storage key to delete.
  ///
  /// This method is safe to call even if the key doesn't exist.
  ///
  /// Example:
  /// ```dart
  /// await userBox.delete('preferences');
  /// ```
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  /// Clears all user data from storage.
  ///
  /// This removes ALL user data including profile and settings.
  /// Use with caution as this cannot be undone.
  ///
  /// Example:
  /// ```dart
  /// await userBox.clearAll();
  /// ```
  Future<void> clearAll() async {
    await _box.clear();
  }

  // ============================================================
  // Sync Timestamp Management
  // ============================================================

  /// Gets the timestamp of the last synchronization.
  ///
  /// Returns the [DateTime] when user data was last synced with the server,
  /// or `null` if no sync has ever occurred.
  ///
  /// Example:
  /// ```dart
  /// final lastSync = userBox.getLastSyncTimestamp();
  /// if (lastSync != null) {
  ///   print('Last synced: $lastSync');
  /// }
  /// ```
  DateTime? getLastSyncTimestamp() {
    final hiveMap = _box.get(_lastSyncKey);
    if (hiveMap == null) {
      return null;
    }

    final timestamp = hiveMap['timestamp'];
    if (timestamp == null) {
      return null;
    }

    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    }

    return null;
  }

  /// Sets the last synchronization timestamp.
  ///
  /// [timestamp] - The [DateTime] of the sync operation.
  ///
  /// Call this after a successful sync with the server.
  ///
  /// Example:
  /// ```dart
  /// await userBox.setLastSyncTimestamp(DateTime.now());
  /// ```
  Future<void> setLastSyncTimestamp(DateTime timestamp) async {
    final hiveMap = <dynamic, dynamic>{
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
    await _box.put(_lastSyncKey, hiveMap);
  }

  // ============================================================
  // Helpers
  // ============================================================

  /// Converts a Hive Map to Map<String, dynamic>.
  Map<String, dynamic> _convertToStringDynamicMap(
    Map<dynamic, dynamic> hiveMap,
  ) {
    return hiveMap.map((key, value) {
      if (value is Map<dynamic, dynamic>) {
        return MapEntry(
          key.toString(),
          _convertToStringDynamicMap(value),
        );
      }
      return MapEntry(key.toString(), value);
    });
  }
}
