import '../../../../core/network/api_client.dart';
import '../../domain/entities/friend_stats.dart';
import '../../domain/entities/relationship.dart';

/// Remote data source for sharing/friends operations.
///
/// Handles all API calls related to friend relationships and shared stats.
abstract interface class SharingRemoteDataSource {
  /// Fetches all relationships from the API.
  Future<List<Relationship>> getRelationships();

  /// Fetches pending friend requests from the API.
  Future<List<Relationship>> getPendingRequests();

  /// Fetches accepted friends from the API.
  Future<List<Relationship>> getAcceptedFriends();

  /// Sends a friend request via the API.
  Future<Relationship> sendFriendRequest(String usernameOrEmail);

  /// Accepts a friend request via the API.
  Future<Relationship> acceptFriendRequest(String relationshipId);

  /// Rejects a friend request via the API.
  Future<Relationship> rejectFriendRequest(String relationshipId);

  /// Removes a friend via the API.
  Future<void> removeFriend(String relationshipId);

  /// Fetches all friends' stats from the API.
  Future<List<FriendStats>> getAllFriendsStats();

  /// Fetches a specific friend's stats from the API.
  Future<FriendStats> getFriendStats(String friendUserId);
}

/// Implementation of [SharingRemoteDataSource] using [ApiClient].
class SharingRemoteDataSourceImpl implements SharingRemoteDataSource {
  SharingRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  static const String _basePath = '/sharing';

  @override
  Future<List<Relationship>> getRelationships() async {
    final response = await _apiClient.get<List<dynamic>>('$_basePath/relationships');
    return (response.data ?? [])
        .map((json) => _relationshipFromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Relationship>> getPendingRequests() async {
    final response =
        await _apiClient.get<List<dynamic>>('$_basePath/requests/pending');
    return (response.data ?? [])
        .map((json) => _relationshipFromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Relationship>> getAcceptedFriends() async {
    final response = await _apiClient.get<List<dynamic>>('$_basePath/friends');
    return (response.data ?? [])
        .map((json) => _relationshipFromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Relationship> sendFriendRequest(String usernameOrEmail) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_basePath/requests',
      data: {'usernameOrEmail': usernameOrEmail},
    );
    return _relationshipFromJson(response.data!);
  }

  @override
  Future<Relationship> acceptFriendRequest(String relationshipId) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '$_basePath/requests/$relationshipId/accept',
    );
    return _relationshipFromJson(response.data!);
  }

  @override
  Future<Relationship> rejectFriendRequest(String relationshipId) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '$_basePath/requests/$relationshipId/reject',
    );
    return _relationshipFromJson(response.data!);
  }

  @override
  Future<void> removeFriend(String relationshipId) async {
    await _apiClient.put<void>('$_basePath/friends/$relationshipId/remove');
  }

  @override
  Future<List<FriendStats>> getAllFriendsStats() async {
    final response = await _apiClient.get<List<dynamic>>('$_basePath/stats');
    return (response.data ?? [])
        .map((json) => _friendStatsFromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FriendStats> getFriendStats(String friendUserId) async {
    final response =
        await _apiClient.get<Map<String, dynamic>>('$_basePath/stats/$friendUserId');
    return _friendStatsFromJson(response.data!);
  }

  /// Converts JSON map to [Relationship] entity.
  Relationship _relationshipFromJson(Map<String, dynamic> json) {
    return Relationship(
      id: json['id'] as String,
      requesterId: json['requesterId'] as String,
      requesterUsername: json['requesterUsername'] as String,
      addresseeId: json['addresseeId'] as String,
      addresseeUsername: json['addresseeUsername'] as String,
      status: _parseRelationshipStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Converts JSON map to [FriendStats] entity.
  FriendStats _friendStatsFromJson(Map<String, dynamic> json) {
    return FriendStats(
      userId: json['userId'] as String,
      username: json['username'] as String,
      todaySteps: json['todaySteps'] as int,
      goalSteps: json['goalSteps'] as int,
      weeklyAverage: (json['weeklyAverage'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  /// Parses relationship status string to enum.
  RelationshipStatus _parseRelationshipStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return RelationshipStatus.pending;
      case 'accepted':
        return RelationshipStatus.accepted;
      case 'rejected':
        return RelationshipStatus.rejected;
      case 'blocked':
        return RelationshipStatus.blocked;
      default:
        return RelationshipStatus.pending;
    }
  }
}
