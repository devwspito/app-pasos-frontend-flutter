/// Remote data source for authentication operations.
///
/// This file defines the interface and implementation for authentication
/// API calls using the ApiClient.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/core/network/api_client.dart';
import 'package:app_pasos_frontend/core/network/api_endpoints.dart';
import 'package:app_pasos_frontend/features/auth/data/models/auth_response_model.dart';
import 'package:app_pasos_frontend/features/auth/data/models/user_model.dart';

/// Abstract interface for authentication remote data operations.
///
/// This interface defines all authentication-related API calls.
/// Implementations should use the [ApiClient] for network requests.
abstract interface class AuthRemoteDatasource {
  /// Authenticates a user with email and password.
  ///
  /// [email] - The user's email address.
  /// [password] - The user's password.
  ///
  /// Returns [AuthResponseModel] containing tokens and user data.
  /// Throws [UnauthorizedException] if credentials are invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  /// Registers a new user account.
  ///
  /// [email] - The email address for the new account.
  /// [password] - The password for the new account.
  /// [name] - The display name for the new user.
  ///
  /// Returns [AuthResponseModel] containing tokens and user data.
  /// Throws [ValidationException] if email is already taken.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String name,
  });

  /// Logs out the current user on the server.
  ///
  /// Throws [NetworkException] on network failures.
  /// Throws [UnauthorizedException] if not authenticated.
  Future<void> logout();

  /// Gets the current user's profile from the server.
  ///
  /// Returns [UserModel] with the user's profile data.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  Future<UserModel> getCurrentUser();

  /// Initiates the forgot password flow.
  ///
  /// [email] - The email address to send the reset link to.
  ///
  /// Throws [ValidationException] if email is invalid or not found.
  /// Throws [NetworkException] on network failures.
  Future<void> forgotPassword({required String email});
}

/// Implementation of [AuthRemoteDatasource] using [ApiClient].
///
/// This class handles all authentication API calls, converting
/// responses to models and handling errors appropriately.
///
/// Example usage:
/// ```dart
/// final datasource = AuthRemoteDatasourceImpl(client: apiClient);
/// final response = await datasource.login(
///   email: 'user@example.com',
///   password: 'password123',
/// );
/// ```
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  /// Creates an [AuthRemoteDatasourceImpl] with the given [ApiClient].
  ///
  /// [client] - The API client for making HTTP requests.
  AuthRemoteDatasourceImpl({required ApiClient client}) : _client = client;

  /// The API client for making HTTP requests.
  final ApiClient _client;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    return AuthResponseModel.fromJson(data);
  }

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: {
        'email': email,
        'password': password,
        'name': name,
      },
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    return AuthResponseModel.fromJson(data);
  }

  @override
  Future<void> logout() async {
    await _client.post<Map<String, dynamic>>(ApiEndpoints.logout);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.userProfile,
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle both wrapped and unwrapped responses
    // Some APIs return { user: {...} } and some return user directly
    final userData = data['user'] as Map<String, dynamic>? ?? data;
    return UserModel.fromJson(userData);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _client.post<Map<String, dynamic>>(
      ApiEndpoints.forgotPassword,
      data: {
        'email': email,
      },
    );
  }
}
