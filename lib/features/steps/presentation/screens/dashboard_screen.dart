import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/steps_provider.dart';
import '../providers/steps_state.dart';
import '../widgets/step_counter_card.dart';
import '../widgets/stats_summary_card.dart';

/// Main dashboard screen displaying step tracking information.
///
/// Shows step counter with circular progress and statistics summary.
/// Supports pull-to-refresh and automatically loads data on init.
///
/// Uses Riverpod for state management with [stepsProvider].
///
/// Example usage:
/// ```dart
/// MaterialApp(
///   home: DashboardScreen(),
/// )
/// ```
class DashboardScreen extends ConsumerStatefulWidget {
  /// Creates a DashboardScreen.
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load today's stats when the screen initializes
    // Using addPostFrameCallback to ensure the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stepsProvider.notifier).loadTodayStats();
    });
  }

  /// Handles pull-to-refresh action.
  Future<void> _onRefresh() async {
    await ref.read(stepsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final stepsState = ref.watch(stepsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Refresh indicator in app bar when refreshing
          if (stepsState.isRefreshing)
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _buildBody(stepsState),
    );
  }

  /// Builds the body based on current state.
  Widget _buildBody(StepsState state) {
    // Handle initial loading state
    if (state.isInitialLoading) {
      return const LoadingIndicator(
        size: LoadingIndicatorSize.large,
        message: 'Loading your steps...',
      );
    }

    // Handle error state with no data
    if (state.status == StepsStatus.error && !state.hasData) {
      return AppErrorWidget(
        title: 'Unable to Load Data',
        message: state.errorMessage ?? 'An unexpected error occurred.',
        onRetry: _onRefresh,
      );
    }

    // Build main content with pull-to-refresh
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _buildContent(state),
    );
  }

  /// Builds the main scrollable content.
  Widget _buildContent(StepsState state) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Error banner (if error but has data)
          if (state.hasError && state.hasData)
            _buildErrorBanner(state.errorMessage),

          // Step counter card
          StepCounterCard(
            currentSteps: state.currentSteps,
            goalSteps: state.goalSteps,
          ),

          SizedBox(height: AppSpacing.md),

          // Stats summary card
          StatsSummaryCard(
            weeklyAverage: state.todayStats?.weeklyAverage ?? 0,
            stepsRemaining: state.todayStats?.stepsRemaining ?? state.goalSteps,
            isGoalAchieved: state.isGoalAchieved,
          ),

          SizedBox(height: AppSpacing.md),

          // Last updated timestamp
          if (state.lastUpdated != null)
            _buildLastUpdated(state.lastUpdated!),

          // Bottom padding for safe area
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// Builds an error banner for showing errors while displaying cached data.
  Widget _buildErrorBanner(String? message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.onErrorContainer,
            size: AppSpacing.iconMd,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message ?? 'Failed to refresh data. Showing cached data.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: colorScheme.onErrorContainer,
              size: AppSpacing.iconSm,
            ),
            onPressed: _onRefresh,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Builds the last updated timestamp display.
  Widget _buildLastUpdated(DateTime lastUpdated) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    String timeAgo;
    if (difference.inMinutes < 1) {
      timeAgo = 'Just now';
    } else if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      timeAgo = '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      timeAgo = '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }

    return Center(
      child: Text(
        'Updated $timeAgo',
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
