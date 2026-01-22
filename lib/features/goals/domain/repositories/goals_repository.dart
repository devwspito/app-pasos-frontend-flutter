import '../entities/goal.dart';
import '../entities/goal_membership.dart';
import '../entities/goal_progress.dart';

/// Abstract repository interface for goal data operations.
///
/// Defines the contract for fetching and managing goal data.
///
/// All methods throw appropriate exceptions on failure:
/// - [ServerException] for API errors
/// - [NetworkException] for connectivity issues
abstract interface class GoalsRepository {
  /// Fetches all goals for the current user.
  ///
  /// Returns a list of [Goal] entities.
  Future<List<Goal>> getUserGoals();

  /// Fetches a specific goal by ID.
  ///
  /// [goalId] The ID of the goal to fetch.
  ///
  /// Returns the [Goal] entity.
  /// Throws [NotFoundException] if goal doesn't exist.
  Future<Goal> getGoalById(String goalId);

  /// Creates a new goal.
  ///
  /// [name] Name of the goal.
  /// [description] Description of the goal.
  /// [targetSteps] Target number of steps.
  /// [startDate] Start date of the goal period.
  /// [endDate] End date of the goal period.
  /// [type] Type of goal (individual or group).
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
  /// [goalId] The ID of the goal to update.
  /// [name] Optional new name.
  /// [description] Optional new description.
  /// [targetSteps] Optional new target steps.
  /// [endDate] Optional new end date.
  ///
  /// Returns the updated [Goal] entity.
  Future<Goal> updateGoal({
    required String goalId,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? endDate,
  });

  /// Fetches the progress of a specific goal.
  ///
  /// [goalId] The ID of the goal.
  ///
  /// Returns the [GoalProgress] entity with member progress details.
  Future<GoalProgress> getGoalProgress(String goalId);

  /// Invites a user to join a group goal.
  ///
  /// [goalId] The ID of the group goal.
  /// [email] Email of the user to invite.
  ///
  /// Returns the created [GoalMembership] entity.
  Future<GoalMembership> inviteUser({
    required String goalId,
    required String email,
  });

  /// Joins a group goal using an invite code.
  ///
  /// [inviteCode] The invite code for the goal.
  ///
  /// Returns the created [GoalMembership] entity.
  Future<GoalMembership> joinGoal(String inviteCode);

  /// Leaves a group goal.
  ///
  /// [goalId] The ID of the goal to leave.
  Future<void> leaveGoal(String goalId);

  /// Fetches all members of a goal.
  ///
  /// [goalId] The ID of the goal.
  ///
  /// Returns a list of [GoalMembership] entities.
  Future<List<GoalMembership>> getGoalMembers(String goalId);
}
