import 'package:equatable/equatable.dart';

/// Domain entity representing a user's progress towards a goal.
///
/// This is an immutable entity that contains business logic methods
/// for tracking goal progress. Unlike data models, entities do NOT
/// contain JSON serialization logic.
///
/// TODO: This is a stub entity file. Full implementation will be added
/// by a future story that creates the complete Goals domain layer.
///
/// Example usage:
/// ```dart
/// final progress = GoalProgress(
///   id: 'prog-123',
///   goalId: 'goal-456',
///   userId: 'user-789',
///   username: 'john_doe',
///   profileImageUrl: 'https://example.com/avatar.png',
///   totalSteps: 75000,
///   dailyAverage: 7500.0,
///   daysCompleted: 10,
///   currentStreak: 5,
///   lastUpdated: DateTime.now(),
/// );
///
/// print(progress.hasStreak); // true
/// print(progress.percentOfTarget(100000)); // 0.75
/// ```
class GoalProgress extends Equatable {
  /// Unique identifier for the progress record.
  final String id;

  /// ID of the goal this progress belongs to.
  final String goalId;

  /// ID of the user whose progress this represents.
  final String userId;

  /// Username of the user.
  final String username;

  /// Profile image URL of the user. May be null if not set.
  final String? profileImageUrl;

  /// Total steps accumulated towards this goal.
  final int totalSteps;

  /// Average steps per day during the goal period.
  final double dailyAverage;

  /// Number of days the user completed their target.
  final int daysCompleted;

  /// Current streak of consecutive days meeting the target.
  final int currentStreak;

  /// Timestamp when this progress was last updated.
  final DateTime lastUpdated;

  /// Creates a [GoalProgress] instance.
  ///
  /// All fields are required except [profileImageUrl] which can be null.
  const GoalProgress({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.totalSteps,
    required this.dailyAverage,
    required this.daysCompleted,
    required this.currentStreak,
    required this.lastUpdated,
  });

  /// Factory constructor for creating empty/placeholder progress.
  ///
  /// Useful when no progress data is available yet or as a loading placeholder.
  factory GoalProgress.empty() {
    return GoalProgress(
      id: '',
      goalId: '',
      userId: '',
      username: '',
      profileImageUrl: null,
      totalSteps: 0,
      dailyAverage: 0.0,
      daysCompleted: 0,
      currentStreak: 0,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Returns true if the user has an active streak.
  bool get hasStreak => currentStreak > 0;

  /// Returns true if any steps have been recorded.
  bool get hasProgress => totalSteps > 0;

  /// Returns the first 2 letters of the username as initials.
  ///
  /// Returns uppercase initials. If the username is empty, returns an empty string.
  /// If the username has only 1 character, returns that character uppercase.
  String get initials {
    if (username.isEmpty) return '';
    if (username.length == 1) return username.toUpperCase();
    return username.substring(0, 2).toUpperCase();
  }

  /// Calculates the percentage of the target achieved by total steps.
  ///
  /// Returns a value between 0.0 and 1.0 (clamped).
  /// A value of 1.0 means the target has been reached or exceeded.
  double percentOfTarget(int targetSteps) {
    if (targetSteps <= 0) return 0.0;
    return (totalSteps / targetSteps).clamp(0.0, 1.0);
  }

  /// Returns true if the progress was updated today.
  bool get isUpdatedToday {
    final now = DateTime.now();
    return lastUpdated.year == now.year &&
        lastUpdated.month == now.month &&
        lastUpdated.day == now.day;
  }

  /// Creates a copy of this progress with optional field overrides.
  GoalProgress copyWith({
    String? id,
    String? goalId,
    String? userId,
    String? username,
    String? profileImageUrl,
    int? totalSteps,
    double? dailyAverage,
    int? daysCompleted,
    int? currentStreak,
    DateTime? lastUpdated,
  }) {
    return GoalProgress(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      totalSteps: totalSteps ?? this.totalSteps,
      dailyAverage: dailyAverage ?? this.dailyAverage,
      daysCompleted: daysCompleted ?? this.daysCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        id,
        goalId,
        userId,
        username,
        profileImageUrl,
        totalSteps,
        dailyAverage,
        daysCompleted,
        currentStreak,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'GoalProgress(id: $id, goalId: $goalId, userId: $userId, '
        'username: $username, profileImageUrl: $profileImageUrl, '
        'totalSteps: $totalSteps, dailyAverage: $dailyAverage, '
        'daysCompleted: $daysCompleted, currentStreak: $currentStreak, '
        'lastUpdated: $lastUpdated)';
  }
}
