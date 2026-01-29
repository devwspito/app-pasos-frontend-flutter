/// Sharing states for the SharingBloc.
///
/// This file defines all possible states that the SharingBloc can emit.
/// States are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/realtime_step_update.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/sharing_relationship.dart';
import 'package:equatable/equatable.dart';

/// Base class for all sharing states.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all state types are handled.
///
/// Example usage:
/// ```dart
/// BlocBuilder<SharingBloc, SharingState>(
///   builder: (context, state) {
///     return switch (state) {
///       SharingInitial() => const SizedBox.shrink(),
///       SharingLoading() => const LoadingIndicator(),
///       SharingLoaded(:final friends) => FriendsList(friends: friends),
///       SharingError(:final message) => ErrorWidget(message: message),
///       SharingActionSuccess(:final message) =>
///         SuccessMessage(message: message),
///     };
///   },
/// )
/// ```
sealed class SharingState extends Equatable {
  /// Creates a [SharingState] instance.
  const SharingState();
}

/// Initial state before any sharing data has been loaded.
///
/// This is the default state when the SharingBloc is first created.
/// The app should transition from this state after loading sharing data.
///
/// Example:
/// ```dart
/// if (state is SharingInitial) {
///   // Trigger initial data load
///   context.read<SharingBloc>().add(const SharingLoadRequested());
/// }
/// ```
final class SharingInitial extends SharingState {
  /// Creates a [SharingInitial] state.
  const SharingInitial();

  @override
  List<Object?> get props => [];
}

/// State indicating that sharing data is being loaded.
///
/// This state is emitted when:
/// - Initial data load is in progress
/// - Pull-to-refresh is in progress
/// - A sharing action is being processed
///
/// Example:
/// ```dart
/// if (state is SharingLoading) {
///   return const CircularProgressIndicator();
/// }
/// ```
final class SharingLoading extends SharingState {
  /// Creates a [SharingLoading] state.
  const SharingLoading();

  @override
  List<Object?> get props => [];
}

/// State indicating that sharing data has been successfully loaded.
///
/// This state is emitted after successful data fetching and contains
/// all the sharing relationships categorized by their status.
///
/// Contains:
/// - [relationships] - All sharing relationships
/// - [pendingRequests] - Requests received that are pending
///   (status == 'pending' && toUserId == currentUserId)
/// - [sentRequests] - Requests sent that are pending
///   (status == 'pending' && fromUserId == currentUserId)
/// - [friends] - Accepted friendships (status == 'accepted')
/// - [realtimeUpdates] - Map of userId to their latest realtime step update
/// - [onlineFriendIds] - Set of currently online friend user IDs
///
/// Example:
/// ```dart
/// if (state is SharingLoaded) {
///   final friendCount = state.friends.length;
///   return Text('You have $friendCount friends');
///
///   // Check realtime data
///   if (state.isFriendOnline('user123')) {
///     final steps = state.getRealtimeSteps('user123');
///     print('Friend has $steps steps');
///   }
/// }
/// ```
final class SharingLoaded extends SharingState {
  /// Creates a [SharingLoaded] state.
  ///
  /// [relationships] - All sharing relationships.
  /// [pendingRequests] - Requests received that are pending acceptance.
  /// [sentRequests] - Requests sent that are awaiting response.
  /// [friends] - Accepted friendships.
  /// [realtimeUpdates] - Map of userId to their latest realtime step update.
  /// [onlineFriendIds] - Set of currently online friend user IDs.
  const SharingLoaded({
    required this.relationships,
    required this.pendingRequests,
    required this.sentRequests,
    required this.friends,
    this.realtimeUpdates = const {},
    this.onlineFriendIds = const {},
  });

  /// All sharing relationships.
  final List<SharingRelationship> relationships;

  /// Requests received that are pending acceptance.
  ///
  /// These are relationships where the current user is the recipient
  /// (toUserId == currentUserId) and status is 'pending'.
  final List<SharingRelationship> pendingRequests;

  /// Requests sent that are awaiting response.
  ///
  /// These are relationships where the current user is the sender
  /// (fromUserId == currentUserId) and status is 'pending'.
  final List<SharingRelationship> sentRequests;

