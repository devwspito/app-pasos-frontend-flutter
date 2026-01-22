import 'package:equatable/equatable.dart';

/// Enum representing the status of a sharing relationship
enum SharingStatus {
  pending,
  accepted,
  rejected,
}

/// Domain entity representing a sharing relationship between users
final class SharingRelationship extends Equatable {
  final String id;
  final String requesterId;
  final String requesterName;
  final String requesterEmail;
  final String? requesterAvatarUrl;
  final String targetId;
  final String targetName;
  final String targetEmail;
  final String? targetAvatarUrl;
  final SharingStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  const SharingRelationship({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.requesterEmail,
    this.requesterAvatarUrl,
    required this.targetId,
    required this.targetName,
    required this.targetEmail,
    this.targetAvatarUrl,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
  });

  @override
  List<Object?> get props => [
        id,
        requesterId,
        requesterName,
        requesterEmail,
        requesterAvatarUrl,
        targetId,
        targetName,
        targetEmail,
        targetAvatarUrl,
        status,
        createdAt,
        acceptedAt,
      ];

  /// Returns true if this relationship is pending
  bool get isPending => status == SharingStatus.pending;

  /// Returns true if this relationship is accepted
  bool get isAccepted => status == SharingStatus.accepted;

  /// Creates a copy of this SharingRelationship with the given fields replaced
  SharingRelationship copyWith({
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
    return SharingRelationship(
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
