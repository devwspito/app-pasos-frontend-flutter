import '../../domain/entities/goal_progress.dart';

/// Data model for MemberProgress with JSON serialization.
final class MemberProgressModel extends MemberProgress {
  const MemberProgressModel({
    required super.userId,
    required super.username,
    required super.totalSteps,
    required super.percentComplete,
  });

  /// Creates a MemberProgressModel from a JSON map.
  factory MemberProgressModel.fromJson(Map<String, dynamic> json) {
    return MemberProgressModel(
      userId: json['userId'] as String,
      username: json['username'] as String,
      totalSteps: json['totalSteps'] as int,
      percentComplete: (json['percentComplete'] as num).toDouble(),
    );
  }

  /// Creates a MemberProgressModel from a MemberProgress entity.
  factory MemberProgressModel.fromEntity(MemberProgress entity) {
    return MemberProgressModel(
      userId: entity.userId,
      username: entity.username,
      totalSteps: entity.totalSteps,
      percentComplete: entity.percentComplete,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'totalSteps': totalSteps,
      'percentComplete': percentComplete,
    };
  }

  @override
  MemberProgressModel copyWith({
    String? userId,
    String? username,
    int? totalSteps,
    double? percentComplete,
  }) {
    return MemberProgressModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      totalSteps: totalSteps ?? this.totalSteps,
      percentComplete: percentComplete ?? this.percentComplete,
    );
  }
}

/// Data model for GoalProgress with JSON serialization.
final class GoalProgressModel extends GoalProgress {
  const GoalProgressModel({
    required super.goalId,
    required super.totalSteps,
    required super.targetSteps,
    required super.percentComplete,
    required super.memberProgress,
    required super.lastUpdated,
  });

  /// Creates a GoalProgressModel from a JSON map.
  factory GoalProgressModel.fromJson(Map<String, dynamic> json) {
    final memberProgressList = (json['memberProgress'] as List<dynamic>?)
            ?.map(
              (item) =>
                  MemberProgressModel.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return GoalProgressModel(
      goalId: json['goalId'] as String,
      totalSteps: json['totalSteps'] as int,
      targetSteps: json['targetSteps'] as int,
      percentComplete: (json['percentComplete'] as num).toDouble(),
      memberProgress: memberProgressList,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// Creates a GoalProgressModel from a GoalProgress entity.
  factory GoalProgressModel.fromEntity(GoalProgress entity) {
    return GoalProgressModel(
      goalId: entity.goalId,
      totalSteps: entity.totalSteps,
      targetSteps: entity.targetSteps,
      percentComplete: entity.percentComplete,
      memberProgress: entity.memberProgress
          .map((m) => MemberProgressModel.fromEntity(m))
          .toList(),
      lastUpdated: entity.lastUpdated,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'totalSteps': totalSteps,
      'targetSteps': targetSteps,
      'percentComplete': percentComplete,
      'memberProgress': memberProgress
          .map((m) => (m as MemberProgressModel).toJson())
          .toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  @override
  GoalProgressModel copyWith({
    String? goalId,
    int? totalSteps,
    int? targetSteps,
    double? percentComplete,
    List<MemberProgress>? memberProgress,
    DateTime? lastUpdated,
  }) {
    return GoalProgressModel(
      goalId: goalId ?? this.goalId,
      totalSteps: totalSteps ?? this.totalSteps,
      targetSteps: targetSteps ?? this.targetSteps,
      percentComplete: percentComplete ?? this.percentComplete,
      memberProgress: memberProgress ?? this.memberProgress,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
