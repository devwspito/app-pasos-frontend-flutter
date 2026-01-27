/// Invite members page for inviting users to join a goal.
///
/// This page allows users to search for other users and invite them
/// to join a group goal, similar to the AddFriendPage.
library;

import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_bloc.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_event.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_state.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/friend_search_bloc.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/friend_search_event.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/friend_search_state.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/widgets/user_search_result_tile.dart';
import 'package:app_pasos_frontend/shared/widgets/empty_state.dart';
import 'package:app_pasos_frontend/shared/widgets/error_widget.dart';
import 'package:app_pasos_frontend/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Invite members page for inviting users to join a goal.
///
/// Features:
/// - Search text field with debounced input
/// - List of search results with invite buttons
/// - Empty state when no results found
/// - Loading state during search
/// - Integration with GoalDetailBloc for sending invites
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: RouteNames.inviteMembers,
///   builder: (context, state) {
///     final goalId = state.uri.queryParameters['goalId'] ?? '';
///     return MultiBlocProvider(
///       providers: [
///         BlocProvider(create: (_) => sl<FriendSearchBloc>()),
///         BlocProvider(create: (_) => sl<GoalDetailBloc>()),
///       ],
///       child: InviteMembersPage(goalId: goalId),
///     );
///   },
/// )
/// ```
class InviteMembersPage extends StatefulWidget {
  /// Creates an [InviteMembersPage].
  ///
  /// [goalId] - The ID of the goal to invite members to.
  const InviteMembersPage({
    required this.goalId,
    super.key,
  });

  /// The ID of the goal to invite members to.
  final String goalId;

  @override
  State<InviteMembersPage> createState() => _InviteMembersPageState();
}

class _InviteMembersPageState extends State<InviteMembersPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  /// Tracks users that are currently being invited (loading state).
  final Set<String> _pendingInvites = {};

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Members'),
        centerTitle: true,
      ),
      body: BlocListener<GoalDetailBloc, GoalDetailState>(
        listener: (context, state) {
          if (state is GoalDetailActionSuccess) {
            // Clear pending state and show success message
            setState(() {
              _pendingInvites.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.primary,
              ),
            );
          } else if (state is GoalDetailError) {
            // Clear pending state and show error message
            setState(() {
              _pendingInvites.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Search bar
            _buildSearchBar(context, theme, colorScheme),

            // Search results
            Expanded(
              child: BlocBuilder<FriendSearchBloc, FriendSearchState>(
                builder: (context, state) {
                  return switch (state) {
                    FriendSearchInitial() => _buildInitialState(context),
                    FriendSearchLoading() => const LoadingIndicator(
                        message: 'Searching...',
                      ),
                    FriendSearchLoaded() => _buildLoadedState(context, state),
                    FriendSearchEmpty(:final query) =>
                      _buildEmptyState(context, query),
                    FriendSearchError(:final message) => AppErrorWidget(
                        message: message,
                        onRetry: () => _retrySearch(),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the search bar widget.
  Widget _buildSearchBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search by name or email...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        textInputAction: TextInputAction.search,
        onChanged: _onSearchChanged,
      ),
    );
  }

  /// Builds the initial state UI.
  Widget _buildInitialState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Invite Members',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for friends by their name or email to invite them to this goal.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the loaded state UI with search results.
  Widget _buildLoadedState(BuildContext context, FriendSearchLoaded state) {
    return ListView.builder(
      itemCount: state.users.length,
      itemBuilder: (context, index) {
        final user = state.users[index];
        final isPending = _pendingInvites.contains(user.id);

        return UserSearchResultTile(
          user: user,
          onAddFriend: () => _onInviteUser(user.id),
          isLoading: isPending,
          isAlreadyFriend: false,
          isRequestPending: false,
        );
      },
    );
  }

  /// Builds the empty state UI when no results found.
  Widget _buildEmptyState(BuildContext context, String query) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results',
      message: 'No users found for "$query".\nTry a different search term.',
    );
  }

  /// Handles search text changes with debouncing.
  void _onSearchChanged(String value) {
    // Update UI to show clear button
    setState(() {});

    // Dispatch search event to bloc
    if (value.trim().isEmpty) {
      context.read<FriendSearchBloc>().add(const FriendSearchCleared());
    } else {
      context.read<FriendSearchBloc>().add(
            FriendSearchQueryChanged(query: value),
          );
    }
  }

  /// Clears the search field and results.
  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    context.read<FriendSearchBloc>().add(const FriendSearchCleared());
    _searchFocusNode.requestFocus();
  }

  /// Retries the current search.
  void _retrySearch() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      context.read<FriendSearchBloc>().add(
            FriendSearchQueryChanged(query: query),
          );
    }
  }

  /// Handles inviting a user to the goal.
  void _onInviteUser(String userId) {
    setState(() {
      _pendingInvites.add(userId);
    });

    context.read<GoalDetailBloc>().add(
          GoalDetailInviteUserRequested(
            goalId: widget.goalId,
            userId: userId,
          ),
        );
  }
}
