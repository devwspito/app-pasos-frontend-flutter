/// Enum representing the status of a goal.
enum GoalStatus {
  active,
  completed,
  cancelled,
}

/// Model representing a group goal for step tracking.
///
/// Goals allow multiple users to collaborate towards a shared step target
/// within a specified time period.
class GoalModel {
  final String id;
  final String name;
  final String? description;
  final int targetSteps;
  final int currentSteps;
  final DateTime startDate;
  final DateTime endDate;
  final GoalStatus status;
  final String creatorId;
  final String creatorUsername;
  final String? creatorProfileImageUrl;
  final int memberCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const GoalModel({
    required this.id,
    required this.name,
    this.description,
    required this.targetSteps,
    required this.currentSteps,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.creatorId,
    required this.creatorUsername,
    this.creatorProfileImageUrl,
    required this.memberCount,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a [GoalModel] from JSON data.
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      targetSteps: json['targetSteps'] as int,
      currentSteps: json['currentSteps'] as int? ?? 0,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: _parseStatus(json['status'] as String),
      creatorId: json['creatorId'] as String,
      creatorUsername: json['creatorUsername'] as String,
      creatorProfileImageUrl: json['creatorProfileImageUrl'] as String?,
      memberCount: json['memberCount'] as int? ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Converts this model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetSteps': targetSteps,
      'currentSteps': currentSteps,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
      'creatorId': creatorId,
      'creatorUsername': creatorUsername,
      'creatorProfileImageUrl': creatorProfileImageUrl,
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Parses the status string to [GoalStatus] enum.
  static GoalStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return GoalStatus.active;
      case 'completed':
        return GoalStatus.completed;
      case 'cancelled':
        return GoalStatus.cancelled;
      default:
        return GoalStatus.active;
    }
  }

  /// Returns the progress percentage towards the target (0.0 to 1.0).
  double get progressPercentage {
    if (targetSteps <= 0) return 0.0;
    final progress = currentSteps / targetSteps;
    return progress > 1.0 ? 1.0 : progress;
  }

  /// Returns true if the goal has been achieved.
  bool get isAchieved => currentSteps >= targetSteps;

  /// Returns true if the goal is still active and within the date range.
  bool get isActive {
    final now = DateTime.now();
    return status == GoalStatus.active &&
        now.isAfter(startDate) &&
        now.isBefore(endDate);
  }
}
