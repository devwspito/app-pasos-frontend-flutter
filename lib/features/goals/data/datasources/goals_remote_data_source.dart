import '../../domain/entities/goal.dart';

/// Remote data source interface for goals API.
///
/// Defines the contract for communicating with the goals backend.
abstract interface class GoalsRemoteDataSource {
  /// Fetches all goals for the current user from the API.
  Future<List<Map<String, dynamic>>> getUserGoals();

  /// Fetches a single goal by ID from the API.
  Future<Map<String, dynamic>> getGoalById(String goalId);

  /// Fetches progress data for a goal from the API.
  Future<Map<String, dynamic>> getGoalProgress(String goalId);

  /// Creates a new goal via the API.
  Future<Map<String, dynamic>> createGoal({
    required String name,
    required String description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
    required GoalType type,
  });

  /// Updates an existing goal via the API.
  Future<Map<String, dynamic>> updateGoal({
    required String goalId,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? endDate,
  });

  /// Sends an invitation to join a goal.
  Future<bool> inviteUser({
    required String goalId,
    required String email,
  });

  /// Joins a goal using an invite code.
  Future<Map<String, dynamic>> joinGoal(String inviteCode);

  /// Leaves a group goal.
  Future<bool> leaveGoal(String goalId);
}
