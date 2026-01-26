import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage key constants for local storage operations.
/// These will be migrated to AppConstants once story-2 is complete.
class _LocalStorageKeys {
  static const String userKey = 'user_data';
}

/// Abstract interface for local storage operations.
///
/// Provides a contract for general-purpose local storage,
/// including user data and arbitrary key-value pairs.
abstract class ILocalStorage {
  /// Saves user data as a JSON-encoded map.
  Future<void> saveUser(Map<String, dynamic> userData);

  /// Retrieves the stored user data as a decoded map.
  Future<Map<String, dynamic>?> getUser();

  /// Deletes the stored user data.
  Future<void> deleteUser();

  /// Saves a string value with the given key.
  Future<void> saveString(String key, String value);

  /// Retrieves a string value for the given key.
  Future<String?> getString(String key);

  /// Deletes the value for the given key.
  Future<void> delete(String key);

  /// Checks if a key exists in storage.
  Future<bool> containsKey(String key);

  /// Deletes all stored data.
  Future<void> deleteAll();
}

/// Implementation of [ILocalStorage] using flutter_secure_storage.
///
/// This service provides secure local storage for non-sensitive data
/// like user preferences and cached user information.
/// Uses flutter_secure_storage for consistency with [SecureStorageService].
///
/// Example usage:
/// ```dart
/// final storage = LocalStorageService();
/// await storage.saveUser({'id': '123', 'name': 'John'});
/// final user = await storage.getUser();
/// ```
class LocalStorageService implements ILocalStorage {
  final FlutterSecureStorage _storage;

  /// Creates a [LocalStorageService] with optional custom storage instance.
  ///
  /// If no storage is provided, creates a default [FlutterSecureStorage]
  /// instance with default configuration.
  LocalStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveUser(Map<String, dynamic> userData) async {
    if (userData.isEmpty) {
      throw ArgumentError('User data cannot be empty');
    }
    final encodedData = jsonEncode(userData);
    await _storage.write(key: _LocalStorageKeys.userKey, value: encodedData);
  }

  @override
  Future<Map<String, dynamic>?> getUser() async {
    final data = await _storage.read(key: _LocalStorageKeys.userKey);
    if (data == null || data.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } on FormatException {
      // If data is corrupted, delete it and return null
      await deleteUser();
      return null;
    }
  }

  @override
  Future<void> deleteUser() async {
    await _storage.delete(key: _LocalStorageKeys.userKey);
  }

  @override
  Future<void> saveString(String key, String value) async {
    if (key.isEmpty) {
      throw ArgumentError('Key cannot be empty');
    }
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> getString(String key) async {
    if (key.isEmpty) {
      throw ArgumentError('Key cannot be empty');
    }
    return await _storage.read(key: key);
  }

  @override
  Future<void> delete(String key) async {
    if (key.isEmpty) {
      throw ArgumentError('Key cannot be empty');
    }
    await _storage.delete(key: key);
  }

  @override
  Future<bool> containsKey(String key) async {
    if (key.isEmpty) {
      throw ArgumentError('Key cannot be empty');
    }
    final value = await _storage.read(key: key);
    return value != null;
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
