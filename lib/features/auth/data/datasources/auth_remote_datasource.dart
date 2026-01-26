import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';

// TODO: These model imports will be available from another epic
// import '../models/user_model.dart';
// import '../models/auth_response_model.dart';

/// Model representing the authentication response from the API.
/// This is a placeholder until the actual model is created by another epic.
class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String? ?? json['accessToken'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? json['refreshToken'] as String? ?? '',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
    };
  }
}

/// Model representing a user.
/// This is a placeholder until the actual model is created by another epic.
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Abstract interface for remote authentication data source.
///
/// This datasource handles all remote API calls related to authentication,
/// including login, registration, logout, token refresh, and profile retrieval.
abstract class AuthRemoteDataSource {
  /// Authenticates a user with email and password.
  ///
  /// [email] The user's email address.
  /// [password] The user's password.
  /// Returns [AuthResponseModel] containing tokens and user data.
  /// Throws [DioException] if the request fails.
  Future<AuthResponseModel> login(String email, String password);

  /// Registers a new user account.
  ///
  /// [username] The desired username.
  /// [email] The user's email address.
  /// [password] The user's password.
  /// Returns [AuthResponseModel] containing tokens and user data.
  /// Throws [DioException] if registration fails.
  Future<AuthResponseModel> register(String username, String email, String password);

  /// Logs out the current user.
  ///
  /// [refreshToken] The refresh token to invalidate.
  /// Throws [DioException] if logout fails.
  Future<void> logout(String refreshToken);

  /// Refreshes the authentication tokens.
  ///
  /// [refreshToken] The current refresh token.
  /// Returns [AuthResponseModel] with new tokens.
  /// Throws [DioException] if token refresh fails.
  Future<AuthResponseModel> refreshToken(String refreshToken);

  /// Retrieves the current user's profile.
  ///
  /// Returns [UserModel] containing user profile data.
  /// Throws [DioException] if profile retrieval fails.
  Future<UserModel> getProfile();
}

/// Implementation of [AuthRemoteDataSource] using DioClient.
///
/// This class handles all HTTP requests to the authentication API endpoints.
/// It uses the singleton [DioClient] for making requests with proper
/// authentication headers and error handling.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  /// Creates an [AuthRemoteDataSourceImpl] instance.
  ///
  /// [dioClient] Optional DioClient instance. If not provided, uses singleton.
  AuthRemoteDataSourceImpl({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Login response data is null',
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      return AuthResponseModel.fromJson(responseData);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        message: 'Failed to parse login response: $e',
      );
    }
  }

  @override
  Future<AuthResponseModel> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Registration response data is null',
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      return AuthResponseModel.fromJson(responseData);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.register),
        message: 'Failed to parse registration response: $e',
      );
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _dioClient.post(
        ApiEndpoints.logout,
        data: {
          'refresh_token': refreshToken,
        },
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.logout),
        message: 'Logout request failed: $e',
      );
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.refreshToken,
        data: {
          'refresh_token': refreshToken,
        },
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Token refresh response data is null',
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      return AuthResponseModel.fromJson(responseData);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.refreshToken),
        message: 'Failed to parse token refresh response: $e',
      );
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.userProfile);

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Profile response data is null',
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      return UserModel.fromJson(responseData);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.userProfile),
        message: 'Failed to parse profile response: $e',
      );
    }
  }
}
