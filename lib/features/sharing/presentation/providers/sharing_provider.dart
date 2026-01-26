import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';

/// Represents the current status of sharing data loading.
///
/// - [initial]: Provider just created, no data loaded
/// - [loading]: Data is being fetched
/// - [loaded]: Data successfully loaded
/// - [error]: An error occurred during data loading
enum SharingStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Entity representing a sharing relationship between users.
///
/// TODO: Will be replaced with import from lib/features/sharing/domain/entities/sharing_relationship.dart
class SharingRelationship {
  /// Unique identifier for the relationship.
  final String id;

  /// ID of the user who initiated the relationship.
  final String requesterId;

  /// ID of the user who received the request.
  final String targetId;

  /// Username of the other user in the relationship.
  final String username;

  /// Email of the other user in the relationship.
  final String? email;

  /// Profile image URL of the other user.
  final String? profileImageUrl;

  /// Status of the relationship: 'pending', 'accepted', 'rejected'.
  final String status;

  /// When the relationship was created.
  final DateTime createdAt;

  /// When the relationship was last updated.
  final DateTime? updatedAt;

  /// Creates a new SharingRelationship instance.
  const SharingRelationship({
    required this.id,
    required this.requesterId,
    required this.targetId,
    required this.username,
    this.email,
    this.profileImageUrl,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a SharingRelationship from a JSON map.
  factory SharingRelationship.fromJson(Map<String, dynamic> json) {
    return SharingRelationship(
      id: json['id']?.toString() ?? '',
      requesterId: json['requesterId']?.toString() ?? '',
      targetId: json['targetId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Converts this SharingRelationship to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterId': requesterId,
      'targetId': targetId,
      'username': username,
      if (email != null) 'email': email,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Creates a copy of this relationship with updated fields.
  SharingRelationship copyWith({
    String? id,
    String? requesterId,
    String? targetId,
    String? username,
    String? email,
    String? profileImageUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SharingRelationship(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      targetId: targetId ?? this.targetId,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharingRelationship &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SharingRelationship(id: $id, username: $username, status: $status)';
}

/// Entity representing statistics about a friend's activity.
///
/// TODO: Will be replaced with import from lib/features/sharing/domain/entities/friend_stats.dart
class FriendStats {
  /// ID of the friend.
  final String friendId;

  /// Username of the friend.
  final String username;

  /// Profile image URL of the friend.
  final String? profileImageUrl;

  /// Friend's total steps today.
  final int todaySteps;

  /// Friend's daily goal.
  final int goalSteps;

  /// Friend's current streak (consecutive days meeting goal).
  final int streak;

  /// When the stats were last updated.
  final DateTime lastUpdated;

  /// Creates a new FriendStats instance.
  const FriendStats({
    required this.friendId,
    required this.username,
    this.profileImageUrl,
    required this.todaySteps,
    required this.goalSteps,
    required this.streak,
    required this.lastUpdated,
  });

  /// Creates a FriendStats from a JSON map.
  factory FriendStats.fromJson(Map<String, dynamic> json) {
    return FriendStats(
      friendId: json['friendId']?.toString() ?? json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profileImageUrl: json['profileImageUrl']?.toString(),
      todaySteps: int.tryParse(json['todaySteps']?.toString() ?? '0') ?? 0,
      goalSteps: int.tryParse(json['goalSteps']?.toString() ?? '10000') ?? 10000,
      streak: int.tryParse(json['streak']?.toString() ?? '0') ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'].toString())
          : DateTime.now(),
    );
  }

  /// Converts this FriendStats to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'username': username,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'todaySteps': todaySteps,
      'goalSteps': goalSteps,
      'streak': streak,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Returns the progress towards the goal as a value between 0.0 and 1.0.
  double get goalProgress =>
      goalSteps > 0 ? (todaySteps / goalSteps).clamp(0.0, 1.0) : 0.0;

  /// Returns true if the friend has achieved their goal today.
  bool get isGoalAchieved => todaySteps >= goalSteps;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendStats &&
          runtimeType == other.runtimeType &&
          friendId == other.friendId;

  @override
  int get hashCode => friendId.hashCode;

  @override
  String toString() =>
      'FriendStats(friendId: $friendId, username: $username, todaySteps: $todaySteps)';
}

/// Entity representing a user search result.
///
/// TODO: Will be replaced with import from lib/features/sharing/domain/entities/user_search_result.dart
class UserSearchResult {
  /// Unique identifier for the user.
  final String id;

  /// Username of the user.
  final String username;

  /// Email of the user.
  final String? email;

  /// Profile image URL of the user.
  final String? profileImageUrl;

  /// Whether the current user already has a relationship with this user.
  final bool hasRelationship;

  /// The status of the existing relationship, if any.
  final String? relationshipStatus;

  /// Creates a new UserSearchResult instance.
  const UserSearchResult({
    required this.id,
    required this.username,
    this.email,
    this.profileImageUrl,
    this.hasRelationship = false,
    this.relationshipStatus,
  });

  /// Creates a UserSearchResult from a JSON map.
  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      hasRelationship: json['hasRelationship'] == true,
      relationshipStatus: json['relationshipStatus']?.toString(),
    );
  }

  /// Converts this UserSearchResult to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      if (email != null) 'email': email,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'hasRelationship': hasRelationship,
      if (relationshipStatus != null) 'relationshipStatus': relationshipStatus,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSearchResult &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserSearchResult(id: $id, username: $username, hasRelationship: $hasRelationship)';
}

/// Abstract interface for GetFriendsUseCase.
///
/// TODO: Will be replaced with import from lib/features/sharing/domain/usecases/get_friends_usecase.dart
abstract class GetFriendsUseCase {
  /// Fetches all accepted friends.
  ///
  /// Returns a list of sharing relationships with status 'accepted'.
  Future<List<SharingRelationship>> call();
}

/// Abstract interface for GetPendingRequestsUseCase.
///
/// TODO: Will be replaced with import from lib/features/sharing/domain/usecases/get_pending_requests_usecase.dart
abstract class GetPendingRequestsUseCase {
  /// Fetches all pending friend requests.
  ///
  /// Returns a list of sharing relationships with status 'pending'.
  Future<List<SharingRelationship>> call();
}

/// Abstract interface for GetFriendStatsUseCase.
///
/// TODO: Will be replaced with import from lib/features/sharing/domain/usecases/get_friend_stats_usecase.dart
abstract class GetFriendStatsUseCase {
  /// Fetches statistics for all friends.
  ///
  /// Returns a list of friend statistics including step counts and streaks.
  Future<List<FriendStats>> call();
}

/// Abstract interface for SendFriendRequestUseCase.
///
/// TODO: Will be replaced with import from lib/features/sharing/domain/usecases/send_friend_request_usecase.dart
abstract class SendFriendRequestUseCase {
  /// Sends a friend request to the specified user.
  ///
  /// [targetUserId] - ID of the user to send the request to.
  /// Returns the created SharingRelationship.
  Future<SharingRelationship> call(String targetUserId);
}

/// Abstract interface for AcceptRequestUseCase.
///
/// TODO: Will be replaced with import from lib/features/sharing/domain/usecases/accept_request_usecase.dart
abstract class AcceptRequestUseCase {
  /// Accepts a pending friend request.
  ///
  /// [relationshipId] - ID of the relationship to accept.
  /// Returns the updated SharingRelationship with status 'accepted'.
  Future<SharingRelationship> call(String relationshipId);
}

/// Abstract interface for RejectRequestUseCase.
///
/// TODO: Will be replaced with import from lib/features/sharing/domain/usecases/reject_request_usecase.dart
abstract class RejectRequestUseCase {
  /// Rejects a pending friend request.
  ///
  /// [relationshipId] - ID of the relationship to reject.
  Future<void> call(String relationshipId);
}

/// Abstract interface for RemoveFriendUseCase.
///
/// TODO: Will be replaced with import from lib/features/sharing/domain/usecases/remove_friend_usecase.dart
abstract class RemoveFriendUseCase {
  /// Removes a friend relationship.
  ///
  /// [relationshipId] - ID of the relationship to remove.
  Future<void> call(String relationshipId);
}

/// Abstract interface for SearchUsersUseCase.
///
/// TODO: Will be replaced with import from lib/features/sharing/domain/usecases/search_users_usecase.dart
abstract class SearchUsersUseCase {
  /// Searches for users by query string.
  ///
  /// [query] - Search term (username or email).
  /// Returns a list of matching users.
  Future<List<UserSearchResult>> call(String query);
}

/// Sharing state management provider using ChangeNotifier.
///
/// Manages friend relationships, pending requests, friend statistics,
/// and user search. Implements [ChangeNotifier] for use with Provider.
///
/// Usage:
/// ```dart
/// final sharingProvider = context.watch<SharingProvider>();
/// if (sharingProvider.status == SharingStatus.loaded) {
///   // Show friends list
///   print('Friends: ${sharingProvider.friendCount}');
///   print('Pending: ${sharingProvider.pendingCount}');
/// }
/// ```
///
/// Features:
/// - Friend list management with real-time updates
/// - Pending request management with optimistic updates
/// - Friend statistics for activity comparison
/// - User search for adding new friends
/// - Error handling with user-friendly messages
class SharingProvider extends ChangeNotifier {
  /// Use case for fetching friends list.
  final GetFriendsUseCase _getFriends;

  /// Use case for fetching pending requests.
  final GetPendingRequestsUseCase _getPendingRequests;

  /// Use case for fetching friend statistics.
  final GetFriendStatsUseCase _getFriendStats;

  /// Use case for sending friend requests.
  final SendFriendRequestUseCase _sendFriendRequest;

  /// Use case for accepting friend requests.
  final AcceptRequestUseCase _acceptRequest;

  /// Use case for rejecting friend requests.
  final RejectRequestUseCase _rejectRequest;

  /// Use case for removing friends.
  final RemoveFriendUseCase _removeFriend;

  /// Use case for searching users.
  final SearchUsersUseCase _searchUsers;

  /// Current data loading status.
  SharingStatus _status = SharingStatus.initial;

  /// List of accepted friends.
  List<SharingRelationship> _friends = [];

  /// List of pending friend requests.
  List<SharingRelationship> _pendingRequests = [];

  /// List of friend statistics.
  List<FriendStats> _friendStats = [];

  /// List of user search results.
  List<UserSearchResult> _searchResults = [];

  /// Error message from the last failed operation.
  String? _errorMessage;

  /// Whether a search is in progress.
  bool _isSearching = false;

  /// Creates a new SharingProvider instance.
  ///
  /// [getFriends] - Use case for fetching friends
  /// [getPendingRequests] - Use case for fetching pending requests
  /// [getFriendStats] - Use case for fetching friend statistics
  /// [sendFriendRequest] - Use case for sending friend requests
  /// [acceptRequest] - Use case for accepting requests
  /// [rejectRequest] - Use case for rejecting requests
  /// [removeFriend] - Use case for removing friends
  /// [searchUsers] - Use case for searching users
  SharingProvider({
    required GetFriendsUseCase getFriends,
    required GetPendingRequestsUseCase getPendingRequests,
    required GetFriendStatsUseCase getFriendStats,
    required SendFriendRequestUseCase sendFriendRequest,
    required AcceptRequestUseCase acceptRequest,
    required RejectRequestUseCase rejectRequest,
    required RemoveFriendUseCase removeFriend,
    required SearchUsersUseCase searchUsers,
  })  : _getFriends = getFriends,
        _getPendingRequests = getPendingRequests,
        _getFriendStats = getFriendStats,
        _sendFriendRequest = sendFriendRequest,
        _acceptRequest = acceptRequest,
        _rejectRequest = rejectRequest,
        _removeFriend = removeFriend,
        _searchUsers = searchUsers;

  // =========================================================================
  // GETTERS
  // =========================================================================

  /// Returns the current data loading status.
  SharingStatus get status => _status;

  /// Returns the list of accepted friends (unmodifiable).
  List<SharingRelationship> get friends => List.unmodifiable(_friends);

  /// Returns the list of pending friend requests (unmodifiable).
  List<SharingRelationship> get pendingRequests =>
      List.unmodifiable(_pendingRequests);

  /// Returns the list of friend statistics (unmodifiable).
  List<FriendStats> get friendStats => List.unmodifiable(_friendStats);

  /// Returns the list of user search results (unmodifiable).
  List<UserSearchResult> get searchResults => List.unmodifiable(_searchResults);

  /// Returns the error message from the last failed operation, or null if no error.
  String? get errorMessage => _errorMessage;

  /// Returns true if a search is in progress.
  bool get isSearching => _isSearching;

  /// Returns true if data is currently being loaded.
  bool get isLoading => _status == SharingStatus.loading;

  /// Returns the number of accepted friends.
  int get friendCount => _friends.length;

  /// Returns the number of pending friend requests.
  int get pendingCount => _pendingRequests.length;

  /// Returns true if there are any pending requests.
  bool get hasPendingRequests => _pendingRequests.isNotEmpty;

  /// Returns true if there are any friends.
  bool get hasFriends => _friends.isNotEmpty;

  /// Returns true if there is any data available.
  bool get hasData =>
      _friends.isNotEmpty ||
      _pendingRequests.isNotEmpty ||
      _friendStats.isNotEmpty;

  // =========================================================================
  // STATE MANAGEMENT
  // =========================================================================

  /// Updates the internal state and notifies listeners.
  ///
  /// This helper method consolidates state changes to prevent multiple
  /// notifyListeners() calls and ensures consistent state updates.
  void _updateState({
    SharingStatus? status,
    List<SharingRelationship>? friends,
    List<SharingRelationship>? pendingRequests,
    List<FriendStats>? friendStats,
    List<UserSearchResult>? searchResults,
    String? error,
    bool? isSearching,
    bool clearFriends = false,
    bool clearPendingRequests = false,
    bool clearFriendStats = false,
    bool clearSearchResults = false,
    bool clearError = false,
  }) {
    if (status != null) _status = status;

    if (clearFriends) {
      _friends = [];
    } else if (friends != null) {
      _friends = friends;
    }

    if (clearPendingRequests) {
      _pendingRequests = [];
    } else if (pendingRequests != null) {
      _pendingRequests = pendingRequests;
    }

    if (clearFriendStats) {
      _friendStats = [];
    } else if (friendStats != null) {
      _friendStats = friendStats;
    }

    if (clearSearchResults) {
      _searchResults = [];
    } else if (searchResults != null) {
      _searchResults = searchResults;
    }

    if (clearError) {
      _errorMessage = null;
    } else if (error != null) {
      _errorMessage = error;
    }

    if (isSearching != null) {
      _isSearching = isSearching;
    }

    notifyListeners();
  }

  // =========================================================================
  // DATA LOADING
  // =========================================================================

  /// Loads all friends data including friends list and pending requests.
  ///
  /// This is the primary method to call when displaying the friends screen.
  /// It fetches friends and pending requests in parallel for optimal performance.
  ///
  /// Updates [status] to [SharingStatus.loaded] on success,
  /// or [SharingStatus.error] with [errorMessage] on failure.
  Future<void> loadFriendsData() async {
    _updateState(status: SharingStatus.loading, clearError: true);

    try {
      // Fetch data in parallel for better performance
      final results = await Future.wait([
        _getFriends.call(),
        _getPendingRequests.call(),
      ]);

      final friends = results[0];
      final pendingRequests = results[1];

      AppLogger.info(
        'Friends data loaded: ${friends.length} friends, '
        '${pendingRequests.length} pending requests',
      );

      _updateState(
        status: SharingStatus.loaded,
        friends: friends,
        pendingRequests: pendingRequests,
        clearError: true,
      );
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to load friends data', e);
      _updateState(
        status: SharingStatus.error,
        error: errorMsg,
      );
    }
  }

  /// Loads friend statistics for activity comparison.
  ///
  /// This should be called when displaying the friends activity screen.
  ///
  /// Updates [status] to [SharingStatus.loaded] on success,
  /// or [SharingStatus.error] with [errorMessage] on failure.
  Future<void> loadFriendStats() async {
    _updateState(status: SharingStatus.loading, clearError: true);

    try {
      final stats = await _getFriendStats.call();

      AppLogger.info('Friend stats loaded: ${stats.length} friends');

      _updateState(
        status: SharingStatus.loaded,
        friendStats: stats,
        clearError: true,
      );
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to load friend stats', e);
      _updateState(
        status: SharingStatus.error,
        error: errorMsg,
      );
    }
  }

  /// Refreshes all friends data.
  ///
  /// Use this for pull-to-refresh functionality.
  /// Same as [loadFriendsData] but semantically indicates a refresh operation.
  Future<void> refreshData() async {
    AppLogger.info('Refreshing sharing data');
    await loadFriendsData();
  }

  // =========================================================================
  // FRIEND REQUEST OPERATIONS
  // =========================================================================

  /// Sends a friend request to the specified user.
  ///
  /// [targetUserId] - ID of the user to send the request to.
  ///
  /// Updates the pending requests list on success.
  /// Sets [errorMessage] on failure.
  Future<void> sendFriendRequest(String targetUserId) async {
    _updateState(status: SharingStatus.loading, clearError: true);

    try {
      final relationship = await _sendFriendRequest.call(targetUserId);

      AppLogger.info('Friend request sent to user: $targetUserId');

      // Add to pending requests (as the requester, this shows in sent requests)
      final updatedPending = [..._pendingRequests, relationship];

      _updateState(
        status: SharingStatus.loaded,
        pendingRequests: updatedPending,
        clearError: true,
      );
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to send friend request', e);
      _updateState(
        status: SharingStatus.error,
        error: errorMsg,
      );
    }
  }

  /// Accepts a pending friend request with optimistic update.
  ///
  /// [relationshipId] - ID of the relationship to accept.
  ///
  /// Optimistically moves the request from pending to friends immediately,
  /// then rolls back on API error.
  Future<void> acceptRequest(String relationshipId) async {
    // Find the request to accept
    final requestIndex =
        _pendingRequests.indexWhere((r) => r.id == relationshipId);
    if (requestIndex == -1) {
      AppLogger.warning('Request not found for acceptance: $relationshipId');
      _updateState(error: 'Friend request not found');
      return;
    }

    final request = _pendingRequests[requestIndex];

    // Optimistic update: move from pending to friends immediately
    final updatedPending = List<SharingRelationship>.from(_pendingRequests)
      ..removeAt(requestIndex);
    final acceptedRelationship = request.copyWith(
      status: 'accepted',
      updatedAt: DateTime.now(),
    );
    final updatedFriends = [..._friends, acceptedRelationship];

    _updateState(
      pendingRequests: updatedPending,
      friends: updatedFriends,
      clearError: true,
    );

    try {
      // Make API call
      await _acceptRequest.call(relationshipId);
      AppLogger.info('Friend request accepted: $relationshipId');
    } catch (e) {
      // Rollback on error
      AppLogger.error('Failed to accept request, rolling back', e);

      final rolledBackPending = [..._pendingRequests, request];
      final rolledBackFriends = List<SharingRelationship>.from(_friends)
        ..removeWhere((r) => r.id == relationshipId);

      _updateState(
        pendingRequests: rolledBackPending,
        friends: rolledBackFriends,
        error: _parseError(e),
      );
    }
  }

  /// Rejects a pending friend request with optimistic update.
  ///
  /// [relationshipId] - ID of the relationship to reject.
  ///
  /// Optimistically removes the request from pending immediately,
  /// then rolls back on API error.
  Future<void> rejectRequest(String relationshipId) async {
    // Find the request to reject
    final requestIndex =
        _pendingRequests.indexWhere((r) => r.id == relationshipId);
    if (requestIndex == -1) {
      AppLogger.warning('Request not found for rejection: $relationshipId');
      _updateState(error: 'Friend request not found');
      return;
    }

    final request = _pendingRequests[requestIndex];

    // Optimistic update: remove from pending immediately
    final updatedPending = List<SharingRelationship>.from(_pendingRequests)
      ..removeAt(requestIndex);

    _updateState(
      pendingRequests: updatedPending,
      clearError: true,
    );

    try {
      // Make API call
      await _rejectRequest.call(relationshipId);
      AppLogger.info('Friend request rejected: $relationshipId');
    } catch (e) {
      // Rollback on error
      AppLogger.error('Failed to reject request, rolling back', e);

      final rolledBackPending = List<SharingRelationship>.from(_pendingRequests)
        ..insert(requestIndex, request);

      _updateState(
        pendingRequests: rolledBackPending,
        error: _parseError(e),
      );
    }
  }

  /// Removes a friend from the friends list.
  ///
  /// [relationshipId] - ID of the relationship to remove.
  ///
  /// Removes the friend from the list and updates friend stats.
  Future<void> removeFriend(String relationshipId) async {
    // Find the friend to remove
    final friendIndex = _friends.indexWhere((r) => r.id == relationshipId);
    if (friendIndex == -1) {
      AppLogger.warning('Friend not found for removal: $relationshipId');
      _updateState(error: 'Friend not found');
      return;
    }

    final friend = _friends[friendIndex];
    _updateState(status: SharingStatus.loading, clearError: true);

    try {
      await _removeFriend.call(relationshipId);

      AppLogger.info('Friend removed: $relationshipId');

      // Update friends list
      final updatedFriends = List<SharingRelationship>.from(_friends)
        ..removeAt(friendIndex);

      // Also remove from friend stats if present
      final updatedStats = List<FriendStats>.from(_friendStats)
        ..removeWhere((s) =>
            s.friendId == friend.targetId || s.friendId == friend.requesterId);

      _updateState(
        status: SharingStatus.loaded,
        friends: updatedFriends,
        friendStats: updatedStats,
        clearError: true,
      );
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to remove friend', e);
      _updateState(
        status: SharingStatus.error,
        error: errorMsg,
      );
    }
  }

  // =========================================================================
  // USER SEARCH
  // =========================================================================

  /// Searches for users to add as friends.
  ///
  /// [query] - Search term (username or email).
  ///
  /// Updates [searchResults] with matching users.
  /// Sets [isSearching] to true during the search.
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _updateState(clearSearchResults: true, isSearching: false);
      return;
    }

    _updateState(isSearching: true, clearError: true);

    try {
      final results = await _searchUsers.call(query);

      AppLogger.info('User search completed: ${results.length} results');

      _updateState(
        searchResults: results,
        isSearching: false,
        clearError: true,
      );
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('User search failed', e);
      _updateState(
        isSearching: false,
        error: errorMsg,
        clearSearchResults: true,
      );
    }
  }

  /// Clears the current search results.
  ///
  /// Call this when the user clears the search input.
  void clearSearch() {
    _updateState(clearSearchResults: true, isSearching: false);
  }

  // =========================================================================
  // ERROR HANDLING
  // =========================================================================

  /// Clears the current error message.
  ///
  /// Call this when displaying errors to reset the error state.
  void clearError() {
    _updateState(clearError: true);
  }

  /// Resets all data to initial state.
  ///
  /// Use this when logging out or switching users.
  void reset() {
    _updateState(
      status: SharingStatus.initial,
      clearFriends: true,
      clearPendingRequests: true,
      clearFriendStats: true,
      clearSearchResults: true,
      clearError: true,
      isSearching: false,
    );
    AppLogger.info('Sharing provider reset');
  }

  // =========================================================================
  // PRIVATE HELPERS
  // =========================================================================

  /// Parses error response into a user-friendly message.
  String _parseError(dynamic error) {
    if (error is Exception) {
      final errorStr = error.toString();

      // Check for common error patterns
      if (errorStr.contains('401')) {
        return 'Please log in to manage friends';
      }
      if (errorStr.contains('403')) {
        return 'You do not have permission for this action';
      }
      if (errorStr.contains('404')) {
        return 'User not found';
      }
      if (errorStr.contains('409')) {
        return 'A friend request already exists for this user';
      }
      if (errorStr.contains('500')) {
        return 'Server error. Please try again later';
      }
      if (errorStr.contains('SocketException') ||
          errorStr.contains('Connection refused')) {
        return 'Unable to connect. Please check your internet connection';
      }
      if (errorStr.contains('timeout')) {
        return 'Request timed out. Please try again';
      }
    }
    return 'An unexpected error occurred. Please try again';
  }

  @override
  void dispose() {
    AppLogger.info('SharingProvider disposed');
    super.dispose();
  }
}
