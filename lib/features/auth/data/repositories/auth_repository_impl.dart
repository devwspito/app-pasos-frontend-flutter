import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

// TODO: This import will be available from domain layer when created by another epic
// import '../../domain/repositories/auth_repository.dart';
// import '../../domain/entities/user.dart';
// import '../../domain/entities/auth_result.dart';

/// Represents the result of an authentication operation.
///
/// This is a placeholder until the actual entity is created in the domain layer.
class AuthResult {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}

/// Abstract interface for authentication repository.
///
/// This is a placeholder until the actual repository interface is created
/// in the domain layer by another epic.
abstract class AuthRepository {
  /// Authenticates a user with email and password.
  Future<AuthResult> login(String email, String password);

  /// Registers a new user account.
  Future<AuthResult> register(String username, String email, String password);

  /// Logs out the current user.
  Future<void> logout();

  /// Refreshes the authentication tokens.
  Future<AuthResult> refreshToken();

  /// Retrieves the current user's profile.
  Future<UserModel> getProfile();

  /// Checks if the user is currently authenticated.
  Future<bool> isAuthenticated();

  /// Gets the cached user data.
  Future<UserModel?> getCachedUser();

  /// Gets the current access token.
  Future<String?> getAccessToken();
}

/// Implementation of [AuthRepository] that coordinates between remote and local datasources.
///
/// This repository implementation handles:
/// - Remote API calls for authentication operations
/// - Local caching of tokens and user data
/// - Token management for the HTTP client
/// - Session state management
///
/// The repository acts as a single source of truth for authentication state,
/// coordinating between the remote API and local secure storage.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final DioClient _dioClient;

  /// Creates an [AuthRepositoryImpl] instance.
  ///
  /// [remoteDataSource] The remote data source for API calls.
  /// [localDataSource] The local data source for secure storage.
  /// [dioClient] Optional DioClient instance for token management.
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    DioClient? dioClient,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _dioClient = dioClient ?? DioClient();

  /// Factory constructor that creates [AuthRepositoryImpl] with default dependencies.
  ///
  /// Creates new instances of [AuthRemoteDataSourceImpl] and [AuthLocalDataSourceImpl].
  factory AuthRepositoryImpl.create({DioClient? dioClient}) {
    return AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(dioClient: dioClient),
      localDataSource: AuthLocalDataSourceImpl(),
      dioClient: dioClient,
    );
  }

  @override
  Future<AuthResult> login(String email, String password) async {
    try {
      // Call remote API to authenticate
      final authResponse = await _remoteDataSource.login(email, password);

      // Save tokens to secure storage
      await _localDataSource.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );

      // Save user data to secure storage
      await _localDataSource.saveUser(authResponse.user);

      // Update DioClient with new tokens for subsequent requests
      _dioClient.setTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return AuthResult(
        user: authResponse.user,
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        message: 'Login failed: $e',
      );
    }
  }

  @override
  Future<AuthResult> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      // Call remote API to register
      final authResponse = await _remoteDataSource.register(
        username,
        email,
        password,
      );

      // Save tokens to secure storage
      await _localDataSource.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );

      // Save user data to secure storage
      await _localDataSource.saveUser(authResponse.user);

      // Update DioClient with new tokens for subsequent requests
      _dioClient.setTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return AuthResult(
        user: authResponse.user,
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/register'),
        message: 'Registration failed: $e',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Get the current refresh token
      final refreshToken = await _localDataSource.getRefreshToken();

      // Call remote API to invalidate the token (if token exists)
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await _remoteDataSource.logout(refreshToken);
        } on DioException {
          // Logout API failure shouldn't prevent local cleanup
          // The user should still be logged out locally
        }
      }

      // Clear local storage regardless of API result
      await _localDataSource.clearAll();

      // Clear DioClient tokens
      _dioClient.clearTokens();
    } catch (e) {
      // Ensure local cleanup happens even if there's an error
      await _localDataSource.clearAll();
      _dioClient.clearTokens();

      // Don't rethrow - logout should always succeed locally
    }
  }

  @override
  Future<AuthResult> refreshToken() async {
    try {
      // Get current refresh token from local storage
      final currentRefreshToken = await _localDataSource.getRefreshToken();

      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        throw DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          message: 'No refresh token available',
          type: DioExceptionType.badResponse,
        );
      }

      // Call remote API to refresh tokens
      final authResponse = await _remoteDataSource.refreshToken(
        currentRefreshToken,
      );

      // Update tokens in secure storage
      await _localDataSource.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );

      // Update user data if included in response
      await _localDataSource.saveUser(authResponse.user);

      // Update DioClient with new tokens
      _dioClient.setTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return AuthResult(
        user: authResponse.user,
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
    } on DioException {
      // If token refresh fails, clear local tokens and rethrow
      await _localDataSource.clearAll();
      _dioClient.clearTokens();
      rethrow;
    } catch (e) {
      await _localDataSource.clearAll();
      _dioClient.clearTokens();
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        message: 'Token refresh failed: $e',
      );
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      // Call remote API to get profile
      final user = await _remoteDataSource.getProfile();

      // Update cached user data
      await _localDataSource.saveUser(user);

      return user;
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/users/profile'),
        message: 'Failed to get profile: $e',
      );
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _localDataSource.isAuthenticated();
  }

  @override
  Future<UserModel?> getCachedUser() async {
    return _localDataSource.getUser();
  }

  @override
  Future<String?> getAccessToken() async {
    return _localDataSource.getAccessToken();
  }

  /// Initializes the repository by restoring tokens from storage.
  ///
  /// Call this method when the app starts to restore the authentication state.
  /// If tokens exist in storage, they will be loaded into the DioClient.
  Future<void> initialize() async {
    final accessToken = await _localDataSource.getAccessToken();
    final refreshToken = await _localDataSource.getRefreshToken();

    if (accessToken != null && refreshToken != null) {
      _dioClient.setTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
  }
}
