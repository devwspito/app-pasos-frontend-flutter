/// Authentication response model for the data layer.
///
/// This file contains the model for authentication API responses,
/// including login and registration endpoints.
library;

import 'package:app_pasos_frontend/features/auth/data/models/user_model.dart';

/// Model representing the authentication response from the API.
///
/// This model parses responses from login and registration endpoints,
/// which return tokens and user data.
///
/// Example usage:
/// ```dart
/// // Parse API response
/// final response = await client.post('/auth/login', data: credentials);
/// final authResponse = AuthResponseModel.fromJson(response.data);
///
/// // Access tokens and user
/// final token = authResponse.token;
/// final user = authResponse.user;
/// ```
class AuthResponseModel {
  /// Creates an [AuthResponseModel] instance.
  ///
  /// [token] - The JWT access token.
  /// [refreshToken] - The refresh token for obtaining new access tokens.
  /// [user] - The authenticated user's data.
  const AuthResponseModel({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  /// The JWT access token for authenticated requests.
  final String token;

  /// The refresh token for obtaining new access tokens.
  final String refreshToken;

  /// The authenticated user's data.
  final UserModel user;

  /// Creates an [AuthResponseModel] from a JSON map.
  ///
  /// [json] - The JSON map from the API response.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "token": "jwt_token_string",
  ///   "refreshToken": "refresh_token_string",
  ///   "user": {
  ///     "id": "user_id",
  ///     "email": "user@example.com",
  ///     "name": "User Name"
  ///   }
  /// }
  /// ```
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be JSON-encoded.
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }

  /// Whether the response contains valid tokens.
  bool get hasValidTokens => token.isNotEmpty && refreshToken.isNotEmpty;

  @override
  String toString() {
    return 'AuthResponseModel(token: [REDACTED], refreshToken: [REDACTED], user: $user)';
  }
}
