import 'package:equatable/equatable.dart';

/// Domain entity representing a user's progress in a goal.
///
/// This is an immutable entity that contains business logic methods
/// for tracking and displaying goal progress. Unlike data models, entities
/// do NOT contain JSON serialization logic.
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
///   daysCompleted: 8,
///   currentStreak: 5,
///   lastUpdated: DateTime.now(),
/// );
///
/// print(progress.progressPercentage(10000)); // 0.75 (75% of daily target)
/// print(progress.isOnTrack(10000)); // false (dailyAverage < target)
/// print(progress.initials); // 'JO'
/// ```
class GoalProgress extends Equatable {
  /// Unique identifier for this progress record.
  final String id;

  /// ID of the goal this progress belongs to.
  final String goalId;

  /// ID of the user whose progress this represents.
  final String userId;

  /// Username of the user.
  final String username;

  /// Profile image URL of the user. May be null if not set.
  final String? profileImageUrl;

  /// Total number of steps taken by this user for this goal.
  final int totalSteps;

  /// Average steps per day for this user in this goal.
  final double dailyAverage;

  /// Number of days the user completed the target steps.
  final int daysCompleted;

  /// Current streak of consecutive days meeting the goal.
  final int currentStreak;

  /// Timestamp of when this progress was last updated.
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

  /// Calculates the progress percentage based on the daily average vs target.
  ///
  /// Returns a value between 0.0 and 1.0 (clamped).
  double progressPercentage(int targetSteps) {
    if (targetSteps <= 0) return 0.0;
    return (dailyAverage / targetSteps).clamp(0.0, 1.0);
  }

  /// Returns true if the user's daily average meets or exceeds the target.
  bool isOnTrack(int targetSteps) {
    if (targetSteps <= 0) return true;
    return dailyAverage >= targetSteps;
  }

  /// Returns the first 2 letters of the username as initials.
  String get initials {
    if (username.isEmpty) return '';
    if (username.length == 1) return username.toUpperCase();
    return username.substring(0, 2).toUpperCase();
  }

  /// Returns true if the user has an active streak.
  bool get hasStreak => currentStreak > 0;

  /// Returns true if this progress record was updated today.
  bool get isUpdatedToday {
    final now = DateTime.now();
    return _isSameDay(lastUpdated, now);
  }

  /// Helper method to check if two dates are the same day.
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
