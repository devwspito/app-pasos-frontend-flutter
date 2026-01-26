import 'package:equatable/equatable.dart';

/// Domain entity representing a user in the application.
///
/// This is a pure domain object with no JSON serialization or persistence logic.
/// The data layer (UserModel) handles conversion to/from JSON.
///
/// Example:
/// ```dart
/// final user = User(
///   id: '123',
///   email: 'user@example.com',
///   username: 'johndoe',
///   createdAt: DateTime.now(),
/// );
/// ```
class User extends Equatable {
  /// Unique identifier for the user.
  final String id;

  /// User's email address.
  final String email;

  /// User's display name/username.
  final String username;

  /// URL to user's profile image, if available.
  final String? profileImageUrl;

  /// Timestamp when the user account was created.
  final DateTime createdAt;

  /// Creates a new [User] instance.
  ///
  /// [id], [email], [username], and [createdAt] are required.
  /// [profileImageUrl] is optional.
  const User({
    required this.id,
    required this.email,
    required this.username,
    this.profileImageUrl,
    required this.createdAt,
  });

  /// Creates a copy of this user with the given fields replaced.
  ///
  /// This is useful for updating user data immutably.
  User copyWith({
    String? id,
    String? email,
    String? username,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return User(
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
    return 'User(id: $id, email: $email, username: $username, '
        'profileImageUrl: $profileImageUrl, createdAt: $createdAt)';
  }
}
