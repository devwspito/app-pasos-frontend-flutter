/// Member contribution entity for the goals domain.
///
/// This is a pure domain entity representing a member's contribution
/// to a group goal. It's independent of any data layer implementation.
library;

import 'package:equatable/equatable.dart';

/// Represents a member's contribution to a group goal.
///
/// Member contribution tracks individual user's step contributions
/// to a group goal, including their total steps, percentage of the
/// group's total, and their rank among members.
///
/// Example usage:
/// ```dart
/// final contribution = MemberContribution(
///   id: '123',
///   goalId: 'goal456',
///   userId: 'user789',
///   userName: 'John Doe',
///   totalSteps: 15000,
///   contributionPercentage: 20.0,
///   rank: 2,
/// );
/// ```
class MemberContribution extends Equatable {
  /// Creates a [MemberContribution] instance.
  ///
  /// [id] - The unique identifier for the contribution record.
  /// [goalId] - The ID of the goal.
  /// [userId] - The ID of the contributing user.
  /// [userName] - The display name of the user.
  /// [totalSteps] - The total steps contributed by this user.
  /// [contributionPercentage] - The percentage of total goal progress.
  /// [rank] - The user's rank among all contributors (1 = highest).
  const MemberContribution({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.userName,
    required this.totalSteps,
    required this.contributionPercentage,
    required this.rank,
  });

  /// Creates an empty contribution for use in initial states.
  ///
  /// Useful for initializing state before contribution data is loaded.
  factory MemberContribution.empty() => const MemberContribution(
        id: '',
        goalId: '',
        userId: '',
        userName: '',
        totalSteps: 0,
        contributionPercentage: 0,
        rank: 0,
      );

  /// The unique identifier for the contribution record.
  final String id;

  /// The ID of the goal this contribution belongs to.
  final String goalId;

  /// The ID of the contributing user.
  final String userId;

  /// The display name of the contributing user.
  final String userName;

  /// The total steps contributed by this user.
  final int totalSteps;

  /// The percentage of total goal progress from this user (0-100).
  final double contributionPercentage;

  /// The user's rank among all contributors.
  ///
  /// 1 = highest contributor, higher numbers = lower rank.
  /// 0 indicates no rank (empty contribution).
  final int rank;

  /// Whether this is an empty/uninitialized contribution.
  bool get isEmpty => id.isEmpty;

  /// Whether this is a valid contribution with data.
  bool get isNotEmpty => !isEmpty;

  /// Whether this user is the top contributor.
  bool get isTopContributor => rank == 1;

  /// Whether this user has contributed any steps.
  bool get hasContributed => totalSteps > 0;

  /// Whether this user is in the top 3 contributors.
  bool get isTopThree => rank > 0 && rank <= 3;

  /// The contribution as a ratio (0.0 to 1.0).
  double get contributionRatio => contributionPercentage / 100.0;

  @override
  List<Object?> get props => [
        id,
        goalId,
        userId,
        userName,
        totalSteps,
        contributionPercentage,
        rank,
      ];

  @override
  String toString() {
    return 'MemberContribution(id: $id, goalId: $goalId, userId: $userId, '
        'userName: $userName, totalSteps: $totalSteps, '
        'contributionPercentage: $contributionPercentage, rank: $rank)';
  }
}
