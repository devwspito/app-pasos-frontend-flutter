import 'package:equatable/equatable.dart';

/// Represents the status of a sharing relationship.
///
/// - [pending]: Request has been sent but not yet accepted
/// - [accepted]: Both users have agreed to share
/// - [rejected]: Request was rejected by the target user
enum RelationshipStatus {
  pending,
  accepted,
  rejected,
}

/// Domain entity representing a sharing relationship between two users.
///
/// This entity contains information about the friend/sharing relationship,
/// including who initiated it, who received it, and the current status.
///
/// Example usage:
/// ```dart
/// final relationship = SharingRelationship(
///   id: 'rel-123',
///   requesterId: 'user-456',
///   receiverId: 'user-789',
///   requesterUsername: 'john_doe',
///   receiverUsername: 'jane_doe',
///   status: RelationshipStatus.accepted,
///   createdAt: DateTime.now(),
///   updatedAt: DateTime.now(),
/// );
/// ```
class SharingRelationship extends Equatable {
  /// Unique identifier for the relationship.
  final String id;

  /// ID of the user who sent the friend request.
  final String requesterId;

  /// ID of the user who received the friend request.
  final String receiverId;

  /// Username of the requester.
  final String requesterUsername;

  /// Username of the receiver.
  final String receiverUsername;

  /// Profile image URL of the requester (optional).
  final String? requesterProfileImageUrl;

  /// Profile image URL of the receiver (optional).
  final String? receiverProfileImageUrl;

  /// Current status of the relationship.
  final RelationshipStatus status;

  /// Timestamp when the relationship was created.
  final DateTime createdAt;

  /// Timestamp when the relationship was last updated.
  final DateTime? updatedAt;

