import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/goal_membership_model.dart';
import '../models/goal_model.dart';
import '../models/goal_progress_model.dart';

/// Local API endpoint constants for goals feature.
///
/// These endpoints are defined locally as per the story requirements
/// to avoid modifying the central ApiEndpoints file.
class _GoalsEndpoints {
  static const String goals = '/goals';
  static const String userGoals = '/goals/user';
  static const String goalMembers = '/goals/{goalId}/members';
  static const String goalProgress = '/goals/{goalId}/progress';

  /// Constructs the goal detail endpoint for a given goal ID.
  static String goalDetail(String id) => '/goals/$id';

  /// Constructs the invite user endpoint for a given goal ID.
  static String inviteUser(String goalId) => '/goals/$goalId/invite';

  /// Constructs the accept invite endpoint for a given goal ID.
  static String acceptInvite(String goalId) => '/goals/$goalId/accept';

  /// Constructs the reject invite endpoint for a given goal ID.
  static String rejectInvite(String goalId) => '/goals/$goalId/reject';

  /// Constructs the goal members endpoint for a given goal ID.
  static String members(String goalId) => '/goals/$goalId/members';

  /// Constructs the goal progress endpoint for a given goal ID.
  static String progress(String goalId) => '/goals/$goalId/progress';

  _GoalsEndpoints._();
}

/// Request model for creating a new goal.
class CreateGoalRequest {
  final String name;
  final String? description;
  final int targetSteps;
  final DateTime startDate;
  final DateTime endDate;

  const CreateGoalRequest({
    required this.name,
    this.description,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
  });

  /// Converts this request to JSON for API submission.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'targetSteps': targetSteps,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}

/// Abstract interface for remote goals data operations.
///
/// Defines the contract for goal CRUD operations, membership management,
/// and progress tracking from the backend API. Implementations should handle
/// network errors and data transformation.
abstract class GoalsRemoteDataSource {
  /// Fetches all goals for the current user.
  ///
  /// Returns a list of [GoalModel] representing the user's goals.
  /// May return an empty list if no goals exist.
  /// Throws [DioException] on network errors.
  Future<List<GoalModel>> getUserGoals();

  /// Fetches a specific goal by its ID.
  ///
  /// [goalId] - The ID of the goal to retrieve.
  /// Returns the [GoalModel] for the specified goal.
  /// Throws [DioException] if the goal is not found or network errors occur.
  Future<GoalModel> getGoalById(String goalId);

  /// Creates a new goal.
  ///
  /// [request] - The goal creation request with name, target, and dates.
  /// Returns the created [GoalModel].
  /// Throws [DioException] if creation fails.
  Future<GoalModel> createGoal(CreateGoalRequest request);

  /// Fetches all members of a specific goal.
  ///
  /// [goalId] - The ID of the goal to get members for.
  /// Returns a list of [GoalMembershipModel] for the goal's members.
  /// May return an empty list if no members exist (unusual case).
  Future<List<GoalMembershipModel>> getGoalMembers(String goalId);

  /// Fetches progress entries for a specific goal.
  ///
  /// [goalId] - The ID of the goal to get progress for.
  /// Returns a list of [GoalProgressModel] with step contributions.
  /// May return an empty list if no progress has been recorded.
  Future<List<GoalProgressModel>> getGoalProgress(String goalId);

  /// Invites a user to join a goal.
  ///
  /// [goalId] - The ID of the goal to invite to.
  /// [userId] - The ID of the user to invite.
  /// Returns the created [GoalMembershipModel] with pending status.
  /// Throws [DioException] if the invitation fails.
  Future<GoalMembershipModel> inviteUser(String goalId, String userId);

  /// Accepts an invitation to join a goal.
  ///
  /// [goalId] - The ID of the goal to accept the invitation for.
  /// Throws [DioException] if the request fails or invitation not found.
  Future<void> acceptInvite(String goalId);

  /// Rejects an invitation to join a goal.
  ///
  /// [goalId] - The ID of the goal to reject the invitation for.
  /// Throws [DioException] if the request fails or invitation not found.
  Future<void> rejectInvite(String goalId);
}

/// Implementation of [GoalsRemoteDataSource] using DioClient.
///
/// Uses the singleton [DioClient] for all HTTP operations.
/// Handles JSON parsing and error transformation.
class GoalsRemoteDataSourceImpl implements GoalsRemoteDataSource {
  final DioClient _dioClient;

  /// Creates a [GoalsRemoteDataSourceImpl] instance.
  ///
  /// [dioClient] - Optional DioClient instance. Uses singleton if not provided.
  GoalsRemoteDataSourceImpl({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  @override
  Future<List<GoalModel>> getUserGoals() async {
    final response = await _dioClient.get<List<dynamic>>(
      _GoalsEndpoints.userGoals,
    );

    if (response.data == null) {
      return [];
    }

    return response.data!
        .map((json) => GoalModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GoalModel> getGoalById(String goalId) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      _GoalsEndpoints.goalDetail(goalId),
    );

    return GoalModel.fromJson(response.data!);
  }

  @override
  Future<GoalModel> createGoal(CreateGoalRequest request) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      _GoalsEndpoints.goals,
      data: request.toJson(),
    );

    return GoalModel.fromJson(response.data!);
  }

  @override
  Future<List<GoalMembershipModel>> getGoalMembers(String goalId) async {
    final response = await _dioClient.get<List<dynamic>>(
      _GoalsEndpoints.members(goalId),
    );

    if (response.data == null) {
      return [];
    }

    return response.data!
        .map((json) =>
            GoalMembershipModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<GoalProgressModel>> getGoalProgress(String goalId) async {
    final response = await _dioClient.get<List<dynamic>>(
      _GoalsEndpoints.progress(goalId),
    );

    if (response.data == null) {
      return [];
    }

    return response.data!
        .map(
            (json) => GoalProgressModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GoalMembershipModel> inviteUser(String goalId, String userId) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      _GoalsEndpoints.inviteUser(goalId),
      data: {'userId': userId},
    );

    return GoalMembershipModel.fromJson(response.data!);
  }

  @override
  Future<void> acceptInvite(String goalId) async {
    await _dioClient.put<void>(
      _GoalsEndpoints.acceptInvite(goalId),
    );
  }

  @override
  Future<void> rejectInvite(String goalId) async {
    await _dioClient.put<void>(
      _GoalsEndpoints.rejectInvite(goalId),
    );
  }
}
