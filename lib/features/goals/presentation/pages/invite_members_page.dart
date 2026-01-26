import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_text_field.dart';

// TODO: Import from goals_provider.dart when Epic 5 is completed
// import '../providers/goals_provider.dart';

// TODO: Import from goal_membership.dart entity when Epic 2 is completed
// import '../../domain/entities/goal_membership.dart';

/// User search result entity for inviting members.
/// TODO: Will be replaced with import from sharing feature or dedicated entity
class UserSearchResult {
  final String id;
  final String username;
  final String? email;
  final String? profileImageUrl;
  final bool hasRelationship;
  final String? relationshipStatus;

  const UserSearchResult({
    required this.id,
    required this.username,
    this.email,
    this.profileImageUrl,
    this.hasRelationship = false,
    this.relationshipStatus,
  });

  String get initials {
    if (username.isEmpty) return '??';
    if (username.length == 1) return username.toUpperCase();
    return username.substring(0, 2).toUpperCase();
  }
}

/// Pending invite entity for displaying sent invitations.
/// TODO: Will be replaced with GoalMembership from lib/features/goals/domain/entities/goal_membership.dart
class PendingInvite {
  final String id;
  final String goalId;
  final String userId;
  final String username;
  final String? profileImageUrl;
  final String status;
  final DateTime? createdAt;

  const PendingInvite({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.status,
    this.createdAt,
  });

  bool get isPending => status == 'pending';

  String get initials {
    if (username.isEmpty) return '??';
    if (username.length == 1) return username.toUpperCase();
    return username.substring(0, 2).toUpperCase();
  }
}

/// Page for inviting members to a goal.
///
/// Features:
/// - Search field to find users
/// - Search results list with invite button
/// - Pending invites list
/// - Loading and error states
class InviteMembersPage extends StatefulWidget {
  final String goalId;

  const InviteMembersPage({
    super.key,
    required this.goalId,
  });

  @override
  State<InviteMembersPage> createState() => _InviteMembersPageState();
}

class _InviteMembersPageState extends State<InviteMembersPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  bool _isSearching = false;
  bool _isInviting = false;
  List<UserSearchResult> _searchResults = [];
  List<PendingInvite> _pendingInvites = [];
  String? _errorMessage;
  Set<String> _invitedUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadPendingInvites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPendingInvites() async {
    try {
      // TODO: Replace with actual API call via GoalsProvider
      // final goalsProvider = context.read<GoalsProvider>();
      // _pendingInvites = await goalsProvider.getPendingInvites(widget.goalId);

      // Simulated data - will be replaced with real data
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _pendingInvites = [];
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load pending invites';
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual API call via GoalsProvider or SharingProvider
      // final results = await goalsProvider.searchUsers(query);

      // Simulated search - will be replaced with real API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate no results for demo
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = 'Search failed. Please try again.';
      });
    }
  }

  Future<void> _inviteUser(UserSearchResult user) async {
    if (_invitedUserIds.contains(user.id)) {
      return;
    }

    setState(() {
      _isInviting = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual API call via GoalsProvider
      // await goalsProvider.inviteUser(widget.goalId, user.id);

      // Simulated invite - will be replaced with real API call
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _invitedUserIds.add(user.id);
        _isInviting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to ${user.username}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Reload pending invites to show the new one
      await _loadPendingInvites();
    } catch (e) {
      setState(() {
        _isInviting = false;
        _errorMessage = 'Failed to send invitation. Please try again.';
      });
    }
  }

  void _navigateBack() {
    context.go('/goals/${widget.goalId}');
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Members'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateBack,
        ),
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            label: 'Search Users',
            hint: 'Enter username or email',
            prefixIcon: Icons.search,
            suffixIcon: _searchController.text.isNotEmpty
                ? Icons.clear
                : null,
            onChanged: (value) {
              _searchUsers(value);
            },
            enabled: !_isInviting,
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Clear search'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const AppLoading(message: 'Searching users...');
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _loadPendingInvites,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_searchResults.isNotEmpty) ...[
              _buildSearchResultsSection(),
              const SizedBox(height: AppSpacing.lg),
            ],
            _buildPendingInvitesSection(),
          ],
        ),
      ),
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
              _errorMessage ?? 'An error occurred',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                _loadPendingInvites();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_searchResults.isEmpty)
          _buildEmptySearchState()
        else
          ..._searchResults.map((user) => _UserSearchResultItem(
                user: user,
                isInvited: _invitedUserIds.contains(user.id),
                isInviting: _isInviting,
                onInvite: () => _inviteUser(user),
              )),
      ],
    );
  }

  Widget _buildEmptySearchState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No users found',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Try a different search term',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingInvitesSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Invites',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_pendingInvites.isEmpty)
          _buildEmptyInvitesState()
        else
          ..._pendingInvites.map((invite) => _PendingInviteItem(
                invite: invite,
              )),
      ],
    );
  }

  Widget _buildEmptyInvitesState() {
    return AppEmptyState(
      icon: Icons.send_outlined,
      title: 'No Pending Invites',
      message: 'Search for users above to invite them to this goal.',
    );
  }
}

/// User search result item widget.
class _UserSearchResultItem extends StatelessWidget {
  final UserSearchResult user;
  final bool isInvited;
  final bool isInviting;
  final VoidCallback onInvite;

  const _UserSearchResultItem({
    required this.user,
    required this.isInvited,
    required this.isInviting,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: user.profileImageUrl,
            initials: user.initials,
            size: AppAvatarSize.medium,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (user.email != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user.email!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildInviteButton(context),
        ],
      ),
    );
  }

  Widget _buildInviteButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isInvited) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              size: 16,
              color: colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Invited',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ],
        ),
      );
    }

    if (user.hasRelationship && user.relationshipStatus == 'pending') {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          'Pending',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return FilledButton.tonalIcon(
      onPressed: isInviting ? null : onInvite,
      icon: isInviting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.person_add, size: 18),
      label: const Text('Invite'),
    );
  }
}

/// Pending invite item widget.
class _PendingInviteItem extends StatelessWidget {
  final PendingInvite invite;

  const _PendingInviteItem({
    required this.invite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: invite.profileImageUrl,
            initials: invite.initials,
            size: AppAvatarSize.small,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.username,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (invite.createdAt != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Invited ${_formatTimeAgo(invite.createdAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Pending',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
