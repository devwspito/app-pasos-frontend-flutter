/// Authentication repository implementation.
///
/// This file implements the [AuthRepository] interface, coordinating
/// between the remote datasource and local secure storage.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/core/storage/secure_storage_service.dart';
import 'package:app_pasos_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';
import 'package:app_pasos_frontend/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] coordinating remote and local storage.
///
/// This class implements the authentication business logic, including:
/// - Making API calls through the datasource
/// - Storing tokens and user data in secure storage
/// - Managing authentication state
///
/// Example usage:
/// ```dart
/// final repository = AuthRepositoryImpl(
///   datasource: authDatasource,
///   storage: secureStorage,
/// );
///
/// final user = await repository.login(
///   email: 'user@example.com',
///   password: 'password123',
/// );
/// ```
class AuthRepositoryImpl implements AuthRepository {
  /// Creates an [AuthRepositoryImpl] with the required dependencies.
  ///
  /// [datasource] - The remote datasource for API calls.
  /// [storage] - The secure storage service for token management.
  AuthRepositoryImpl({
    required AuthRemoteDatasource datasource,
    required SecureStorageService storage,
  })  : _datasource = datasource,
        _storage = storage;

  /// The remote datasource for API operations.
  final AuthRemoteDatasource _datasource;

  /// The secure storage service for local data.
  final SecureStorageService _storage;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _datasource.login(
      email: email,
      password: password,
    );

    // Store authentication data
    await _storeAuthData(response.token, response.refreshToken, response.user);

    return response.user;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _datasource.register(
      email: email,
      password: password,
      name: name,
    );

    // Store authentication data
    await _storeAuthData(response.token, response.refreshToken, response.user);

    return response.user;
  }

  @override
  Future<void> logout() async {
    try {
      // Try to logout on server first
      await _datasource.logout();
    } on AppException catch (_) {
      // Ignore server errors during logout
      // We still want to clear local data even if server call fails
    } finally {
      // Always clear local authentication data
      await _storage.clearAuthData();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    // First check if we have stored auth data
    final isAuth = await isAuthenticated();
    if (!isAuth) {
      return null;
    }

    try {
      // Fetch fresh user data from server
      final userModel = await _datasource.getCurrentUser();

      // Update stored user data
      await _storage.saveUserId(userModel.id);
      await _storage.saveUserEmail(userModel.email);
      await _storage.saveUserName(userModel.name);

      return userModel;
    } on UnauthorizedException catch (_) {
      // Token is invalid or expired, clear local data
      await _storage.clearAuthData();
      return null;
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _datasource.forgotPassword(email: email);
  }

  @override
  Future<bool> isAuthenticated() async {
    return _storage.isAuthenticated();
  }

  /// Stores authentication data in secure storage.
  ///
  /// [token] - The JWT access token.
  /// [refreshToken] - The refresh token.
  /// [user] - The user data to store.
  Future<void> _storeAuthData(
    String token,
    String refreshToken,
    User user,
  ) async {
    await Future.wait([
      _storage.saveAuthToken(token),
      _storage.saveRefreshToken(refreshToken),
      _storage.saveUserId(user.id),
      _storage.saveUserEmail(user.email),
      _storage.saveUserName(user.name),
    ]);
  }
}
