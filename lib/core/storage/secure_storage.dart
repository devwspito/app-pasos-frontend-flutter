import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstract class for secure storage operations.
abstract class SecureStorage {
  /// Store a value securely.
  Future<void> write({required String key, required String? value});

  /// Read a value from secure storage.
  Future<String?> read({required String key});

  /// Delete a value from secure storage.
  Future<void> delete({required String key});

  /// Delete all values from secure storage.
  Future<void> deleteAll();

  /// Check if a key exists in secure storage.
  Future<bool> containsKey({required String key});
}

/// Implementation of [SecureStorage] using flutter_secure_storage package.
class SecureStorageImpl implements SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorageImpl() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<void> write({required String key, required String? value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }
}

/// Keys used for secure storage
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
}
