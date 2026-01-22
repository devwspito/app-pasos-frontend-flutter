import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/goal.dart';
import '../../domain/repositories/goals_repository.dart';
import '../../domain/usecases/create_goal_usecase.dart';
import '../../domain/usecases/get_goal_details_usecase.dart';
import '../../domain/usecases/get_user_goals_usecase.dart';
import '../../domain/usecases/invite_user_usecase.dart';
import '../../domain/usecases/join_goal_usecase.dart';
import 'goals_state.dart';

/// StateNotifier for managing goals feature state.
///
/// This notifier handles all goals-related state changes including
/// loading user goals, creating goals, inviting users, and joining goals.
///
/// Usage:
/// ```dart
/// final goalsState = ref.watch(goalsProvider);
/// ref.read(goalsProvider.notifier).loadUserGoals();
/// ```
class GoalsNotifier extends StateNotifier<GoalsState> {
  GoalsNotifier({
    required GetUserGoalsUseCase getUserGoalsUseCase,
    required GetGoalDetailsUseCase getGoalDetailsUseCase,
    required CreateGoalUseCase createGoalUseCase,
    required InviteUserUseCase inviteUserUseCase,
    required JoinGoalUseCase joinGoalUseCase,
  })  : _getUserGoalsUseCase = getUserGoalsUseCase,
        _getGoalDetailsUseCase = getGoalDetailsUseCase,
        _createGoalUseCase = createGoalUseCase,
        _inviteUserUseCase = inviteUserUseCase,
        _joinGoalUseCase = joinGoalUseCase,
        super(const GoalsState.initial());

  final GetUserGoalsUseCase _getUserGoalsUseCase;
  final GetGoalDetailsUseCase _getGoalDetailsUseCase;
  final CreateGoalUseCase _createGoalUseCase;
  final InviteUserUseCase _inviteUserUseCase;
  final JoinGoalUseCase _joinGoalUseCase;

