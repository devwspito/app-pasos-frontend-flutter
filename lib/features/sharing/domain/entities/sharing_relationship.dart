import 'package:equatable/equatable.dart';

/// Enum representing the status of a sharing relationship
enum SharingStatus {
  pending,
  accepted,
  rejected,
}

/// Enum representing the direction of a sharing request
enum SharingDirection {
  sent,
  received,
}

/// Enum representing the permissions granted in a sharing relationship
enum SharingPermission {
  viewSteps,
  viewGoals,
  viewStats,
}

/// Domain entity representing a sharing relationship between users
final class SharingRelationship extends Equatable {
  final String id;
  final String userId;
  final String friendId;
  final String friendName;
  final String friendEmail;
  final SharingStatus status;
  final SharingDirection direction;
  final List<SharingPermission> permissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SharingRelationship({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friendName,
    required this.friendEmail,
    required this.status,
    required this.direction,
    required this.permissions,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        friendId,
        friendName,
        friendEmail,
        status,
        direction,
        permissions,
        createdAt,
        updatedAt,
      ];

  /// Creates a copy of this SharingRelationship with the given fields replaced
  SharingRelationship copyWith({
    String? id,
    String? userId,
    String? friendId,
    String? friendName,
    String? friendEmail,
    SharingStatus? status,
    SharingDirection? direction,
    List<SharingPermission>? permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SharingRelationship(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      friendName: friendName ?? this.friendName,
      friendEmail: friendEmail ?? this.friendEmail,
      status: status ?? this.status,
      direction: direction ?? this.direction,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns true if the relationship is active (accepted)
  bool get isActive => status == SharingStatus.accepted;

  /// Returns true if this is a pending request
  bool get isPending => status == SharingStatus.pending;

  /// Returns true if the current user sent this request
  bool get isSentByMe => direction == SharingDirection.sent;

  /// Returns true if the user can view friend's steps
  bool get canViewSteps => permissions.contains(SharingPermission.viewSteps);

  /// Returns true if the user can view friend's goals
  bool get canViewGoals => permissions.contains(SharingPermission.viewGoals);

  /// Returns true if the user can view friend's stats
  bool get canViewStats => permissions.contains(SharingPermission.viewStats);
}
