import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_loading.dart';
import '../widgets/step_counter_card.dart';

// TODO: StepsProvider will be created by another story. Once available, replace
// the local state management with Provider.of<StepsProvider>(context) or
// context.watch<StepsProvider>().
// import 'package:provider/provider.dart';
// import '../providers/steps_provider.dart';

/// The main dashboard page displaying the user's step tracking information.
///
/// This page shows:
/// - Today's step count with progress towards the daily goal
/// - Pull-to-refresh functionality to update data
/// - Loading state while fetching data
///
/// The dashboard uses local state management until StepsProvider is available.
/// Once StepsProvider is implemented, replace the local state with:
/// ```dart
/// Consumer<StepsProvider>(
///   builder: (context, provider, _) {
///     // ... use provider.isLoading, provider.todayStepCount, etc.
///   },
/// )
/// ```
class DashboardPage extends StatefulWidget {
  /// Creates a [DashboardPage] widget.
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  /// Whether data is currently being loaded.
  bool _isLoading = true;

  /// Whether initial data has been loaded.
  bool _hasLoadedInitialData = false;

  /// Today's step count.
  int _todayStepCount = 0;

  /// The daily step goal.
  int _goalSteps = 10000;

  /// Error message if data loading fails.
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Load data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  /// Loads the dashboard data.
  ///
  /// TODO: Replace with context.read<StepsProvider>().loadDashboardData()
  /// when StepsProvider is available.
  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate network delay for loading state demonstration
      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // TODO: Replace with actual data from StepsProvider
      // For now, use simulated data to demonstrate UI functionality
      setState(() {
        _todayStepCount = 5420;
        _goalSteps = 10000;
        _isLoading = false;
        _hasLoadedInitialData = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load step data. Please try again.';
      });
    }
  }

  /// Refreshes the dashboard data.
  ///
  /// TODO: Replace with context.read<StepsProvider>().refreshData()
  /// when StepsProvider is available.
  Future<void> _refreshData() async {
    if (!mounted) return;

    try {
      // Simulate refresh delay
      await Future<void>.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      // Simulate getting new step data (slightly different each refresh)
      setState(() {
        // Add some random variation to simulate real data updates
        _todayStepCount = _todayStepCount + 100 + (DateTime.now().millisecond % 200);
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to refresh data. Please try again.';
      });
    }
  }

  /// Calculates the progress towards the daily goal.
  double get _goalProgress {
    if (_goalSteps <= 0) return 0.0;
    return (_todayStepCount / _goalSteps).clamp(0.0, 1.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showSettingsHint,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Builds the body content based on loading and error states.
  Widget _buildBody() {
    // Show loading indicator for initial load
    if (_isLoading && !_hasLoadedInitialData) {
      return const AppLoading(message: 'Loading steps...');
    }

    // Show error state if there's an error and no data
    if (_errorMessage != null && !_hasLoadedInitialData) {
      return _buildErrorState();
    }

    // Show main content with pull-to-refresh
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.paddingPage),
        children: [
          // Step Counter Card
          StepCounterCard(
            stepCount: _todayStepCount,
            goalSteps: _goalSteps,
            goalProgress: _goalProgress,
          ),

          SizedBox(height: AppSpacing.gapLarge),

          // Placeholder section for activity history (will be added in next stories)
          _buildUpcomingFeatureHint(
            icon: Icons.history,
            title: 'Activity History',
            description: 'Your activity history will appear here',
          ),

          SizedBox(height: AppSpacing.md),

          // Placeholder section for weekly chart (will be added in next stories)
          _buildUpcomingFeatureHint(
            icon: Icons.bar_chart,
            title: 'Weekly Stats',
            description: 'Weekly step statistics will appear here',
          ),

          // Show error banner if refresh failed but we have existing data
          if (_errorMessage != null && _hasLoadedInitialData)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: _buildErrorBanner(),
            ),

          // Bottom padding for scroll
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// Builds the error state widget for when no data could be loaded.
  Widget _buildErrorState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.paddingPage),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Unable to Load Data',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage ?? 'An unknown error occurred.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an error banner for when refresh fails but existing data is available.
  Widget _buildErrorBanner() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
              _errorMessage ?? 'Refresh failed',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: _refreshData,
            child: Text(
              'Retry',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a placeholder hint for upcoming features.
  Widget _buildUpcomingFeatureHint({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSpacing.iconLg,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a hint about settings functionality.
  void _showSettingsHint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings will be available in a future update.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
