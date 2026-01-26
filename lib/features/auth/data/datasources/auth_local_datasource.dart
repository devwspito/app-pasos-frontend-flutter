import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import 'auth_remote_datasource.dart';

/// Abstract interface for local authentication data source.
///
/// This datasource handles all local storage operations related to authentication,
/// including storing and retrieving tokens and user data using secure storage.
abstract class AuthLocalDataSource {
  /// Saves both access and refresh tokens to secure storage.
  ///
  /// [accessToken] The JWT access token to store.
  /// [refreshToken] The refresh token to store.
  Future<void> saveTokens(String accessToken, String refreshToken);

  /// Retrieves the stored access token.
  ///
  /// Returns the access token string, or null if not found.
  Future<String?> getAccessToken();

  /// Retrieves the stored refresh token.
  ///
  /// Returns the refresh token string, or null if not found.
  Future<String?> getRefreshToken();

  /// Clears all stored tokens from secure storage.
  Future<void> clearTokens();

  /// Saves user data to secure storage.
  ///
  /// [user] The UserModel to store.
  Future<void> saveUser(UserModel user);

  /// Retrieves the stored user data.
  ///
  /// Returns the UserModel, or null if not found.
  Future<UserModel?> getUser();

  /// Clears all stored user data from secure storage.
  Future<void> clearUser();

  /// Clears all authentication data (tokens and user).
  Future<void> clearAll();

  /// Checks if the user is currently authenticated (has tokens).
  ///
  /// Returns true if access token exists, false otherwise.
  Future<bool> isAuthenticated();
}

/// Implementation of [AuthLocalDataSource] using FlutterSecureStorage.
///
/// This class handles all local storage operations for authentication data
/// using Flutter Secure Storage, which provides secure key-value storage
/// using platform-specific encryption (Keychain on iOS, Keystore on Android).
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;

  /// Android options for secure storage.
  /// Using encrypted shared preferences for better security.
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  /// iOS options for secure storage.
  /// Using first unlock accessibility for better user experience.
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  /// Creates an [AuthLocalDataSourceImpl] instance.
  ///
  /// [secureStorage] Optional FlutterSecureStorage instance.
  /// If not provided, creates a default instance.
  AuthLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: _androidOptions,
              iOptions: _iosOptions,
            );

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: accessToken,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      ),
      _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: refreshToken,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      ),
    ]);
  }

  @override
  Future<String?> getAccessToken() async {
    return _secureStorage.read(
      key: AppConstants.accessTokenKey,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }

  @override
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(
      key: AppConstants.refreshTokenKey,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(
        key: AppConstants.accessTokenKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      ),
      _secureStorage.delete(
        key: AppConstants.refreshTokenKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      ),
    ]);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _secureStorage.write(
      key: AppConstants.userDataKey,
      value: userJson,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = await _secureStorage.read(
      key: AppConstants.userDataKey,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );

    if (userJson == null || userJson.isEmpty) {
      return null;
    }

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      // If JSON parsing fails, clear corrupted data and return null
      await clearUser();
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await _secureStorage.delete(
      key: AppConstants.userDataKey,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }

  @override
  Future<void> clearAll() async {
    await Future.wait([
      clearTokens(),
      clearUser(),
    ]);
  }

  @override
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}
