import '../../domain/entities/goal_membership.dart';

/// Data model for GoalMembership with JSON serialization.
final class GoalMembershipModel extends GoalMembership {
  const GoalMembershipModel({
    required super.id,
    required super.goalId,
    required super.userId,
    required super.username,
    required super.role,
    required super.status,
    required super.joinedAt,
    required super.totalSteps,
  });

  /// Creates a GoalMembershipModel from a JSON map.
  factory GoalMembershipModel.fromJson(Map<String, dynamic> json) {
    return GoalMembershipModel(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      role: _parseMemberRole(json['role'] as String),
      status: _parseMembershipStatus(json['status'] as String),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      totalSteps: json['totalSteps'] as int,
    );
  }

  /// Creates a GoalMembershipModel from a GoalMembership entity.
  factory GoalMembershipModel.fromEntity(GoalMembership entity) {
    return GoalMembershipModel(
      id: entity.id,
      goalId: entity.goalId,
      userId: entity.userId,
      username: entity.username,
      role: entity.role,
      status: entity.status,
      joinedAt: entity.joinedAt,
      totalSteps: entity.totalSteps,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'userId': userId,
      'username': username,
      'role': role.name,
      'status': status.name,
      'joinedAt': joinedAt.toIso8601String(),
      'totalSteps': totalSteps,
    };
  }

  /// Parses a string to MemberRole enum.
  static MemberRole _parseMemberRole(String value) {
    return MemberRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MemberRole.member,
    );
  }

  /// Parses a string to MembershipStatus enum.
  static MembershipStatus _parseMembershipStatus(String value) {
    return MembershipStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MembershipStatus.pending,
    );
  }

  @override
  GoalMembershipModel copyWith({
    String? id,
    String? goalId,
    String? userId,
    String? username,
    MemberRole? role,
    MembershipStatus? status,
    DateTime? joinedAt,
    int? totalSteps,
  }) {
    return GoalMembershipModel(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }
}
