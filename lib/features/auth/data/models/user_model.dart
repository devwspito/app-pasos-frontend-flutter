import 'package:equatable/equatable.dart';

// TODO: User entity will be created by Domain Layer story
// import '../../domain/entities/user.dart';

/// Data layer model for User.
///
/// This model handles JSON serialization/deserialization for API responses.
/// Extends [Equatable] for value equality comparison.
///
/// Example JSON:
/// ```json
/// {
///   "id": "user-123",
///   "email": "user@example.com",
///   "username": "johndoe",
///   "profileImageUrl": "https://example.com/avatar.jpg",
///   "createdAt": "2024-01-15T10:30:00Z"
/// }
/// ```
class UserModel extends Equatable {
  /// Unique identifier for the user.
  final String id;

  /// User's email address.
  final String email;

  /// User's display username.
  final String username;

  /// Optional URL to user's profile image.
  final String? profileImageUrl;

  /// Timestamp when the user account was created.
  final DateTime createdAt;

  /// Creates a [UserModel] instance.
  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.profileImageUrl,
    required this.createdAt,
  });

  /// Creates a [UserModel] from a JSON map.
  ///
  /// Handles null safety for all fields with appropriate defaults.
  /// Parses [createdAt] from ISO 8601 string format.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// Serializes [createdAt] to ISO 8601 string format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Converts this data model to a domain [User] entity.
  ///
  /// Note: Uncomment when User entity is available in domain layer.
  // User toEntity() {
  //   return User(
  //     id: id,
  //     email: email,
  //     username: username,
  //     profileImageUrl: profileImageUrl,
  //     createdAt: createdAt,
  //   );
  // }

  /// Creates a copy of this model with optional field overrides.
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, username, profileImageUrl, createdAt];

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username, '
        'profileImageUrl: $profileImageUrl, createdAt: $createdAt)';
  }
}
