/// Profile events for the ProfileBloc.
///
/// This file defines all possible events that can be dispatched to the
/// ProfileBloc. Events are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:equatable/equatable.dart';

/// Base class for all profile events.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all event types are handled.
sealed class ProfileEvent extends Equatable {
  /// Creates a [ProfileEvent] instance.
  const ProfileEvent();
}

/// Event dispatched when the user's profile should be loaded.
///
/// This event is typically dispatched when:
/// - The profile screen is first opened
/// - The user wants to refresh their profile data
/// - After a successful profile update to reload the data
///
/// Example:
/// ```dart
/// context.read<ProfileBloc>().add(const ProfileLoadRequested());
/// ```
final class ProfileLoadRequested extends ProfileEvent {
  /// Creates a [ProfileLoadRequested] event.
  const ProfileLoadRequested();

  @override
  List<Object?> get props => [];
}

/// Event dispatched when the user requests to update their profile.
///
/// This event is dispatched from the profile edit form when the user
/// submits their changes.
///
/// Example:
/// ```dart
/// context.read<ProfileBloc>().add(
///   ProfileUpdateRequested(
///     name: 'John Doe',
///     email: 'john@example.com',
///   ),
/// );
/// ```
final class ProfileUpdateRequested extends ProfileEvent {
  /// Creates a [ProfileUpdateRequested] event.
  ///
  /// [name] - The updated display name for the user.
  /// [email] - The updated email address for the user.
  const ProfileUpdateRequested({
    required this.name,
    required this.email,
  });

  /// The updated display name for the user.
  final String name;

  /// The updated email address for the user.
  final String email;

  @override
  List<Object?> get props => [name, email];
}
