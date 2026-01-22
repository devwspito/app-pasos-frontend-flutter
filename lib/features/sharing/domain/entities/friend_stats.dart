import 'package:equatable/equatable.dart';

/// Entity representing a friend's step statistics.
///
/// This contains the shared step data from a friend that
/// has accepted a sharing relationship.
final class FriendStats extends Equatable {
  const FriendStats({
    required this.userId,
    required this.username,
    required this.todaySteps,
    required this.goalSteps,
    required this.weeklyAverage,
    required this.lastUpdated,
    this.avatarUrl,
  });

  /// The friend's user ID.
  final String userId;

  /// The friend's username.
  final String username;

  /// Friend's step count for today.
  final int todaySteps;

  /// Friend's daily step goal.
  final int goalSteps;

  /// Friend's average steps over the past week.
  final double weeklyAverage;

  /// When the friend's data was last synced.
  final DateTime lastUpdated;

  /// Optional URL to the friend's avatar image.
  final String? avatarUrl;

  /// Progress percentage towards daily goal.
  double get progressPercent =>
      goalSteps > 0 ? (todaySteps / goalSteps * 100).clamp(0, 200) : 0;

  /// Returns true if friend has achieved their daily goal.
  bool get isGoalAchieved => todaySteps >= goalSteps;

  /// Creates a copy of this FriendStats with the given fields replaced.
  FriendStats copyWith({
    String? userId,
    String? username,
    int? todaySteps,
    int? goalSteps,
    double? weeklyAverage,
    DateTime? lastUpdated,
    String? avatarUrl,
  }) {
    return FriendStats(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      todaySteps: todaySteps ?? this.todaySteps,
      goalSteps: goalSteps ?? this.goalSteps,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        username,
        todaySteps,
        goalSteps,
        weeklyAverage,
        lastUpdated,
        avatarUrl,
      ];

  @override
  String toString() =>
      'FriendStats(user: $username, steps: $todaySteps/$goalSteps)';
}
