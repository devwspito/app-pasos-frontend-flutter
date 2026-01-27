/// Friend activity page for displaying a friend's step statistics.
///
/// This page shows detailed step statistics for a specific friend,
/// including their activity over different time periods.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/friend_stats.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/shared_user.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/widgets/friend_stats_card.dart';
import 'package:app_pasos_frontend/shared/widgets/error_widget.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';

/// Friend activity page displaying a friend's step statistics.
///
/// Features:
/// - Friend stats card with step data
/// - Pull-to-refresh functionality
/// - Activity feed placeholder for future expansion
/// - Loading and error states
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

class _FriendActivityPageState extends State<FriendActivityPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  FriendStats? _stats;
  SharedUser? _friend;

  @override
  void initState() {
    super.initState();
    _loadFriendData();
  }

  /// Loads friend data from the repository.
  ///
  /// In production, this would use a BLoC or fetch from repository.
  Future<void> _loadFriendData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulate loading friend data
      // In production, this would call the GetFriendStatsUseCase
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Create placeholder data
      // In production, this comes from the API
      setState(() {
        _friend = SharedUser(
          id: widget.friendId,
          name: 'Friend ${widget.friendId.length > 4 ? widget.friendId.substring(0, 4) : widget.friendId}',
          email: 'friend@example.com',
        );
        _stats = FriendStats(
          userId: widget.friendId,
          todaySteps: 5234,
          weekSteps: 38500,
          monthSteps: 165000,
          allTimeSteps: 1250000,
        );
        _isLoading = false;
      });
    } catch (e) {
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
          // Friend stats card
          FriendStatsCard(
            friend: _friend!,
            stats: _stats!,
          ),
          const SizedBox(height: 24),

          // Activity feed section header
          Row(
            children: [
              Icon(
                Icons.history,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Recent Activity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Activity feed placeholder
          _buildActivityFeedPlaceholder(context, colorScheme),
        ],
      ),
    );
  }

  /// Builds a placeholder for the activity feed.
  ///
  /// This will be replaced with actual activity data in a future story.
  Widget _buildActivityFeedPlaceholder(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timeline,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Activity Feed',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Detailed activity history will be available soon.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
