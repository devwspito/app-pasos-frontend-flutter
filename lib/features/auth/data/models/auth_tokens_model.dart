import 'package:equatable/equatable.dart';

/// Data model for authentication tokens with JSON serialization.
///
/// Contains the access token for API authentication and
/// refresh token for obtaining new access tokens.
final class AuthTokensModel extends Equatable {
  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  /// JWT access token for API authentication.
  final String accessToken;

  /// Refresh token for obtaining new access tokens.
  final String refreshToken;

  /// Optional expiration timestamp for the access token.
  final DateTime? expiresAt;

  /// Creates an [AuthTokensModel] from JSON map.
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "accessToken": "string",
  ///   "refreshToken": "string",
  ///   "expiresAt": "2024-01-01T00:00:00.000Z" // optional
  /// }
  /// ```
  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be serialized to JSON.
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    };
  }

  /// Creates a copy of this AuthTokensModel with the given fields replaced.
  AuthTokensModel copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) {
    return AuthTokensModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Returns true if the access token has expired.
  ///
  /// Returns false if [expiresAt] is null (no expiration known).
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Returns true if the access token will expire within the given duration.
  ///
  /// Useful for proactive token refresh before actual expiration.
  bool willExpireSoon({Duration threshold = const Duration(minutes: 5)}) {
    if (expiresAt == null) return false;
    return DateTime.now().add(threshold).isAfter(expiresAt!);
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];

  @override
  String toString() =>
      'AuthTokensModel(accessToken: ${accessToken.length > 10 ? '${accessToken.substring(0, 10)}...' : accessToken}, '
      'refreshToken: ${refreshToken.length > 10 ? '${refreshToken.substring(0, 10)}...' : refreshToken}, '
      'expiresAt: $expiresAt)';
}
