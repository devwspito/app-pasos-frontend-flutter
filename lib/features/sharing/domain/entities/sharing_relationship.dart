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
  const SharingRelationship({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
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

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        toUserId,
        status,
        createdAt,
        acceptedAt,
      ];

  @override
  String toString() {
    return 'SharingRelationship(id: $id, fromUserId: $fromUserId, '
        'toUserId: $toUserId, status: $status, createdAt: $createdAt, '
        'acceptedAt: $acceptedAt)';
  }
}
