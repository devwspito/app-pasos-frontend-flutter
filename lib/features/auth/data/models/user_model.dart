import '../../domain/entities/user.dart';

/// Data model for User with JSON serialization support.
///
/// Extends [User] entity to add API serialization capabilities.
/// Use this model in the data layer for API communication.
final class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.createdAt,
  });

  /// Creates a [UserModel] from JSON map.
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "id": "string",
  ///   "username": "string",
  ///   "email": "string",
  ///   "createdAt": "2024-01-01T00:00:00.000Z"
  /// }
  /// ```
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Creates a [UserModel] from an existing [User] entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      createdAt: user.createdAt,
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// Returns a map that can be serialized to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this UserModel with the given fields replaced.
  @override
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, username: $username, email: $email)';
}
