/// Friend activity page for displaying a friend's step statistics.
///
/// This page shows detailed step statistics for a specific friend,
/// including their activity over different time periods.
library;

import 'package:app_pasos_frontend/core/di/injection_container.dart';
import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/friend_stats.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/shared_user.dart';
import 'package:app_pasos_frontend/features/sharing/domain/usecases/get_friend_stats_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/widgets/friend_stats_card.dart';
import 'package:app_pasos_frontend/shared/widgets/error_widget.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';

/// Friend activity page displaying a friend's step statistics.
///
/// Uses [GetFriendStatsUseCase] to fetch real data from the API.
/// Supports pull-to-refresh and proper loading/error states.
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: RouteNames.friendActivity,
///   builder: (context, state) {
///     final friendId = state.uri.queryParameters['friendId'] ?? '';
///     return FriendActivityPage(friendId: friendId);
///   },
/// )
/// ```
class FriendActivityPage extends StatefulWidget {
  /// Creates a [FriendActivityPage].
  ///
  /// [friendId] is the ID of the friend whose activity to display.
  const FriendActivityPage({
    required this.friendId,
    super.key,
  });

  /// The ID of the friend whose activity to display.
  final String friendId;

  @override
  State<FriendActivityPage> createState() => _FriendActivityPageState();
}

/// State for [FriendActivityPage].
///
/// Manages loading state, error handling, and data fetching
/// using the [GetFriendStatsUseCase].
class _FriendActivityPageState extends State<FriendActivityPage> {
  /// The use case for fetching friend stats from the repository.
  late final GetFriendStatsUseCase _getFriendStatsUseCase;

  /// Current loading state.
  bool _isLoading = true;

  /// Whether an error occurred.
  bool _hasError = false;

  /// Error message to display.
  String _errorMessage = '';

  /// The fetched friend stats.
  FriendStats? _stats;

  /// The friend's user data derived from stats.
  SharedUser? _friend;

  @override
  void initState() {
    super.initState();
    _getFriendStatsUseCase = sl<GetFriendStatsUseCase>();
    _loadFriendData();
  }

  /// Loads friend data using the [GetFriendStatsUseCase].
  ///
  /// Fetches real data from the API and updates the UI state accordingly.
  Future<void> _loadFriendData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Fetch real stats using the use case
      final stats = await _getFriendStatsUseCase(friendId: widget.friendId);

      if (!mounted) return;

      setState(() {
        _stats = stats;
        // Create user representation from the stats
        _friend = SharedUser(
          id: stats.userId,
          name: 'Friend',
          email: '',
        );
        _isLoading = false;
      });
    } on NetworkException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.isNoConnection
            ? 'No internet connection. Please check your network.'
            : e.isTimeout
                ? 'Connection timed out. Please try again.'
                : 'Network error: ${e.message}';
      });
    } on ServerException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.statusCode == 404
            ? 'Friend not found.'
            : e.statusCode == 500
                ? 'Server error. Please try again later.'
                : 'Error: ${e.message}';
      });
    } on UnauthorizedException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.isTokenExpired
            ? 'Your session has expired. Please log in again.'
            : 'Unauthorized: ${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load friend activity: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_friend?.name ?? 'Friend Activity'),
        centerTitle: true,
      ),
      body: _buildBody(context, theme, colorScheme),
    );
  }

  /// Builds the main body content based on current state.
  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (_isLoading) {
      return const LoadingIndicator(
        message: 'Loading friend activity...',
      );
    }

    if (_hasError) {
      return AppErrorWidget(
        message: _errorMessage,
        onRetry: _loadFriendData,
      );
    }

    if (_friend == null || _stats == null) {
      return const AppErrorWidget(
        message: 'Friend data not available',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriendData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Friend stats card with real data
          FriendStatsCard(
            friend: _friend!,
            stats: _stats!,
          ),
          const SizedBox(height: 24),

          // Activity summary section
          _buildActivitySummary(context, theme, colorScheme),
        ],
      ),
    );
  }

  /// Builds the activity summary section.
  ///
  /// Displays a summary of the friend's step activity with real data.
  Widget _buildActivitySummary(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Activity Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Step breakdown
            _buildStepRow(
              context,
              'Today',
              _stats!.todaySteps,
              Icons.today,
              colorScheme.primary,
            ),
            const Divider(height: 24),
            _buildStepRow(
              context,
              'This Week',
              _stats!.weekSteps,
              Icons.date_range,
              colorScheme.secondary,
            ),
            const Divider(height: 24),
            _buildStepRow(
              context,
              'This Month',
              _stats!.monthSteps,
              Icons.calendar_month,
              colorScheme.tertiary,
            ),
            const Divider(height: 24),
            _buildStepRow(
              context,
              'All Time',
              _stats!.allTimeSteps,
              Icons.timeline,
              colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a row displaying step count with icon and label.
  Widget _buildStepRow(
    BuildContext context,
    String label,
    int steps,
    IconData icon,
    Color iconColor,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          _formatSteps(steps),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Formats step count with thousand separators.
  String _formatSteps(int steps) {
    if (steps >= 1000000) {
      return '${(steps / 1000000).toStringAsFixed(1)}M';
    } else if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}K';
    }
    return steps.toString();
  }
}
