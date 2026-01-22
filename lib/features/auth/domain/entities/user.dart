import 'package:equatable/equatable.dart';

/// User entity representing the domain model for a user.
///
/// This is a pure domain entity with no serialization logic.
/// Use [UserModel] in the data layer for API serialization.
final class User extends Equatable {
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  /// Unique identifier for the user.
  final String id;

  /// User's display username.
  final String username;

  /// User's email address.
  final String email;

  /// Timestamp when the user account was created.
  final DateTime createdAt;

  /// Creates a copy of this User with the given fields replaced.
  User copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, username, email, createdAt];

  @override
  String toString() => 'User(id: $id, username: $username, email: $email)';
}
