import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../widgets/friend_card.dart';

/// Model representing a friend in the friends list.
///
/// This is a temporary model until the domain layer is available.
class _Friend {
  const _Friend({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.lastActiveAt,
    this.todaySteps = 0,
  });

  final String id;
  final String username;
  final String? avatarUrl;
  final DateTime? lastActiveAt;
  final int todaySteps;
}

/// A page displaying the user's friends list.
///
/// Features:
/// - AppBar with title 'Friends'
/// - IconButton for friend requests (with badge for pending count)
/// - IconButton for add friend
/// - ListView of FriendCard widgets showing accepted friends
/// - Pull-to-refresh using RefreshIndicator
/// - Empty state when no friends
/// - Loading state with CircularProgressIndicator
class FriendsPage extends StatefulWidget {
  /// Creates a [FriendsPage] widget.
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  bool _isLoading = true;
  List<_Friend> _friends = [];
  int _pendingRequestsCount = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual SharingProvider call when available
      // final provider = context.read<SharingProvider>();
      // await provider.loadFriends();
      // _friends = provider.friends;
      // _pendingRequestsCount = provider.pendingRequestsCount;

      // Simulated loading delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Empty state by default - will be populated by SharingProvider
      setState(() {
        _friends = [];
        _pendingRequestsCount = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load friends. Pull to refresh.';
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadFriends();
  }

  void _navigateToFriendDetail(String friendId) {
    context.push('${AppRoutes.friends}/$friendId');
  }

  void _navigateToFriendRequests() {
    context.push(AppRoutes.friendRequests);
  }

  void _navigateToAddFriend() {
    context.push(AppRoutes.addFriend);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        centerTitle: true,
        actions: [
          // Friend requests button with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.person_add_alt),
                onPressed: _navigateToFriendRequests,
                tooltip: 'Friend Requests',
              ),
              if (_pendingRequestsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _pendingRequestsCount > 9
                          ? '9+'
                          : _pendingRequestsCount.toString(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Add friend button
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _navigateToAddFriend,
            tooltip: 'Add Friend',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: Center(
              child: AppEmptyState(
                icon: Icons.error_outline,
                title: 'Error',
                message: _errorMessage!,
                actionLabel: 'Retry',
                onAction: _loadFriends,
              ),
            ),
          ),
        ),
      );
    }

    if (_friends.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: Center(
              child: AppEmptyState(
                icon: Icons.people_outline,
                title: 'No Friends Yet',
                message: 'Add your first friend!',
                actionLabel: 'Add Friend',
                onAction: _navigateToAddFriend,
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return FriendCard(
            friendId: friend.id,
            username: friend.username,
            avatarUrl: friend.avatarUrl,
            lastActiveAt: friend.lastActiveAt,
            todaySteps: friend.todaySteps,
            onTap: _navigateToFriendDetail,
          );
        },
      ),
    );
  }
}