  /// Accepted friendships.
  ///
  /// These are relationships where status is 'accepted'.
  final List<SharingRelationship> friends;

  /// Map of userId to their latest realtime step update.
  ///
  /// This map is populated when realtime updates are received via WebSocket.
  /// Use [getRealtimeUpdate] or [getRealtimeSteps] for convenient access.
  final Map<String, RealtimeStepUpdate> realtimeUpdates;

  /// Set of currently online friend user IDs.
  ///
  /// A friend is considered online when a realtime update has been received
  /// from them. Use [isFriendOnline] for convenient access.
  final Set<String> onlineFriendIds;

  /// Whether the user has any pending requests to respond to.
  bool get hasPendingRequests => pendingRequests.isNotEmpty;

  /// Whether the user has any sent requests awaiting response.
  bool get hasSentRequests => sentRequests.isNotEmpty;

  /// Whether the user has any friends.
  bool get hasFriends => friends.isNotEmpty;

  /// Total count of all relationships.
  int get totalCount => relationships.length;

  /// Whether any friends are currently online.
  bool get hasOnlineFriends => onlineFriendIds.isNotEmpty;

  /// Count of currently online friends.
  int get onlineFriendsCount => onlineFriendIds.length;

  /// Checks if a specific friend is currently online.
  ///
  /// Returns `true` if [friendId] is in the [onlineFriendIds] set.
  ///
  /// Example:
  /// ```dart
  /// if (state.isFriendOnline('user123')) {
  ///   showOnlineIndicator();
  /// }
  /// ```
  bool isFriendOnline(String friendId) => onlineFriendIds.contains(friendId);

  /// Gets the latest realtime step update for a specific friend.
  ///
  /// Returns `null` if no realtime update has been received for [friendId].
  ///
  /// Example:
  /// ```dart
  /// final update = state.getRealtimeUpdate('user123');
  /// if (update != null) {
  ///   print('Last activity: ${update.timestamp}');
  /// }
  /// ```
  RealtimeStepUpdate? getRealtimeUpdate(String friendId) =>
      realtimeUpdates[friendId];

  /// Gets the latest realtime step count for a specific friend.
  ///
  /// Returns `null` if no realtime update has been received for [friendId].
  ///
  /// Example:
  /// ```dart
  /// final steps = state.getRealtimeSteps('user123');
  /// if (steps != null) {
  ///   print('Friend walked $steps steps');
  /// }
  /// ```
  int? getRealtimeSteps(String friendId) => realtimeUpdates[friendId]?.stepCount;

  @override
  List<Object?> get props => [
        relationships,
        pendingRequests,
        sentRequests,
        friends,
        realtimeUpdates,
        onlineFriendIds,
      ];
}

/// State indicating that a sharing operation has failed.
///
/// This state is emitted when an error occurs during:
/// - Initial data load
/// - Pull-to-refresh
/// - Sending a request
/// - Accepting/rejecting a request
/// - Revoking a relationship
///
/// Contains an error [message] describing what went wrong.
///
/// Example:
/// ```dart
/// if (state is SharingError) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(state.message)),
///   );
/// }
/// ```
final class SharingError extends SharingState {
  /// Creates a [SharingError] state.
  ///
  /// [message] - A human-readable error message.
  const SharingError({required this.message});

  /// The error message describing what went wrong.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// State indicating that a sharing action was successful.
///
/// This state is emitted when:
/// - A sharing request was sent successfully
/// - A request was accepted successfully
/// - A request was rejected successfully
/// - A relationship was revoked successfully
///
/// Contains a success [message] to display to the user.
///
/// Example:
/// ```dart
/// BlocListener<SharingBloc, SharingState>(
///   listenWhen: (previous, current) => current is SharingActionSuccess,
///   listener: (context, state) {
///     if (state is SharingActionSuccess) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text(state.message)),
///       );
///     }
///   },
/// )
/// ```
final class SharingActionSuccess extends SharingState {
  /// Creates a [SharingActionSuccess] state.
  ///
  /// [message] - A human-readable success message.
  const SharingActionSuccess({required this.message});

  /// The success message describing what action completed.
  final String message;

  @override
  List<Object?> get props => [message];
}
