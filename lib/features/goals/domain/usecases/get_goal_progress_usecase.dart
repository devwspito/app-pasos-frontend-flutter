/// Use case for retrieving progress data for all members of a goal.
///
/// This use case follows the single responsibility principle - it has only
/// one method [call] that fetches member progress from the repository.
///
/// Example usage:
/// ```dart
/// final useCase = GetGoalProgressUseCase(goalsRepository);
/// final progressList = await useCase('goal-123');
/// for (final progress in progressList) {
///   print('${progress.username}: ${progress.totalSteps} total steps');
/// }
/// ```
library;

// =============================================================================
// TEMPORARY INLINE DEFINITIONS
// TODO: Replace with imports when entity/repository files are created by their
// respective epic stories:
// - lib/features/goals/domain/entities/goal_progress.dart
// - lib/features/goals/domain/repositories/goals_repository.dart
// =============================================================================

/// Entity representing a member's progress towards a goal.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/entities/goal_progress.dart
class GoalProgress {
  /// Unique identifier for the goal this progress belongs to.
  final String goalId;

  /// Unique identifier for the user.
  final String userId;

  /// Username of the member.
  final String username;

  /// Profile image URL of the member.
  final String? profileImageUrl;

  /// Total steps accumulated during the goal period.
  final int totalSteps;

  /// Daily average steps.
  final double dailyAverage;

  /// Number of days the member has hit the target.
  final int daysCompleted;

  /// Current streak of consecutive days meeting the goal.
  final int currentStreak;

  /// Best streak achieved during the goal.
  final int bestStreak;

  /// When this progress was last updated.
  final DateTime lastUpdated;

  /// Creates a new GoalProgress instance.
  const GoalProgress({
    required this.goalId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.totalSteps,
    required this.dailyAverage,
    required this.daysCompleted,
    required this.currentStreak,
    required this.bestStreak,
    required this.lastUpdated,
  });

  /// Creates a GoalProgress from a JSON map.
  factory GoalProgress.fromJson(Map<String, dynamic> json) {
    return GoalProgress(
      goalId: json['goalId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profileImageUrl: json['profileImageUrl']?.toString(),
      totalSteps: int.tryParse(json['totalSteps']?.toString() ?? '0') ?? 0,
      dailyAverage: double.tryParse(json['dailyAverage']?.toString() ?? '0') ?? 0.0,
      daysCompleted: int.tryParse(json['daysCompleted']?.toString() ?? '0') ?? 0,
      currentStreak: int.tryParse(json['currentStreak']?.toString() ?? '0') ?? 0,
      bestStreak: int.tryParse(json['bestStreak']?.toString() ?? '0') ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'].toString())
          : DateTime.now(),
    );
  }

  /// Converts this GoalProgress to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'userId': userId,
      'username': username,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'totalSteps': totalSteps,
      'dailyAverage': dailyAverage,
      'daysCompleted': daysCompleted,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalProgress &&
          runtimeType == other.runtimeType &&
          goalId == other.goalId &&
          userId == other.userId;

  @override
  int get hashCode => Object.hash(goalId, userId);

  @override
  String toString() =>
      'GoalProgress(userId: $userId, username: $username, totalSteps: $totalSteps)';
}

/// Abstract interface for GoalsRepository (partial - only what this use case needs).
///
/// TODO: Will be replaced with import from lib/features/goals/domain/repositories/goals_repository.dart
abstract class GoalsRepository {
  /// Gets progress for all members of a goal.
  Future<List<GoalProgress>> getGoalProgress(String goalId);
}

// =============================================================================
// USE CASE IMPLEMENTATION
// =============================================================================

/// Use case for retrieving progress data for all members of a goal.
///
/// Follows the single responsibility principle with a single [call] method.
/// Inject [GoalsRepository] via constructor for dependency injection.
///
/// Returns a list of [GoalProgress] entities with member progress data.
///
/// Example:
/// ```dart
/// final useCase = GetGoalProgressUseCase(repository);
/// final progressList = await useCase('goal-123');
///
/// // Display leaderboard
/// for (final progress in progressList) {
///   print('${progress.username}: ${progress.totalSteps} total steps');
///   print('  Daily average: ${progress.dailyAverage.toStringAsFixed(0)}');
///   print('  Current streak: ${progress.currentStreak} days');
/// }
/// ```
class GetGoalProgressUseCase {
  /// The repository used to fetch goal progress data.
  final GoalsRepository _repository;

  /// Creates a new [GetGoalProgressUseCase] with the given repository.
  ///
  /// [repository] - The goals repository implementation to use.
  GetGoalProgressUseCase(this._repository);

  /// Fetches progress data for all members of the specified goal.
  ///
  /// [goalId] - The unique identifier of the goal.
  ///
  /// Returns a [Future] that completes with a list of [GoalProgress] entities.
  /// The list may be empty if no progress has been recorded.
  ///
  /// Throws an [Exception] if:
  /// - The network request fails
  /// - The goal is not found
  /// - The user doesn't have access to the goal
  Future<List<GoalProgress>> call(String goalId) =>
      _repository.getGoalProgress(goalId);
}
