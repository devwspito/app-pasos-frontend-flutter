import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'user_model.dart';

part 'sharing_model.g.dart';

/// Enum representing the status of a sharing relationship.
///
/// - [pending]: Request has been sent but not yet accepted
/// - [accepted]: Request has been accepted (one-way sharing)
/// - [bidirectional]: Both users share data with each other
/// - [rejected]: Request was rejected by the target user
enum SharingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('bidirectional')
  bidirectional,
  @JsonValue('rejected')
  rejected,
}

/// Data model representing a sharing relationship between users.
///
/// Maps to the MongoDB SharingRelationship schema with JSON serialization.
/// Represents a request from one user (requester) to share step data with another (target).
@JsonSerializable()
class SharingRelationshipModel extends Equatable {
  /// MongoDB document ID
  @JsonKey(name: '_id')
  final String id;

  /// ID of the user who initiated the sharing request
  final String requesterId;

  /// ID of the user who receives the sharing request
  final String targetId;

  /// Current status of the sharing relationship
  final SharingStatus status;

  /// Timestamp when the relationship was created
  final DateTime createdAt;

  /// Timestamp when the request was accepted (if applicable)
  final DateTime? acceptedAt;

  /// Populated requester user object (when returned from API with .populate())
  @JsonKey(includeIfNull: false)
  final UserModel? requester;

  /// Populated target user object (when returned from API with .populate())
  @JsonKey(includeIfNull: false)
  final UserModel? target;

  const SharingRelationshipModel({
    required this.id,
    required this.requesterId,
    required this.targetId,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.requester,
    this.target,
  });

  /// Creates a [SharingRelationshipModel] from a JSON map.
  factory SharingRelationshipModel.fromJson(Map<String, dynamic> json) =>
      _$SharingRelationshipModelFromJson(json);

  /// Converts this [SharingRelationshipModel] to a JSON map.
  Map<String, dynamic> toJson() => _$SharingRelationshipModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        requesterId,
        targetId,
        status,
        createdAt,
        acceptedAt,
        requester,
        target,
      ];

  /// Returns true if the request is still pending.
  bool get isPending => status == SharingStatus.pending;

  /// Returns true if the relationship has been accepted (one-way or bidirectional).
  bool get isAccepted =>
      status == SharingStatus.accepted || status == SharingStatus.bidirectional;

  /// Returns true if both users share data with each other.
  bool get isBidirectional => status == SharingStatus.bidirectional;

  /// Returns true if the request was rejected.
  bool get isRejected => status == SharingStatus.rejected;

  /// Creates a copy of this [SharingRelationshipModel] with the given fields replaced.
  SharingRelationshipModel copyWith({
    String? id,
    String? requesterId,
    String? targetId,
    SharingStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    UserModel? requester,
    UserModel? target,
  }) {
    return SharingRelationshipModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      targetId: targetId ?? this.targetId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      requester: requester ?? this.requester,
      target: target ?? this.target,
    );
  }

  @override
  String toString() =>
      'SharingRelationshipModel(id: $id, requesterId: $requesterId, targetId: $targetId, status: $status)';
}

/// Request model for creating a new share request.
///
/// Used when sending a request to share step data with another user.
@JsonSerializable()
class CreateShareRequest extends Equatable {
  /// ID of the user to share data with
  final String targetId;

  const CreateShareRequest({required this.targetId});

  /// Creates a [CreateShareRequest] from a JSON map.
  factory CreateShareRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateShareRequestFromJson(json);

  /// Converts this [CreateShareRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$CreateShareRequestToJson(this);

  @override
  List<Object?> get props => [targetId];

  @override
  String toString() => 'CreateShareRequest(targetId: $targetId)';
}

/// Response model for pending share requests.
///
/// Contains lists of incoming and outgoing pending requests.
@JsonSerializable()
class PendingSharesResponse extends Equatable {
  /// List of incoming share requests (others wanting to share with you)
  final List<SharingRelationshipModel> incoming;

  /// List of outgoing share requests (your pending requests to others)
  final List<SharingRelationshipModel> outgoing;

  const PendingSharesResponse({
    required this.incoming,
    required this.outgoing,
  });

  /// Creates a [PendingSharesResponse] from a JSON map.
  factory PendingSharesResponse.fromJson(Map<String, dynamic> json) =>
      _$PendingSharesResponseFromJson(json);

  /// Converts this [PendingSharesResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$PendingSharesResponseToJson(this);

  @override
  List<Object?> get props => [incoming, outgoing];

  /// Returns true if there are any pending requests (incoming or outgoing).
  bool get hasPendingRequests => incoming.isNotEmpty || outgoing.isNotEmpty;

  /// Returns the total count of pending requests.
  int get totalPendingCount => incoming.length + outgoing.length;

  @override
  String toString() =>
      'PendingSharesResponse(incoming: ${incoming.length}, outgoing: ${outgoing.length})';
}
