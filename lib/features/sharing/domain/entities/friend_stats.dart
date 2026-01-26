import 'package:equatable/equatable.dart';

/// Domain entity representing a friend's step statistics.
///
/// This is an immutable entity that contains business logic methods
/// for displaying friend statistics in the sharing feature. Unlike data models,
/// entities do NOT contain JSON serialization logic.
///
/// Example usage:
/// ```dart
/// final friendStats = FriendStats(
///   friendId: 'user-123',
///   username: 'john_doe',
///   profileImageUrl: 'https://example.com/avatar.png',
///   todaySteps: 7500,
///   weeklyAverage: 8200.0,
///   lastActive: DateTime.now(),
///   streak: 5,
/// );
///
/// print(friendStats.isActiveToday); // true
/// print(friendStats.hasStreak); // true
/// print(friendStats.initials); // 'JO'
/// print(friendStats.percentOfGoal(10000)); // 0.75
/// ```
class FriendStats extends Equatable {
  /// Unique identifier of the friend.
  final String friendId;

  /// Username of the friend.
  final String username;

  /// Profile image URL of the friend. May be null if not set.
  final String? profileImageUrl;

  /// Number of steps the friend has taken today.
  final int todaySteps;

  /// Average steps per day over the past week.
  final double weeklyAverage;

  /// Timestamp of the friend's last activity.
  final DateTime lastActive;

  /// Current streak of consecutive days meeting the goal.
  final int streak;

  /// Creates a [FriendStats] instance.
  ///
  /// All fields are required except [profileImageUrl] which can be null.
  const FriendStats({
    required this.friendId,
    required this.username,
    this.profileImageUrl,
    required this.todaySteps,
    required this.weeklyAverage,
    required this.lastActive,
    required this.streak,
  });

  /// Factory constructor for creating empty/placeholder stats.
  ///
  /// Useful when no friend data is available yet or as a loading placeholder.
  ///
  /// Example:
  /// ```dart
  /// final placeholder = FriendStats.empty();
  /// print(placeholder.username); // ''
  /// print(placeholder.todaySteps); // 0
  /// ```
  factory FriendStats.empty() {
    return FriendStats(
      friendId: '',
      username: '',
      profileImageUrl: null,
      todaySteps: 0,
      weeklyAverage: 0.0,
      lastActive: DateTime.fromMillisecondsSinceEpoch(0),
      streak: 0,
    );
  }

  /// Returns true if the friend's last activity was today.
  ///
  /// Compares only the year, month, and day components, ignoring time.
  bool get isActiveToday {
    final now = DateTime.now();
    return _isSameDay(lastActive, now);
  }

  /// Returns true if the friend has an active streak.
  bool get hasStreak => streak > 0;

  /// Returns the first 2 letters of the username as initials.
  ///
  /// Returns uppercase initials. If the username is empty, returns an empty string.
  /// If the username has only 1 character, returns that character uppercase.
  ///
  /// Example:
  /// ```dart
  /// FriendStats(username: 'john_doe', ...).initials; // 'JO'
  /// FriendStats(username: 'a', ...).initials; // 'A'
  /// FriendStats(username: '', ...).initials; // ''
  /// ```
  String get initials {
    if (username.isEmpty) return '';
    if (username.length == 1) return username.toUpperCase();
    return username.substring(0, 2).toUpperCase();
  }

  /// Calculates the percentage of a given goal achieved by today's steps.
  ///
  /// Returns a value between 0.0 and 1.0 (clamped).
  /// A value of 1.0 means the goal has been reached or exceeded.
  ///
  /// Example:
  /// ```dart
  /// final friend = FriendStats(todaySteps: 7500, ...);
  /// print(friend.percentOfGoal(10000)); // 0.75
  /// print(friend.percentOfGoal(5000)); // 1.0 (clamped)
  /// print(friend.percentOfGoal(0)); // 0.0 (handles zero goal)
  /// ```
  double percentOfGoal(int goal) {
    if (goal <= 0) return 0.0;
    return (todaySteps / goal).clamp(0.0, 1.0);
  }

  /// Creates a copy of this friend stats with optional field overrides.
  FriendStats copyWith({
    String? friendId,
    String? username,
    String? profileImageUrl,
    int? todaySteps,
    double? weeklyAverage,
    DateTime? lastActive,
    int? streak,
  }) {
    return FriendStats(
      friendId: friendId ?? this.friendId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      todaySteps: todaySteps ?? this.todaySteps,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      lastActive: lastActive ?? this.lastActive,
      streak: streak ?? this.streak,
    );
  }

  /// Helper method to check if two dates are the same day.
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  List<Object?> get props => [
        friendId,
        username,
        profileImageUrl,
        todaySteps,
        weeklyAverage,
        lastActive,
        streak,
      ];

  @override
  String toString() {
    return 'FriendStats(friendId: $friendId, username: $username, '
        'profileImageUrl: $profileImageUrl, todaySteps: $todaySteps, '
        'weeklyAverage: $weeklyAverage, lastActive: $lastActive, '
        'streak: $streak)';
  }
}
