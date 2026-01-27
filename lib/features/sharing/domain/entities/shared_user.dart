/// Shared user entity for the sharing domain.
///
/// This is a pure domain entity representing a user who can share steps.
/// It's independent of any data layer implementation details.
library;

import 'package:equatable/equatable.dart';

/// Represents a user that can be shared with or is sharing steps.
///
/// This entity contains basic user profile information plus optional
/// step data for displaying in sharing-related UI.
///
/// Example usage:
/// ```dart
/// final friend = SharedUser(
///   id: '123',
///   name: 'John Doe',
///   email: 'john@example.com',
///   avatarUrl: 'https://example.com/avatar.jpg',
///   todaySteps: 5000,
/// );
/// ```
class SharedUser extends Equatable {
  /// Creates a [SharedUser] instance.
  ///
  /// [id] - The unique identifier for the user.
  /// [name] - The user's display name.
  /// [email] - The user's email address.
  /// [avatarUrl] - URL to the user's avatar image (optional).
  /// [todaySteps] - The user's step count for today (optional).
  const SharedUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.todaySteps,
  });

  /// Creates an empty shared user for use in initial states.
  ///
  /// Useful for initializing state before user data is loaded.
  factory SharedUser.empty() => const SharedUser(
        id: '',
        name: '',
        email: '',
      );

  /// The unique identifier for the user.
  final String id;

  /// The user's display name.
  final String name;

  /// The user's email address.
  final String email;

  /// URL to the user's avatar image.
  ///
  /// This may be null if the user has not set an avatar.
  final String? avatarUrl;

  /// The user's step count for today.
  ///
  /// This may be null if the step data is not available or not shared.
  final int? todaySteps;

  /// Whether this is an empty/uninitialized user.
  bool get isEmpty => id.isEmpty;

  /// Whether this is a valid user with data.
  bool get isNotEmpty => !isEmpty;

  /// Whether this user has an avatar.
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Whether this user has step data available.
  bool get hasStepData => todaySteps != null;

  @override
  List<Object?> get props => [id, name, email, avatarUrl, todaySteps];

  @override
  String toString() {
    return 'SharedUser(id: $id, name: $name, email: $email, '
        'avatarUrl: $avatarUrl, todaySteps: $todaySteps)';
  }
}
