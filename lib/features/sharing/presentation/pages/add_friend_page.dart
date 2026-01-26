import 'package:flutter/material.dart';

import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../widgets/user_search_field.dart';

/// Enum representing the status of a user in relation to the current user.
enum _UserRelationStatus {
  /// Not a friend, no pending request.
  none,

  /// Friend request already sent.
  requestPending,

  /// Already friends.
  friend,
}

/// Model representing a user search result.
///
/// This is a temporary model until the domain layer is available.
class _UserSearchResult {
  const _UserSearchResult({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.status = _UserRelationStatus.none,
  });

  final String id;
  final String username;
  final String? avatarUrl;
  final _UserRelationStatus status;
}

/// A page for searching and adding new friends.
///
/// Features:
/// - AppBar with title 'Add Friend' and back button
/// - UserSearchField at top with search icon and debounced search
/// - ListView of search results with 'Add Friend' button for each
/// - Shows existing friend status and pending request status
/// - Empty state when search returns no results
class AddFriendPage extends StatefulWidget {
  /// Creates an [AddFriendPage] widget.
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _hasSearched = false;
  List<_UserSearchResult> _searchResults = [];
  final Set<String> _sendingRequests = {};
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual SharingProvider call when available
      // final provider = context.read<SharingProvider>();
      // _searchResults = await provider.searchUsers(query);

      // Simulated search delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Empty results by default - will be populated by SharingProvider
      setState(() {
        _searchResults = [];
        _hasSearched = true;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed. Please try again.';
        _isSearching = false;
        _hasSearched = true;
      });
    }
  }

  Future<void> _sendFriendRequest(String userId) async {
    if (_sendingRequests.contains(userId)) return;

    setState(() {
      _sendingRequests.add(userId);
    });

    try {
      // TODO: Replace with actual SharingProvider call when available
      // final provider = context.read<SharingProvider>();
      // await provider.sendFriendRequest(userId);

      // Simulated action
      await Future.delayed(const Duration(milliseconds: 500));

      // Update the user's status in the list
      setState(() {
        _sendingRequests.remove(userId);
        _searchResults = _searchResults.map((user) {
          if (user.id == userId) {
            return _UserSearchResult(
              id: user.id,
              username: user.username,
              avatarUrl: user.avatarUrl,
              status: _UserRelationStatus.requestPending,
            );
          }
          return user;
        }).toList();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Friend request sent'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _sendingRequests.remove(userId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Extracts initials from the username.
  String _getInitials(String username) {
    if (username.isEmpty) return '?';
    final parts = username.split(RegExp(r'[\s_.-]'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username.substring(0, username.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(16),
            child: UserSearchField(
              controller: _searchController,
              onChanged: _onSearch,
              autofocus: true,
            ),
          ),
          // Results
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: AppEmptyState(
          icon: Icons.error_outline,
          title: 'Error',
          message: _errorMessage!,
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for friends by username',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: AppEmptyState(
          icon: Icons.person_search,
          title: 'No Results',
          message: 'No users found matching your search.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _UserSearchResultCard(
          user: user,
          initials: _getInitials(user.username),
          isSending: _sendingRequests.contains(user.id),
          onAddFriend: () => _sendFriendRequest(user.id),
        );
      },
    );
  }
}

/// A card displaying a user search result with action button.
class _UserSearchResultCard extends StatelessWidget {
  const _UserSearchResultCard({
    required this.user,
    required this.initials,
    required this.isSending,
    required this.onAddFriend,
  });

  final _UserSearchResult user;
  final String initials;
  final bool isSending;
  final VoidCallback onAddFriend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Avatar
          AppAvatar(
            imageUrl: user.avatarUrl,
            initials: initials,
            size: AppAvatarSize.medium,
          ),
          const SizedBox(width: 12),
          // Username
          Expanded(
            child: Text(
              user.username,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          // Action button based on status
          _buildActionWidget(colorScheme, theme),
        ],
      ),
    );
  }

  Widget _buildActionWidget(ColorScheme colorScheme, ThemeData theme) {
    switch (user.status) {
      case _UserRelationStatus.friend:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check,
                size: 16,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 4),
              Text(
                'Friends',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        );
      case _UserRelationStatus.requestPending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 4),
              Text(
                'Pending',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        );
      case _UserRelationStatus.none:
        return AppButton(
          label: 'Add Friend',
          onPressed: onAddFriend,
          isLoading: isSending,
          size: AppButtonSize.small,
        );
    }
  }
}
