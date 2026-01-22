import '../../domain/entities/goal_progress.dart';

/// Data model for MemberProgress entity.
class MemberProgressModel extends MemberProgress {
  const MemberProgressModel({
    required super.userId,
    required super.userName,
    required super.steps,
    required super.contributionPercent,
  });

  /// Creates a [MemberProgressModel] from JSON map.
  factory MemberProgressModel.fromJson(Map<String, dynamic> json) {
    return MemberProgressModel(
      userId: json['userId'] as String? ?? json['_id'] as String? ?? '',
      userName: json['userName'] as String? ?? json['name'] as String? ?? '',
      steps: json['steps'] as int? ?? 0,
      contributionPercent: (json['contributionPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'steps': steps,
      'contributionPercent': contributionPercent,
    };
  }
}

/// Data model for GoalProgress entity.
///
/// Handles JSON serialization/deserialization for API communication.
class GoalProgressModel extends GoalProgress {
  const GoalProgressModel({
    required super.goalId,
    required super.totalSteps,
    required super.targetSteps,
    required super.progressPercent,
    required super.isCompleted,
    required super.daysRemaining,
    super.memberProgress,
    super.dailyAverage,
    super.projectedCompletion,
  });

  /// Creates a [GoalProgressModel] from JSON map.
  factory GoalProgressModel.fromJson(Map<String, dynamic> json) {
    final memberProgressList = (json['memberProgress'] as List<dynamic>?)
            ?.map((e) => MemberProgressModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return GoalProgressModel(
      goalId: json['goalId'] as String? ?? json['_id'] as String? ?? '',
      totalSteps: json['totalSteps'] as int? ?? 0,
      targetSteps: json['targetSteps'] as int? ?? 0,
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      daysRemaining: json['daysRemaining'] as int? ?? 0,
      memberProgress: memberProgressList,
      dailyAverage: json['dailyAverage'] as int? ?? 0,
      projectedCompletion: _parseDate(json['projectedCompletion']),
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'totalSteps': totalSteps,
      'targetSteps': targetSteps,
      'progressPercent': progressPercent,
      'isCompleted': isCompleted,
      'daysRemaining': daysRemaining,
      'memberProgress': memberProgress
          .map((e) => e is MemberProgressModel
              ? e.toJson()
              : MemberProgressModel(
                  userId: e.userId,
                  userName: e.userName,
                  steps: e.steps,
                  contributionPercent: e.contributionPercent,
                ).toJson())
          .toList(),
      'dailyAverage': dailyAverage,
      if (projectedCompletion != null)
        'projectedCompletion': projectedCompletion!.toIso8601String(),
    };
  }

  /// Converts a [GoalProgress] entity to a [GoalProgressModel].
  factory GoalProgressModel.fromEntity(GoalProgress progress) {
    return GoalProgressModel(
      goalId: progress.goalId,
      totalSteps: progress.totalSteps,
      targetSteps: progress.targetSteps,
      progressPercent: progress.progressPercent,
      isCompleted: progress.isCompleted,
      daysRemaining: progress.daysRemaining,
      memberProgress: progress.memberProgress,
      dailyAverage: progress.dailyAverage,
      projectedCompletion: progress.projectedCompletion,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
