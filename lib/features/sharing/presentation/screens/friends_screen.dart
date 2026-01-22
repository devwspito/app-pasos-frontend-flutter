import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../widgets/friend_list_item.dart';
import '../widgets/pending_request_card.dart';

/// Screen displaying the user's friends list and pending requests.
///
/// Features:
/// - Tab bar switching between 'Friends' and 'Pending' tabs
/// - Pull-to-refresh functionality
/// - Empty states for when lists are empty
/// - Loading and error states
///
/// Example usage:
/// ```dart
/// GoRoute(
///   path: '/friends',
///   builder: (context, state) => const FriendsScreen(),
/// )
/// ```
class FriendsScreen extends ConsumerStatefulWidget {
  /// Creates a [FriendsScreen].
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for UI - will be replaced with provider data
  bool _isLoading = false;
  String? _errorMessage;
  int _myTodaySteps = 5000;

  // Sample friends data
  final List<FriendData> _friends = [
    const FriendData(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      todaySteps: 7500,
      status: FriendStatus.active,
    ),
    const FriendData(
      id: '2',
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      todaySteps: 3200,
      status: FriendStatus.active,
    ),
    const FriendData(
      id: '3',
      name: 'Bob Wilson',
      email: 'bob.wilson@example.com',
      todaySteps: 5000,
      status: FriendStatus.inactive,
    ),
  ];

  // Sample pending requests
  final List<PendingRequest> _pendingRequests = [
    PendingRequest(
      id: '1',
      userId: 'user1',
      userName: 'Alice Brown',
      userEmail: 'alice.brown@example.com',
      direction: RequestDirection.received,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    PendingRequest(
      id: '2',
      userId: 'user2',
      userName: 'Charlie Davis',
      userEmail: 'charlie.davis@example.com',
      direction: RequestDirection.sent,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // TODO: Replace with actual provider refresh
    // await ref.read(sharingProvider.notifier).refresh();
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {});
    }
  }

  void _navigateToAddFriend() {
    context.push('/friends/add');
  }

  void _navigateToFriendDetail(String friendId) {
    context.push('/friends/$friendId');
  }

  void _handleAcceptRequest(String requestId) {
    // TODO: Implement accept request via provider
    // ref.read(sharingProvider.notifier).acceptRequest(requestId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request accepted')),
    );
  }

  void _handleRejectRequest(String requestId) {
    // TODO: Implement reject request via provider
    // ref.read(sharingProvider.notifier).rejectRequest(requestId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request rejected')),
    );
  }

  void _handleCancelRequest(String requestId) {
    // TODO: Implement cancel request via provider
    // ref.read(sharingProvider.notifier).cancelRequest(requestId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request cancelled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // TODO: Watch sharing provider state
    // final sharingState = ref.watch(sharingProvider);
    // final isLoading = sharingState.isLoading;
    // final errorMessage = sharingState.errorMessage;
    // final friends = sharingState.friends;
    // final pendingRequests = sharingState.pendingRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: _navigateToAddFriend,
            tooltip: 'Add Friend',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Friends'),
                  if (_friends.isNotEmpty) ...[
                    SizedBox(width: AppSpacing.xs),
                    _buildBadge(colorScheme, _friends.length),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pending'),
                  if (_pendingRequests.isNotEmpty) ...[
                    SizedBox(width: AppSpacing.xs),
                    _buildBadge(colorScheme, _pendingRequests.length),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsTab(),
          _buildPendingTab(),
        ],
      ),
    );
  }

  Widget _buildBadge(ColorScheme colorScheme, int count) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: AppSpacing.borderRadiusPill,
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    if (_isLoading && _friends.isEmpty) {
      return const LoadingIndicator(
        message: 'Loading friends...',
      );
    }

    if (_errorMessage != null && _friends.isEmpty) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: _handleRefresh,
      );
    }

    if (_friends.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outline_rounded,
        title: 'No friends yet',
        description: 'Add friends to compare steps and stay motivated together!',
        actionLabel: 'Add Friend',
        onAction: _navigateToAddFriend,
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: AppSpacing.allMd,
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < _friends.length - 1 ? AppSpacing.sm : 0,
            ),
            child: FriendListItem(
              friend: friend,
              myTodaySteps: _myTodaySteps,
              onTap: () => _navigateToFriendDetail(friend.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_isLoading && _pendingRequests.isEmpty) {
      return const LoadingIndicator(
        message: 'Loading requests...',
      );
    }

    if (_errorMessage != null && _pendingRequests.isEmpty) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: _handleRefresh,
      );
    }

    if (_pendingRequests.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.mail_outline_rounded,
        title: 'No pending requests',
        description: 'Friend requests you send or receive will appear here.',
      );
    }

    // Separate received and sent requests
    final receivedRequests = _pendingRequests
        .where((r) => r.direction == RequestDirection.received)
        .toList();
    final sentRequests = _pendingRequests
        .where((r) => r.direction == RequestDirection.sent)
        .toList();

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        padding: AppSpacing.allMd,
        children: [
          // Received requests section
          if (receivedRequests.isNotEmpty) ...[
            _buildSectionHeader('Received'),
            SizedBox(height: AppSpacing.sm),
            ...receivedRequests.map((request) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: PendingRequestCard(
                    request: request,
                    onAccept: () => _handleAcceptRequest(request.id),
                    onReject: () => _handleRejectRequest(request.id),
                  ),
                )),
          ],

          // Sent requests section
          if (sentRequests.isNotEmpty) ...[
            if (receivedRequests.isNotEmpty) SizedBox(height: AppSpacing.md),
            _buildSectionHeader('Sent'),
            SizedBox(height: AppSpacing.sm),
            ...sentRequests.map((request) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: PendingRequestCard(
                    request: request,
                    onCancel: () => _handleCancelRequest(request.id),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      title,
      style: textTheme.titleSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
