import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

/// Model representing detailed friend information.
///
/// This is a temporary model until the domain layer is available.
class _FriendDetail {
  const _FriendDetail({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.todaySteps = 0,
    this.weeklyAverage = 0,
    this.streak = 0,
  });

  final String id;
  final String username;
  final String? avatarUrl;
  final int todaySteps;
  final int weeklyAverage;
  final int streak;
}

/// A page displaying detailed information about a friend.
///
/// Features:
/// - Receives friendId from route parameters
/// - AppBar with back button
/// - Large AppAvatar at top
/// - Username and stats display (today's steps, weekly average, streak)
/// - 'Remove Friend' button with confirmation dialog
class FriendDetailPage extends StatefulWidget {
  /// Creates a [FriendDetailPage] widget.
  const FriendDetailPage({
    super.key,
    required this.friendId,
  });

  /// The unique identifier of the friend to display.
  final String friendId;

  @override
  State<FriendDetailPage> createState() => _FriendDetailPageState();
}

class _FriendDetailPageState extends State<FriendDetailPage> {
  bool _isLoading = true;
  _FriendDetail? _friend;
  bool _isRemoving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFriendDetail();
  }

  Future<void> _loadFriendDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual SharingProvider call when available
      // final provider = context.read<SharingProvider>();
      // _friend = await provider.getFriendDetail(widget.friendId);

      // Simulated loading delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Default friend data - will be populated by SharingProvider
      setState(() {
        _friend = _FriendDetail(
          id: widget.friendId,
          username: 'Loading...',
          todaySteps: 0,
          weeklyAverage: 0,
          streak: 0,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load friend details.';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFriend() async {
    final confirmed = await _showRemoveConfirmation();
    if (!confirmed) return;

    setState(() {
      _isRemoving = true;
    });

    try {
      // TODO: Replace with actual SharingProvider call when available
      // final provider = context.read<SharingProvider>();
      // await provider.removeFriend(widget.friendId);

      // Simulated action
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Friend removed'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _isRemoving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove friend: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<bool> _showRemoveConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text(
          'Are you sure you want to remove ${_friend?.username ?? 'this friend'}? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Extracts initials from the username.
  String _getInitials() {
    final username = _friend?.username ?? '';
    if (username.isEmpty) return '?';
    final parts = username.split(RegExp(r'[\s_.-]'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username.substring(0, username.length >= 2 ? 2 : 1).toUpperCase();
  }

  /// Formats number with thousands separator.
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_friend?.username ?? 'Friend'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildError(theme, colorScheme)
              : _buildContent(theme, colorScheme),
    );
  }

  Widget _buildError(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Retry',
              onPressed: _loadFriendDetail,
              variant: AppButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colorScheme) {
    final friend = _friend!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Large avatar
          AppAvatar(
            imageUrl: friend.avatarUrl,
            initials: _getInitials(),
            size: AppAvatarSize.xlarge,
          ),
          const SizedBox(height: 16),
          // Username
          Text(
            friend.username,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Stats cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.directions_walk,
                  label: "Today's Steps",
                  value: _formatNumber(friend.todaySteps),
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_today,
                  label: 'Weekly Average',
                  value: _formatNumber(friend.weeklyAverage),
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '${friend.streak} days',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          // Remove friend button
          AppButton(
            label: 'Remove Friend',
            onPressed: _removeFriend,
            isLoading: _isRemoving,
            variant: AppButtonVariant.outline,
            icon: Icons.person_remove,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

/// A card displaying a single statistic.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
