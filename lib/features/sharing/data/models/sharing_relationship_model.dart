import '../../domain/entities/sharing_relationship.dart';

/// Data model for SharingRelationship with JSON serialization
final class SharingRelationshipModel extends SharingRelationship {
  const SharingRelationshipModel({
    required super.id,
    required super.requesterId,
    required super.requesterName,
    required super.requesterEmail,
    super.requesterAvatarUrl,
    required super.targetId,
    required super.targetName,
    required super.targetEmail,
    super.targetAvatarUrl,
    required super.status,
    required super.createdAt,
    super.acceptedAt,
  });

  /// Creates a SharingRelationshipModel from a JSON map
  factory SharingRelationshipModel.fromJson(Map<String, dynamic> json) {
    return SharingRelationshipModel(
      id: json['id'] as String,
      requesterId: json['requesterId'] as String,
      requesterName: json['requesterName'] as String,
      requesterEmail: json['requesterEmail'] as String,
      requesterAvatarUrl: json['requesterAvatarUrl'] as String?,
      targetId: json['targetId'] as String,
      targetName: json['targetName'] as String,
      targetEmail: json['targetEmail'] as String,
      targetAvatarUrl: json['targetAvatarUrl'] as String?,
      status: _parseSharingStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
    );
  }

  /// Creates a SharingRelationshipModel from a SharingRelationship entity
  factory SharingRelationshipModel.fromEntity(SharingRelationship entity) {
    return SharingRelationshipModel(
      id: entity.id,
      requesterId: entity.requesterId,
      requesterName: entity.requesterName,
      requesterEmail: entity.requesterEmail,
      requesterAvatarUrl: entity.requesterAvatarUrl,
      targetId: entity.targetId,
      targetName: entity.targetName,
      targetEmail: entity.targetEmail,
      targetAvatarUrl: entity.targetAvatarUrl,
      status: entity.status,
      createdAt: entity.createdAt,
      acceptedAt: entity.acceptedAt,
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterEmail': requesterEmail,
      'requesterAvatarUrl': requesterAvatarUrl,
      'targetId': targetId,
      'targetName': targetName,
      'targetEmail': targetEmail,
      'targetAvatarUrl': targetAvatarUrl,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
    };
  }

  /// Parses a string to SharingStatus enum
  static SharingStatus _parseSharingStatus(String value) {
    return SharingStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SharingStatus.pending,
    );
  }

  @override
  SharingRelationshipModel copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    String? requesterEmail,
    String? requesterAvatarUrl,
    String? targetId,
    String? targetName,
    String? targetEmail,
    String? targetAvatarUrl,
    SharingStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
  }) {
    return SharingRelationshipModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterEmail: requesterEmail ?? this.requesterEmail,
      requesterAvatarUrl: requesterAvatarUrl ?? this.requesterAvatarUrl,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      targetEmail: targetEmail ?? this.targetEmail,
      targetAvatarUrl: targetAvatarUrl ?? this.targetAvatarUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}
