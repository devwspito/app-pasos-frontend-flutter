import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// User model representing authenticated user data.
/// Maps to backend IUser interface.
@JsonSerializable()
class UserModel extends Equatable {
  /// Unique user identifier (maps from backend _id)
  @JsonKey(name: '_id')
  final String id;

  /// Unique username (3-30 characters)
  final String username;

  /// User email address (lowercase, unique)
  final String email;

  /// Timestamp when user was created
  final DateTime createdAt;

  /// Timestamp when user was last updated
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a UserModel from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Converts UserModel to JSON map
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Creates a copy of UserModel with optional field updates
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
  List<Object?> get props => [id, username, email, createdAt, updatedAt];

  @override
  bool get stringify => true;
}
