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
///       ProfileInitial() => const SizedBox.shrink(),
///       ProfileLoading() => const LoadingIndicator(),
///       ProfileLoaded(:final user) => ProfileView(user: user),
///       ProfileUpdating(:final user) =>
///           ProfileView(user: user, isUpdating: true),
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
/// The profile should transition from this state after loading begins.
///
/// Example:
/// ```dart
/// if (state is ProfileInitial) {
///   // Trigger profile load
///   context.read<ProfileBloc>().add(const ProfileLoadRequested());
/// }
/// ```
final class ProfileInitial extends ProfileState {
  /// Creates a [ProfileInitial] state.
  const ProfileInitial();

  @override
  List<Object?> get props => [];
}

/// State indicating that profile data is being loaded.
///
/// This state is emitted when:
/// - The profile screen first loads the user data
/// - A profile refresh is requested
///
/// Example:
/// ```dart
/// if (state is ProfileLoading) {
///   return const Center(child: CircularProgressIndicator());
/// }
/// ```
final class ProfileLoading extends ProfileState {
  /// Creates a [ProfileLoading] state.
  const ProfileLoading();

  @override
  List<Object?> get props => [];
}

/// State indicating that profile data has been successfully loaded.
///
/// This state is emitted after:
/// - Successfully fetching the user's profile from the server
/// - Successfully refreshing profile data
///
/// Contains the [User] object with profile information.
///
/// Example:
/// ```dart
/// if (state is ProfileLoaded) {
///   return ProfileView(user: state.user);
/// }
/// ```
final class ProfileLoaded extends ProfileState {
  /// Creates a [ProfileLoaded] state.
  ///
  /// [user] - The user's profile data.
  const ProfileLoaded({required this.user});

  /// The user's profile data.
  final User user;

  @override
  List<Object?> get props => [user];
}

/// State indicating that a profile update is in progress.
///
/// This state is emitted while the profile update request is being processed.
/// It preserves the current user data so the UI can still display it.
///
/// Example:
/// ```dart
/// if (state is ProfileUpdating) {
///   return ProfileView(
///     user: state.user,
///     isUpdating: true,
///   );
/// }
/// ```
final class ProfileUpdating extends ProfileState {
  /// Creates a [ProfileUpdating] state.
  ///
  /// [user] - The current user data while updating.
  const ProfileUpdating({required this.user});

  /// The current user data while the update is in progress.
  final User user;

  @override
  List<Object?> get props => [user];
}

/// State indicating that a profile update was successful.
///
/// This state is emitted after successfully updating the user's profile.
/// Contains the updated [User] object with new profile information.
///
/// Example:
/// ```dart
/// if (state is ProfileUpdateSuccess) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     const SnackBar(content: Text('Profile updated successfully!')),
///   );
///   return ProfileView(user: state.user);
/// }
/// ```
final class ProfileUpdateSuccess extends ProfileState {
  /// Creates a [ProfileUpdateSuccess] state.
  ///
  /// [user] - The updated user profile data.
  const ProfileUpdateSuccess({required this.user});

  /// The updated user profile data.
  final User user;

  @override
  List<Object?> get props => [user];
}

/// State indicating that a profile operation has failed.
///
/// This state is emitted when an error occurs during:
/// - Profile loading
/// - Profile updating
///
/// Contains an error [message] describing what went wrong.
///
/// Example:
/// ```dart
/// if (state is ProfileError) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(state.message)),
///   );
/// }
/// ```
final class ProfileError extends ProfileState {
  /// Creates a [ProfileError] state.
  ///
  /// [message] - A human-readable error message.
  const ProfileError({required this.message});

  /// The error message describing what went wrong.
  final String message;

  @override
  List<Object?> get props => [message];
}