  /// Loads all goals for the current user.
  ///
  /// Updates state to loading while in progress, then either
  /// loaded with goals data or error with message.
  Future<void> loadUserGoals() async {
    state = state.copyWith(
      status: state.hasData ? GoalsStatus.loaded : GoalsStatus.loading,
      isLoading: true,
      clearError: true,
    );

    try {
      final goals = await _getUserGoalsUseCase();
      state = state.copyWith(
        status: GoalsStatus.loaded,
        goals: goals,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: GoalsStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
    }
  }

  /// Loads detailed information for a specific goal.
  ///
  /// [goalId] The unique identifier of the goal.
  ///
  /// Updates state with the selected goal and its progress data.
  Future<void> loadGoalDetails(String goalId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final details = await _getGoalDetailsUseCase(goalId);
      state = state.copyWith(
        status: GoalsStatus.loaded,
        selectedGoal: details.goal,
        goalProgress: details.progress,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: GoalsStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
    }
  }

  /// Creates a new goal.
  ///
  /// [name] Display name for the goal.
  /// [description] Detailed description.
  /// [targetSteps] Target number of steps.
  /// [startDate] When the goal period begins.
  /// [endDate] When the goal period ends.
  /// [type] Whether individual or group goal.
  ///
  /// Returns the created [Goal] on success, null on failure.
  /// After creating, automatically refreshes the goals list.
  Future<Goal?> createGoal({
    required String name,
    required String description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
    required GoalType type,
  }) async {
    if (name.isEmpty) {
      state = state.copyWith(
        status: GoalsStatus.error,
        errorMessage: 'Goal name is required',
      );
      return null;
    }

    if (targetSteps <= 0) {
      state = state.copyWith(
        status: GoalsStatus.error,
        errorMessage: 'Target steps must be positive',
      );
      return null;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final goal = await _createGoalUseCase(CreateGoalParams(
        name: name,
        description: description,
        targetSteps: targetSteps,
        startDate: startDate,
        endDate: endDate,
        type: type,
      ));

      // Refresh the goals list
      await loadUserGoals();

      return goal;
    } catch (e) {
      state = state.copyWith(
        status: GoalsStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
      return null;
    }
  }

  /// Invites a user to a group goal.
  ///
  /// [goalId] The goal to invite the user to.
  /// [email] Email address of the user to invite.
  ///
  /// Returns true if invitation was sent successfully.
  Future<bool> inviteUser(String goalId, String email) async {
    if (email.isEmpty) {
      state = state.copyWith(
        status: GoalsStatus.error,
        errorMessage: 'Email is required',
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final success = await _inviteUserUseCase(
        goalId: goalId,
        email: email,
      );

      state = state.copyWith(
        isLoading: false,
      );

      return success;
    } catch (e) {
      state = state.copyWith(
        status: GoalsStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
      return false;
    }
  }

  /// Joins a group goal using an invite code.
  ///
  /// [inviteCode] The invitation code for the goal.
  ///
  /// Returns the joined [Goal] on success, null on failure.
  /// After joining, automatically refreshes the goals list.
  Future<Goal?> joinGoal(String inviteCode) async {
    if (inviteCode.isEmpty) {
      state = state.copyWith(
        status: GoalsStatus.error,
        errorMessage: 'Invite code is required',
      );
      return null;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final goal = await _joinGoalUseCase(inviteCode);

      // Refresh the goals list
      await loadUserGoals();

      return goal;
    } catch (e) {
      state = state.copyWith(
        status: GoalsStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
      return null;
    }
  }

  /// Refreshes all goals data.
  ///
  /// Use this when:
  /// - App comes to foreground
  /// - User pulls to refresh
  /// - After a period of inactivity
  Future<void> refresh() async {
    await loadUserGoals();
  }

  /// Clears any error in the current state.
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(clearError: true);
    }
  }

  /// Clears the selected goal and progress.
  void clearSelectedGoal() {
    state = state.copyWith(
      clearSelectedGoal: true,
      clearProgress: true,
    );
  }

  /// Resets state to initial.
  ///
  /// Use when user logs out or switches accounts.
  void reset() {
    state = const GoalsState.initial();
  }

  /// Formats error for display.
  String _formatError(Object error) {
    final message = error.toString();

    // Clean up common error prefixes
    if (message.startsWith('Exception:')) {
      return message.substring(10).trim();
    }

    return message;
  }
}

/// Provider for the goals repository.
///
/// This provider requires an actual [GoalsRepository] implementation
/// to be provided. In production, override this with the actual repository.
///
/// Override in main.dart or test:
/// ```dart
/// ProviderScope(
///   overrides: [
///     goalsRepositoryProvider.overrideWithValue(repository),
///   ],
///   child: MyApp(),
/// )
/// ```
final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  throw UnimplementedError(
    'goalsRepositoryProvider must be overridden with actual implementation',
  );
});

/// Provider for the goals notifier.
///
/// Usage:
/// ```dart
/// // Watch goals state
/// final goalsState = ref.watch(goalsProvider);
///
/// // Access notifier methods
/// ref.read(goalsProvider.notifier).loadUserGoals();
///
/// // Check if has goals
/// if (goalsState.hasData) {
///   showGoalsList();
/// }
/// ```
final goalsProvider = StateNotifierProvider<GoalsNotifier, GoalsState>((ref) {
  final repository = ref.watch(goalsRepositoryProvider);

  return GoalsNotifier(
    getUserGoalsUseCase: GetUserGoalsUseCase(repository: repository),
    getGoalDetailsUseCase: GetGoalDetailsUseCase(repository: repository),
    createGoalUseCase: CreateGoalUseCase(repository: repository),
    inviteUserUseCase: InviteUserUseCase(repository: repository),
    joinGoalUseCase: JoinGoalUseCase(repository: repository),
  );
});
