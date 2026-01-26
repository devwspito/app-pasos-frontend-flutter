import 'package:equatable/equatable.dart';

/// Data layer model for a sharing relationship between users.
///
/// This model handles JSON serialization/deserialization for API responses.
/// Extends [Equatable] for value equality comparison.
///
/// Example JSON:
/// ```json
/// {
///   "id": "rel-123",
///   "requesterId": "user-001",
///   "targetId": "user-002",
///   "status": "accepted",
///   "createdAt": "2024-01-15T10:30:00Z",
///   "updatedAt": "2024-01-16T08:00:00Z",
///   "requesterUsername": "johndoe",
///   "requesterProfileImageUrl": "https://example.com/avatar1.jpg",
///   "targetUsername": "janedoe",
///   "targetProfileImageUrl": "https://example.com/avatar2.jpg"
/// }
/// ```
class SharingRelationshipModel extends Equatable {
  /// Unique identifier for the relationship.
  final String id;

  /// User ID of the person who sent the request.
  final String requesterId;

  /// User ID of the person who received the request.
  final String targetId;

  /// Status of the relationship: 'pending', 'accepted', 'rejected', or 'blocked'.
  final String status;

  /// Timestamp when the relationship was created.
  final DateTime createdAt;

  /// Timestamp when the relationship was last updated.
  final DateTime? updatedAt;

  /// Username of the requester (for display purposes).
  final String? requesterUsername;

  /// Profile image URL of the requester.
  final String? requesterProfileImageUrl;

  /// Username of the target user (for display purposes).
  final String? targetUsername;

  /// Profile image URL of the target user.
  final String? targetProfileImageUrl;

  /// Creates a [SharingRelationshipModel] instance.
  const SharingRelationshipModel({
    required this.id,
    required this.requesterId,
    required this.targetId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.requesterUsername,
    this.requesterProfileImageUrl,
    this.targetUsername,
    this.targetProfileImageUrl,
  });

  /// Creates a [SharingRelationshipModel] from a JSON map.
  ///
  /// Handles null safety for all fields with appropriate defaults.
  /// Parses [createdAt] and [updatedAt] from ISO 8601 string format.
  factory SharingRelationshipModel.fromJson(Map<String, dynamic> json) {
    return SharingRelationshipModel(
      id: json['id'] as String? ?? '',
      requesterId: json['requesterId'] as String? ?? '',
      targetId: json['targetId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      requesterUsername: json['requesterUsername'] as String?,
      requesterProfileImageUrl: json['requesterProfileImageUrl'] as String?,
      targetUsername: json['targetUsername'] as String?,
      targetProfileImageUrl: json['targetProfileImageUrl'] as String?,
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// Serializes [createdAt] and [updatedAt] to ISO 8601 string format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterId': requesterId,
      'targetId': targetId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (requesterUsername != null) 'requesterUsername': requesterUsername,
      if (requesterProfileImageUrl != null)
        'requesterProfileImageUrl': requesterProfileImageUrl,
      if (targetUsername != null) 'targetUsername': targetUsername,
      if (targetProfileImageUrl != null)
        'targetProfileImageUrl': targetProfileImageUrl,
    };
  }

  /// Creates a copy of this model with optional field overrides.
  SharingRelationshipModel copyWith({
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
    return SharingRelationshipModel(
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

  /// Checks if the relationship is pending.
  bool get isPending => status == 'pending';

  /// Checks if the relationship is accepted.
  bool get isAccepted => status == 'accepted';

  /// Checks if the relationship is rejected.
  bool get isRejected => status == 'rejected';

  /// Checks if the relationship is blocked.
  bool get isBlocked => status == 'blocked';

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
    return 'SharingRelationshipModel(id: $id, requesterId: $requesterId, '
        'targetId: $targetId, status: $status, createdAt: $createdAt, '
        'updatedAt: $updatedAt, requesterUsername: $requesterUsername, '
        'requesterProfileImageUrl: $requesterProfileImageUrl, '
        'targetUsername: $targetUsername, '
        'targetProfileImageUrl: $targetProfileImageUrl)';
  }
}
