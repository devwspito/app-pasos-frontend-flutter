/// Friend stats entity for the sharing domain.
///
/// This is a pure domain entity representing step statistics for a friend.
/// It's independent of any data layer implementation details.
library;

import 'package:equatable/equatable.dart';

/// Represents step statistics for a specific friend.
///
/// This entity contains aggregated step data for a friend across
/// different time periods, used for comparison and social features.
///
/// Example usage:
/// ```dart
/// final friendStats = FriendStats(
///   userId: '123',
///   todaySteps: 5000,
///   weekSteps: 35000,
///   monthSteps: 150000,
///   allTimeSteps: 1500000,
/// );
/// ```
class FriendStats extends Equatable {
  /// Creates a [FriendStats] instance.
  ///
  /// [userId] - The unique identifier for the friend.
  /// [todaySteps] - Total steps recorded today.
  /// [weekSteps] - Total steps recorded this week.
  /// [monthSteps] - Total steps recorded this month.
  /// [allTimeSteps] - Total steps recorded all time.
  const FriendStats({
    required this.userId,
    required this.todaySteps,
    required this.weekSteps,
    required this.monthSteps,
    required this.allTimeSteps,
  });

  /// Creates empty friend stats for use in initial states.
  ///
  /// Useful for initializing state before stats data is loaded.
  factory FriendStats.empty() => const FriendStats(
        userId: '',
        todaySteps: 0,
        weekSteps: 0,
        monthSteps: 0,
        allTimeSteps: 0,
      );

  /// The unique identifier for the friend.
  final String userId;

  /// Total steps recorded today.
  final int todaySteps;

  /// Total steps recorded this week (last 7 days).
  final int weekSteps;

  /// Total steps recorded this month.
  final int monthSteps;

  /// Total steps recorded all time.
  final int allTimeSteps;

  /// Whether this stats object has no recorded steps.
  bool get isEmpty =>
      userId.isEmpty ||
      (todaySteps == 0 &&
          weekSteps == 0 &&
          monthSteps == 0 &&
          allTimeSteps == 0);

  /// Whether this stats object has some recorded steps.
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [
        userId,
        todaySteps,
        weekSteps,
        monthSteps,
        allTimeSteps,
      ];

  @override
  String toString() {
    return 'FriendStats(userId: $userId, todaySteps: $todaySteps, '
        'weekSteps: $weekSteps, monthSteps: $monthSteps, '
        'allTimeSteps: $allTimeSteps)';
  }
}
