import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'user_model.dart';

part 'goal_model.g.dart';

/// Enum representing the membership status in a group goal.
///
/// - [pending]: User has been invited but hasn't responded
/// - [active]: User is an active member of the goal
/// - [left]: User has left the group goal
enum MembershipStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('left')
  left,
}

/// Data model representing a group goal from the backend API.
///
/// Maps to the MongoDB GroupGoal schema with JSON serialization support.
/// Represents a collaborative step goal that multiple users can participate in.
@JsonSerializable()
class GroupGoalModel extends Equatable {
  /// MongoDB document ID
  @JsonKey(name: '_id')
  final String id;

  /// Title of the group goal
  final String title;

  /// Optional description of the goal
  final String? description;

  /// Target number of steps to achieve
  final int targetSteps;

  /// Date when the goal period starts
  final DateTime startDate;

  /// Date when the goal period ends
  final DateTime endDate;

  /// ID of the user who created the goal
  final String creatorId;

  /// Timestamp when the goal was created
  final DateTime createdAt;

  /// Timestamp when the goal was last updated
  final DateTime updatedAt;

  /// Populated creator user object (when returned from API with .populate())
  @JsonKey(includeIfNull: false)
  final UserModel? creator;

  /// List of goal memberships (when returned with members populated)
  @JsonKey(includeIfNull: false)
  final List<GroupGoalMembershipModel>? members;

  const GroupGoalModel({
    required this.id,
    required this.title,
    this.description,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
    required this.creatorId,
    required this.createdAt,
    required this.updatedAt,
    this.creator,
    this.members,
  });

  /// Creates a [GroupGoalModel] from a JSON map.
  factory GroupGoalModel.fromJson(Map<String, dynamic> json) =>
      _$GroupGoalModelFromJson(json);

  /// Converts this [GroupGoalModel] to a JSON map.
  Map<String, dynamic> toJson() => _$GroupGoalModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        targetSteps,
        startDate,
        endDate,
        creatorId,
        createdAt,
        updatedAt,
        creator,
        members,
      ];

  /// Returns true if the goal is currently active (between start and end dates).
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Returns true if the goal hasn't started yet.
  bool get isUpcoming => DateTime.now().isBefore(startDate);

  /// Returns true if the goal period has ended.
  bool get isCompleted => DateTime.now().isAfter(endDate);

  /// Returns the number of days remaining until the goal ends.
  /// Returns 0 if the goal has already ended.
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  /// Returns the number of active members in this goal.
  int get activeMemberCount =>
      members?.where((m) => m.isActive).length ?? 0;

  /// Creates a copy of this [GroupGoalModel] with the given fields replaced.
  GroupGoalModel copyWith({
    String? id,
    String? title,
    String? description,
    int? targetSteps,
    DateTime? startDate,
    DateTime? endDate,
    String? creatorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? creator,
    List<GroupGoalMembershipModel>? members,
  }) {
    return GroupGoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetSteps: targetSteps ?? this.targetSteps,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creator: creator ?? this.creator,
      members: members ?? this.members,
    );
  }

  @override
  String toString() =>
      'GroupGoalModel(id: $id, title: $title, targetSteps: $targetSteps, isActive: $isActive)';
}

/// Data model representing a user's membership in a group goal.
///
/// Maps to the MongoDB GroupGoalMembership schema with JSON serialization.
/// Tracks when a user joined and their current status in the goal.
@JsonSerializable()
class GroupGoalMembershipModel extends Equatable {
  /// MongoDB document ID
  @JsonKey(name: '_id')
  final String id;

  /// ID of the group goal this membership belongs to
  final String goalId;

  /// ID of the member user
  final String userId;

  /// Timestamp when the user joined the goal
  final DateTime joinedAt;

  /// Current membership status
  final MembershipStatus status;

  /// Timestamp when the membership was created
  final DateTime createdAt;

  /// Timestamp when the membership was last updated
  final DateTime updatedAt;

  /// Populated user object (when returned from API with .populate())
  @JsonKey(includeIfNull: false)
  final UserModel? user;

