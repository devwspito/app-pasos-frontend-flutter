import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/goal.dart';
import '../models/goal_membership_model.dart';
import '../models/goal_model.dart';
import '../models/goal_progress_model.dart';

/// Abstract interface for goals remote data source.
///
/// Defines the contract for fetching and managing goal data from the API.
abstract interface class GoalsRemoteDataSource {
  /// Fetches all goals for the current user.
  Future<List<GoalModel>> getUserGoals();

  /// Fetches a specific goal by ID.
  Future<GoalModel> getGoalById(String goalId);

  /// Creates a new goal.
  Future<GoalModel> createGoal({
    required String name,
    required String description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
    required GoalType type,
  });

  /// Updates an existing goal.
  Future<GoalModel> updateGoal({
    required String goalId,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? endDate,
  });

  /// Fetches the progress of a specific goal.
  Future<GoalProgressModel> getGoalProgress(String goalId);

  /// Invites a user to join a group goal.
  Future<GoalMembershipModel> inviteUser({
    required String goalId,
    required String email,
  });

  /// Joins a group goal using an invite code.
  Future<GoalMembershipModel> joinGoal(String inviteCode);

  /// Leaves a group goal.
  Future<void> leaveGoal(String goalId);

  /// Fetches all members of a goal.
  Future<List<GoalMembershipModel>> getGoalMembers(String goalId);
}

/// Implementation of [GoalsRemoteDataSource] using [ApiClient].
class GoalsRemoteDataSourceImpl implements GoalsRemoteDataSource {
  const GoalsRemoteDataSourceImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<GoalModel>> getUserGoals() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.goals,
    );

    final data = response.data;
    if (data == null) {
      return [];
    }

    final goalsList = data['goals'] as List<dynamic>? ?? [];
    return goalsList
        .map((json) => GoalModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GoalModel> getGoalById(String goalId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.getGoalById(goalId),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch goal: No data received');
    }

    return GoalModel.fromJson(data);
  }

  @override
  Future<GoalModel> createGoal({
    required String name,
    required String description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
    required GoalType type,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.createGoal,
      data: {
        'name': name,
        'description': description,
        'targetSteps': targetSteps,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'type': type.name,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to create goal: No data received');
    }

    return GoalModel.fromJson(data);
  }

  @override
  Future<GoalModel> updateGoal({
    required String goalId,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? endDate,
  }) async {
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (description != null) updateData['description'] = description;
    if (targetSteps != null) updateData['targetSteps'] = targetSteps;
    if (endDate != null) updateData['endDate'] = endDate.toIso8601String();

    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateGoal(goalId),
      data: updateData,
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to update goal: No data received');
    }

    return GoalModel.fromJson(data);
  }

  @override
  Future<GoalProgressModel> getGoalProgress(String goalId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.goalProgress(goalId),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch goal progress: No data received');
    }

    return GoalProgressModel.fromJson(data);
  }

  @override
  Future<GoalMembershipModel> inviteUser({
    required String goalId,
    required String email,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.inviteToGoal(goalId),
      data: {'email': email},
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to invite user: No data received');
    }

    return GoalMembershipModel.fromJson(data);
  }

  @override
  Future<GoalMembershipModel> joinGoal(String inviteCode) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.joinGoal,
      data: {'inviteCode': inviteCode},
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to join goal: No data received');
    }

    return GoalMembershipModel.fromJson(data);
  }

  @override
  Future<void> leaveGoal(String goalId) async {
    await _apiClient.post<void>(
      ApiEndpoints.leaveGoal(goalId),
    );
  }

  @override
  Future<List<GoalMembershipModel>> getGoalMembers(String goalId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.goalMembers(goalId),
    );

    final data = response.data;
    if (data == null) {
      return [];
    }

    final membersList = data['members'] as List<dynamic>? ?? [];
    return membersList
        .map((json) => GoalMembershipModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
