import 'sharing_permission.dart';

/// Represents a sharing relationship between two users.
///
/// A sharing relationship is established when one user sends
/// a sharing request to another user. Once accepted, both users
/// can view each other's step data according to the granted permissions.
///
/// Example:
/// ```dart
/// final relationship = SharingRelationship(
///   id: '123',
///   friendId: 'user-456',
///   friendName: 'John Doe',
///   friendEmail: 'john@example.com',
///   status: RelationshipStatus.accepted,
///   permissions: [SharingPermission.viewSteps, SharingPermission.viewTrends],
///   createdAt: DateTime.now(),
/// );
/// ```
final class SharingRelationship {
  const SharingRelationship({
    required this.id,
    required this.friendId,
    required this.friendName,
    required this.friendEmail,
    required this.status,
    required this.permissions,
    required this.createdAt,
    this.acceptedAt,
  });

  /// Unique identifier for this relationship.
  final String id;

  /// The ID of the friend user in this relationship.
  final String friendId;

  /// Display name of the friend.
  final String friendName;

  /// Email address of the friend.
  final String friendEmail;

  /// Current status of the relationship.
  final RelationshipStatus status;

  /// List of permissions granted in this relationship.
  final List<SharingPermission> permissions;

  /// When the sharing request was created.
  final DateTime createdAt;

  /// When the sharing request was accepted (null if pending).
  final DateTime? acceptedAt;

  /// Whether this relationship is active and data can be shared.
  bool get isActive => status == RelationshipStatus.accepted;

  /// Whether this relationship is awaiting acceptance.
  bool get isPending => status == RelationshipStatus.pending;
}

/// Status of a sharing relationship.
enum RelationshipStatus {
  /// Request has been sent but not yet accepted.
  pending,

  /// Request has been accepted, sharing is active.
  accepted,

  /// Request was declined by the recipient.
  declined,

  /// Relationship was terminated by one of the users.
  revoked,
}
