import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_membership.dart';
import '../../domain/entities/goal_progress.dart';
import '../../domain/repositories/goals_repository.dart';
import '../datasources/goals_remote_datasource.dart';

/// Implementation of [GoalsRepository] using [GoalsRemoteDataSource].
///
/// Delegates API calls to the remote data source and converts
/// models to domain entities.
class GoalsRepositoryImpl implements GoalsRepository {
  const GoalsRepositoryImpl({
    required GoalsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final GoalsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Goal>> getUserGoals() async {
    final models = await _remoteDataSource.getUserGoals();
    // Models already extend Goal, so they can be returned directly
    return models;
  }

  @override
  Future<Goal> getGoalById(String goalId) async {
    final model = await _remoteDataSource.getGoalById(goalId);
    // Model already extends Goal, so it can be returned directly
    return model;
  }

  @override
  Future<Goal> createGoal({
    required String name,
    required String description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
    required GoalType type,
  }) async {
    final model = await _remoteDataSource.createGoal(
      name: name,
      description: description,
      targetSteps: targetSteps,
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
    return model;
  }

  @override
  Future<Goal> updateGoal({
    required String goalId,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? endDate,
  }) async {
    final model = await _remoteDataSource.updateGoal(
      goalId: goalId,
      name: name,
      description: description,
      targetSteps: targetSteps,
      endDate: endDate,
    );
    return model;
  }

  @override
  Future<GoalProgress> getGoalProgress(String goalId) async {
    final model = await _remoteDataSource.getGoalProgress(goalId);
    return model;
  }

  @override
  Future<GoalMembership> inviteUser({
    required String goalId,
    required String email,
  }) async {
    final model = await _remoteDataSource.inviteUser(
      goalId: goalId,
      email: email,
    );
    return model;
  }

  @override
  Future<GoalMembership> joinGoal(String inviteCode) async {
    final model = await _remoteDataSource.joinGoal(inviteCode);
    return model;
  }

  @override
  Future<void> leaveGoal(String goalId) async {
    await _remoteDataSource.leaveGoal(goalId);
  }

  @override
  Future<List<GoalMembership>> getGoalMembers(String goalId) async {
    final models = await _remoteDataSource.getGoalMembers(goalId);
    return models;
  }
}
