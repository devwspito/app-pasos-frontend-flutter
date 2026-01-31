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

/// Event dispatched when profile data load is requested.
final class ProfileLoadRequested extends ProfileEvent {
  /// Creates a [ProfileLoadRequested] event.
  const ProfileLoadRequested();

  @override
  List<Object?> get props => [];
}

/// Event dispatched when edit mode is toggled.
final class ProfileEditModeToggled extends ProfileEvent {
  /// Creates a [ProfileEditModeToggled] event.
  const ProfileEditModeToggled();

  @override
  List<Object?> get props => [];
}

/// Event dispatched when profile update is requested.
final class ProfileUpdateRequested extends ProfileEvent {
  /// Creates a [ProfileUpdateRequested] event.
  const ProfileUpdateRequested({
    this.name,
    this.email,
  });

  /// The new display name (optional).
  final String? name;

  /// The new email address (optional).
  final String? email;

  @override
  List<Object?> get props => [name, email];
}

/// Event dispatched when edit is cancelled.
final class ProfileCancelEditRequested extends ProfileEvent {
  /// Creates a [ProfileCancelEditRequested] event.
  const ProfileCancelEditRequested();

  @override
  List<Object?> get props => [];
}
