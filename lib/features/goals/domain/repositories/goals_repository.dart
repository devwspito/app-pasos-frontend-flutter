import '../entities/goal.dart';
import '../entities/goal_progress.dart';

/// Abstract repository interface for goal data operations.
///
/// Defines the contract for fetching and managing goal data.
/// The implementation should handle API communication and
/// potential caching strategies.
///
/// All methods throw appropriate exceptions on failure:
/// - [ServerException] for API errors
/// - [NetworkException] for connectivity issues
abstract interface class GoalsRepository {
  /// Fetches all goals for the current user.
  ///
  /// Returns a list of [Goal] entities the user participates in,
  /// including both individual and group goals.
  Future<List<Goal>> getUserGoals();

  /// Fetches detailed information for a specific goal.
  ///
  /// [goalId] The unique identifier of the goal.
  ///
  /// Returns the [Goal] entity with full details.
  /// Throws if goal not found or user lacks access.
  Future<Goal> getGoalById(String goalId);

  /// Fetches progress details for a specific goal.
  ///
  /// [goalId] The unique identifier of the goal.
  ///
  /// Returns [GoalProgress] with detailed progress data
  /// including member contributions for group goals.
  Future<GoalProgress> getGoalProgress(String goalId);

  /// Creates a new goal.
  ///
  /// [name] Display name for the goal.
  /// [description] Detailed description.
  /// [targetSteps] Target number of steps.
  /// [startDate] When the goal period begins.
  /// [endDate] When the goal period ends.
  /// [type] Whether individual or group goal.
  ///
  /// Returns the created [Goal] entity.
  Future<Goal> createGoal({
    required String name,
    required String description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
    required GoalType type,
  });

  /// Updates an existing goal.
  ///
  /// [goalId] The goal to update.
  /// [name] Optional new name.
  /// [description] Optional new description.
  /// [targetSteps] Optional new target.
  /// [endDate] Optional new end date.
  ///
  /// Returns the updated [Goal] entity.
  /// Only the goal creator can update goals.
  Future<Goal> updateGoal({
    required String goalId,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? endDate,
  });

  /// Invites a user to join a group goal.
  ///
  /// [goalId] The goal to invite to.
  /// [email] Email address of the user to invite.
  ///
  /// Returns true if invitation was sent successfully.
  /// Only works for group goals.
  Future<bool> inviteUser({
    required String goalId,
    required String email,
  });

  /// Joins a group goal using an invite code.
  ///
  /// [inviteCode] The invitation code for the goal.
  ///
  /// Returns the [Goal] that was joined.
  /// Throws if code is invalid or expired.
  Future<Goal> joinGoal(String inviteCode);

  /// Leaves a group goal.
  ///
  /// [goalId] The goal to leave.
  ///
  /// Returns true if successfully left.
  /// Cannot leave if you're the only member.
  Future<bool> leaveGoal(String goalId);
}
