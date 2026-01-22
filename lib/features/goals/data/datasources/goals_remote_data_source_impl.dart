import '../../../../core/network/api_client.dart';
import '../../domain/entities/goal.dart';
import 'goals_remote_data_source.dart';

/// Implementation of [GoalsRemoteDataSource] using [ApiClient].
///
/// Handles all API communication for goals-related operations.
class GoalsRemoteDataSourceImpl implements GoalsRemoteDataSource {
  GoalsRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<Map<String, dynamic>>> getUserGoals() async {
    final response = await _apiClient.get('/api/goals');
    final data = response.data as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> getGoalById(String goalId) async {
    final response = await _apiClient.get('/api/goals/$goalId');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getGoalProgress(String goalId) async {
    final response = await _apiClient.get('/api/goals/$goalId/progress');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> createGoal({
    required String name,
    required String description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
    required GoalType type,
  }) async {
    final response = await _apiClient.post(
      '/api/goals',
      data: {
        'name': name,
        'description': description,
        'targetSteps': targetSteps,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'type': type == GoalType.group ? 'group' : 'individual',
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateGoal({
    required String goalId,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? endDate,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (targetSteps != null) data['targetSteps'] = targetSteps;
    if (endDate != null) data['endDate'] = endDate.toIso8601String();

    final response = await _apiClient.patch(
      '/api/goals/$goalId',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<bool> inviteUser({
    required String goalId,
    required String email,
  }) async {
    await _apiClient.post(
      '/api/goals/$goalId/invite',
      data: {'email': email},
    );
    return true;
  }

  @override
  Future<Map<String, dynamic>> joinGoal(String inviteCode) async {
    final response = await _apiClient.post(
      '/api/goals/join',
      data: {'inviteCode': inviteCode},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<bool> leaveGoal(String goalId) async {
    await _apiClient.post('/api/goals/$goalId/leave');
    return true;
  }
}
