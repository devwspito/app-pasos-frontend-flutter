import 'package:equatable/equatable.dart';

/// Enum representing the status of a relationship between users.
enum RelationshipStatus {
  /// Request has been sent but not yet accepted.
  pending,

  /// Request has been accepted, users are friends.
  accepted,

  /// Request has been rejected.
  rejected,

  /// Relationship has been blocked.
  blocked,
}

/// Entity representing a relationship between two users.
///
/// This is a pure domain entity with no serialization logic.
/// Use corresponding model in the data layer for API serialization.
final class Relationship extends Equatable {
  const Relationship({
    required this.id,
    required this.requesterId,
    required this.requesterUsername,
    required this.addresseeId,
    required this.addresseeUsername,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier for the relationship.
  final String id;

  /// ID of the user who sent the friend request.
  final String requesterId;

  /// Username of the requester.
  final String requesterUsername;

  /// ID of the user who received the friend request.
  final String addresseeId;

  /// Username of the addressee.
  final String addresseeUsername;

  /// Current status of the relationship.
  final RelationshipStatus status;

  /// Timestamp when the relationship was created.
  final DateTime createdAt;

  /// Timestamp when the relationship was last updated.
  final DateTime? updatedAt;

  /// Returns true if this is a pending request.
  bool get isPending => status == RelationshipStatus.pending;

  /// Returns true if users are friends.
  bool get isFriend => status == RelationshipStatus.accepted;

  /// Creates a copy of this Relationship with the given fields replaced.
  Relationship copyWith({
    String? id,
    String? requesterId,
    String? requesterUsername,
    String? addresseeId,
    String? addresseeUsername,
    RelationshipStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Relationship(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterUsername: requesterUsername ?? this.requesterUsername,
      addresseeId: addresseeId ?? this.addresseeId,
      addresseeUsername: addresseeUsername ?? this.addresseeUsername,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        requesterId,
        requesterUsername,
        addresseeId,
        addresseeUsername,
        status,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() =>
      'Relationship(id: $id, requester: $requesterUsername, addressee: $addresseeUsername, status: $status)';
}