  /// Creates a [SharingRelationship] instance.
  const SharingRelationship({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.requesterUsername,
    required this.receiverUsername,
    this.requesterProfileImageUrl,
    this.receiverProfileImageUrl,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  /// Returns true if this relationship is pending acceptance.
  bool get isPending => status == RelationshipStatus.pending;

  /// Returns true if this relationship has been accepted.
  bool get isAccepted => status == RelationshipStatus.accepted;

  /// Returns true if this relationship was rejected.
  bool get isRejected => status == RelationshipStatus.rejected;

  /// Returns the friend's user ID for a given user.
  ///
  /// [currentUserId] - The ID of the current user.
  /// Returns the other user's ID in the relationship.
  String getFriendId(String currentUserId) {
    return currentUserId == requesterId ? receiverId : requesterId;
  }

  /// Returns the friend's username for a given user.
  ///
  /// [currentUserId] - The ID of the current user.
  /// Returns the other user's username in the relationship.
  String getFriendUsername(String currentUserId) {
    return currentUserId == requesterId ? receiverUsername : requesterUsername;
  }

  /// Returns the friend's profile image URL for a given user.
  ///
  /// [currentUserId] - The ID of the current user.
  /// Returns the other user's profile image URL, or null if not set.
  String? getFriendProfileImageUrl(String currentUserId) {
    return currentUserId == requesterId
        ? receiverProfileImageUrl
        : requesterProfileImageUrl;
  }

  /// Creates a copy of this relationship with optional field overrides.
  SharingRelationship copyWith({
    String? id,
    String? requesterId,
    String? receiverId,
    String? requesterUsername,
    String? receiverUsername,
    String? requesterProfileImageUrl,
    String? receiverProfileImageUrl,
    RelationshipStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SharingRelationship(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      receiverId: receiverId ?? this.receiverId,
      requesterUsername: requesterUsername ?? this.requesterUsername,
      receiverUsername: receiverUsername ?? this.receiverUsername,
      requesterProfileImageUrl:
          requesterProfileImageUrl ?? this.requesterProfileImageUrl,
      receiverProfileImageUrl:
          receiverProfileImageUrl ?? this.receiverProfileImageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        requesterId,
        receiverId,
        requesterUsername,
        receiverUsername,
        requesterProfileImageUrl,
        receiverProfileImageUrl,
        status,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'SharingRelationship(id: $id, requesterId: $requesterId, '
        'receiverId: $receiverId, status: $status)';
  }
}

/// Domain entity representing aggregated statistics for a friend.
///
/// Contains step data and comparison metrics between the current user
/// and a friend for competitive/social features.
///
/// Example usage:
/// ```dart
/// final stats = FriendStats(
///   friendId: 'user-789',
///   friendUsername: 'jane_doe',
///   todaySteps: 8500,
///   weeklyAverage: 7200.5,
///   lastSevenDaysSteps: [7000, 8000, 6500, 9000, 7500, 8000, 8500],
///   lastUpdated: DateTime.now(),
/// );
/// ```
class FriendStats extends Equatable {
  /// ID of the friend.
  final String friendId;

  /// Username of the friend.
  final String friendUsername;

  /// Profile image URL of the friend (optional).
  final String? friendProfileImageUrl;

  /// Friend's step count for today.
  final int todaySteps;

  /// Friend's weekly average step count.
  final double weeklyAverage;

  /// Friend's step counts for the last 7 days (oldest to newest).
  final List<int> lastSevenDaysSteps;

  /// Timestamp when these stats were last updated.
  final DateTime lastUpdated;

  /// Creates a [FriendStats] instance.
  const FriendStats({
    required this.friendId,
    required this.friendUsername,
    this.friendProfileImageUrl,
    required this.todaySteps,
    required this.weeklyAverage,
    required this.lastSevenDaysSteps,
    required this.lastUpdated,
  });

  /// Returns the total steps for the last 7 days.
  int get weeklyTotal => lastSevenDaysSteps.fold(0, (sum, steps) => sum + steps);

  /// Returns true if the friend has more steps today than the given count.
  bool isAheadOf(int otherSteps) => todaySteps > otherSteps;

  /// Returns the step difference between the friend and the given count.
  ///
  /// Positive means the friend has more steps.
  int stepDifference(int otherSteps) => todaySteps - otherSteps;

  /// Creates a copy of this stats with optional field overrides.
  FriendStats copyWith({
    String? friendId,
    String? friendUsername,
    String? friendProfileImageUrl,
    int? todaySteps,
    double? weeklyAverage,
    List<int>? lastSevenDaysSteps,
    DateTime? lastUpdated,
  }) {
    return FriendStats(
      friendId: friendId ?? this.friendId,
      friendUsername: friendUsername ?? this.friendUsername,
      friendProfileImageUrl:
          friendProfileImageUrl ?? this.friendProfileImageUrl,
      todaySteps: todaySteps ?? this.todaySteps,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      lastSevenDaysSteps: lastSevenDaysSteps ?? this.lastSevenDaysSteps,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        friendId,
        friendUsername,
        friendProfileImageUrl,
        todaySteps,
        weeklyAverage,
        lastSevenDaysSteps,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'FriendStats(friendId: $friendId, friendUsername: $friendUsername, '
        'todaySteps: $todaySteps, weeklyAverage: $weeklyAverage)';
  }
}

/// Domain entity representing a user search result.
///
/// Used when searching for users to add as friends.
/// Contains basic user info and relationship status flags.
///
/// Example usage:
/// ```dart
/// final result = UserSearchResult(
///   id: 'user-123',
///   username: 'new_friend',
///   profileImageUrl: 'https://example.com/avatar.png',
///   isAlreadyFriend: false,
///   hasPendingRequest: false,
/// );
/// ```
class UserSearchResult extends Equatable {
  /// Unique identifier for the user.
  final String id;

  /// Username of the user.
  final String username;

  /// Profile image URL (optional).
  final String? profileImageUrl;

  /// True if this user is already a friend.
  final bool isAlreadyFriend;

  /// True if there's a pending friend request with this user.
  final bool hasPendingRequest;

  /// Creates a [UserSearchResult] instance.
  const UserSearchResult({
    required this.id,
    required this.username,
    this.profileImageUrl,
    required this.isAlreadyFriend,
    required this.hasPendingRequest,
  });

  /// Returns true if the user can receive a friend request.
  ///
  /// A user can receive a request if they're not already a friend
  /// and there's no pending request.
  bool get canSendRequest => !isAlreadyFriend && !hasPendingRequest;

  /// Creates a copy of this search result with optional field overrides.
  UserSearchResult copyWith({
    String? id,
    String? username,
    String? profileImageUrl,
    bool? isAlreadyFriend,
    bool? hasPendingRequest,
  }) {
    return UserSearchResult(
      id: id ?? this.id,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isAlreadyFriend: isAlreadyFriend ?? this.isAlreadyFriend,
      hasPendingRequest: hasPendingRequest ?? this.hasPendingRequest,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        profileImageUrl,
        isAlreadyFriend,
        hasPendingRequest,
      ];

  @override
  String toString() {
    return 'UserSearchResult(id: $id, username: $username, '
        'isAlreadyFriend: $isAlreadyFriend, hasPendingRequest: $hasPendingRequest)';
  }
}

/// Abstract repository interface for sharing operations.
///
/// Defines the contract for managing friend relationships, sharing requests,
/// and friend statistics. Implementations should handle data persistence
/// and network communication.
///
/// This is a domain layer interface - implementations should NOT be in the
/// domain layer but in the data layer.
///
/// Example implementation in data layer:
/// ```dart
/// class SharingRepositoryImpl implements SharingRepository {
///   final SharingRemoteDataSource remoteDataSource;
///
///   @override
///   Future<List<SharingRelationship>> getRelationships() async {
///     final models = await remoteDataSource.getRelationships();
///     return models.map((m) => m.toEntity()).toList();
///   }
/// }
/// ```
abstract class SharingRepository {
  /// Fetches all sharing relationships for the current user.
  ///
  /// Returns a list of all relationships regardless of status.
  /// Throws an exception if the operation fails.
  Future<List<SharingRelationship>> getRelationships();

  /// Fetches all pending friend requests for the current user.
  ///
  /// Returns only relationships where the current user is the receiver
  /// and status is pending.
  /// Throws an exception if the operation fails.
  Future<List<SharingRelationship>> getPendingRequests();

  /// Sends a friend request to another user.
  ///
  /// [targetUserId] - The ID of the user to send the request to.
  /// Returns the created relationship with pending status.
  /// Throws an exception if the request fails or user not found.
  Future<SharingRelationship> sendFriendRequest(String targetUserId);

  /// Accepts a pending friend request.
  ///
  /// [relationshipId] - The ID of the relationship to accept.
  /// Returns the updated relationship with accepted status.
  /// Throws an exception if the relationship is not found or not pending.
  Future<SharingRelationship> acceptRequest(String relationshipId);

  /// Rejects a pending friend request.
  ///
  /// [relationshipId] - The ID of the relationship to reject.
  /// Throws an exception if the relationship is not found or not pending.
  Future<void> rejectRequest(String relationshipId);

  /// Removes an existing friend (deletes the relationship).
  ///
  /// [relationshipId] - The ID of the relationship to remove.
  /// Throws an exception if the relationship is not found.
  Future<void> removeFriend(String relationshipId);

  /// Fetches step statistics for all friends.
  ///
  /// Returns statistics including today's steps, weekly average,
  /// and historical data for comparison features.
  /// Throws an exception if the operation fails.
  Future<List<FriendStats>> getFriendStats();

  /// Searches for users by username.
  ///
  /// [query] - The search query (partial username match).
  /// Returns a list of matching users with relationship status flags.
  /// Throws an exception if the search fails.
  Future<List<UserSearchResult>> searchUsers(String query);
}
