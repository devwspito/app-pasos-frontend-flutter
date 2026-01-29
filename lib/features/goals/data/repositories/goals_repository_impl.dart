/// Goals repository implementation.
///
/// This file implements the [GoalsRepository] interface, coordinating
/// data operations through the remote datasource.
library;

import 'package:app_pasos_frontend/features/goals/data/datasources/goals_remote_datasource.dart';
import 'package:app_pasos_frontend/features/goals/domain/entities/goal_progress.dart';
import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';
import 'package:app_pasos_frontend/features/goals/domain/repositories/goals_repository.dart';

/// Implementation of [GoalsRepository] using the remote datasource.
///
/// This class implements the goals business logic, making API calls
/// through the datasource and returning domain entities.
///
/// Example usage:
/// ```dart
/// final repository = GoalsRepositoryImpl(
///   datasource: goalsDatasource,
/// );
///
/// final goals = await repository.getUserGoals();
/// ```
class GoalsRepositoryImpl implements GoalsRepository {
  /// Creates a [GoalsRepositoryImpl] with the required dependencies.
  ///
  /// [datasource] - The remote datasource for API calls.
  GoalsRepositoryImpl({
    required GoalsRemoteDatasource datasource,
  }) : _datasource = datasource;

  /// The remote datasource for API operations.
  final GoalsRemoteDatasource _datasource;

  @override
  Future<List<GroupGoal>> getUserGoals() async {
    // The datasource returns List<GroupGoalModel> which extends GroupGoal
    return _datasource.getUserGoals();
  }

  @override
  Future<GroupGoal> createGoal({
    required String name,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) async {
    // The datasource returns GroupGoalModel which extends GroupGoal
    return _datasource.createGoal(
      name: name,
      targetSteps: targetSteps,
      startDate: startDate,
      endDate: endDate,
      description: description,
    );
  }

  @override
  Future<GroupGoal> getGoalDetails({required String goalId}) async {
    // The datasource returns GroupGoalModel which extends GroupGoal
    return _datasource.getGoalDetails(goalId: goalId);
  }

  @override
  Future<GoalProgress> getGoalProgress({required String goalId}) async {
    // The datasource returns GoalProgressModel which extends GoalProgress
    return _datasource.getGoalProgress(goalId: goalId);
  }

  @override
  Future<void> inviteUser({
    required String goalId,
    required String userId,
  }) async {
    // Delegate to datasource - no return value needed
    await _datasource.inviteUser(goalId: goalId, userId: userId);
  }

  @override
  Future<void> joinGoal({required String goalId}) async {
    // Delegate to datasource - no return value needed
    await _datasource.joinGoal(goalId: goalId);
  }

  @override
  Future<void> leaveGoal({required String goalId}) async {
    // Delegate to datasource - no return value needed
    await _datasource.leaveGoal(goalId: goalId);
  }

  @override
  Future<GroupGoal> updateGoal({
    required String goalId,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // The datasource returns GroupGoalModel which extends GroupGoal
    return _datasource.updateGoal(
      goalId: goalId,
      name: name,
      description: description,
      targetSteps: targetSteps,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
