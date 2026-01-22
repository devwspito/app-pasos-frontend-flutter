import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_progress.dart';
import '../../domain/repositories/goals_repository.dart';
import '../datasources/goals_remote_data_source.dart';
import '../models/goal_model.dart';
import '../models/goal_progress_model.dart';

/// Implementation of [GoalsRepository].
///
/// Uses [GoalsRemoteDataSource] for API communication.
class GoalsRepositoryImpl implements GoalsRepository {
  GoalsRepositoryImpl({required GoalsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final GoalsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Goal>> getUserGoals() async {
    final data = await _remoteDataSource.getUserGoals();
    return data.map((json) => GoalModel.fromJson(json)).toList();
  }

  @override
  Future<Goal> getGoalById(String goalId) async {
    final data = await _remoteDataSource.getGoalById(goalId);
    return GoalModel.fromJson(data);
  }

  @override
  Future<GoalProgress> getGoalProgress(String goalId) async {
    final data = await _remoteDataSource.getGoalProgress(goalId);
    return GoalProgressModel.fromJson(data);
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
    final data = await _remoteDataSource.createGoal(
      name: name,
      description: description,
      targetSteps: targetSteps,
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
    return GoalModel.fromJson(data);
  }

  @override
  Future<Goal> updateGoal({
    required String goalId,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? endDate,
  }) async {
    final data = await _remoteDataSource.updateGoal(
      goalId: goalId,
      name: name,
      description: description,
      targetSteps: targetSteps,
      endDate: endDate,
    );
    return GoalModel.fromJson(data);
  }

  @override
  Future<bool> inviteUser({
    required String goalId,
    required String email,
  }) {
    return _remoteDataSource.inviteUser(
      goalId: goalId,
      email: email,
    );
  }

  @override
  Future<Goal> joinGoal(String inviteCode) async {
    final data = await _remoteDataSource.joinGoal(inviteCode);
    return GoalModel.fromJson(data);
  }

  @override
  Future<bool> leaveGoal(String goalId) {
    return _remoteDataSource.leaveGoal(goalId);
  }
}
