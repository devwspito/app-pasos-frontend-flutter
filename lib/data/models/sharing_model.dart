import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sharing_model.g.dart';

/// Status values for sharing relationships.
/// Matches backend SharingStatus type.
enum SharingStatus {
  /// Request is pending approval
  @JsonValue('pending')
  pending,

  /// Request has been accepted (one-way sharing)
  @JsonValue('accepted')
  accepted,

  /// Both users share with each other
  @JsonValue('bidirectional')
  bidirectional,

  /// Request was rejected
  @JsonValue('rejected')
  rejected,
}

/// Sharing model representing a sharing relationship between users.
/// Maps to backend ISharingRelationship interface.
@JsonSerializable()
class SharingModel extends Equatable {
  /// Unique sharing relationship identifier (maps from backend _id)
  @JsonKey(name: '_id')
  final String id;

  /// User who initiated the share request
  final String requesterId;

  /// User receiving the share request
  final String targetId;

  /// Current status of the sharing relationship
  final SharingStatus status;

  /// Timestamp when the request was created
  final DateTime createdAt;

  /// Timestamp when the request was accepted (optional)
  final DateTime? acceptedAt;

  const SharingModel({
    required this.id,
    required this.requesterId,
    required this.targetId,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
  });

  /// Creates a SharingModel from JSON map
  factory SharingModel.fromJson(Map<String, dynamic> json) =>
      _$SharingModelFromJson(json);

  /// Converts SharingModel to JSON map
  Map<String, dynamic> toJson() => _$SharingModelToJson(this);

  /// Creates a copy of SharingModel with optional field updates
  SharingModel copyWith({
    String? id,
    String? requesterId,
    String? targetId,
    SharingStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
  }) {
    return SharingModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      targetId: targetId ?? this.targetId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        requesterId,
        targetId,
        status,
        createdAt,
        acceptedAt,
      ];

  @override
  bool get stringify => true;
}
