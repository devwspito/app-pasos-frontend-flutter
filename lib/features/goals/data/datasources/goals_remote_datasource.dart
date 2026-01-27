/// Remote data source for goals operations.
///
/// This file defines the interface and implementation for goals
/// API calls using the ApiClient.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/core/network/api_client.dart';
import 'package:app_pasos_frontend/core/network/api_endpoints.dart';
import 'package:app_pasos_frontend/features/goals/data/models/goal_progress_model.dart';
import 'package:app_pasos_frontend/features/goals/data/models/group_goal_model.dart';

/// Abstract interface for goals remote data operations.
///
/// This interface defines all goals-related API calls.
/// Implementations should use the [ApiClient] for network requests.
abstract interface class GoalsRemoteDatasource {
  /// Gets all group goals for the current user.
  ///
  /// Returns a list of [GroupGoalModel] containing both created
  /// and joined goals.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<List<GroupGoalModel>> getUserGoals();

  /// Creates a new group goal.
  ///
  /// [name] - The name of the goal.
  /// [targetSteps] - The total step target for the group.
  /// [startDate] - When the goal period starts.
  /// [endDate] - When the goal period ends.
  /// [description] - An optional description of the goal.
  ///
  /// Returns the created [GroupGoalModel] with 'active' status.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ValidationException] if required fields are invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<GroupGoalModel> createGoal({
    required String name,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  });

  /// Gets detailed information about a specific goal.
  ///
  /// [goalId] - The ID of the goal to retrieve.
  ///
  /// Returns the [GroupGoalModel] with full details.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NotFoundException] if goal not found.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<GroupGoalModel> getGoalDetails({required String goalId});

  /// Gets the progress information for a specific goal.
  ///
  /// [goalId] - The ID of the goal to get progress for.
  ///
  /// Returns [GoalProgressModel] containing current and target steps.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NotFoundException] if goal not found.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<GoalProgressModel> getGoalProgress({required String goalId});

  /// Invites a user to join a goal.
  ///
  /// [goalId] - The ID of the goal to invite to.
  /// [userId] - The ID of the user to invite.
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NotFoundException] if goal or user not found.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<void> inviteUser({required String goalId, required String userId});

  /// Joins a goal that the user has been invited to.
  ///
  /// [goalId] - The ID of the goal to join.
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NotFoundException] if goal not found.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<void> joinGoal({required String goalId});

  /// Leaves a goal that the user is a member of.
  ///
  /// [goalId] - The ID of the goal to leave.
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NotFoundException] if goal not found.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<void> leaveGoal({required String goalId});
}

/// Implementation of [GoalsRemoteDatasource] using [ApiClient].
///
/// This class handles all goals API calls, converting
/// responses to models and handling errors appropriately.
///
/// Example usage:
/// ```dart
/// final datasource = GoalsRemoteDatasourceImpl(client: apiClient);
/// final goals = await datasource.getUserGoals();
/// ```
class GoalsRemoteDatasourceImpl implements GoalsRemoteDatasource {
  /// Creates a [GoalsRemoteDatasourceImpl] with the given [ApiClient].
  ///
  /// [client] - The API client for making HTTP requests.
  GoalsRemoteDatasourceImpl({required ApiClient client}) : _client = client;

  /// The API client for making HTTP requests.
  final ApiClient _client;

  @override
  Future<List<GroupGoalModel>> getUserGoals() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.goals,
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle { goals: [...] } or { data: [...] } response format
    final goalsList = data['goals'] ?? data['data'] ?? <dynamic>[];
    return GroupGoalModel.fromJsonList(goalsList);
  }

  @override
  Future<GroupGoalModel> createGoal({
    required String name,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.goals,
      data: {
        'name': name,
        'targetSteps': targetSteps,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (description != null) 'description': description,
      },
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle both wrapped and unwrapped responses
    final goalData = data['goal'] as Map<String, dynamic>? ?? data;
    return GroupGoalModel.fromJson(goalData);
  }

  @override
  Future<GroupGoalModel> getGoalDetails({required String goalId}) async {
    final endpoint = ApiEndpoints.withParams(
      ApiEndpoints.goalDetails,
      {'id': goalId},
    );

    final response = await _client.get<Map<String, dynamic>>(endpoint);

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle both wrapped and unwrapped responses
    final goalData = data['goal'] as Map<String, dynamic>? ?? data;
    return GroupGoalModel.fromJson(goalData);
  }

  @override
  Future<GoalProgressModel> getGoalProgress({required String goalId}) async {
    final endpoint = ApiEndpoints.withParams(
      ApiEndpoints.goalProgress,
      {'id': goalId},
    );

    final response = await _client.get<Map<String, dynamic>>(endpoint);

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle both wrapped and unwrapped responses
    final progressData = data['progress'] as Map<String, dynamic>? ?? data;
    return GoalProgressModel.fromJson(progressData);
  }

  @override
  Future<void> inviteUser({
    required String goalId,
    required String userId,
  }) async {
    final endpoint = ApiEndpoints.withParams(
      ApiEndpoints.goalInvite,
      {'id': goalId},
    );

    final response = await _client.post<Map<String, dynamic>>(
      endpoint,
      data: {'userId': userId},
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Success response may contain { success: true } or similar
    // No return value needed for invite operation
  }

  @override
  Future<void> joinGoal({required String goalId}) async {
    final endpoint = ApiEndpoints.withParams(
      ApiEndpoints.goalJoin,
      {'id': goalId},
    );

    final response = await _client.post<Map<String, dynamic>>(endpoint);

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Success response may contain { success: true } or similar
    // No return value needed for join operation
  }

  @override
  Future<void> leaveGoal({required String goalId}) async {
    final endpoint = ApiEndpoints.withParams(
      ApiEndpoints.goalLeave,
      {'id': goalId},
    );

    // Note: Using POST instead of DELETE for data safety
    // The backend should handle this as a soft-delete or status change
    final response = await _client.post<Map<String, dynamic>>(endpoint);

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Success response may contain { success: true } or similar
    // No return value needed for leave operation
  }
}
