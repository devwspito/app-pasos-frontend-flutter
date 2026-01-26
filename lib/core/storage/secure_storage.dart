import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage key constants for secure storage operations.
/// These will be migrated to AppConstants once story-2 is complete.
class _StorageKeys {
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
}

/// Abstract interface for secure storage operations.
///
/// Provides a contract for JWT token management operations,
/// allowing for easy testing and mocking.
abstract class ISecureStorage {
  /// Saves the authentication JWT token.
  Future<void> saveToken(String token);

  /// Retrieves the stored authentication JWT token.
  Future<String?> getToken();

  /// Saves the refresh token for token renewal.
  Future<void> saveRefreshToken(String token);

  /// Retrieves the stored refresh token.
  Future<String?> getRefreshToken();

  /// Deletes the stored authentication token.
  Future<void> deleteToken();

  /// Deletes the stored refresh token.
  Future<void> deleteRefreshToken();

  /// Deletes all stored secure data.
  Future<void> deleteAll();

  /// Checks if a valid authentication token exists.
  Future<bool> hasToken();
}

/// Implementation of [ISecureStorage] using flutter_secure_storage.
///
/// This service provides secure storage for sensitive data like JWT tokens
/// using platform-specific encryption:
/// - Android: EncryptedSharedPreferences (AES-256)
/// - iOS: Keychain with first_unlock accessibility
///
/// Example usage:
/// ```dart
/// final storage = SecureStorageService();
/// await storage.saveToken('jwt_token_here');
/// final token = await storage.getToken();
/// ```
class SecureStorageService implements ISecureStorage {
  final FlutterSecureStorage _storage;

  /// Creates a [SecureStorageService] with optional custom storage instance.
  ///
  /// If no storage is provided, creates a default instance with:
  /// - Android: encryptedSharedPreferences enabled for AES-256 encryption
  /// - iOS: first_unlock accessibility for reasonable security/usability balance
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  @override
  Future<void> saveToken(String token) async {
    if (token.isEmpty) {
      throw ArgumentError('Token cannot be empty');
    }
    await _storage.write(key: _StorageKeys.tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _StorageKeys.tokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    if (token.isEmpty) {
      throw ArgumentError('Refresh token cannot be empty');
    }
    await _storage.write(key: _StorageKeys.refreshTokenKey, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _StorageKeys.refreshTokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await _storage.delete(key: _StorageKeys.tokenKey);
  }

  @override
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _StorageKeys.refreshTokenKey);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
