import 'package:equatable/equatable.dart';

import 'user_model.dart';

/// Data layer model for authentication response.
///
/// This model handles JSON serialization/deserialization for login/register
/// API responses. Contains tokens and user data.
/// Extends [Equatable] for value equality comparison.
///
/// Example JSON:
/// ```json
/// {
///   "accessToken": "eyJhbGciOiJIUzI1NiIs...",
///   "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
///   "user": {
///     "id": "user-123",
///     "email": "user@example.com",
///     "username": "johndoe"
///   },
///   "expiresAt": "2024-01-15T11:30:00Z"
/// }
/// ```
class AuthResponseModel extends Equatable {
  /// JWT access token for authenticated requests.
  final String accessToken;

  /// Refresh token for obtaining new access tokens.
  final String refreshToken;

  /// The authenticated user's data.
  final UserModel user;

  /// Timestamp when the access token expires.
  final DateTime expiresAt;

  /// Creates an [AuthResponseModel] instance.
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  /// Creates an [AuthResponseModel] from a JSON map.
  ///
  /// Handles null safety for all fields with appropriate defaults.
  /// Parses nested [user] object and [expiresAt] from ISO 8601 string.
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : UserModel(
              id: '',
              email: '',
              username: '',
              createdAt: DateTime.now(),
            ),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(hours: 1)),
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// Serializes nested [user] and [expiresAt] to appropriate formats.
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// Returns true if the access token has expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Returns true if the access token is still valid.
  bool get isValid => !isExpired && accessToken.isNotEmpty;

  /// Creates a copy of this model with optional field overrides.
  AuthResponseModel copyWith({
    String? accessToken,
    String? refreshToken,
    UserModel? user,
    DateTime? expiresAt,
  }) {
    return AuthResponseModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, user, expiresAt];

  @override
  String toString() {
    return 'AuthResponseModel(accessToken: ${accessToken.substring(0, accessToken.length > 10 ? 10 : accessToken.length)}..., '
        'refreshToken: ${refreshToken.substring(0, refreshToken.length > 10 ? 10 : refreshToken.length)}..., '
        'user: $user, expiresAt: $expiresAt)';
  }
}
