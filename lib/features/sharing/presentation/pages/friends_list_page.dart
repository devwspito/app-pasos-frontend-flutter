/// Friends list page for displaying the user's friends.
///
/// This page shows all accepted friends with their step data,
/// and provides navigation to add new friends.
library;

import 'package:app_pasos_frontend/core/router/route_names.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/shared_user.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/sharing_relationship.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/sharing_bloc.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/sharing_event.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/sharing_state.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/widgets/friend_card.dart';
import 'package:app_pasos_frontend/shared/widgets/empty_state.dart';
import 'package:app_pasos_frontend/shared/widgets/error_widget.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Friends list page displaying all accepted friends.
///
/// Features:
/// - Pull-to-refresh functionality
/// - List of friend cards with step data
/// - Empty state when no friends
/// - Navigation to add friend and friend activity pages
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: RouteNames.friends,
///   builder: (context, state) => BlocProvider(
///     create: (context) => SharingBloc(...)
///       ..add(const SharingLoadRequested()),
///     child: const FriendsListPage(),
///   ),
/// )
/// ```
class FriendsListPage extends StatelessWidget {
  /// Creates a [FriendsListPage].
  const FriendsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => context.push(RouteNames.addFriend),
            tooltip: 'Add Friend',
          ),
        ],
      ),
      body: BlocBuilder<SharingBloc, SharingState>(
        builder: (context, state) {
          return switch (state) {
            SharingInitial() => _buildInitialState(context),
            SharingLoading() => const LoadingIndicator(
                message: 'Loading friends...',
              ),
            SharingLoaded() => _buildLoadedState(context, state),
            SharingError(:final message) => AppErrorWidget(
                message: message,
                onRetry: () => _onRefresh(context),
              ),
            SharingActionSuccess() => _buildInitialState(context),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.addFriend),
        tooltip: 'Add Friend',
        child: const Icon(Icons.person_add),
      ),
    );
  }

  /// Builds the initial state UI.
  ///
  /// Shows a loading indicator and triggers data load.
  Widget _buildInitialState(BuildContext context) {
    // Trigger initial load when in initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SharingBloc>().add(const SharingLoadRequested());
    });

    return const LoadingIndicator(
      message: 'Initializing...',
    );
  }

  /// Builds the loaded state UI with friends list.
  Widget _buildLoadedState(BuildContext context, SharingLoaded state) {
    final friends = state.friends;

    if (friends.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _onRefresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: EmptyState(
                icon: Icons.people_outline,
                title: 'No Friends Yet',
                message: 'Add friends to see their step progress and compare stats.',
                action: FilledButton.icon(
                  onPressed: () => context.push(RouteNames.addFriend),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Friend'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(context),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: friends.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final relationship = friends[index];
          return _FriendCardItem(
            relationship: relationship,
            onTap: () => _navigateToFriendActivity(context, relationship),
            onRemove: () => _showRemoveFriendDialog(context, relationship),
          );
        },
      ),
    );
  }

  /// Navigates to the friend activity page.
  void _navigateToFriendActivity(
    BuildContext context,
    SharingRelationship relationship,
  ) {
    // Navigate to friend activity with the friend's user ID
    final friendId = relationship.toUserId.isNotEmpty
        ? relationship.toUserId
        : relationship.fromUserId;
    context.push('${RouteNames.friendActivity}?friendId=$friendId');
  }

  /// Shows a dialog to confirm removing a friend.
  void _showRemoveFriendDialog(
    BuildContext context,
    SharingRelationship relationship,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Friend'),
        content: const Text(
          'Are you sure you want to remove this friend? '
          'You will no longer be able to see their activity.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<SharingBloc>().add(
                    SharingRevokeRequested(relationshipId: relationship.id),
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  /// Handles refresh action by dispatching a refresh event.
  void _onRefresh(BuildContext context) {
    context.read<SharingBloc>().add(const SharingRefreshRequested());
  }
}

/// A friend card item that displays friend information from a relationship.
///
/// This widget integrates with the [SharingBloc] to display realtime
/// step data and online status for friends.
class _FriendCardItem extends StatelessWidget {
  const _FriendCardItem({
    required this.relationship,
    required this.onTap,
    this.onRemove,
  });

  final SharingRelationship relationship;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    // Create a SharedUser from the relationship data
    // Note: In production, the API should return user details with relationships
    final friendId = relationship.toUserId.isNotEmpty
        ? relationship.toUserId
        : relationship.fromUserId;
    final friend = SharedUser(
      id: friendId,
      name: 'Friend ${friendId.length > 4 ? friendId.substring(0, 4) : friendId}',
      email: 'friend@example.com',
    );

    // Get realtime data from BLoC state
    final state = context.read<SharingBloc>().state;
    bool? isOnline;
    int? realtimeSteps;
    bool isLive = false;

    if (state is SharingLoaded) {
      isOnline = state.isFriendOnline(friendId);
      realtimeSteps = state.getRealtimeSteps(friendId);

      // Determine if the data is "live" (updated within the last 5 minutes)
      final realtimeUpdate = state.getRealtimeUpdate(friendId);
      if (realtimeUpdate != null) {
        final timeSinceUpdate =
            DateTime.now().difference(realtimeUpdate.timestamp);
        isLive = timeSinceUpdate.inMinutes < 5;
      }
    }

    return FriendCard(
      friend: friend,
      onTap: onTap,
      onRemove: onRemove,
      isOnline: isOnline,
      realtimeSteps: realtimeSteps,
      isLive: isLive,
    );
  }
}
