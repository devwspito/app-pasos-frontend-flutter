import '../entities/goal.dart';
import '../entities/goal_progress.dart';

/// Abstract repository interface for goal data operations.
///
/// Defines the contract for managing goals, including creation,
/// retrieval, member management, and progress tracking.
///
/// All methods throw appropriate exceptions on failure:
/// - [ServerException] for API errors
/// - [NetworkException] for connectivity issues
/// - [CacheException] for local storage errors
abstract interface class GoalsRepository {
  /// Fetches all goals for the current user.
  ///
  /// Returns goals where the user is either the owner or a member.
  /// Implements offline-first strategy:
  /// 1. Attempts to fetch from remote server
  /// 2. On success, caches locally and returns data
  /// 3. On network failure, returns cached data if available
  ///
  /// Returns list of [Goal] entities.
  Future<List<Goal>> getUserGoals();

  /// Fetches a specific goal by its ID.
  ///
  /// [id] The unique identifier of the goal.
  ///
  /// Returns the [Goal] if found, null otherwise.
  Future<Goal?> getGoalById(String id);

  /// Creates a new goal.
  ///
  /// [name] The name of the goal.
  /// [description] A description of the goal.
  /// [targetSteps] The target number of steps to achieve.
  /// [startDate] When the goal period begins.
  /// [endDate] When the goal period ends.
  /// [isPublic] Whether the goal is publicly visible.
  ///
  /// Returns the created [Goal] with server-assigned ID.
  /// Note: Requires network connectivity.
  Future<Goal> createGoal({
    required String name,
    required String description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
    required bool isPublic,
  });

  /// Fetches the progress for a specific goal.
  ///
  /// [goalId] The unique identifier of the goal.
  ///
  /// Returns [GoalProgress] containing total steps, target,
  /// and individual member contributions.
  Future<GoalProgress> getGoalProgress(String goalId);

  /// Invites a user to join a goal via email.
  ///
  /// [goalId] The goal to invite the user to.
  /// [email] The email address of the user to invite.
  ///
  /// Sends an invitation email to the specified address.
  /// Note: Requires network connectivity and owner/admin permissions.
  Future<void> inviteUser(String goalId, String email);

  /// Joins a goal using an invitation code.
  ///
  /// [inviteCode] The invitation code received via email or link.
  ///
  /// Returns the joined [Goal] entity.
  /// Note: Requires network connectivity.
  Future<Goal> joinGoal(String inviteCode);
}
