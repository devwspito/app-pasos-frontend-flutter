import '../../domain/entities/shared_user_stats.dart';

/// Data model for SharedUserStats with JSON serialization
final class SharedUserStatsModel extends SharedUserStats {
  const SharedUserStatsModel({
    required super.friendId,
    required super.friendName,
    super.friendAvatarUrl,
    required super.todaySteps,
    required super.goalSteps,
    required super.percentComplete,
    required super.weeklyAverage,
    required super.lastUpdated,
  });

  /// Creates a SharedUserStatsModel from a JSON map
  factory SharedUserStatsModel.fromJson(Map<String, dynamic> json) {
    return SharedUserStatsModel(
      friendId: json['friendId'] as String,
      friendName: json['friendName'] as String,
      friendAvatarUrl: json['friendAvatarUrl'] as String?,
      todaySteps: json['todaySteps'] as int,
      goalSteps: json['goalSteps'] as int,
      percentComplete: (json['percentComplete'] as num).toDouble(),
      weeklyAverage: json['weeklyAverage'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// Creates a SharedUserStatsModel from a SharedUserStats entity
  factory SharedUserStatsModel.fromEntity(SharedUserStats entity) {
    return SharedUserStatsModel(
      friendId: entity.friendId,
      friendName: entity.friendName,
      friendAvatarUrl: entity.friendAvatarUrl,
      todaySteps: entity.todaySteps,
      goalSteps: entity.goalSteps,
      percentComplete: entity.percentComplete,
      weeklyAverage: entity.weeklyAverage,
      lastUpdated: entity.lastUpdated,
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'friendName': friendName,
      'friendAvatarUrl': friendAvatarUrl,
      'todaySteps': todaySteps,
      'goalSteps': goalSteps,
      'percentComplete': percentComplete,
      'weeklyAverage': weeklyAverage,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  @override
  SharedUserStatsModel copyWith({
    String? friendId,
    String? friendName,
    String? friendAvatarUrl,
    int? todaySteps,
    int? goalSteps,
    double? percentComplete,
    int? weeklyAverage,
    DateTime? lastUpdated,
  }) {
    return SharedUserStatsModel(
      friendId: friendId ?? this.friendId,
      friendName: friendName ?? this.friendName,
      friendAvatarUrl: friendAvatarUrl ?? this.friendAvatarUrl,
      todaySteps: todaySteps ?? this.todaySteps,
      goalSteps: goalSteps ?? this.goalSteps,
      percentComplete: percentComplete ?? this.percentComplete,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
