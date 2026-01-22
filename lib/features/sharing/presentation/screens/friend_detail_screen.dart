import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../widgets/friend_list_item.dart';
import '../widgets/stats_comparison_widget.dart';

/// Screen displaying detailed information about a friend.
///
/// Features:
/// - Friend info card (name, email, status)
/// - Stats comparison widget
/// - Permission toggles for sharing settings
/// - Remove friend action with confirmation
///
/// Example usage:
/// ```dart
/// GoRoute(
///   path: '/friends/:friendId',
///   builder: (context, state) {
///     final friendId = state.pathParameters['friendId']!;
///     return FriendDetailScreen(friendId: friendId);
///   },
/// )
/// ```
class FriendDetailScreen extends ConsumerStatefulWidget {
  /// Creates a [FriendDetailScreen].
  const FriendDetailScreen({
    required this.friendId,
    super.key,
  });

  /// The ID of the friend to display.
  final String friendId;

  @override
  ConsumerState<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends ConsumerState<FriendDetailScreen> {
  bool _isLoading = false;
  bool _isRemoving = false;

  // Permission toggles
  bool _canViewSteps = true;
  bool _canViewGoals = true;
  bool _canViewStats = false;

  // Mock friend data - will be replaced with provider data
  late FriendData _friend;
  late UserStats _myStats;
  late UserStats _friendStats;

  @override
  void initState() {
    super.initState();
    _loadFriendData();
  }

  void _loadFriendData() {
    // TODO: Load from provider
    // final sharingState = ref.read(sharingProvider);
    // _friend = sharingState.getFriend(widget.friendId);

    // Mock data
    _friend = const FriendData(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      todaySteps: 7500,
      status: FriendStatus.active,
    );

    _myStats = const UserStats(
      todaySteps: 5000,
      goalProgress: 50,
      weeklyAverage: 6200,
    );

    _friendStats = const UserStats(
      todaySteps: 7500,
      goalProgress: 75,
      weeklyAverage: 8100,
    );
  }

  Future<void> _handleRemoveFriend() async {
    final confirmed = await _showRemoveConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isRemoving = true;
    });

    try {
      // TODO: Call provider to remove friend
      // await ref.read(sharingProvider.notifier).removeFriend(widget.friendId);

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_friend.name} removed from friends')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove friend: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRemoving = false;
        });
      }
    }
  }

  Future<bool> _showRemoveConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text(
          'Are you sure you want to remove ${_friend.name} from your friends? '
          'This will also remove any shared data between you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _handlePermissionChanged(String permission, bool value) {
    setState(() {
      switch (permission) {
        case 'steps':
          _canViewSteps = value;
        case 'goals':
          _canViewGoals = value;
        case 'stats':
          _canViewStats = value;
      }
    });

    // TODO: Update permissions via provider
    // ref.read(sharingProvider.notifier).updatePermissions(
    //   widget.friendId,
    //   FriendPermissions(
    //     canViewSteps: _canViewSteps,
    //     canViewGoals: _canViewGoals,
    //     canViewStats: _canViewStats,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // TODO: Watch sharing provider
    // final sharingState = ref.watch(sharingProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const LoadingIndicator(
          message: 'Loading friend details...',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_friend.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_remove_rounded,
              color: colorScheme.error,
            ),
            onPressed: _isRemoving ? null : _handleRemoveFriend,
            tooltip: 'Remove Friend',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.allMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Friend info card
            _buildFriendInfoCard(colorScheme, textTheme),
            SizedBox(height: AppSpacing.lg),

            // Stats comparison
            StatsComparisonWidget(
              myStats: _myStats,
              friendStats: _friendStats,
              friendName: _friend.name.split(' ').first,
            ),
            SizedBox(height: AppSpacing.lg),

            // Permission toggles
            _buildPermissionsCard(colorScheme, textTheme),
            SizedBox(height: AppSpacing.xl),

            // Remove friend button
            _buildRemoveFriendButton(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendInfoCard(ColorScheme colorScheme, TextTheme textTheme) {
    return AppCard(
      elevation: AppCardElevation.low,
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              _getInitials(_friend.name),
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _friend.name,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  _friend.email,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                _buildStatusChip(colorScheme, textTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ColorScheme colorScheme, TextTheme textTheme) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (_friend.status) {
      case FriendStatus.active:
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        label = 'Active';
        icon = Icons.check_circle_outline_rounded;
      case FriendStatus.inactive:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurfaceVariant;
        label = 'Inactive';
        icon = Icons.access_time_rounded;
      case FriendStatus.blocked:
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        label = 'Blocked';
        icon = Icons.block_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppSpacing.borderRadiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsCard(ColorScheme colorScheme, TextTheme textTheme) {
    return AppCard(
      elevation: AppCardElevation.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sharing Permissions',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Control what ${_friend.name.split(' ').first} can see about you',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Permission toggles
          _buildPermissionToggle(
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: Icons.directions_walk_rounded,
            title: 'View Steps',
            subtitle: 'Can see your daily step count',
            value: _canViewSteps,
            onChanged: (v) => _handlePermissionChanged('steps', v),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          _buildPermissionToggle(
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: Icons.flag_rounded,
            title: 'View Goals',
            subtitle: 'Can see your goal progress',
            value: _canViewGoals,
            onChanged: (v) => _handlePermissionChanged('goals', v),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          _buildPermissionToggle(
            colorScheme: colorScheme,
            textTheme: textTheme,
            icon: Icons.bar_chart_rounded,
            title: 'View Stats',
            subtitle: 'Can see your weekly statistics',
            value: _canViewStats,
            onChanged: (v) => _handlePermissionChanged('stats', v),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionToggle({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: AppSpacing.allSm,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(
              icon,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveFriendButton(ColorScheme colorScheme) {
    return AppButton(
      label: 'Remove Friend',
      onPressed: _handleRemoveFriend,
      variant: AppButtonVariant.secondary,
      fullWidth: true,
      icon: Icons.person_remove_rounded,
      isLoading: _isRemoving,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
