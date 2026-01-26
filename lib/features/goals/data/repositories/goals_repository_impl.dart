import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_membership.dart';
import '../../domain/entities/goal_progress.dart';
import '../../domain/repositories/goals_repository.dart';
// TODO: GoalsRemoteDataSource will be created by another story in this epic
// import '../datasources/goals_remote_datasource.dart';

/// Implementation of [GoalsRepository] that connects the domain layer to the data layer.
///
/// This repository acts as a bridge between the domain layer (which works with entities)
/// and the data layer (which works with models and data sources). It handles the conversion
/// between models and entities and delegates data operations to the remote data source.
///
/// Example usage:
/// ```dart
/// final repository = GoalsRepositoryImpl();
/// final goals = await repository.getUserGoals();
/// final goal = await repository.getGoalById('goal-123');
/// ```
class GoalsRepositoryImpl implements GoalsRepository {
  final GoalsRemoteDataSource _remoteDataSource;

  /// Creates a [GoalsRepositoryImpl] instance.
  ///
  /// [remoteDataSource] - Optional data source instance. Uses default implementation if not provided.
  GoalsRepositoryImpl({GoalsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? GoalsRemoteDataSourceImpl();

  @override
  Future<List<Goal>> getUserGoals() async {
    final models = await _remoteDataSource.getUserGoals();
    return models.map((model) => _goalModelToEntity(model)).toList();
  }

  @override
  Future<Goal> getGoalById(String goalId) async {
    final model = await _remoteDataSource.getGoalById(goalId);
    return _goalModelToEntity(model);
  }

  @override
  Future<Goal> createGoal({
    required String name,
    String? description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final model = await _remoteDataSource.createGoal(
      name: name,
      description: description,
      targetSteps: targetSteps,
      startDate: startDate,
      endDate: endDate,
    );
    return _goalModelToEntity(model);
  }

  @override
  Future<List<GoalMembership>> getGoalMembers(String goalId) async {
    final models = await _remoteDataSource.getGoalMembers(goalId);
    return models.map((model) => _membershipModelToEntity(model)).toList();
  }

  @override
  Future<List<GoalProgress>> getGoalProgress(String goalId) async {
    final models = await _remoteDataSource.getGoalProgress(goalId);
    return models.map((model) => _progressModelToEntity(model)).toList();
  }

  @override
  Future<GoalMembership> inviteUser(String goalId, String userId) async {
    final model = await _remoteDataSource.inviteUser(goalId, userId);
    return _membershipModelToEntity(model);
  }

  @override
  Future<void> acceptInvite(String goalId) async {
    await _remoteDataSource.acceptInvite(goalId);
  }

  @override
  Future<void> rejectInvite(String goalId) async {
    await _remoteDataSource.rejectInvite(goalId);
  }

  // ============================================
  // PRIVATE HELPER METHODS - Model to Entity Conversion
  // ============================================

  /// Converts a [GoalModel] to a [Goal] entity.
  ///
  /// Maps all model fields to their corresponding entity fields.
  Goal _goalModelToEntity(GoalModel model) {
    return Goal(
      id: model.id,
      name: model.name,
      description: model.description,
      targetSteps: model.targetSteps,
      startDate: model.startDate,
      endDate: model.endDate,
      creatorId: model.creatorId,
      creatorUsername: model.creatorUsername,
      status: model.status.name,
      createdAt: model.createdAt,
    );
  }

  /// Converts a [GoalMembershipModel] to a [GoalMembership] entity.
  ///
  /// Maps all model fields to their corresponding entity fields.
  /// The model uses enum for role/status while entity uses String.
  GoalMembership _membershipModelToEntity(GoalMembershipModel model) {
    return GoalMembership(
      id: model.id,
      goalId: model.goalId,
      userId: model.userId,
      username: model.username,
      profileImageUrl: model.profileImageUrl,
      role: model.role.name,
      status: model.status.name,
      joinedAt: model.joinedAt,
    );
  }

  /// Converts a [GoalProgressModel] to a [GoalProgress] entity.
  ///
  /// Maps all model fields to their corresponding entity fields.
  GoalProgress _progressModelToEntity(GoalProgressModel model) {
    return GoalProgress(
      id: model.id,
      goalId: model.goalId,
      userId: model.userId,
      username: model.username,
      profileImageUrl: model.profileImageUrl,
      totalSteps: model.totalSteps,
      dailyAverage: model.dailyAverage,
      daysCompleted: model.daysCompleted,
      currentStreak: model.currentStreak,
      lastUpdated: model.lastUpdated,
    );
  }
}

// =============================================================================
// TEMPORARY TYPE DEFINITIONS
// These will be replaced by actual datasource/model imports when they are
// created by another story in this epic.
// =============================================================================

/// Temporary abstract interface for remote goals data operations.
///
/// TODO: Remove this when goals_remote_datasource.dart is created by another story.
abstract class GoalsRemoteDataSource {
  Future<List<GoalModel>> getUserGoals();
  Future<GoalModel> getGoalById(String goalId);
  Future<GoalModel> createGoal({
    required String name,
    String? description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<List<GoalMembershipModel>> getGoalMembers(String goalId);
  Future<List<GoalProgressModel>> getGoalProgress(String goalId);
  Future<GoalMembershipModel> inviteUser(String goalId, String userId);
  Future<void> acceptInvite(String goalId);
  Future<void> rejectInvite(String goalId);
}

/// Temporary implementation stub for [GoalsRemoteDataSource].
///
/// TODO: Remove this when goals_remote_datasource.dart is created by another story.
class GoalsRemoteDataSourceImpl implements GoalsRemoteDataSource {
  @override
  Future<List<GoalModel>> getUserGoals() async {
    throw UnimplementedError(
      'GoalsRemoteDataSourceImpl will be implemented by another story in this epic',
    );
  }

  @override
  Future<GoalModel> getGoalById(String goalId) async {
    throw UnimplementedError(
      'GoalsRemoteDataSourceImpl will be implemented by another story in this epic',
    );
  }

  @override
  Future<GoalModel> createGoal({
    required String name,
    String? description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    throw UnimplementedError(
      'GoalsRemoteDataSourceImpl will be implemented by another story in this epic',
    );
  }

  @override
  Future<List<GoalMembershipModel>> getGoalMembers(String goalId) async {
    throw UnimplementedError(
      'GoalsRemoteDataSourceImpl will be implemented by another story in this epic',
    );
  }

  @override
  Future<List<GoalProgressModel>> getGoalProgress(String goalId) async {
    throw UnimplementedError(
      'GoalsRemoteDataSourceImpl will be implemented by another story in this epic',
    );
  }

  @override
  Future<GoalMembershipModel> inviteUser(String goalId, String userId) async {
    throw UnimplementedError(
      'GoalsRemoteDataSourceImpl will be implemented by another story in this epic',
    );
  }

  @override
  Future<void> acceptInvite(String goalId) async {
    throw UnimplementedError(
      'GoalsRemoteDataSourceImpl will be implemented by another story in this epic',
    );
  }

  @override
  Future<void> rejectInvite(String goalId) async {
    throw UnimplementedError(
      'GoalsRemoteDataSourceImpl will be implemented by another story in this epic',
    );
  }
}

/// Enum representing the status of a goal.
enum GoalStatus {
  active,
  completed,
  cancelled,
}

/// Enum representing the role of a member in a goal.
enum GoalMemberRole {
  owner,
  member,
}

/// Enum representing the status of a goal membership.
enum GoalMembershipStatus {
  pending,
  accepted,
  rejected,
}

/// Temporary GoalModel type definition until model is created.
///
/// TODO: Remove this when goal_model.dart is created by another story.
class GoalModel {
  final String id;
  final String name;
  final String? description;
  final int targetSteps;
  final DateTime startDate;
  final DateTime endDate;
  final String creatorId;
  final String creatorUsername;
  final GoalStatus status;
  final DateTime createdAt;

  const GoalModel({
    required this.id,
    required this.name,
    this.description,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
    required this.creatorId,
    required this.creatorUsername,
    required this.status,
    required this.createdAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      targetSteps: json['targetSteps'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      creatorId: json['creatorId'] as String,
      creatorUsername: json['creatorUsername'] as String,
      status: _parseGoalStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static GoalStatus _parseGoalStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return GoalStatus.active;
      case 'completed':
        return GoalStatus.completed;
      case 'cancelled':
        return GoalStatus.cancelled;
      default:
        return GoalStatus.active;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetSteps': targetSteps,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'creatorId': creatorId,
      'creatorUsername': creatorUsername,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Temporary GoalMembershipModel type definition until model is created.
///
/// TODO: Remove this when goal_membership_model.dart is created by another story.
class GoalMembershipModel {
  final String id;
  final String goalId;
  final String userId;
  final String username;
  final String? profileImageUrl;
  final GoalMemberRole role;
  final GoalMembershipStatus status;
  final DateTime joinedAt;

  const GoalMembershipModel({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.role,
    required this.status,
    required this.joinedAt,
  });

  factory GoalMembershipModel.fromJson(Map<String, dynamic> json) {
    return GoalMembershipModel(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: _parseRole(json['role'] as String),
      status: _parseStatus(json['status'] as String),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  static GoalMemberRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return GoalMemberRole.owner;
      case 'member':
        return GoalMemberRole.member;
      default:
        return GoalMemberRole.member;
    }
  }

  static GoalMembershipStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return GoalMembershipStatus.pending;
      case 'accepted':
        return GoalMembershipStatus.accepted;
      case 'rejected':
        return GoalMembershipStatus.rejected;
      default:
        return GoalMembershipStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'userId': userId,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'role': role.name,
      'status': status.name,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}

/// Temporary GoalProgressModel type definition until model is created.
///
/// TODO: Remove this when goal_progress_model.dart is created by another story.
class GoalProgressModel {
  final String id;
  final String goalId;
  final String userId;
  final String username;
  final String? profileImageUrl;
  final int totalSteps;
  final double dailyAverage;
  final int daysCompleted;
  final int currentStreak;
  final DateTime lastUpdated;

  const GoalProgressModel({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.totalSteps,
    required this.dailyAverage,
    required this.daysCompleted,
    required this.currentStreak,
    required this.lastUpdated,
  });

  factory GoalProgressModel.fromJson(Map<String, dynamic> json) {
    return GoalProgressModel(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      totalSteps: json['totalSteps'] as int? ?? 0,
      dailyAverage: (json['dailyAverage'] as num?)?.toDouble() ?? 0.0,
      daysCompleted: json['daysCompleted'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'userId': userId,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'totalSteps': totalSteps,
      'dailyAverage': dailyAverage,
      'daysCompleted': daysCompleted,
      'currentStreak': currentStreak,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
