import 'package:equatable/equatable.dart';

/// Domain entity representing a sharing relationship between two users.
///
/// This is an immutable entity that contains business logic methods
/// for managing sharing relationships. Unlike data models, entities do NOT
/// contain JSON serialization logic.
///
/// Example usage:
/// ```dart
/// final relationship = SharingRelationship(
///   id: 'rel-123',
///   requesterId: 'user-456',
///   targetId: 'user-789',
///   status: 'pending',
///   createdAt: DateTime.now(),
///   updatedAt: DateTime.now(),
///   requesterUsername: 'john_doe',
///   requesterProfileImageUrl: 'https://example.com/avatar.png',
///   targetUsername: 'jane_smith',
///   targetProfileImageUrl: null,
/// );
///
/// print(relationship.isPending); // true
/// print(relationship.isRequester('user-456')); // true
/// print(relationship.getOtherUsername('user-456')); // 'jane_smith'
/// ```
class SharingRelationship extends Equatable {
  /// Unique identifier for the sharing relationship.
  final String id;

  /// ID of the user who initiated the sharing request.
  final String requesterId;

  /// ID of the user who received the sharing request.
  final String targetId;

  /// Current status of the relationship.
  /// Possible values: 'pending', 'accepted', 'rejected', 'blocked'.
  final String status;

  /// Timestamp when this relationship was created.
  final DateTime createdAt;

  /// Timestamp when this relationship was last updated.
  final DateTime updatedAt;

  /// Username of the requester.
  final String requesterUsername;

  /// Profile image URL of the requester. May be null if not set.
  final String? requesterProfileImageUrl;

  /// Username of the target user.
  final String targetUsername;

  /// Profile image URL of the target user. May be null if not set.
  final String? targetProfileImageUrl;

  /// Creates a [SharingRelationship] instance.
  ///
  /// All fields are required except profile image URLs which can be null.
  const SharingRelationship({
    required this.id,
    required this.requesterId,
    required this.targetId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.requesterUsername,
    this.requesterProfileImageUrl,
    required this.targetUsername,
    this.targetProfileImageUrl,
  });

  /// Returns true if the relationship status is 'pending'.
  bool get isPending => status == 'pending';

  /// Returns true if the relationship status is 'accepted'.
  bool get isAccepted => status == 'accepted';

  /// Returns true if the relationship status is 'rejected'.
  bool get isRejected => status == 'rejected';

  /// Returns true if the relationship status is 'blocked'.
  bool get isBlocked => status == 'blocked';

  /// Returns true if the given [userId] is the requester of this relationship.
  ///
  /// Example:
  /// ```dart
  /// final relationship = SharingRelationship(requesterId: 'user-123', ...);
  /// print(relationship.isRequester('user-123')); // true
  /// print(relationship.isRequester('user-456')); // false
  /// ```
  bool isRequester(String userId) => requesterId == userId;

  /// Returns the username of the other person in the relationship.
  ///
  /// If [currentUserId] is the requester, returns the target's username.
  /// If [currentUserId] is the target, returns the requester's username.
  ///
  /// Example:
  /// ```dart
  /// final relationship = SharingRelationship(
  ///   requesterId: 'user-123',
  ///   targetId: 'user-456',
  ///   requesterUsername: 'john',
  ///   targetUsername: 'jane',
  ///   ...
  /// );
  /// print(relationship.getOtherUsername('user-123')); // 'jane'
  /// print(relationship.getOtherUsername('user-456')); // 'john'
  /// ```
  String getOtherUsername(String currentUserId) {
    if (currentUserId == requesterId) {
      return targetUsername;
    }
    return requesterUsername;
  }

  /// Returns the profile image URL of the other person in the relationship.
  ///
  /// If [currentUserId] is the requester, returns the target's profile image.
  /// If [currentUserId] is the target, returns the requester's profile image.
  /// May return null if the other user has no profile image set.
  ///
  /// Example:
  /// ```dart
  /// final relationship = SharingRelationship(
  ///   requesterId: 'user-123',
  ///   targetId: 'user-456',
  ///   requesterProfileImageUrl: 'https://example.com/john.png',
  ///   targetProfileImageUrl: null,
  ///   ...
  /// );
  /// print(relationship.getOtherProfileImage('user-123')); // null
  /// print(relationship.getOtherProfileImage('user-456')); // 'https://example.com/john.png'
  /// ```
  String? getOtherProfileImage(String currentUserId) {
    if (currentUserId == requesterId) {
      return targetProfileImageUrl;
    }
    return requesterProfileImageUrl;
  }

  /// Creates a copy of this relationship with optional field overrides.
  SharingRelationship copyWith({
    String? id,
    String? requesterId,
    String? targetId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? requesterUsername,
    String? requesterProfileImageUrl,
    String? targetUsername,
    String? targetProfileImageUrl,
  }) {
    return SharingRelationship(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      targetId: targetId ?? this.targetId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      requesterUsername: requesterUsername ?? this.requesterUsername,
      requesterProfileImageUrl:
          requesterProfileImageUrl ?? this.requesterProfileImageUrl,
      targetUsername: targetUsername ?? this.targetUsername,
      targetProfileImageUrl:
          targetProfileImageUrl ?? this.targetProfileImageUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        requesterId,
        targetId,
        status,
        createdAt,
        updatedAt,
        requesterUsername,
        requesterProfileImageUrl,
        targetUsername,
        targetProfileImageUrl,
      ];

  @override
  String toString() {
    return 'SharingRelationship(id: $id, requesterId: $requesterId, '
        'targetId: $targetId, status: $status, createdAt: $createdAt, '
        'updatedAt: $updatedAt, requesterUsername: $requesterUsername, '
        'requesterProfileImageUrl: $requesterProfileImageUrl, '
        'targetUsername: $targetUsername, '
        'targetProfileImageUrl: $targetProfileImageUrl)';
  }
}
