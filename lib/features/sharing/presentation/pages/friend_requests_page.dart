import 'package:flutter/material.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../widgets/request_card.dart';

/// Model representing a friend request.
///
/// This is a temporary model until the domain layer is available.
class _FriendRequest {
  const _FriendRequest({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.requestedAt,
  });

  final String id;
  final String username;
  final String? avatarUrl;
  final DateTime requestedAt;
}

/// A page displaying pending friend requests.
///
/// Features:
/// - AppBar with title 'Friend Requests' and back button
/// - ListView of RequestCard widgets showing pending requests
/// - Empty state when no pending requests
/// - Loading indicator during initial load
class FriendRequestsPage extends StatefulWidget {
  /// Creates a [FriendRequestsPage] widget.
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  bool _isLoading = true;
  List<_FriendRequest> _requests = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual SharingProvider call when available
      // final provider = context.read<SharingProvider>();
      // await provider.loadFriendRequests();
      // _requests = provider.pendingRequests;

      // Simulated loading delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Empty state by default - will be populated by SharingProvider
      setState(() {
        _requests = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load friend requests.';
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadRequests();
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      // TODO: Replace with actual SharingProvider call when available
      // final provider = context.read<SharingProvider>();
      // await provider.acceptFriendRequest(requestId);

      // Simulated action
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove the request from the list on success
      setState(() {
        _requests.removeWhere((r) => r.id == requestId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Friend request accepted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept request: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    try {
      // TODO: Replace with actual SharingProvider call when available
      // final provider = context.read<SharingProvider>();
      // await provider.rejectFriendRequest(requestId);

      // Simulated action
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove the request from the list on success
      setState(() {
        _requests.removeWhere((r) => r.id == requestId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Friend request rejected'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject request: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
        centerTitle: true,
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
                onAction: _loadRequests,
              ),
            ),
          ),
        ),
      );
    }

    if (_requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: const Center(
              child: AppEmptyState(
                icon: Icons.mail_outline,
                title: 'No Requests',
                message: 'You have no pending friend requests.',
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
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return RequestCard(
            requestId: request.id,
            username: request.username,
            avatarUrl: request.avatarUrl,
            requestedAt: request.requestedAt,
            onAccept: _acceptRequest,
            onReject: _rejectRequest,
          );
        },
      ),
    );
  }
}
