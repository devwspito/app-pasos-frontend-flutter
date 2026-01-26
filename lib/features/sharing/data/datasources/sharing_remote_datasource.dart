import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';

/// Local API endpoint constants for sharing feature.
///
/// These endpoints are defined locally as per the story requirements
/// to avoid modifying the central ApiEndpoints file.
class _SharingEndpoints {
  static const String relationships = '/sharing/relationships';
  static const String pendingRequests = '/sharing/requests/pending';
  static const String sendRequest = '/sharing/requests';
  static const String friendStats = '/sharing/friends/stats';
  static const String usersSearch = '/users/search';

  /// Constructs the accept request endpoint for a given relationship ID.
  static String acceptRequest(String relationshipId) =>
      '/sharing/requests/$relationshipId/accept';

  /// Constructs the reject request endpoint for a given relationship ID.
  static String rejectRequest(String relationshipId) =>
      '/sharing/requests/$relationshipId/reject';

  /// Constructs the remove friend endpoint for a given relationship ID.
  static String removeRelationship(String relationshipId) =>
      '/sharing/relationships/$relationshipId';

  _SharingEndpoints._();
}

/// Enum representing the status of a sharing relationship.
enum SharingRelationshipStatus {
  pending,
  accepted,
  rejected,
}

/// Model representing a sharing relationship between two users.
///
/// This model is used for friend requests and established friendships.
class SharingRelationshipModel {
  final String id;
  final String requesterId;
  final String requesterUsername;
  final String? requesterProfileImageUrl;
  final String targetId;
  final String targetUsername;
  final String? targetProfileImageUrl;
  final SharingRelationshipStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  const SharingRelationshipModel({
    required this.id,
    required this.requesterId,
    required this.requesterUsername,
    this.requesterProfileImageUrl,
    required this.targetId,
    required this.targetUsername,
    this.targetProfileImageUrl,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
  });

  /// Creates a [SharingRelationshipModel] from JSON data.
  factory SharingRelationshipModel.fromJson(Map<String, dynamic> json) {
    return SharingRelationshipModel(
      id: json['id'] as String,
      requesterId: json['requesterId'] as String,
      requesterUsername: json['requesterUsername'] as String,
      requesterProfileImageUrl: json['requesterProfileImageUrl'] as String?,
      targetId: json['targetId'] as String,
      targetUsername: json['targetUsername'] as String,
      targetProfileImageUrl: json['targetProfileImageUrl'] as String?,
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
    );
  }

  /// Converts this model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterId': requesterId,
      'requesterUsername': requesterUsername,
      'requesterProfileImageUrl': requesterProfileImageUrl,
      'targetId': targetId,
      'targetUsername': targetUsername,
      'targetProfileImageUrl': targetProfileImageUrl,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
    };
  }

  static SharingRelationshipStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return SharingRelationshipStatus.pending;
      case 'accepted':
        return SharingRelationshipStatus.accepted;
      case 'rejected':
        return SharingRelationshipStatus.rejected;
      default:
        return SharingRelationshipStatus.pending;
    }
  }
}

/// Model representing step statistics for a friend.
///
/// Used to display friend activity and comparisons.
class FriendStatsModel {
  final String friendId;
  final String friendUsername;
  final String? friendProfileImageUrl;
  final int todaySteps;
  final int weeklyAverage;
  final int currentStreak;
  final DateTime? lastActiveAt;

  const FriendStatsModel({
    required this.friendId,
    required this.friendUsername,
    this.friendProfileImageUrl,
    required this.todaySteps,
    required this.weeklyAverage,
    required this.currentStreak,
    this.lastActiveAt,
  });

  /// Creates a [FriendStatsModel] from JSON data.
  factory FriendStatsModel.fromJson(Map<String, dynamic> json) {
    return FriendStatsModel(
      friendId: json['friendId'] as String,
      friendUsername: json['friendUsername'] as String,
      friendProfileImageUrl: json['friendProfileImageUrl'] as String?,
      todaySteps: json['todaySteps'] as int? ?? 0,
      weeklyAverage: json['weeklyAverage'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
    );
  }

  /// Converts this model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'friendUsername': friendUsername,
      'friendProfileImageUrl': friendProfileImageUrl,
      'todaySteps': todaySteps,
      'weeklyAverage': weeklyAverage,
      'currentStreak': currentStreak,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
    };
  }
}

/// Model representing a user search result.
///
/// Includes relationship status information for the search context.
class UserSearchResult {
  final String id;
  final String username;
  final String? profileImageUrl;
  final bool isAlreadyFriend;
  final bool hasPendingRequest;

  const UserSearchResult({
    required this.id,
    required this.username,
    this.profileImageUrl,
    required this.isAlreadyFriend,
    required this.hasPendingRequest,
  });

  /// Creates a [UserSearchResult] from JSON data.
  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      isAlreadyFriend: json['isAlreadyFriend'] as bool? ?? false,
      hasPendingRequest: json['hasPendingRequest'] as bool? ?? false,
    );
  }

  /// Converts this model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'isAlreadyFriend': isAlreadyFriend,
      'hasPendingRequest': hasPendingRequest,
    };
  }
}

