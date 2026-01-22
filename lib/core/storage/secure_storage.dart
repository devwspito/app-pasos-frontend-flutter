import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstract interface for secure storage operations.
///
/// Used for storing sensitive data like JWT tokens.
/// Implementations should use platform-specific secure storage.
abstract interface class SecureStorage {
  /// Reads a value from secure storage.
  Future<String?> read(String key);

  /// Writes a value to secure storage.
  Future<void> write(String key, String value);

  /// Deletes a value from secure storage.
  Future<void> delete(String key);

  /// Deletes all values from secure storage.
  Future<void> deleteAll();

  /// Checks if a key exists in secure storage.
  Future<bool> containsKey(String key);
}

/// Implementation of [SecureStorage] using flutter_secure_storage.
///
/// Uses Android EncryptedSharedPreferences and iOS Keychain
/// for secure storage of sensitive data.
final class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl() : _storage = _createSecureStorage();

  final FlutterSecureStorage _storage;

  /// Creates a FlutterSecureStorage instance with platform-specific options.
  static FlutterSecureStorage _createSecureStorage() {
    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'app_pasos_secure_prefs',
      preferencesKeyPrefix: 'app_pasos_',
    );

    const iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'app_pasos',
    );

    return const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );
  }

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
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }
}

/// Storage keys for secure storage.
abstract final class SecureStorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String tokenExpiry = 'token_expiry';
}

/// Extension methods for convenient token management.
extension SecureStorageTokenExtension on SecureStorage {
  /// Gets the stored access token.
  Future<String?> getAccessToken() => read(SecureStorageKeys.accessToken);

  /// Saves the access token.
  Future<void> saveAccessToken(String token) =>
      write(SecureStorageKeys.accessToken, token);

  /// Deletes the access token.
  Future<void> deleteAccessToken() => delete(SecureStorageKeys.accessToken);

  /// Gets the stored refresh token.
  Future<String?> getRefreshToken() => read(SecureStorageKeys.refreshToken);

  /// Saves the refresh token.
  Future<void> saveRefreshToken(String token) =>
      write(SecureStorageKeys.refreshToken, token);

  /// Deletes the refresh token.
  Future<void> deleteRefreshToken() => delete(SecureStorageKeys.refreshToken);

  /// Gets the stored user ID.
  Future<String?> getUserId() => read(SecureStorageKeys.userId);

  /// Saves the user ID.
  Future<void> saveUserId(String userId) =>
      write(SecureStorageKeys.userId, userId);

  /// Deletes the user ID.
  Future<void> deleteUserId() => delete(SecureStorageKeys.userId);

  /// Gets the token expiry timestamp.
  Future<DateTime?> getTokenExpiry() async {
    final expiryStr = await read(SecureStorageKeys.tokenExpiry);
    if (expiryStr == null) return null;
    return DateTime.tryParse(expiryStr);
  }

  /// Saves the token expiry timestamp.
  Future<void> saveTokenExpiry(DateTime expiry) =>
      write(SecureStorageKeys.tokenExpiry, expiry.toIso8601String());

  /// Checks if the current token is expired.
  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  /// Saves all auth tokens at once.
  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiry,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    if (expiry != null) {
      await saveTokenExpiry(expiry);
    }
  }

  /// Clears all auth-related data.
  Future<void> clearAuthData() async {
    await deleteAccessToken();
    await deleteRefreshToken();
    await deleteUserId();
    await delete(SecureStorageKeys.tokenExpiry);
  }

  /// Checks if user is authenticated (has access token).
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
