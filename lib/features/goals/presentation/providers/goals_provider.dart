import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';

/// Represents the current status of goals data loading.
///
/// - [initial]: Provider just created, no data loaded
/// - [loading]: Data is being fetched
/// - [loaded]: Data successfully loaded
/// - [error]: An error occurred during data loading
enum GoalsStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Entity representing a group goal.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/entities/goal.dart
class Goal {
  /// Unique identifier for the goal.
  final String id;

  /// Name of the goal.
  final String name;

  /// Optional description of the goal.
  final String? description;

  /// Target number of steps to achieve.
  final int targetSteps;

  /// ID of the user who created the goal.
  final String creatorId;

  /// When the goal starts.
  final DateTime startDate;

  /// When the goal ends.
  final DateTime endDate;

  /// Current total steps accumulated by all members.
  final int currentSteps;

  /// Status of the goal: 'active', 'completed', 'cancelled'.
  final String status;

  /// When the goal was created.
  final DateTime createdAt;

  /// When the goal was last updated.
  final DateTime? updatedAt;

  /// Creates a new Goal instance.
  const Goal({
    required this.id,
    required this.name,
    this.description,
    required this.targetSteps,
    required this.creatorId,
    required this.startDate,
    required this.endDate,
    this.currentSteps = 0,
    this.status = 'active',
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a Goal from a JSON map.
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      targetSteps: int.tryParse(json['targetSteps']?.toString() ?? '0') ?? 0,
      creatorId: json['creatorId']?.toString() ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'].toString())
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'].toString())
          : DateTime.now().add(const Duration(days: 30)),
      currentSteps:
          int.tryParse(json['currentSteps']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Converts this Goal to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'targetSteps': targetSteps,
      'creatorId': creatorId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'currentSteps': currentSteps,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Creates a copy of this goal with updated fields.
  Goal copyWith({
    String? id,
    String? name,
    String? description,
    int? targetSteps,
    String? creatorId,
    DateTime? startDate,
    DateTime? endDate,
    int? currentSteps,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetSteps: targetSteps ?? this.targetSteps,
      creatorId: creatorId ?? this.creatorId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currentSteps: currentSteps ?? this.currentSteps,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns the progress towards the goal as a value between 0.0 and 1.0.
  double get progress =>
      targetSteps > 0 ? (currentSteps / targetSteps).clamp(0.0, 1.0) : 0.0;

  /// Returns true if the goal has been completed.
  bool get isCompleted => status == 'completed' || currentSteps >= targetSteps;

  /// Returns true if the goal is still active.
  bool get isActive => status == 'active' && DateTime.now().isBefore(endDate);

  /// Returns true if the goal has expired.
  bool get isExpired => DateTime.now().isAfter(endDate) && !isCompleted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Goal(id: $id, name: $name, status: $status, progress: ${(progress * 100).toStringAsFixed(1)}%)';
}

/// Entity representing a user's membership in a goal.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/entities/goal_membership.dart
class GoalMembership {
  /// Unique identifier for the membership.
  final String id;

  /// ID of the goal.
  final String goalId;

  /// ID of the user.
  final String userId;

  /// Username of the member.
  final String username;

  /// Profile image URL of the member.
  final String? profileImageUrl;

  /// Role in the goal: 'creator', 'member'.
  final String role;

  /// Membership status: 'pending', 'accepted', 'rejected'.
  final String status;

  /// Total steps contributed by this member.
  final int contributedSteps;

  /// When the membership was created.
  final DateTime createdAt;

  /// When the membership was last updated.
  final DateTime? updatedAt;

  /// Creates a new GoalMembership instance.
  const GoalMembership({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.role,
    required this.status,
    this.contributedSteps = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a GoalMembership from a JSON map.
  factory GoalMembership.fromJson(Map<String, dynamic> json) {
    return GoalMembership(
      id: json['id']?.toString() ?? '',
      goalId: json['goalId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profileImageUrl: json['profileImageUrl']?.toString(),
      role: json['role']?.toString() ?? 'member',
      status: json['status']?.toString() ?? 'pending',
      contributedSteps:
          int.tryParse(json['contributedSteps']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Converts this GoalMembership to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'userId': userId,
      'username': username,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'role': role,
      'status': status,
      'contributedSteps': contributedSteps,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Creates a copy of this membership with updated fields.
  GoalMembership copyWith({
    String? id,
    String? goalId,
    String? userId,
    String? username,
    String? profileImageUrl,
    String? role,
    String? status,
    int? contributedSteps,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalMembership(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      contributedSteps: contributedSteps ?? this.contributedSteps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns true if this membership is pending acceptance.
  bool get isPending => status == 'pending';

  /// Returns true if this membership has been accepted.
  bool get isAccepted => status == 'accepted';

  /// Returns true if this member is the creator.
  bool get isCreator => role == 'creator';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalMembership &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'GoalMembership(id: $id, goalId: $goalId, userId: $userId, status: $status)';
}

/// Entity representing progress towards a goal.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/entities/goal_progress.dart
class GoalProgress {
  /// Unique identifier for the progress record.
  final String id;

  /// ID of the goal.
  final String goalId;

  /// ID of the user who contributed.
  final String userId;

  /// Username of the contributor.
  final String username;

  /// Number of steps added.
  final int steps;

  /// Date of the contribution.
  final DateTime date;

  /// When the progress was recorded.
  final DateTime createdAt;

  /// Creates a new GoalProgress instance.
  const GoalProgress({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.username,
    required this.steps,
    required this.date,
    required this.createdAt,
  });

  /// Creates a GoalProgress from a JSON map.
  factory GoalProgress.fromJson(Map<String, dynamic> json) {
    return GoalProgress(
      id: json['id']?.toString() ?? '',
      goalId: json['goalId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      steps: int.tryParse(json['steps']?.toString() ?? '0') ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  /// Converts this GoalProgress to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'userId': userId,
      'username': username,
      'steps': steps,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalProgress &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'GoalProgress(id: $id, goalId: $goalId, userId: $userId, steps: $steps)';
}

/// Abstract interface for GetUserGoalsUseCase.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/usecases/get_user_goals_usecase.dart
abstract class GetUserGoalsUseCase {
  /// Fetches all goals the user is a member of.
  ///
  /// Returns a list of goals including created and invited goals.
  Future<List<Goal>> call();
}

/// Abstract interface for GetGoalDetailsUseCase.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/usecases/get_goal_details_usecase.dart
abstract class GetGoalDetailsUseCase {
  /// Fetches detailed information about a specific goal.
  ///
  /// [goalId] - ID of the goal to fetch.
  /// Returns the goal with full details.
  Future<Goal> call(String goalId);
}

/// Abstract interface for GetGoalMembersUseCase.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/usecases/get_goal_members_usecase.dart
abstract class GetGoalMembersUseCase {
  /// Fetches all members of a goal.
  ///
  /// [goalId] - ID of the goal.
  /// Returns a list of goal memberships.
  Future<List<GoalMembership>> call(String goalId);
}

/// Abstract interface for GetGoalProgressUseCase.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/usecases/get_goal_progress_usecase.dart
abstract class GetGoalProgressUseCase {
  /// Fetches progress history for a goal.
  ///
  /// [goalId] - ID of the goal.
  /// Returns a list of progress entries.
  Future<List<GoalProgress>> call(String goalId);
}

/// Abstract interface for CreateGoalUseCase.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/usecases/create_goal_usecase.dart
abstract class CreateGoalUseCase {
  /// Creates a new goal.
  ///
  /// [params] - Parameters containing name, description, targetSteps, startDate, endDate.
  /// Returns the created goal.
  Future<Goal> call(CreateGoalParams params);
}

/// Parameters for creating a new goal.
class CreateGoalParams {
  /// Name of the goal.
  final String name;

  /// Optional description.
  final String? description;

  /// Target number of steps.
  final int targetSteps;

  /// Start date of the goal.
  final DateTime startDate;

  /// End date of the goal.
  final DateTime endDate;

  /// Creates new CreateGoalParams.
  const CreateGoalParams({
    required this.name,
    this.description,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
  });

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'targetSteps': targetSteps,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}

/// Abstract interface for InviteUserToGoalUseCase.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/usecases/invite_user_to_goal_usecase.dart
abstract class InviteUserToGoalUseCase {
  /// Invites a user to join a goal.
  ///
  /// [goalId] - ID of the goal.
  /// [userId] - ID of the user to invite.
  /// Returns the created membership.
  Future<GoalMembership> call(String goalId, String userId);
}

/// Abstract interface for AcceptGoalInviteUseCase.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/usecases/accept_goal_invite_usecase.dart
abstract class AcceptGoalInviteUseCase {
  /// Accepts an invitation to join a goal.
  ///
  /// [goalId] - ID of the goal to accept.
  /// Returns the updated membership.
  Future<GoalMembership> call(String goalId);
}

/// Abstract interface for RejectGoalInviteUseCase.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/usecases/reject_goal_invite_usecase.dart
abstract class RejectGoalInviteUseCase {
  /// Rejects an invitation to join a goal.
  ///
  /// [goalId] - ID of the goal to reject.
  Future<void> call(String goalId);
}

/// Goals state management provider using ChangeNotifier.
///
/// Manages group goals, memberships, progress tracking, and invitations.
/// Implements [ChangeNotifier] for use with Provider.
///
/// Usage:
/// ```dart
/// final goalsProvider = context.watch<GoalsProvider>();
/// if (goalsProvider.status == GoalsStatus.loaded) {
///   // Show goals list
///   print('Active goals: ${goalsProvider.activeGoals.length}');
///   print('Completed goals: ${goalsProvider.completedGoals.length}');
/// }
/// ```
///
/// Features:
/// - Goal list management with real-time updates
/// - Goal details with members and progress
/// - Create and manage goals
/// - Invite users with optimistic updates
/// - Accept/reject invitations
/// - Error handling with user-friendly messages
class GoalsProvider extends ChangeNotifier {
  /// Use case for fetching user goals.
  final GetUserGoalsUseCase _getUserGoals;

  /// Use case for fetching goal details.
  final GetGoalDetailsUseCase _getGoalDetails;

  /// Use case for fetching goal members.
  final GetGoalMembersUseCase _getGoalMembers;

  /// Use case for fetching goal progress.
  final GetGoalProgressUseCase _getGoalProgress;

  /// Use case for creating goals.
  final CreateGoalUseCase _createGoal;

  /// Use case for inviting users to goals.
  final InviteUserToGoalUseCase _inviteUserToGoal;

  /// Use case for accepting goal invitations.
  final AcceptGoalInviteUseCase _acceptGoalInvite;

  /// Use case for rejecting goal invitations.
  final RejectGoalInviteUseCase _rejectGoalInvite;

  /// Current data loading status.
  GoalsStatus _status = GoalsStatus.initial;

  /// List of user's goals.
  List<Goal> _goals = [];

  /// Currently selected goal for details view.
  Goal? _selectedGoal;

  /// Members of the selected goal.
  List<GoalMembership> _goalMembers = [];

  /// Progress history of the selected goal.
  List<GoalProgress> _goalProgress = [];

  /// Error message from the last failed operation.
  String? _errorMessage;

  /// Creates a new GoalsProvider instance.
  ///
  /// [getUserGoals] - Use case for fetching user goals
  /// [getGoalDetails] - Use case for fetching goal details
  /// [getGoalMembers] - Use case for fetching goal members
  /// [getGoalProgress] - Use case for fetching goal progress
  /// [createGoal] - Use case for creating goals
  /// [inviteUserToGoal] - Use case for inviting users
  /// [acceptGoalInvite] - Use case for accepting invitations
  /// [rejectGoalInvite] - Use case for rejecting invitations
  GoalsProvider({
    required GetUserGoalsUseCase getUserGoals,
    required GetGoalDetailsUseCase getGoalDetails,
    required GetGoalMembersUseCase getGoalMembers,
    required GetGoalProgressUseCase getGoalProgress,
    required CreateGoalUseCase createGoal,
    required InviteUserToGoalUseCase inviteUserToGoal,
    required AcceptGoalInviteUseCase acceptGoalInvite,
    required RejectGoalInviteUseCase rejectGoalInvite,
  })  : _getUserGoals = getUserGoals,
        _getGoalDetails = getGoalDetails,
        _getGoalMembers = getGoalMembers,
        _getGoalProgress = getGoalProgress,
        _createGoal = createGoal,
        _inviteUserToGoal = inviteUserToGoal,
        _acceptGoalInvite = acceptGoalInvite,
        _rejectGoalInvite = rejectGoalInvite;

  // =========================================================================
  // GETTERS
  // =========================================================================

  /// Returns the current data loading status.
  GoalsStatus get status => _status;

  /// Returns the list of user's goals (unmodifiable).
  List<Goal> get goals => List.unmodifiable(_goals);

  /// Returns the currently selected goal for details view.
  Goal? get selectedGoal => _selectedGoal;

  /// Returns the members of the selected goal (unmodifiable).
  List<GoalMembership> get goalMembers => List.unmodifiable(_goalMembers);

  /// Returns the progress history of the selected goal (unmodifiable).
  List<GoalProgress> get goalProgress => List.unmodifiable(_goalProgress);

  /// Returns the error message from the last failed operation, or null if no error.
  String? get errorMessage => _errorMessage;

  /// Returns true if data is currently being loaded.
  bool get isLoading => _status == GoalsStatus.loading;

  /// Returns true if there are any goals.
  bool get hasGoals => _goals.isNotEmpty;

  /// Returns the list of active goals.
  List<Goal> get activeGoals =>
      _goals.where((goal) => goal.isActive).toList();

  /// Returns the list of completed goals.
  List<Goal> get completedGoals =>
      _goals.where((goal) => goal.isCompleted).toList();

  /// Returns goals where the user has pending invitations.
  List<Goal> get pendingInvitations => _goals
      .where((goal) => _hasPendingInvitation(goal.id))
      .toList();

  /// Returns the number of active goals.
  int get activeGoalCount => activeGoals.length;

  /// Returns the number of completed goals.
  int get completedGoalCount => completedGoals.length;

  // =========================================================================
  // STATE MANAGEMENT
  // =========================================================================

  /// Updates the internal state and notifies listeners.
  ///
  /// This helper method consolidates state changes to prevent multiple
  /// notifyListeners() calls and ensures consistent state updates.
  void _updateState({
    GoalsStatus? status,
    List<Goal>? goals,
    Goal? selectedGoal,
    List<GoalMembership>? goalMembers,
    List<GoalProgress>? goalProgress,
    String? error,
    bool clearGoals = false,
    bool clearSelectedGoal = false,
    bool clearGoalMembers = false,
    bool clearGoalProgress = false,
    bool clearError = false,
  }) {
    if (status != null) _status = status;

    if (clearGoals) {
      _goals = [];
    } else if (goals != null) {
      _goals = goals;
    }

    if (clearSelectedGoal) {
      _selectedGoal = null;
    } else if (selectedGoal != null) {
      _selectedGoal = selectedGoal;
    }

    if (clearGoalMembers) {
      _goalMembers = [];
    } else if (goalMembers != null) {
      _goalMembers = goalMembers;
    }

    if (clearGoalProgress) {
      _goalProgress = [];
    } else if (goalProgress != null) {
      _goalProgress = goalProgress;
    }

    if (clearError) {
      _errorMessage = null;
    } else if (error != null) {
      _errorMessage = error;
    }

    notifyListeners();
  }

  // =========================================================================
  // DATA LOADING
  // =========================================================================

  /// Loads all goals the user is a member of.
  ///
  /// This is the primary method to call when displaying the goals screen.
  ///
  /// Updates [status] to [GoalsStatus.loaded] on success,
  /// or [GoalsStatus.error] with [errorMessage] on failure.
  Future<void> loadUserGoals() async {
    _updateState(status: GoalsStatus.loading, clearError: true);

    try {
      final goals = await _getUserGoals.call();

      AppLogger.info('User goals loaded: ${goals.length} goals');

      _updateState(
        status: GoalsStatus.loaded,
        goals: goals,
        clearError: true,
      );
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to load user goals', e);
      _updateState(
        status: GoalsStatus.error,
        error: errorMsg,
      );
    }
  }

  /// Loads detailed information about a specific goal.
  ///
  /// [goalId] - ID of the goal to load.
  ///
  /// Fetches goal details, members, and progress in parallel.
  /// Updates [selectedGoal], [goalMembers], and [goalProgress].
  Future<void> loadGoalDetails(String goalId) async {
    _updateState(
      status: GoalsStatus.loading,
      clearError: true,
      clearGoalMembers: true,
      clearGoalProgress: true,
    );

    try {
      // Fetch data in parallel for better performance
      final results = await Future.wait([
        _getGoalDetails.call(goalId),
        _getGoalMembers.call(goalId),
        _getGoalProgress.call(goalId),
      ]);

      final goal = results[0] as Goal;
      final members = results[1] as List<GoalMembership>;
      final progress = results[2] as List<GoalProgress>;

      AppLogger.info(
        'Goal details loaded: ${goal.name} with '
        '${members.length} members and ${progress.length} progress entries',
      );

      _updateState(
        status: GoalsStatus.loaded,
        selectedGoal: goal,
        goalMembers: members,
        goalProgress: progress,
        clearError: true,
      );
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to load goal details', e);
      _updateState(
        status: GoalsStatus.error,
        error: errorMsg,
      );
    }
  }

  /// Refreshes all goals data.
  ///
  /// Use this for pull-to-refresh functionality.
  /// Same as [loadUserGoals] but semantically indicates a refresh operation.
  Future<void> refreshData() async {
    AppLogger.info('Refreshing goals data');
    await loadUserGoals();
  }

  // =========================================================================
  // GOAL OPERATIONS
  // =========================================================================

  /// Creates a new goal.
  ///
  /// [name] - Name of the goal.
  /// [description] - Optional description.
  /// [targetSteps] - Target number of steps to achieve.
  /// [startDate] - When the goal starts.
  /// [endDate] - When the goal ends.
  ///
  /// Adds the created goal to the goals list on success.
  /// Sets [errorMessage] on failure.
  Future<void> createGoal({
    required String name,
    String? description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _updateState(status: GoalsStatus.loading, clearError: true);

    try {
      final params = CreateGoalParams(
        name: name,
        description: description,
        targetSteps: targetSteps,
        startDate: startDate,
        endDate: endDate,
      );

      final goal = await _createGoal.call(params);

      AppLogger.info('Goal created: ${goal.name} (${goal.id})');

      // Add to goals list
      final updatedGoals = [..._goals, goal];

      _updateState(
        status: GoalsStatus.loaded,
        goals: updatedGoals,
        clearError: true,
      );
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to create goal', e);
      _updateState(
        status: GoalsStatus.error,
        error: errorMsg,
      );
    }
  }

  /// Invites a user to join a goal.
  ///
  /// [goalId] - ID of the goal.
  /// [userId] - ID of the user to invite.
  ///
  /// Updates the goal members list on success.
  /// Sets [errorMessage] on failure.
  Future<void> inviteUser(String goalId, String userId) async {
    _updateState(status: GoalsStatus.loading, clearError: true);

    try {
      final membership = await _inviteUserToGoal.call(goalId, userId);

      AppLogger.info('User $userId invited to goal $goalId');

      // Add to goal members if viewing this goal
      if (_selectedGoal?.id == goalId) {
        final updatedMembers = [..._goalMembers, membership];
        _updateState(
          status: GoalsStatus.loaded,
          goalMembers: updatedMembers,
          clearError: true,
        );
      } else {
        _updateState(
          status: GoalsStatus.loaded,
          clearError: true,
        );
      }
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to invite user to goal', e);
      _updateState(
        status: GoalsStatus.error,
        error: errorMsg,
      );
    }
  }

  /// Accepts an invitation to join a goal with optimistic update.
  ///
  /// [goalId] - ID of the goal to accept.
  ///
  /// Optimistically updates the membership status immediately,
  /// then rolls back on API error.
  Future<void> acceptInvite(String goalId) async {
    // Find the goal
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex == -1) {
      AppLogger.warning('Goal not found for acceptance: $goalId');
      _updateState(error: 'Goal not found');
      return;
    }

    // Find pending membership in goalMembers if viewing this goal
    final memberIndex = _goalMembers.indexWhere(
      (m) => m.goalId == goalId && m.isPending,
    );

    // Optimistic update for membership status
    List<GoalMembership>? updatedMembers;
    GoalMembership? originalMember;
    if (memberIndex != -1) {
      originalMember = _goalMembers[memberIndex];
      final acceptedMember = originalMember.copyWith(
        status: 'accepted',
        updatedAt: DateTime.now(),
      );
      updatedMembers = List<GoalMembership>.from(_goalMembers)
        ..[memberIndex] = acceptedMember;
      _updateState(
        goalMembers: updatedMembers,
        clearError: true,
      );
    }

    try {
      // Make API call
      await _acceptGoalInvite.call(goalId);
      AppLogger.info('Goal invitation accepted: $goalId');
    } catch (e) {
      // Rollback on error
      AppLogger.error('Failed to accept goal invitation, rolling back', e);

      if (originalMember != null) {
        final rolledBackMembers = List<GoalMembership>.from(_goalMembers);
        final idx = rolledBackMembers.indexWhere((m) => m.id == originalMember!.id);
        if (idx != -1) {
          rolledBackMembers[idx] = originalMember;
        }

        _updateState(
          goalMembers: rolledBackMembers,
          error: _parseError(e),
        );
      } else {
        _updateState(error: _parseError(e));
      }
    }
  }

  /// Rejects an invitation to join a goal with optimistic update.
  ///
  /// [goalId] - ID of the goal to reject.
  ///
  /// Optimistically removes the goal from the list immediately,
  /// then rolls back on API error.
  Future<void> rejectInvite(String goalId) async {
    // Find the goal
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex == -1) {
      AppLogger.warning('Goal not found for rejection: $goalId');
      _updateState(error: 'Goal not found');
      return;
    }

    final goal = _goals[goalIndex];

    // Optimistic update: remove from goals immediately
    final updatedGoals = List<Goal>.from(_goals)..removeAt(goalIndex);

    _updateState(
      goals: updatedGoals,
      clearError: true,
    );

    try {
      // Make API call
      await _rejectGoalInvite.call(goalId);
      AppLogger.info('Goal invitation rejected: $goalId');
    } catch (e) {
      // Rollback on error
      AppLogger.error('Failed to reject goal invitation, rolling back', e);

      final rolledBackGoals = List<Goal>.from(_goals)..insert(goalIndex, goal);

      _updateState(
        goals: rolledBackGoals,
        error: _parseError(e),
      );
    }
  }

  // =========================================================================
  // REAL-TIME UPDATES
  // =========================================================================

  /// Handle real-time goal updates from WebSocket.
  ///
  /// This method is called when WebSocket events indicate goal-related
  /// updates. It handles various event types:
  /// - 'goal_invite_received': User was invited to join a goal
  /// - 'goal_member_joined': A new member joined a goal
  /// - 'goal_progress_updated': Goal progress was updated
  /// - 'goal_completed': A goal was completed
  /// - 'goal_updated': Goal details were updated
  ///
  /// [eventType] - Type of the event (string identifier)
  /// [data] - Map containing the event-specific data
  ///
  /// Example:
  /// ```dart
  /// goalsProvider.handleRealtimeUpdate(
  ///   'goal_invite_received',
  ///   {'goalId': '123', 'goalName': 'Team Challenge'},
  /// );
  /// ```
  void handleRealtimeUpdate(String eventType, Map<String, dynamic> data) {
    AppLogger.info('Received real-time goals update: $eventType');

    try {
      switch (eventType) {
        case 'goal_invite_received':
          _handleGoalInviteReceived(data);
          break;

        case 'goal_member_joined':
          _handleGoalMemberJoined(data);
          break;

        case 'goal_progress_updated':
          _handleGoalProgressUpdated(data);
          break;

        case 'goal_completed':
          _handleGoalCompleted(data);
          break;

        case 'goal_updated':
          _handleGoalUpdated(data);
          break;

        default:
          AppLogger.warning('Unknown goals event type: $eventType');
          // For unknown events, refresh the data to stay in sync
          loadUserGoals();
      }
    } catch (e) {
      AppLogger.error('Error handling real-time goals update', e);
    }
  }

  /// Handles goal invitation notification from WebSocket.
  void _handleGoalInviteReceived(Map<String, dynamic> data) {
    final goal = Goal.fromJson(data);

    // Check if this goal is already in the list
    final existingIndex = _goals.indexWhere((g) => g.id == goal.id);
    if (existingIndex == -1) {
      // Add new goal to the list
      final updatedGoals = [..._goals, goal];
      _updateState(
        goals: updatedGoals,
        clearError: true,
      );
      AppLogger.info('New goal invitation received: ${goal.name}');
    }
  }

  /// Handles new member joining a goal from WebSocket.
  void _handleGoalMemberJoined(Map<String, dynamic> data) {
    final goalId = data['goalId']?.toString() ?? '';
    if (goalId.isEmpty) {
      AppLogger.warning('Goal member joined event missing goalId');
      return;
    }

    // Create membership from data
    final membership = GoalMembership.fromJson(data);

    // If we're currently viewing this goal, update the members list
    if (_selectedGoal?.id == goalId) {
      final existingIndex = _goalMembers.indexWhere((m) => m.id == membership.id);
      if (existingIndex == -1) {
        final updatedMembers = [..._goalMembers, membership];
        _updateState(
          goalMembers: updatedMembers,
          clearError: true,
        );
        AppLogger.info('New member joined goal: ${membership.username}');
      }
    }
  }

  /// Handles goal progress update from WebSocket.
  void _handleGoalProgressUpdated(Map<String, dynamic> data) {
    final goalId = data['goalId']?.toString() ?? '';
    final currentSteps = data['currentSteps'] as int?;

    if (goalId.isEmpty) {
      AppLogger.warning('Goal progress event missing goalId');
      return;
    }

    // Update the goal's current steps in the list
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1 && currentSteps != null) {
      final updatedGoal = _goals[goalIndex].copyWith(currentSteps: currentSteps);
      final updatedGoals = List<Goal>.from(_goals)..[goalIndex] = updatedGoal;

      // Also update selectedGoal if it's the same goal
      Goal? updatedSelectedGoal;
      if (_selectedGoal?.id == goalId) {
        updatedSelectedGoal = updatedGoal;
      }

      _updateState(
        goals: updatedGoals,
        selectedGoal: updatedSelectedGoal,
        clearError: true,
      );
      AppLogger.info('Goal progress updated: $currentSteps steps');
    }

    // If we have progress data, add it to the progress list
    if (_selectedGoal?.id == goalId && data['progressEntry'] != null) {
      final progress = GoalProgress.fromJson(data['progressEntry'] as Map<String, dynamic>);
      final updatedProgress = [..._goalProgress, progress];
      _updateState(
        goalProgress: updatedProgress,
        clearError: true,
      );
    }
  }

  /// Handles goal completion notification from WebSocket.
  void _handleGoalCompleted(Map<String, dynamic> data) {
    final goalId = data['goalId']?.toString() ?? '';
    if (goalId.isEmpty) {
      AppLogger.warning('Goal completed event missing goalId');
      return;
    }

    // Update the goal's status in the list
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final updatedGoal = _goals[goalIndex].copyWith(
        status: 'completed',
        updatedAt: DateTime.now(),
      );
      final updatedGoals = List<Goal>.from(_goals)..[goalIndex] = updatedGoal;

      // Also update selectedGoal if it's the same goal
      Goal? updatedSelectedGoal;
      if (_selectedGoal?.id == goalId) {
        updatedSelectedGoal = updatedGoal;
      }

      _updateState(
        goals: updatedGoals,
        selectedGoal: updatedSelectedGoal,
        clearError: true,
      );
      AppLogger.info('Goal completed: ${_goals[goalIndex].name}');
    }
  }

  /// Handles goal details update from WebSocket.
  void _handleGoalUpdated(Map<String, dynamic> data) {
    final updatedGoal = Goal.fromJson(data);

    // Update in the goals list
    final goalIndex = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (goalIndex != -1) {
      final updatedGoals = List<Goal>.from(_goals)..[goalIndex] = updatedGoal;

      // Also update selectedGoal if it's the same goal
      Goal? newSelectedGoal;
      if (_selectedGoal?.id == updatedGoal.id) {
        newSelectedGoal = updatedGoal;
      }

      _updateState(
        goals: updatedGoals,
        selectedGoal: newSelectedGoal,
        clearError: true,
      );
      AppLogger.info('Goal updated: ${updatedGoal.name}');
    }
  }

  // =========================================================================
  // ERROR HANDLING
  // =========================================================================

  /// Clears the current error message.
  ///
  /// Call this when displaying errors to reset the error state.
  void clearError() {
    _updateState(clearError: true);
  }

  /// Resets all data to initial state.
  ///
  /// Use this when logging out or switching users.
  void reset() {
    _updateState(
      status: GoalsStatus.initial,
      clearGoals: true,
      clearSelectedGoal: true,
      clearGoalMembers: true,
      clearGoalProgress: true,
      clearError: true,
    );
    AppLogger.info('Goals provider reset');
  }

  // =========================================================================
  // PRIVATE HELPERS
  // =========================================================================

  /// Checks if the user has a pending invitation for a goal.
  bool _hasPendingInvitation(String goalId) {
    return _goalMembers.any(
      (m) => m.goalId == goalId && m.isPending,
    );
  }

  /// Parses error response into a user-friendly message.
  String _parseError(dynamic error) {
    if (error is Exception) {
      final errorStr = error.toString();

      // Check for common error patterns
      if (errorStr.contains('401')) {
        return 'Please log in to manage goals';
      }
      if (errorStr.contains('403')) {
        return 'You do not have permission for this action';
      }
      if (errorStr.contains('404')) {
        return 'Goal not found';
      }
      if (errorStr.contains('409')) {
        return 'A goal with this name already exists';
      }
      if (errorStr.contains('500')) {
        return 'Server error. Please try again later';
      }
      if (errorStr.contains('SocketException') ||
          errorStr.contains('Connection refused')) {
        return 'Unable to connect. Please check your internet connection';
      }
      if (errorStr.contains('timeout')) {
        return 'Request timed out. Please try again';
      }
    }
    return 'An unexpected error occurred. Please try again';
  }

  @override
  void dispose() {
    AppLogger.info('GoalsProvider disposed');
    super.dispose();
  }
}
