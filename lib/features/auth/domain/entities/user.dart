/// User entity for the authentication domain.
///
/// This is a pure domain entity representing a user in the application.
/// It's independent of any data layer implementation details.
library;

import 'package:equatable/equatable.dart';

/// Represents a user in the application.
///
/// This entity is the core domain representation of a user, containing
/// only the essential identity and profile information.
///
/// Example usage:
/// ```dart
/// final user = User(
///   id: '123',
///   email: 'john@example.com',
///   name: 'John Doe',
///   createdAt: DateTime.now(),
/// );
/// ```
class User extends Equatable {
  /// Creates a [User] instance.
  ///
  /// [id] - The unique identifier for the user.
  /// [email] - The user's email address.
  /// [name] - The user's display name.
  /// [createdAt] - When the user account was created (optional).
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.createdAt,
  });

  /// The unique identifier for the user.
  final String id;

  /// The user's email address.
  final String email;

  /// The user's display name.
  final String name;

  /// When the user account was created.
  ///
  /// This may be null if the information is not available.
  final DateTime? createdAt;

  /// Creates an empty user for use in initial states.
  ///
  /// Useful for initializing state before user data is loaded.
  factory User.empty() => const User(
        id: '',
        email: '',
        name: '',
      );

  /// Whether this is an empty/uninitialized user.
  bool get isEmpty => id.isEmpty;

  /// Whether this is a valid user with data.
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [id, email, name, createdAt];

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, createdAt: $createdAt)';
  }
}