/// Abstract interface for remote sharing data operations.
///
/// Defines the contract for friend requests, relationships, and user search
/// from the backend API. Implementations should handle network errors and
/// data transformation.
abstract class SharingRemoteDataSource {
  /// Fetches all accepted sharing relationships (friends).
  ///
  /// Returns a list of [SharingRelationshipModel] representing friends.
  /// May return an empty list if no friends exist.
  /// Throws [DioException] on network errors.
  Future<List<SharingRelationshipModel>> getRelationships();

  /// Fetches all pending friend requests (both sent and received).
  ///
  /// Returns a list of [SharingRelationshipModel] with pending status.
  /// May return an empty list if no pending requests exist.
  Future<List<SharingRelationshipModel>> getPendingRequests();

  /// Sends a friend request to another user.
  ///
  /// [targetUserId] - The ID of the user to send the request to.
  /// Returns the created [SharingRelationshipModel] with pending status.
  /// Throws [DioException] if the request fails (e.g., user not found,
  /// request already exists).
  Future<SharingRelationshipModel> sendFriendRequest(String targetUserId);

  /// Accepts a pending friend request.
  ///
  /// [relationshipId] - The ID of the relationship to accept.
  /// Returns the updated [SharingRelationshipModel] with accepted status.
  /// Throws [DioException] if the request fails or relationship not found.
  Future<SharingRelationshipModel> acceptRequest(String relationshipId);

  /// Rejects a pending friend request.
  ///
  /// [relationshipId] - The ID of the relationship to reject.
  /// Throws [DioException] if the request fails or relationship not found.
  Future<void> rejectRequest(String relationshipId);

  /// Removes an existing friend relationship.
  ///
  /// [relationshipId] - The ID of the relationship to remove.
  /// Throws [DioException] if the request fails or relationship not found.
  Future<void> removeFriend(String relationshipId);

  /// Fetches step statistics for all friends.
  ///
  /// Returns a list of [FriendStatsModel] with step data for each friend.
  /// May return an empty list if no friends exist.
  Future<List<FriendStatsModel>> getFriendStats();

  /// Searches for users by username query.
  ///
  /// [query] - The search query string to match against usernames.
  /// Returns a list of [UserSearchResult] matching the query.
  /// May return an empty list if no matches found.
  Future<List<UserSearchResult>> searchUsers(String query);
}

/// Implementation of [SharingRemoteDataSource] using DioClient.
///
/// Uses the singleton [DioClient] for all HTTP operations.
/// Handles JSON parsing and error transformation.
class SharingRemoteDataSourceImpl implements SharingRemoteDataSource {
  final DioClient _dioClient;

  /// Creates a [SharingRemoteDataSourceImpl] instance.
  ///
  /// [dioClient] - Optional DioClient instance. Uses singleton if not provided.
  SharingRemoteDataSourceImpl({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  @override
  Future<List<SharingRelationshipModel>> getRelationships() async {
    final response = await _dioClient.get<List<dynamic>>(
      _SharingEndpoints.relationships,
    );

    if (response.data == null) {
      return [];
    }

    return response.data!
        .map((json) =>
            SharingRelationshipModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SharingRelationshipModel>> getPendingRequests() async {
    final response = await _dioClient.get<List<dynamic>>(
      _SharingEndpoints.pendingRequests,
    );

    if (response.data == null) {
      return [];
    }

    return response.data!
        .map((json) =>
            SharingRelationshipModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SharingRelationshipModel> sendFriendRequest(String targetUserId) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      _SharingEndpoints.sendRequest,
      data: {'targetUserId': targetUserId},
    );

    return SharingRelationshipModel.fromJson(response.data!);
  }

  @override
  Future<SharingRelationshipModel> acceptRequest(String relationshipId) async {
    final response = await _dioClient.put<Map<String, dynamic>>(
      _SharingEndpoints.acceptRequest(relationshipId),
    );

    return SharingRelationshipModel.fromJson(response.data!);
  }

  @override
  Future<void> rejectRequest(String relationshipId) async {
    await _dioClient.put<void>(
      _SharingEndpoints.rejectRequest(relationshipId),
    );
  }

  @override
  Future<void> removeFriend(String relationshipId) async {
    await _dioClient.delete<void>(
      _SharingEndpoints.removeRelationship(relationshipId),
    );
  }

  @override
  Future<List<FriendStatsModel>> getFriendStats() async {
    final response = await _dioClient.get<List<dynamic>>(
      _SharingEndpoints.friendStats,
    );

    if (response.data == null) {
      return [];
    }

    return response.data!
        .map((json) => FriendStatsModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<UserSearchResult>> searchUsers(String query) async {
    try {
      final response = await _dioClient.get<List<dynamic>>(
        _SharingEndpoints.usersSearch,
        queryParameters: {'q': query},
      );

      if (response.data == null) {
        return [];
      }

      return response.data!
          .map((json) => UserSearchResult.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Return empty list for 404 (no users found)
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }
}
