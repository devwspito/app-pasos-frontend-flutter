import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing secure storage operations.
///
/// Wraps [FlutterSecureStorage] to provide a type-safe interface for
/// storing and retrieving sensitive data like authentication tokens.
///
/// All data is encrypted using platform-specific encryption:
/// - iOS: Keychain Services
/// - Android: EncryptedSharedPreferences (with AES encryption)
///
/// Example:
/// ```dart
/// final storage = SecureStorageService();
/// await storage.saveAccessToken('jwt_token_here');
/// final token = await storage.getAccessToken();
/// ```
class SecureStorageService {
  /// Creates a new [SecureStorageService] instance.
  ///
  /// Optionally accepts a [FlutterSecureStorage] instance for testing purposes.
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(aOptions: _androidOptions);

  /// The underlying secure storage instance.
  final FlutterSecureStorage _storage;

  // ==========================================================================
  // Storage Keys
  // ==========================================================================

  /// Key for storing the access token.
  static const String keyAccessToken = 'access_token';

  /// Key for storing the refresh token.
  static const String keyRefreshToken = 'refresh_token';

  /// Key for storing the user ID.
  static const String keyUserId = 'user_id';

  // ==========================================================================
  // Android-specific Options
  // ==========================================================================

  /// Android-specific storage options with enhanced security.
  ///
  /// Uses EncryptedSharedPreferences for secure storage on Android.
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  // ==========================================================================
  // Access Token Operations
  // ==========================================================================

  /// Saves the access token to secure storage.
  ///
  /// [token] The JWT access token to store.
  ///
  /// Throws [PlatformException] if storage operation fails.
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: keyAccessToken, value: token);
  }

  /// Retrieves the access token from secure storage.
  ///
  /// Returns the stored access token, or `null` if not found.
  ///
  /// Throws [PlatformException] if storage operation fails.
  Future<String?> getAccessToken() async {
    return _storage.read(key: keyAccessToken);
  }

  // ==========================================================================
  // Refresh Token Operations
  // ==========================================================================

  /// Saves the refresh token to secure storage.
  ///
  /// [token] The JWT refresh token to store.
  ///
  /// Throws [PlatformException] if storage operation fails.
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: keyRefreshToken, value: token);
  }

  /// Retrieves the refresh token from secure storage.
  ///
  /// Returns the stored refresh token, or `null` if not found.
  ///
  /// Throws [PlatformException] if storage operation fails.
  Future<String?> getRefreshToken() async {
    return _storage.read(key: keyRefreshToken);
  }

  // ==========================================================================
  // User ID Operations
  // ==========================================================================

  /// Saves the user ID to secure storage.
  ///
  /// [userId] The user's unique identifier to store.
  ///
  /// Throws [PlatformException] if storage operation fails.
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: keyUserId, value: userId);
  }

  /// Retrieves the user ID from secure storage.
  ///
  /// Returns the stored user ID, or `null` if not found.
  ///
  /// Throws [PlatformException] if storage operation fails.
  Future<String?> getUserId() async {
    return _storage.read(key: keyUserId);
  }

  // ==========================================================================
  // Utility Methods
  // ==========================================================================

  /// Clears all stored data from secure storage.
  ///
  /// Use this when logging out to ensure all sensitive data is removed.
  ///
  /// Throws [PlatformException] if storage operation fails.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Checks if an access token exists in secure storage.
  ///
  /// Returns `true` if an access token is stored, `false` otherwise.
  ///
  /// Throws [PlatformException] if storage operation fails.
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Deletes a specific key from secure storage.
  ///
  /// [key] The key to delete.
  ///
  /// Throws [PlatformException] if storage operation fails.
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
