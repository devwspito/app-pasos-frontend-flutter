import 'package:equatable/equatable.dart';

/// Data layer model for friend statistics.
///
/// This model handles JSON serialization/deserialization for API responses.
/// Contains step statistics and activity information for a friend.
/// Extends [Equatable] for value equality comparison.
///
/// Example JSON:
/// ```json
/// {
///   "friendId": "user-001",
///   "username": "johndoe",
///   "profileImageUrl": "https://example.com/avatar.jpg",
///   "todaySteps": 8500,
///   "weeklyAverage": 7250.5,
///   "lastActive": "2024-01-15T10:30:00Z",
///   "streak": 15
/// }
/// ```
class FriendStatsModel extends Equatable {
  /// Unique identifier for the friend.
  final String friendId;

  /// Friend's display username.
  final String username;

  /// Optional URL to friend's profile image.
  final String? profileImageUrl;

  /// Number of steps the friend has taken today.
  final int todaySteps;

  /// Friend's weekly average step count.
  final double weeklyAverage;

  /// Timestamp of the friend's last activity.
  final DateTime? lastActive;

  /// Number of consecutive days the friend has reached their goal.
  final int streak;

  /// Creates a [FriendStatsModel] instance.
  const FriendStatsModel({
    required this.friendId,
    required this.username,
    this.profileImageUrl,
    required this.todaySteps,
    required this.weeklyAverage,
    this.lastActive,
    required this.streak,
  });

  /// Creates a [FriendStatsModel] from a JSON map.
  ///
  /// Handles null safety for all fields with appropriate defaults.
  /// Parses [lastActive] from ISO 8601 string format.
  factory FriendStatsModel.fromJson(Map<String, dynamic> json) {
    return FriendStatsModel(
      friendId: json['friendId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      todaySteps: (json['todaySteps'] as num?)?.toInt() ?? 0,
      weeklyAverage: (json['weeklyAverage'] as num?)?.toDouble() ?? 0.0,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'] as String)
          : null,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// Serializes [lastActive] to ISO 8601 string format if present.
  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'username': username,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'todaySteps': todaySteps,
      'weeklyAverage': weeklyAverage,
      if (lastActive != null) 'lastActive': lastActive!.toIso8601String(),
      'streak': streak,
    };
  }

  /// Creates a copy of this model with optional field overrides.
  FriendStatsModel copyWith({
    String? friendId,
    String? username,
    String? profileImageUrl,
    int? todaySteps,
    double? weeklyAverage,
    DateTime? lastActive,
    int? streak,
  }) {
    return FriendStatsModel(
      friendId: friendId ?? this.friendId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      todaySteps: todaySteps ?? this.todaySteps,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      lastActive: lastActive ?? this.lastActive,
      streak: streak ?? this.streak,
    );
  }

  /// Checks if the friend is currently active (within last 5 minutes).
  bool get isOnline {
    if (lastActive == null) return false;
    final difference = DateTime.now().difference(lastActive!);
    return difference.inMinutes < 5;
  }

  /// Checks if the friend has any activity today.
  bool get hasActivityToday => todaySteps > 0;

  /// Checks if the friend has an active streak.
  bool get hasStreak => streak > 0;

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
    return 'FriendStatsModel(friendId: $friendId, username: $username, '
        'profileImageUrl: $profileImageUrl, todaySteps: $todaySteps, '
        'weeklyAverage: $weeklyAverage, lastActive: $lastActive, '
        'streak: $streak)';
  }
}
