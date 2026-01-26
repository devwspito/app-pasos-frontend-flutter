import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';

// TODO: Import from goals_provider.dart when Epic 5 is completed
// import '../providers/goals_provider.dart';

// TODO: Import from goal.dart entity when Epic 2 is completed
// import '../../domain/entities/goal.dart';

// TODO: Import from goal_card.dart widget when Epic 6 is completed
// import '../widgets/goal_card.dart';

/// Status enum for goals loading state.
/// TODO: Will be replaced with import from goals_provider.dart
enum GoalsStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Goal entity stub for the goals list page.
/// TODO: Will be replaced with import from lib/features/goals/domain/entities/goal.dart
class Goal {
  final String id;
  final String name;
  final String? description;
  final int targetSteps;
  final DateTime startDate;
  final DateTime endDate;
  final String creatorId;
  final String creatorUsername;
  final String status;
  final int memberCount;
  final DateTime createdAt;

  const Goal({
    required this.id,
    required this.name,
    this.description,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
    required this.creatorId,
    required this.creatorUsername,
    required this.status,
    required this.memberCount,
    required this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isExpired => DateTime.now().isAfter(endDate);
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  double progressPercent(int currentSteps) {
    if (targetSteps <= 0) return 0.0;
    return (currentSteps / targetSteps).clamp(0.0, 1.0);
  }
}

/// GoalsProvider stub for managing goals state.
/// TODO: Will be replaced with import from lib/features/goals/presentation/providers/goals_provider.dart
class GoalsProvider extends ChangeNotifier {
  GoalsStatus _status = GoalsStatus.initial;
  List<Goal> _goals = [];
  String? _errorMessage;

  GoalsStatus get status => _status;
  List<Goal> get goals => List.unmodifiable(_goals);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == GoalsStatus.loading;
  bool get hasGoals => _goals.isNotEmpty;

  /// Loads the user's goals from the backend.
  Future<void> loadUserGoals() async {
    _status = GoalsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call via use case
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulated data for now - will be replaced with real data
      _goals = [];
      _status = GoalsStatus.loaded;
    } catch (e) {
      _status = GoalsStatus.error;
      _errorMessage = 'Failed to load goals. Please try again.';
    }
    notifyListeners();
  }

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

/// Filter tabs for the goals list.
enum GoalFilter {
  all,
  active,
  completed,
}

/// Page displaying a list of the user's goals with filter tabs.
///
/// Features:
/// - Filter tabs: All, Active, Completed
/// - Pull-to-refresh support
/// - FAB to create new goal
/// - Empty state when no goals
/// - Loading and error states
class GoalsListPage extends StatefulWidget {
  const GoalsListPage({super.key});

  @override
  State<GoalsListPage> createState() => _GoalsListPageState();
}

class _GoalsListPageState extends State<GoalsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late GoalsProvider _goalsProvider;
  GoalFilter _currentFilter = GoalFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _goalsProvider = GoalsProvider();
    _loadGoals();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _goalsProvider.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentFilter = GoalFilter.values[_tabController.index];
    });
  }

  Future<void> _loadGoals() async {
    await _goalsProvider.loadUserGoals();
    if (mounted) setState(() {});
  }

  Future<void> _onRefresh() async {
    await _goalsProvider.loadUserGoals();
    if (mounted) setState(() {});
  }

  List<Goal> get _filteredGoals {
    switch (_currentFilter) {
      case GoalFilter.all:
        return _goalsProvider.goals;
      case GoalFilter.active:
        return _goalsProvider.goals.where((g) => g.isActive).toList();
      case GoalFilter.completed:
        return _goalsProvider.goals.where((g) => g.isCompleted).toList();
    }
  }

  void _navigateToCreateGoal() {
    context.go('/goals/create');
  }

  void _navigateToGoalDetail(String goalId) {
    context.go('/goals/$goalId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateGoal,
            tooltip: 'Create Goal',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateGoal,
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }

  Widget _buildBody() {
    if (_goalsProvider.status == GoalsStatus.loading &&
        !_goalsProvider.hasGoals) {
      return const AppLoading(message: 'Loading goals...');
    }

    if (_goalsProvider.status == GoalsStatus.error) {
      return _buildErrorState();
    }

    if (!_goalsProvider.hasGoals) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _buildGoalsList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _goalsProvider.errorMessage ?? 'An error occurred',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _loadGoals,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String title;

    switch (_currentFilter) {
      case GoalFilter.all:
        title = 'No Goals Yet';
        message = 'Create your first goal and start tracking your progress!';
        break;
      case GoalFilter.active:
        title = 'No Active Goals';
        message = 'All your goals are completed or there are none yet.';
        break;
      case GoalFilter.completed:
        title = 'No Completed Goals';
        message = 'Keep working on your active goals!';
        break;
    }

    return AppEmptyState(
      icon: Icons.flag_outlined,
      title: title,
      message: message,
      actionLabel: 'Create Goal',
      onAction: _navigateToCreateGoal,
    );
  }

  Widget _buildGoalsList() {
    final filteredGoals = _filteredGoals;

    if (filteredGoals.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: filteredGoals.length,
      itemBuilder: (context, index) {
        final goal = filteredGoals[index];
        return _GoalCardWidget(
          goal: goal,
          onTap: () => _navigateToGoalDetail(goal.id),
        );
      },
    );
  }
}

/// Goal card widget displaying goal information.
/// TODO: Will be replaced with GoalCard from lib/features/goals/presentation/widgets/goal_card.dart
class _GoalCardWidget extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const _GoalCardWidget({
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusBadge(context),
            ],
          ),
          if (goal.description != null && goal.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              goal.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildInfoChip(
                context,
                Icons.directions_walk,
                '${goal.targetSteps} steps/day',
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildInfoChip(
                context,
                Icons.people_outline,
                '${goal.memberCount} members',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                goal.isActive
                    ? '${goal.daysRemaining} days remaining'
                    : goal.isCompleted
                        ? 'Completed'
                        : 'Expired',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    String label;

    if (goal.isActive) {
      backgroundColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
      label = 'Active';
    } else if (goal.isCompleted) {
      backgroundColor = colorScheme.tertiaryContainer;
      textColor = colorScheme.onTertiaryContainer;
      label = 'Completed';
    } else {
      backgroundColor = colorScheme.errorContainer;
      textColor = colorScheme.onErrorContainer;
      label = 'Expired';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