  const GroupGoalMembershipModel({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.joinedAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  /// Creates a [GroupGoalMembershipModel] from a JSON map.
  factory GroupGoalMembershipModel.fromJson(Map<String, dynamic> json) =>
      _$GroupGoalMembershipModelFromJson(json);

  /// Converts this [GroupGoalMembershipModel] to a JSON map.
  Map<String, dynamic> toJson() => _$GroupGoalMembershipModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        goalId,
        userId,
        joinedAt,
        status,
        createdAt,
        updatedAt,
        user,
      ];

  /// Returns true if the membership is active.
  bool get isActive => status == MembershipStatus.active;

  /// Returns true if the membership is pending (invitation not yet accepted).
  bool get isPending => status == MembershipStatus.pending;

  /// Returns true if the user has left the goal.
  bool get hasLeft => status == MembershipStatus.left;

  /// Creates a copy of this [GroupGoalMembershipModel] with the given fields replaced.
  GroupGoalMembershipModel copyWith({
    String? id,
    String? goalId,
    String? userId,
    DateTime? joinedAt,
    MembershipStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? user,
  }) {
    return GroupGoalMembershipModel(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      joinedAt: joinedAt ?? this.joinedAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  @override
  String toString() =>
      'GroupGoalMembershipModel(id: $id, goalId: $goalId, userId: $userId, status: $status)';
}

/// Request model for creating a new group goal.
///
/// Contains all required fields to create a goal via the API.
@JsonSerializable()
class CreateGoalRequest extends Equatable {
  /// Title of the goal
  final String title;

  /// Optional description
  final String? description;

  /// Target number of steps
  final int targetSteps;

  /// Start date of the goal period
  final DateTime startDate;

  /// End date of the goal period
  final DateTime endDate;

  const CreateGoalRequest({
    required this.title,
    this.description,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
  });

  /// Creates a [CreateGoalRequest] from a JSON map.
  factory CreateGoalRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGoalRequestFromJson(json);

  /// Converts this [CreateGoalRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$CreateGoalRequestToJson(this);

  @override
  List<Object?> get props => [title, description, targetSteps, startDate, endDate];

  @override
  String toString() =>
      'CreateGoalRequest(title: $title, targetSteps: $targetSteps)';
}

/// Request model for inviting a user to a group goal.
@JsonSerializable()
class InviteToGoalRequest extends Equatable {
  /// ID of the user to invite
  final String userId;

  const InviteToGoalRequest({required this.userId});

  /// Creates an [InviteToGoalRequest] from a JSON map.
  factory InviteToGoalRequest.fromJson(Map<String, dynamic> json) =>
      _$InviteToGoalRequestFromJson(json);

  /// Converts this [InviteToGoalRequest] to a JSON map.
  Map<String, dynamic> toJson() => _$InviteToGoalRequestToJson(this);

  @override
  List<Object?> get props => [userId];

  @override
  String toString() => 'InviteToGoalRequest(userId: $userId)';
}

/// Response model for goal progress API endpoint.
///
/// Contains aggregated progress information for a group goal.
@JsonSerializable()
class GoalProgressResponse extends Equatable {
  /// ID of the goal
  final String goalId;

  /// Target steps for the goal
  final int targetSteps;

  /// Total steps achieved by all members
  final int totalSteps;

  /// Percentage of progress (0-100)
  final double progressPercentage;

  /// Progress breakdown by member
  final List<MemberProgress> memberProgress;

  const GoalProgressResponse({
    required this.goalId,
    required this.targetSteps,
    required this.totalSteps,
    required this.progressPercentage,
    required this.memberProgress,
  });

  /// Creates a [GoalProgressResponse] from a JSON map.
  factory GoalProgressResponse.fromJson(Map<String, dynamic> json) =>
      _$GoalProgressResponseFromJson(json);

  /// Converts this [GoalProgressResponse] to a JSON map.
  Map<String, dynamic> toJson() => _$GoalProgressResponseToJson(this);

  @override
  List<Object?> get props =>
      [goalId, targetSteps, totalSteps, progressPercentage, memberProgress];

  /// Returns true if the goal has been achieved (100% or more).
  bool get isGoalAchieved => progressPercentage >= 100;

  /// Returns the number of steps remaining to achieve the goal.
  int get stepsRemaining =>
      totalSteps >= targetSteps ? 0 : targetSteps - totalSteps;

  @override
  String toString() =>
      'GoalProgressResponse(goalId: $goalId, progress: $progressPercentage%)';
}

/// Model representing an individual member's progress in a goal.
@JsonSerializable()
class MemberProgress extends Equatable {
  /// ID of the member
  final String userId;

  /// Username of the member
  final String username;

  /// Number of steps contributed by this member
  final int steps;

  /// Percentage contribution to the total (0-100)
  final double contribution;

  const MemberProgress({
    required this.userId,
    required this.username,
    required this.steps,
    required this.contribution,
  });

  /// Creates a [MemberProgress] from a JSON map.
  factory MemberProgress.fromJson(Map<String, dynamic> json) =>
      _$MemberProgressFromJson(json);

  /// Converts this [MemberProgress] to a JSON map.
  Map<String, dynamic> toJson() => _$MemberProgressToJson(this);

  @override
  List<Object?> get props => [userId, username, steps, contribution];

  @override
  String toString() =>
      'MemberProgress(userId: $userId, username: $username, steps: $steps, contribution: $contribution%)';
}
