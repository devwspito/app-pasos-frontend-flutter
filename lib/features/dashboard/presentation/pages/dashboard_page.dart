/// Dashboard page for displaying step tracking overview.
///
/// This page is the main entry point for the dashboard feature, showing
/// the user's step progress, statistics, and activity data.
library;

import 'package:app_pasos_frontend/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:app_pasos_frontend/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:app_pasos_frontend/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:app_pasos_frontend/features/dashboard/presentation/widgets/stats_overview_card.dart';
import 'package:app_pasos_frontend/features/dashboard/presentation/widgets/step_counter_card.dart';
import 'package:app_pasos_frontend/shared/widgets/error_widget.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Dashboard page displaying step tracking overview and statistics.
///
/// Features:
/// - Pull-to-refresh functionality
/// - Circular progress indicator for today's steps
/// - Statistics overview (Today, Week, Month, All-Time)
/// - Loading and error states with retry functionality
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: RouteNames.dashboard,
///   builder: (context, state) => BlocProvider(
///     create: (context) => DashboardBloc(...)
///       ..add(const DashboardLoadRequested()),
///     child: const DashboardPage(),
///   ),
/// )
/// ```
class DashboardPage extends StatelessWidget {
  /// Creates a [DashboardPage].
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return switch (state) {
            DashboardInitial() => _buildInitialState(context),
            DashboardLoading() => const LoadingIndicator(
                message: 'Loading your steps...',
              ),
            DashboardLoaded() => _buildLoadedState(context, state),
            DashboardError(:final message) => AppErrorWidget(
                message: message,
                onRetry: () => _onRefresh(context),
              ),
          };
        },
      ),
    );
  }

  /// Builds the initial state UI.
  ///
  /// Shows a loading indicator and triggers data load.
  Widget _buildInitialState(BuildContext context) {
    // Trigger initial load when in initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(const DashboardLoadRequested());
    });

    return const LoadingIndicator(
      message: 'Initializing...',
    );
  }

  /// Builds the loaded state UI with step data.
  Widget _buildLoadedState(BuildContext context, DashboardLoaded state) {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(context),
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Step counter card (prominent at top)
          StepCounterCard(
            currentSteps: state.todaySteps,
            goal: state.goal,
          ),
          const SizedBox(height: 16),

          // Stats overview card
          StatsOverviewCard(
            stats: state.stats,
          ),
          const SizedBox(height: 16),

          // Placeholder for Weekly Trend Chart (added in story-5)
          _buildPlaceholderSection(
            context: context,
            title: 'Weekly Trend',
            icon: Icons.show_chart,
          ),
          const SizedBox(height: 16),

          // Placeholder for Activity List (added in story-6)
          _buildPlaceholderSection(
            context: context,
            title: 'Recent Activity',
            icon: Icons.history,
          ),
        ],
      ),
    );
  }

  /// Builds a placeholder section for future features.
  ///
  /// These sections will be replaced with actual widgets in later stories.
  Widget _buildPlaceholderSection({
    required BuildContext context,
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Coming in a future update',
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

  /// Handles refresh action by dispatching a refresh event.
  void _onRefresh(BuildContext context) {
    context.read<DashboardBloc>().add(const DashboardRefreshRequested());
  }
}
