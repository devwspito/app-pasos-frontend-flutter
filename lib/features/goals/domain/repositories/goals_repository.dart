import '../entities/goal.dart';
import '../entities/goal_membership.dart';
import '../entities/goal_progress.dart';

/// Abstract interface for goals repository operations.
///
/// Defines the contract for goal management, membership, and progress tracking
/// operations. This interface lives in the domain layer and should be
/// implemented by a concrete class in the data layer.
///
/// The repository acts as a bridge between the domain layer (which works with entities)
/// and the data layer (which works with models and data sources). Implementations
/// handle the conversion between models and entities.
///
/// Example usage:
/// ```dart
/// final repository = GoalsRepositoryImpl();
/// final goals = await repository.getUserGoals();
/// final newGoal = await repository.createGoal(
///   name: 'Daily Steps Challenge',
///   targetSteps: 10000,
///   startDate: DateTime.now(),
///   endDate: DateTime.now().add(Duration(days: 30)),
/// );
/// ```
abstract class GoalsRepository {
  /// Fetches all goals for the current user.
  ///
  /// Returns a list of [Goal] entities representing the user's goals.
  /// May return an empty list if no goals exist.
  /// Throws an exception on network or parsing errors.
  Future<List<Goal>> getUserGoals();

  /// Fetches a specific goal by its ID.
  ///
  /// [goalId] - The unique identifier of the goal to fetch.
  /// Returns the [Goal] entity if found.
  /// Throws an exception if the goal is not found or on network errors.
  Future<Goal> getGoalById(String goalId);

  /// Creates a new goal with the specified parameters.
  ///
  /// [name] - The display name for the goal.
  /// [description] - Optional description providing more details about the goal.
  /// [targetSteps] - The target number of steps to achieve.
  /// [startDate] - When the goal tracking should begin.
  /// [endDate] - When the goal tracking should end.
  ///
  /// Returns the created [Goal] entity with its assigned ID.
  /// Throws an exception on validation or network errors.
  Future<Goal> createGoal({
    required String name,
    String? description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Fetches all members of a specific goal.
  ///
  /// [goalId] - The unique identifier of the goal.
  /// Returns a list of [GoalMembership] entities representing goal participants.
  /// May return an empty list if no members exist (besides the owner).
  /// Throws an exception if the goal is not found or on network errors.
  Future<List<GoalMembership>> getGoalMembers(String goalId);

  /// Fetches progress records for a specific goal.
  ///
  /// [goalId] - The unique identifier of the goal.
  /// Returns a list of [GoalProgress] entities with progress data.
  /// May return an empty list if no progress has been recorded.
  /// Throws an exception if the goal is not found or on network errors.
  Future<List<GoalProgress>> getGoalProgress(String goalId);

  /// Invites a user to join a goal.
  ///
  /// [goalId] - The unique identifier of the goal.
  /// [userId] - The unique identifier of the user to invite.
  /// Returns the created [GoalMembership] entity with pending status.
  /// Throws an exception if the goal/user is not found, user is already
  /// a member, or on network errors.
  Future<GoalMembership> inviteUser(String goalId, String userId);

  /// Accepts an invitation to join a goal.
  ///
  /// [goalId] - The unique identifier of the goal to accept the invite for.
  /// The current user's pending invitation will be accepted.
  /// Throws an exception if no pending invitation exists or on network errors.
  Future<void> acceptInvite(String goalId);

  /// Rejects an invitation to join a goal.
  ///
  /// [goalId] - The unique identifier of the goal to reject the invite for.
  /// The current user's pending invitation will be rejected.
  /// Throws an exception if no pending invitation exists or on network errors.
  Future<void> rejectInvite(String goalId);
}
