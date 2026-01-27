/// Sharing events for the SharingBloc.
///
/// This file defines all possible events that can be dispatched to the
/// SharingBloc. Events are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:equatable/equatable.dart';

/// Base class for all sharing events.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all event types are handled.
sealed class SharingEvent extends Equatable {
  /// Creates a [SharingEvent] instance.
  const SharingEvent();
}

/// Event dispatched when the sharing data needs to be loaded.
///
/// This event triggers fetching of all sharing relationships including:
/// - Pending requests received
/// - Pending requests sent
/// - Accepted friendships
final class SharingLoadRequested extends SharingEvent {
  /// Creates a [SharingLoadRequested] event.
  const SharingLoadRequested();

  @override
  List<Object?> get props => [];
}

/// Event dispatched when the user requests to refresh sharing data.
///
/// This event is typically triggered by a pull-to-refresh gesture
/// and re-fetches all sharing relationships from the server.
final class SharingRefreshRequested extends SharingEvent {
  /// Creates a [SharingRefreshRequested] event.
  const SharingRefreshRequested();

  @override
  List<Object?> get props => [];
}

/// Event dispatched when the user wants to send a sharing request.
///
/// This event is used when the user initiates a friend request
/// to another user.
final class SharingSendRequestRequested extends SharingEvent {
  /// Creates a [SharingSendRequestRequested] event.
  ///
  /// [toUserId] - The ID of the user to send the request to.
  const SharingSendRequestRequested({
    required this.toUserId,
  });

  /// The ID of the user to send the request to.
  final String toUserId;

  @override
  List<Object?> get props => [toUserId];
}

/// Event dispatched when the user wants to accept a pending request.
///
/// This event is used when the user accepts a friend request
/// they have received.
final class SharingAcceptRequestRequested extends SharingEvent {
  /// Creates a [SharingAcceptRequestRequested] event.
  ///
  /// [relationshipId] - The ID of the relationship to accept.
  const SharingAcceptRequestRequested({
    required this.relationshipId,
  });

  /// The ID of the relationship to accept.
  final String relationshipId;

  @override
  List<Object?> get props => [relationshipId];
}

/// Event dispatched when the user wants to reject a pending request.
///
/// This event is used when the user rejects a friend request
/// they have received.
final class SharingRejectRequestRequested extends SharingEvent {
  /// Creates a [SharingRejectRequestRequested] event.
  ///
  /// [relationshipId] - The ID of the relationship to reject.
  const SharingRejectRequestRequested({
    required this.relationshipId,
  });

  /// The ID of the relationship to reject.
  final String relationshipId;

  @override
  List<Object?> get props => [relationshipId];
}

/// Event dispatched when the user wants to revoke a sharing relationship.
///
/// This event is used when the user wants to end an existing
/// friendship or cancel a pending request they sent.
final class SharingRevokeRequested extends SharingEvent {
  /// Creates a [SharingRevokeRequested] event.
  ///
  /// [relationshipId] - The ID of the relationship to revoke.
  const SharingRevokeRequested({
    required this.relationshipId,
  });

  /// The ID of the relationship to revoke.
  final String relationshipId;

  @override
  List<Object?> get props => [relationshipId];
}
