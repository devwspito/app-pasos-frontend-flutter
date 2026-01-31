/// Remote data source for profile operations.
///
/// This file defines the interface and implementation for profile
/// API calls using the ApiClient.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/core/network/api_client.dart';
import 'package:app_pasos_frontend/core/network/api_endpoints.dart';
import 'package:app_pasos_frontend/features/auth/data/models/user_model.dart';

/// Abstract interface for profile remote data operations.
///
/// This interface defines all profile-related API calls.
/// Implementations should use the [ApiClient] for network requests.
abstract interface class ProfileRemoteDatasource {
  /// Fetches the current user's profile from the server.
  ///
  /// Returns [UserModel] with the user's profile data.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<UserModel> getProfile();

  /// Updates the current user's profile on the server.
  ///
  /// [name] - The new display name (optional).
  /// [email] - The new email address (optional).
  ///
  /// Returns [UserModel] with the updated profile data.
  /// Throws [ValidationException] if data is invalid.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<UserModel> updateProfile({
    String? name,
    String? email,
  });
}

/// Implementation of [ProfileRemoteDatasource] using [ApiClient].
///
/// This class handles all profile API calls, converting
/// responses to models and handling errors appropriately.
///
/// Example usage:
/// ```dart
/// final datasource = ProfileRemoteDatasourceImpl(client: apiClient);
/// final userModel = await datasource.getProfile();
/// ```
class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  /// Creates a [ProfileRemoteDatasourceImpl] with the given [ApiClient].
  ///
  /// [client] - The API client for making HTTP requests.
  ProfileRemoteDatasourceImpl({required ApiClient client}) : _client = client;

  /// The API client for making HTTP requests.
  final ApiClient _client;

  @override
  Future<UserModel> getProfile() async {
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
  Future<UserModel> updateProfile({
    String? name,
    String? email,
  }) async {
    final requestData = <String, dynamic>{};
    if (name != null) {
      requestData['name'] = name;
    }
    if (email != null) {
      requestData['email'] = email;
    }

    final response = await _client.put<Map<String, dynamic>>(
      ApiEndpoints.updateProfile,
      data: requestData,
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle both wrapped and unwrapped responses
    final userData = data['user'] as Map<String, dynamic>? ?? data;
    return UserModel.fromJson(userData);
  }
}
