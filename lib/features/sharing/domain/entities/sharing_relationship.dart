/// Sharing relationship entity for the sharing domain.
///
/// This is a pure domain entity representing a sharing relationship
/// between users. It's independent of any data layer implementation.
library;

import 'package:equatable/equatable.dart';

/// Represents a sharing relationship between two users.
///
/// A sharing relationship allows one user to share their step data
/// with another. The relationship has three possible statuses:
/// pending, accepted, or rejected.
///
/// Example usage:
/// ```dart
/// final relationship = SharingRelationship(
///   id: '123',
///   fromUserId: 'user1',
///   toUserId: 'user2',
///   status: 'pending',
///   createdAt: DateTime.now(),
/// );
/// ```
class SharingRelationship extends Equatable {
  /// Creates a [SharingRelationship] instance.
  ///
  /// [id] - The unique identifier for the relationship.
  /// [fromUserId] - The ID of the user who initiated the request.
  /// [toUserId] - The ID of the user who receives the request.
  /// [status] - The current status: 'pending', 'accepted', or 'rejected'.
  /// [createdAt] - When the relationship was created.
  /// [acceptedAt] - When the relationship was accepted (optional).
  /// [isOnline] - Whether the friend is currently online (optional).
  /// [realtimeSteps] - The friend's current step count (optional).
  /// [lastStepUpdate] - When realtime step data was last updated (optional).
  /// [friendName] - The friend's display name (optional).
  /// [friendAvatarUrl] - The friend's avatar URL (optional).
  const SharingRelationship({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.isOnline,
    this.realtimeSteps,
    this.lastStepUpdate,
    this.friendName,
    this.friendAvatarUrl,
  });

  /// Creates an empty relationship for use in initial states.
  ///
  /// Useful for initializing state before relationship data is loaded.
  factory SharingRelationship.empty() => SharingRelationship(
        id: '',
        fromUserId: '',
        toUserId: '',
        status: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        acceptedAt: null,
        isOnline: null,
        realtimeSteps: null,
        lastStepUpdate: null,
        friendName: null,
        friendAvatarUrl: null,
      );

  /// The unique identifier for the relationship.
  final String id;

  /// The ID of the user who initiated the sharing request.
  final String fromUserId;

  /// The ID of the user who receives the sharing request.
  final String toUserId;

  /// The current status of the relationship.
  ///
  /// Possible values: 'pending', 'accepted', 'rejected'.
  final String status;

  /// When the relationship was created.
  final DateTime createdAt;

  /// When the relationship was accepted.
  ///
  /// This is null if the relationship has not been accepted yet.
  final DateTime? acceptedAt;

  /// Whether the friend is currently online.
  ///
  /// This is null if online status is not available.
  final bool? isOnline;

  /// The friend's current step count (realtime).
  ///
  /// This is null if realtime steps data is not available.
  final int? realtimeSteps;

  /// When the realtime step data was last updated.
  ///
  /// This is null if realtime data has not been received.
  final DateTime? lastStepUpdate;

  /// The friend's display name (for UI).
  ///
  /// This is null if the friend name is not available.
  final String? friendName;

  /// The friend's avatar URL.
  ///
  /// This is null if the friend has no avatar.
  final String? friendAvatarUrl;

  /// Whether this is an empty/uninitialized relationship.
  bool get isEmpty => id.isEmpty;

  /// Whether this is a valid relationship with data.
  bool get isNotEmpty => !isEmpty;

  /// Whether this relationship is pending acceptance.
  bool get isPending => status == 'pending';

  /// Whether this relationship has been accepted.
  bool get isAccepted => status == 'accepted';

  /// Whether this relationship has been rejected.
  bool get isRejected => status == 'rejected';

  /// Whether realtime step data is available for this relationship.
  bool get hasRealtimeData => realtimeSteps != null;

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        toUserId,
        status,
        createdAt,
        acceptedAt,
        isOnline,
        realtimeSteps,
        lastStepUpdate,
        friendName,
        friendAvatarUrl,
      ];

  @override
  String toString() {
    return 'SharingRelationship(id: $id, fromUserId: $fromUserId, '
        'toUserId: $toUserId, status: $status, createdAt: $createdAt, '
        'acceptedAt: $acceptedAt, isOnline: $isOnline, '
        'realtimeSteps: $realtimeSteps, lastStepUpdate: $lastStepUpdate, '
        'friendName: $friendName, friendAvatarUrl: $friendAvatarUrl)';
  }
}
