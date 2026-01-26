/// Enum representing the role of a member in a goal.
enum GoalMemberRole {
  owner,
  member,
}

/// Enum representing the status of a goal membership invitation.
enum GoalMembershipStatus {
  pending,
  accepted,
  rejected,
}

/// Model representing a user's membership in a goal.
///
/// Tracks who is participating in a goal and their contribution status.
class GoalMembershipModel {
  final String id;
  final String goalId;
  final String userId;
  final String username;
  final String? profileImageUrl;
  final GoalMemberRole role;
  final GoalMembershipStatus status;
  final int contributedSteps;
  final DateTime joinedAt;
  final DateTime? invitedAt;

  const GoalMembershipModel({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.role,
    required this.status,
    required this.contributedSteps,
    required this.joinedAt,
    this.invitedAt,
  });

  /// Creates a [GoalMembershipModel] from JSON data.
  factory GoalMembershipModel.fromJson(Map<String, dynamic> json) {
    return GoalMembershipModel(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: _parseRole(json['role'] as String),
      status: _parseStatus(json['status'] as String),
      contributedSteps: json['contributedSteps'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      invitedAt: json['invitedAt'] != null
          ? DateTime.parse(json['invitedAt'] as String)
          : null,
    );
  }

  /// Converts this model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'userId': userId,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'role': role.name,
      'status': status.name,
      'contributedSteps': contributedSteps,
      'joinedAt': joinedAt.toIso8601String(),
      'invitedAt': invitedAt?.toIso8601String(),
    };
  }

  /// Parses the role string to [GoalMemberRole] enum.
  static GoalMemberRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return GoalMemberRole.owner;
      case 'member':
        return GoalMemberRole.member;
      default:
        return GoalMemberRole.member;
    }
  }

  /// Parses the status string to [GoalMembershipStatus] enum.
  static GoalMembershipStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return GoalMembershipStatus.pending;
      case 'accepted':
        return GoalMembershipStatus.accepted;
      case 'rejected':
        return GoalMembershipStatus.rejected;
      default:
        return GoalMembershipStatus.pending;
    }
  }

  /// Returns true if this member is the owner of the goal.
  bool get isOwner => role == GoalMemberRole.owner;

  /// Returns true if the invitation has been accepted.
  bool get isAccepted => status == GoalMembershipStatus.accepted;

  /// Returns true if the invitation is still pending.
  bool get isPending => status == GoalMembershipStatus.pending;
}
