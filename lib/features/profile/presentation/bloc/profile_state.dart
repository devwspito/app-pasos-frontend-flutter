/// Profile states for the ProfileBloc.
///
/// This file defines all possible states that the ProfileBloc can emit.
/// States are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

/// Base class for all profile states.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all state types are handled.
///
/// Example usage:
/// ```dart
/// BlocBuilder<ProfileBloc, ProfileState>(
///   builder: (context, state) {
///     return switch (state) {
///       ProfileInitial() => const LoadingIndicator(),
///       ProfileLoading() => const LoadingIndicator(),
///       ProfileLoaded(:final user) => ProfileView(user: user),
///       ProfileEditing(:final user) => ProfileEditForm(user: user),
///       ProfileUpdateSuccess(:final user) => ProfileView(user: user),
///       ProfileError(:final message) => ErrorView(message: message),
///     };
///   },
/// )
/// ```
sealed class ProfileState extends Equatable {
  /// Creates a [ProfileState] instance.
  const ProfileState();
}

/// Initial state before any profile operation has been performed.
///
/// This is the default state when the ProfileBloc is first created.
/// The app should transition from this state after loading profile.
final class ProfileInitial extends ProfileState {
  /// Creates a [ProfileInitial] state.
  const ProfileInitial();

  @override
  List<Object?> get props => [];
}

/// State indicating that a profile operation is in progress.
///
/// This state is emitted when:
/// - Profile data is being fetched
/// - Profile update is being processed
final class ProfileLoading extends ProfileState {
  /// Creates a [ProfileLoading] state.
  const ProfileLoading();

  @override
  List<Object?> get props => [];
}

/// State indicating that profile data has been loaded successfully.
///
/// Contains the user's profile data.
final class ProfileLoaded extends ProfileState {
  /// Creates a [ProfileLoaded] state.
  ///
  /// [user] - The loaded user profile.
  const ProfileLoaded({required this.user});

  /// The loaded user profile.
  final User user;

  @override
  List<Object?> get props => [user];
}

/// State indicating that the user is editing their profile.
///
/// Contains the original user data for reference during editing.
final class ProfileEditing extends ProfileState {
  /// Creates a [ProfileEditing] state.
  ///
  /// [user] - The current user profile being edited.
  const ProfileEditing({required this.user});

  /// The current user profile being edited.
  final User user;

  @override
  List<Object?> get props => [user];
}

/// State indicating that profile update was successful.
///
/// Contains the updated user data and a success message.
final class ProfileUpdateSuccess extends ProfileState {
  /// Creates a [ProfileUpdateSuccess] state.
  ///
  /// [user] - The updated user profile.
  /// [message] - Success message to display.
  const ProfileUpdateSuccess({
    required this.user,
    this.message = 'Profile updated successfully',
  });

  /// The updated user profile.
  final User user;

  /// Success message to display.
  final String message;

  @override
  List<Object?> get props => [user, message];
}

/// State indicating that a profile error has occurred.
///
/// Contains an error message and optionally the last known user data.
final class ProfileError extends ProfileState {
  /// Creates a [ProfileError] state.
  ///
  /// [message] - A human-readable error message.
  /// [user] - The last known user data (optional).
  const ProfileError({
    required this.message,
    this.user,
  });

  /// The error message describing what went wrong.
  final String message;

  /// The last known user data, if available.
  final User? user;

  @override
  List<Object?> get props => [message, user];
}
