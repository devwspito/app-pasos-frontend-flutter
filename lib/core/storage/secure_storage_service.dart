/// Secure storage service for sensitive data in App Pasos.
///
/// This file defines an abstract interface and implementation for secure
/// storage operations. Uses flutter_secure_storage for encrypted storage
/// of sensitive data like authentication tokens.
library;

import 'package:app_pasos_frontend/core/constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstract interface for secure storage operations.
///
/// This interface enables dependency injection and testing by allowing
/// mock implementations. All sensitive data storage should go through
/// this service.
///
/// Example usage:
/// ```dart
/// final storage = SecureStorageServiceImpl();
/// await storage.saveAuthToken('jwt_token_here');
/// final token = await storage.getAuthToken();
/// ```
abstract interface class SecureStorageService {
  /// Saves the authentication JWT token.
  ///
  /// [token] - The JWT token to store securely.
  Future<void> saveAuthToken(String token);

  /// Retrieves the stored authentication token.
  ///
  /// Returns `null` if no token is stored.
  Future<String?> getAuthToken();

  /// Deletes the stored authentication token.
  Future<void> deleteAuthToken();

  /// Saves the refresh token for token renewal.
  ///
  /// [token] - The refresh token to store securely.
  Future<void> saveRefreshToken(String token);

  /// Retrieves the stored refresh token.
  ///
  /// Returns `null` if no refresh token is stored.
  Future<String?> getRefreshToken();

  /// Deletes the stored refresh token.
  Future<void> deleteRefreshToken();

  /// Saves the current user's ID.
  ///
  /// [userId] - The user's unique identifier.
  Future<void> saveUserId(String userId);

  /// Retrieves the stored user ID.
  ///
  /// Returns `null` if no user ID is stored.
  Future<String?> getUserId();

  /// Deletes the stored user ID.
  Future<void> deleteUserId();

  /// Saves the user's email address.
  ///
  /// [email] - The user's email address.
  Future<void> saveUserEmail(String email);

  /// Retrieves the stored user email.
  ///
  /// Returns `null` if no email is stored.
  Future<String?> getUserEmail();

  /// Saves the user's display name.
  ///
  /// [name] - The user's display name.
  Future<void> saveUserName(String name);

  /// Retrieves the stored user name.
  ///
  /// Returns `null` if no name is stored.
  Future<String?> getUserName();

  /// Checks if the user is authenticated.
  ///
  /// Returns `true` if an auth token exists, `false` otherwise.
  Future<bool> isAuthenticated();

  /// Clears all authentication-related data.
  ///
  /// Use this during logout to remove all sensitive data.
  Future<void> clearAuthData();

  /// Deletes all stored data.
  ///
  /// Use with caution - this removes ALL data from secure storage.
  Future<void> deleteAll();

  /// Reads a value by key.
  ///
  /// [key] - The storage key to read.
  /// Returns `null` if the key doesn't exist.
  Future<String?> read(String key);

  /// Writes a value by key.
  ///
  /// [key] - The storage key.
  /// [value] - The value to store.
  Future<void> write(String key, String value);

  /// Deletes a value by key.
  ///
  /// [key] - The storage key to delete.
  Future<void> delete(String key);

  /// Checks if a key exists in storage.
  ///
  /// [key] - The storage key to check.
  Future<bool> containsKey(String key);
}

/// Implementation of [SecureStorageService] using flutter_secure_storage.
///
/// This implementation uses platform-specific secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences (AES-256)
/// - Web: Encrypted local storage
///
/// Example usage:
/// ```dart
/// final storage = SecureStorageServiceImpl();
/// await storage.saveAuthToken('my_jwt_token');
/// ```
class SecureStorageServiceImpl implements SecureStorageService {
  /// Creates a [SecureStorageServiceImpl] instance.
  ///
  /// Optionally accepts a [FlutterSecureStorage] instance for testing.
  SecureStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? _createSecureStorage();

  /// Creates secure storage with platform-appropriate options.
  static FlutterSecureStorage _createSecureStorage() {
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        sharedPreferencesName: 'app_pasos_secure_prefs',
        preferencesKeyPrefix: 'app_pasos_',
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        accountName: 'app_pasos_keychain',
      ),
      webOptions: WebOptions(
        dbName: 'app_pasos_secure_db',
        publicKey: 'app_pasos_public_key',
      ),
    );
  }

  /// The underlying secure storage instance.
  final FlutterSecureStorage _storage;

  // ============================================================
  // Auth Token Operations
  // ============================================================

  @override
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: StorageKeys.authToken, value: token);
  }

  @override
  Future<String?> getAuthToken() async {
    return _storage.read(key: StorageKeys.authToken);
  }

  @override
  Future<void> deleteAuthToken() async {
    await _storage.delete(key: StorageKeys.authToken);
  }

  // ============================================================
  // Refresh Token Operations
  // ============================================================

  @override
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage.read(key: StorageKeys.refreshToken);
  }

  @override
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: StorageKeys.refreshToken);
  }

  // ============================================================
  // User ID Operations
  // ============================================================

  @override
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: StorageKeys.userId, value: userId);
  }

  @override
  Future<String?> getUserId() async {
    return _storage.read(key: StorageKeys.userId);
  }

  @override
  Future<void> deleteUserId() async {
    await _storage.delete(key: StorageKeys.userId);
  }

  // ============================================================
  // User Email Operations
  // ============================================================

  @override
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: StorageKeys.userEmail, value: email);
  }

  @override
  Future<String?> getUserEmail() async {
    return _storage.read(key: StorageKeys.userEmail);
  }

  // ============================================================
  // User Name Operations
  // ============================================================

  @override
  Future<void> saveUserName(String name) async {
    await _storage.write(key: StorageKeys.userName, value: name);
  }

  @override
  Future<String?> getUserName() async {
    return _storage.read(key: StorageKeys.userName);
  }

  // ============================================================
  // Authentication Status
  // ============================================================

  @override
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // Bulk Operations
  // ============================================================

  @override
  Future<void> clearAuthData() async {
    await Future.wait([
      deleteAuthToken(),
      deleteRefreshToken(),
      deleteUserId(),
      _storage.delete(key: StorageKeys.userEmail),
      _storage.delete(key: StorageKeys.userName),
    ]);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // ============================================================
  // Generic Operations
  // ============================================================

  @override
  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }
}
