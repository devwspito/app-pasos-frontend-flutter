/// Statistics of a friend's step activity that has been shared.
///
/// This entity contains the step data that a user has shared
/// with you through a sharing relationship.
///
/// Example:
/// ```dart
/// final stats = SharedUserStats(
///   friendId: 'user-456',
///   friendName: 'John Doe',
///   todaySteps: 8500,
///   goalSteps: 10000,
///   weeklyAverage: 7200,
///   lastUpdated: DateTime.now(),
/// );
/// print('${stats.friendName} has taken ${stats.todaySteps} steps today');
/// ```
final class SharedUserStats {
  const SharedUserStats({
    required this.friendId,
    required this.friendName,
    required this.todaySteps,
    required this.goalSteps,
    required this.weeklyAverage,
    required this.lastUpdated,
  });

  /// The ID of the friend these stats belong to.
  final String friendId;

  /// Display name of the friend.
  final String friendName;

  /// Number of steps the friend has taken today.
  final int todaySteps;

  /// Friend's daily step goal.
  final int goalSteps;

  /// Friend's average daily steps over the past week.
  final int weeklyAverage;

  /// When this data was last updated from the server.
  final DateTime lastUpdated;

  /// Progress percentage toward daily goal (0-100+).
  double get percentComplete => goalSteps > 0
      ? (todaySteps / goalSteps) * 100
      : 0;

  /// Whether the friend has reached their daily goal.
  bool get goalReached => todaySteps >= goalSteps;
}
