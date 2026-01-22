import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/friend_stats.dart';
import '../../domain/entities/relationship.dart';
import '../../domain/repositories/sharing_repository.dart';
import 'sharing_state.dart';

/// StateNotifier for managing sharing/friends state.
///
/// This notifier handles all sharing-related state changes including
/// loading relationships, managing friend requests, and fetching friend stats.
///
/// Usage:
/// ```dart
/// final sharingState = ref.watch(sharingProvider);
/// ref.read(sharingProvider.notifier).loadRelationships();
/// ```
class SharingNotifier extends StateNotifier<SharingState> {
  SharingNotifier({
    required SharingRepository sharingRepository,
  })  : _repository = sharingRepository,
        super(const SharingState.initial());

  final SharingRepository _repository;

  /// Loads all relationships for the current user.
  ///
  /// This includes pending requests, accepted friends, and other statuses.
  /// Updates state to loading while in progress, then either
  /// loaded with data or error with message.
  Future<void> loadRelationships() async {
    state = state.copyWith(
      status: state.hasData ? SharingStatus.loaded : SharingStatus.loading,
      isLoading: true,
      clearError: true,
    );

    try {
      // Load all data in parallel for efficiency
      final results = await Future.wait([
        _repository.getRelationships(),
        _repository.getPendingRequests(),
        _repository.getAcceptedFriends(),
      ]);

      final relationships = results[0] as List<Relationship>;
      final pendingRequests = results[1] as List<Relationship>;
      final acceptedFriends = results[2] as List<Relationship>;

      state = state.copyWith(
        status: SharingStatus.loaded,
        relationships: relationships,
        pendingRequests: pendingRequests,
        acceptedFriends: acceptedFriends,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: SharingStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
    }
  }

  /// Sends a friend request to another user.
  ///
  /// [usernameOrEmail] The username or email of the user to add.
  ///
  /// Returns the created [Relationship] on success, null on failure.
  /// Automatically refreshes relationships after sending.
  Future<Relationship?> sendRequest(String usernameOrEmail) async {
    if (usernameOrEmail.isEmpty) {
      state = state.copyWith(
        status: SharingStatus.error,
        errorMessage: 'Username or email is required',
      );
      return null;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final relationship = await _repository.sendFriendRequest(usernameOrEmail);

      // Refresh relationships to include the new pending request
      await loadRelationships();

      return relationship;
    } catch (e) {
      state = state.copyWith(
        status: SharingStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
      return null;
    }
  }

  /// Accepts a pending friend request.
  ///
  /// [relationshipId] The ID of the relationship to accept.
  ///
  /// Returns the updated [Relationship] on success, null on failure.
  /// Automatically refreshes relationships after accepting.
  Future<Relationship?> acceptRequest(String relationshipId) async {
    if (relationshipId.isEmpty) {
      state = state.copyWith(
        status: SharingStatus.error,
        errorMessage: 'Relationship ID is required',
      );
      return null;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final relationship =
          await _repository.acceptFriendRequest(relationshipId);

      // Refresh relationships to reflect the new friendship
      await loadRelationships();

      return relationship;
    } catch (e) {
      state = state.copyWith(
        status: SharingStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
      return null;
    }
  }

  /// Rejects a pending friend request.
  ///
  /// [relationshipId] The ID of the relationship to reject.
  ///
  /// Returns the updated [Relationship] on success, null on failure.
  /// Automatically refreshes relationships after rejecting.
  Future<Relationship?> rejectRequest(String relationshipId) async {
    if (relationshipId.isEmpty) {
      state = state.copyWith(
        status: SharingStatus.error,
        errorMessage: 'Relationship ID is required',
      );
      return null;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final relationship =
          await _repository.rejectFriendRequest(relationshipId);

      // Refresh relationships to reflect the rejection
      await loadRelationships();

      return relationship;
    } catch (e) {
      state = state.copyWith(
        status: SharingStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
      return null;
    }
  }

  /// Loads step statistics for a specific friend.
  ///
  /// [friendUserId] The user ID of the friend.
  ///
  /// Returns the [FriendStats] on success, null on failure.
  /// Updates selectedFriendStats in state.
  Future<FriendStats?> loadFriendStats(String friendUserId) async {
    if (friendUserId.isEmpty) {
      state = state.copyWith(
        status: SharingStatus.error,
        errorMessage: 'Friend user ID is required',
      );
      return null;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSelectedFriend: true,
    );

    try {
      final friendStats = await _repository.getFriendStats(friendUserId);

      state = state.copyWith(
        status: SharingStatus.loaded,
        selectedFriendStats: friendStats,
        isLoading: false,
      );

      return friendStats;
    } catch (e) {
      state = state.copyWith(
        status: SharingStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
      return null;
    }
  }

  /// Refreshes all sharing data (relationships and friend stats).
  ///
  /// Use this when:
  /// - App comes to foreground
  /// - User pulls to refresh
  /// - After a period of inactivity
  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      // Load all data in parallel for efficiency
      final results = await Future.wait([
        _repository.getRelationships(),
        _repository.getPendingRequests(),
        _repository.getAcceptedFriends(),
        _repository.getAllFriendsStats(),
      ]);

      final relationships = results[0] as List<Relationship>;
      final pendingRequests = results[1] as List<Relationship>;
      final acceptedFriends = results[2] as List<Relationship>;
      final sharedStats = results[3] as List<FriendStats>;

      state = state.copyWith(
        status: SharingStatus.loaded,
        relationships: relationships,
        pendingRequests: pendingRequests,
        acceptedFriends: acceptedFriends,
        sharedStats: sharedStats,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: SharingStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
    }
  }

  /// Clears any error in the current state.
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(clearError: true);
    }
  }

  /// Resets state to initial.
  ///
  /// Use when user logs out or switches accounts.
  void reset() {
    state = const SharingState.initial();
  }

  /// Formats error for display.
  String _formatError(Object error) {
    final message = error.toString();

    // Clean up common error prefixes
    if (message.startsWith('Exception:')) {
      return message.substring(10).trim();
    }

    return message;
  }
}

/// Provider for the sharing repository.
///
/// This provider must be overridden with the actual repository implementation.
///
/// Usage:
/// ```dart
/// ProviderScope(
///   overrides: [
///     sharingRepositoryProvider.overrideWithValue(repository),
///   ],
///   child: MyApp(),
/// )
/// ```
final sharingRepositoryProvider = Provider<SharingRepository>((ref) {
  throw UnimplementedError(
    'sharingRepositoryProvider must be overridden with actual implementation',
  );
});

/// Provider for the sharing notifier.
///
/// This provider requires a [SharingRepository] to be provided.
/// In production, this should be overridden with the actual repository.
///
/// Usage:
/// ```dart
/// // Watch sharing state
/// final sharingState = ref.watch(sharingProvider);
///
/// // Access notifier methods
/// ref.read(sharingProvider.notifier).loadRelationships();
///
/// // Check pending requests
/// if (sharingState.pendingCount > 0) {
///   showNotificationBadge();
/// }
/// ```
final sharingProvider =
    StateNotifierProvider<SharingNotifier, SharingState>((ref) {
  final repository = ref.watch(sharingRepositoryProvider);

  return SharingNotifier(
    sharingRepository: repository,
  );
});
