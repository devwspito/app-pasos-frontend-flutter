/// Friend requests page for displaying pending friend requests.
///
/// This page shows all incoming friend requests that need to be
/// accepted or rejected by the user.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/shared_user.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/sharing_relationship.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/sharing_bloc.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/sharing_event.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/sharing_state.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/widgets/friend_request_card.dart';
import 'package:app_pasos_frontend/shared/widgets/empty_state.dart';
import 'package:app_pasos_frontend/shared/widgets/error_widget.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Friend requests page displaying all pending requests.
///
/// Features:
/// - Pull-to-refresh functionality
/// - List of request cards with accept/reject buttons
/// - Empty state when no pending requests
/// - Loading states during accept/reject operations
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: RouteNames.friendRequests,
///   builder: (context, state) => BlocProvider(
///     create: (context) => SharingBloc(...)
///       ..add(const SharingLoadRequested()),
///     child: const FriendRequestsPage(),
///   ),
/// )
/// ```
class FriendRequestsPage extends StatelessWidget {
  /// Creates a [FriendRequestsPage].
  const FriendRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
        centerTitle: true,
      ),
      body: BlocConsumer<SharingBloc, SharingState>(
        listener: (context, state) {
          // Show snackbar for action success/error
          if (state is SharingActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            SharingInitial() => _buildInitialState(context),
            SharingLoading() => const LoadingIndicator(
                message: 'Loading requests...',
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

  /// Builds the loaded state UI with requests list.
  Widget _buildLoadedState(BuildContext context, SharingLoaded state) {
    final requests = state.pendingRequests;

    if (requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _onRefresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: const EmptyState(
                icon: Icons.mark_email_read_outlined,
                title: 'No Pending Requests',
                message: 'You have no friend requests at the moment.',
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
        itemCount: requests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final relationship = requests[index];
          return _FriendRequestCardItem(
            relationship: relationship,
            onAccept: () => _onAcceptRequest(context, relationship),
            onReject: () => _onRejectRequest(context, relationship),
          );
        },
      ),
    );
  }

  /// Handles accepting a friend request.
  void _onAcceptRequest(
    BuildContext context,
    SharingRelationship relationship,
  ) {
    context.read<SharingBloc>().add(
          SharingAcceptRequestRequested(relationshipId: relationship.id),
        );
  }

  /// Handles rejecting a friend request.
  void _onRejectRequest(
    BuildContext context,
    SharingRelationship relationship,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Request'),
        content: const Text(
          'Are you sure you want to reject this friend request?',
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
                    SharingRejectRequestRequested(
                      relationshipId: relationship.id,
                    ),
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reject'),
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

/// A friend request card item that displays request information.
class _FriendRequestCardItem extends StatelessWidget {
  const _FriendRequestCardItem({
    required this.relationship,
    required this.onAccept,
    required this.onReject,
  });

  final SharingRelationship relationship;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    // Create a SharedUser from the relationship data
    // Note: In production, the API should return user details with relationships
    final user = SharedUser(
      id: relationship.fromUserId,
      name: 'User ${relationship.fromUserId.length > 4 ? relationship.fromUserId.substring(0, 4) : relationship.fromUserId}',
      email: 'user@example.com',
    );

    return FriendRequestCard(
      relationship: relationship,
      user: user,
      onAccept: onAccept,
      onReject: onReject,
    );
  }
}
