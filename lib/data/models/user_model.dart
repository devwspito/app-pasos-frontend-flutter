import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// Data model representing a user from the backend API.
///
/// Maps to the MongoDB User schema with JSON serialization support.
/// Uses `@JsonKey(name: '_id')` to handle MongoDB's default ID field.
@JsonSerializable()
class UserModel extends Equatable {
  /// MongoDB document ID
  @JsonKey(name: '_id')
  final String id;

  /// Unique username for the user
  final String username;

  /// User's email address
  final String email;

  /// Timestamp when the user was created
  final DateTime createdAt;

  /// Timestamp when the user was last updated
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [UserModel] from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Converts this [UserModel] to a JSON map.
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [id, username, email, createdAt, updatedAt];

  /// Creates a copy of this [UserModel] with the given fields replaced.
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, username: $username, email: $email)';
}
