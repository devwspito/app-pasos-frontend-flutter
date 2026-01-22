import 'package:shared_preferences/shared_preferences.dart';

/// Abstract interface for local storage operations.
///
/// Used for storing non-sensitive user preferences and app settings.
/// Implementations should use shared preferences or similar.
abstract interface class LocalStorage {
  /// Gets a string value.
  String? getString(String key);

  /// Sets a string value.
  Future<bool> setString(String key, String value);

  /// Gets an integer value.
  int? getInt(String key);

  /// Sets an integer value.
  Future<bool> setInt(String key, int value);

  /// Gets a double value.
  double? getDouble(String key);

  /// Sets a double value.
  Future<bool> setDouble(String key, double value);

  /// Gets a boolean value.
  bool? getBool(String key);

  /// Sets a boolean value.
  Future<bool> setBool(String key, bool value);

  /// Gets a list of strings.
  List<String>? getStringList(String key);

  /// Sets a list of strings.
  Future<bool> setStringList(String key, List<String> value);

  /// Removes a value.
  Future<bool> remove(String key);

  /// Clears all values.
  Future<bool> clear();

  /// Checks if a key exists.
  bool containsKey(String key);

  /// Gets all keys.
  Set<String> getKeys();
}

/// Implementation of [LocalStorage] using shared_preferences.
///
/// Requires async initialization before use via [init] factory method.
final class LocalStorageImpl implements LocalStorage {
  LocalStorageImpl._(this._prefs);

  final SharedPreferences _prefs;

  /// Factory method to create and initialize LocalStorage.
  /// Must be called with await before using the storage.
  static Future<LocalStorageImpl> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageImpl._(prefs);
  }

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  double? getDouble(String key) => _prefs.getDouble(key);

  @override
  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  @override
  Future<bool> remove(String key) => _prefs.remove(key);

  @override
  Future<bool> clear() => _prefs.clear();

  @override
  bool containsKey(String key) => _prefs.containsKey(key);

  @override
  Set<String> getKeys() => _prefs.getKeys();
}

/// Storage keys for local storage.
abstract final class LocalStorageKeys {
  static const String isDarkMode = 'is_dark_mode';
  static const String locale = 'locale';
  static const String isFirstLaunch = 'is_first_launch';
  static const String lastSyncTime = 'last_sync_time';
  static const String cacheVersion = 'cache_version';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String biometricsEnabled = 'biometrics_enabled';
  static const String fontSize = 'font_size';
}

/// Extension methods for convenient preference management.
extension LocalStoragePreferencesExtension on LocalStorage {
  /// Gets the dark mode preference.
  bool get isDarkMode => getBool(LocalStorageKeys.isDarkMode) ?? false;

  /// Sets the dark mode preference.
  Future<bool> setIsDarkMode(bool value) =>
      setBool(LocalStorageKeys.isDarkMode, value);

  /// Gets the locale preference.
  String? get locale => getString(LocalStorageKeys.locale);

  /// Sets the locale preference.
  Future<bool> setLocale(String locale) =>
      setString(LocalStorageKeys.locale, locale);

  /// Checks if this is the first app launch.
  bool get isFirstLaunch => getBool(LocalStorageKeys.isFirstLaunch) ?? true;

  /// Sets the first launch flag.
  Future<bool> setIsFirstLaunch(bool value) =>
      setBool(LocalStorageKeys.isFirstLaunch, value);

  /// Gets the last sync timestamp.
  DateTime? get lastSyncTime {
    final timestamp = getInt(LocalStorageKeys.lastSyncTime);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Sets the last sync timestamp.
  Future<bool> setLastSyncTime(DateTime time) =>
      setInt(LocalStorageKeys.lastSyncTime, time.millisecondsSinceEpoch);

  /// Gets the cache version.
  int get cacheVersion => getInt(LocalStorageKeys.cacheVersion) ?? 0;

  /// Sets the cache version.
  Future<bool> setCacheVersion(int version) =>
      setInt(LocalStorageKeys.cacheVersion, version);

  /// Checks if notifications are enabled.
  bool get notificationsEnabled =>
      getBool(LocalStorageKeys.notificationsEnabled) ?? true;

  /// Sets the notifications preference.
  Future<bool> setNotificationsEnabled(bool value) =>
      setBool(LocalStorageKeys.notificationsEnabled, value);

  /// Checks if biometrics are enabled.
  bool get biometricsEnabled =>
      getBool(LocalStorageKeys.biometricsEnabled) ?? false;

  /// Sets the biometrics preference.
  Future<bool> setBiometricsEnabled(bool value) =>
      setBool(LocalStorageKeys.biometricsEnabled, value);

  /// Gets the font size preference.
  double get fontSize => getDouble(LocalStorageKeys.fontSize) ?? 1.0;

  /// Sets the font size preference.
  Future<bool> setFontSize(double size) =>
      setDouble(LocalStorageKeys.fontSize, size);

  /// Clears all user preferences (for logout).
  Future<void> clearUserPreferences() async {
    await remove(LocalStorageKeys.lastSyncTime);
    await remove(LocalStorageKeys.cacheVersion);
    // Keep theme, locale, and accessibility settings
  }
}
