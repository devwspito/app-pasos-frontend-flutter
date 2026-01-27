/// Remote data source for sharing operations.
///
/// This file defines the interface and implementation for sharing
/// API calls using the ApiClient.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/core/network/api_client.dart';
import 'package:app_pasos_frontend/features/sharing/data/models/friend_stats_model.dart';
import 'package:app_pasos_frontend/features/sharing/data/models/shared_user_model.dart';
import 'package:app_pasos_frontend/features/sharing/data/models/sharing_relationship_model.dart';

/// Abstract interface for sharing remote data operations.
///
/// This interface defines all sharing-related API calls.
/// Implementations should use the [ApiClient] for network requests.
abstract interface class SharingRemoteDatasource {
  /// Gets all sharing relationships for the current user.
  ///
  /// Returns a list of [SharingRelationshipModel] containing both
  /// sent and received sharing requests.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<List<SharingRelationshipModel>> getRelationships();

  /// Sends a sharing request to another user.
  ///
  /// [toUserId] - The ID of the user to send the request to.
  ///
  /// Returns the created [SharingRelationshipModel] with 'pending' status.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ValidationException] if toUserId is invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<SharingRelationshipModel> sendRequest({required String toUserId});

  /// Accepts a pending sharing request.
  ///
  /// [relationshipId] - The ID of the relationship to accept.
  ///
  /// Returns the updated [SharingRelationshipModel] with 'accepted' status.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<SharingRelationshipModel> acceptRequest({
    required String relationshipId,
  });

  /// Rejects a pending sharing request.
  ///
  /// [relationshipId] - The ID of the relationship to reject.
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<void> rejectRequest({required String relationshipId});

  /// Revokes an existing sharing relationship.
  ///
  /// [relationshipId] - The ID of the relationship to revoke.
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<void> revokeSharing({required String relationshipId});

  /// Gets step statistics for a specific friend.
  ///
  /// [friendId] - The ID of the friend to get stats for.
  ///
  /// Returns [FriendStatsModel] containing the friend's step statistics.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<FriendStatsModel> getFriendStats({required String friendId});

  /// Searches for users to share with.
  ///
  /// [query] - The search query (name or email).
  ///
  /// Returns a list of [SharedUserModel] matching the query.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ValidationException] if query is invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<List<SharedUserModel>> searchUsers({required String query});
}

/// Implementation of [SharingRemoteDatasource] using [ApiClient].
///
/// This class handles all sharing API calls, converting
/// responses to models and handling errors appropriately.
///
/// Example usage:
/// ```dart
/// final datasource = SharingRemoteDatasourceImpl(client: apiClient);
/// final relationships = await datasource.getRelationships();
/// ```
class SharingRemoteDatasourceImpl implements SharingRemoteDatasource {
  /// Creates a [SharingRemoteDatasourceImpl] with the given [ApiClient].
  ///
  /// [client] - The API client for making HTTP requests.
  SharingRemoteDatasourceImpl({required ApiClient client}) : _client = client;

  /// The API client for making HTTP requests.
  final ApiClient _client;

  /// API endpoint paths for sharing operations.
  /// Note: These will be moved to ApiEndpoints in a future story.
  static const String _sharingRelationships = '/sharing/relationships';
  static const String _sharingRequest = '/sharing/request';
  static const String _sharingAccept = '/sharing/accept';
  static const String _sharingReject = '/sharing/reject';
  static const String _sharingRevoke = '/sharing/revoke';
  static const String _sharingStats = '/sharing/stats';
  static const String _sharingSearch = '/sharing/search';

  @override
  Future<List<SharingRelationshipModel>> getRelationships() async {
    final response = await _client.get<Map<String, dynamic>>(
      _sharingRelationships,
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle { relationships: [...] } or { data: [...] } response format
    final relationshipsList =
        data['relationships'] ?? data['data'] ?? <dynamic>[];
    return SharingRelationshipModel.fromJsonList(relationshipsList);
  }

  @override
  Future<SharingRelationshipModel> sendRequest({
    required String toUserId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      _sharingRequest,
      data: {'toUserId': toUserId},
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle both wrapped and unwrapped responses
    final relationshipData =
        data['relationship'] as Map<String, dynamic>? ?? data;
    return SharingRelationshipModel.fromJson(relationshipData);
  }

  @override
  Future<SharingRelationshipModel> acceptRequest({
    required String relationshipId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      _sharingAccept,
      data: {'relationshipId': relationshipId},
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle both wrapped and unwrapped responses
    final relationshipData =
        data['relationship'] as Map<String, dynamic>? ?? data;
    return SharingRelationshipModel.fromJson(relationshipData);
  }

  @override
  Future<void> rejectRequest({required String relationshipId}) async {
    final response = await _client.post<Map<String, dynamic>>(
      _sharingReject,
      data: {'relationshipId': relationshipId},
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Success response may contain { success: true } or similar
    // No return value needed for reject operation
  }

  @override
  Future<void> revokeSharing({required String relationshipId}) async {
    // Note: Using POST instead of DELETE for data safety
    // The backend should handle this as a soft-delete or status change
    final response = await _client.post<Map<String, dynamic>>(
      _sharingRevoke,
      data: {'relationshipId': relationshipId},
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Success response may contain { success: true } or similar
    // No return value needed for revoke operation
  }

  @override
  Future<FriendStatsModel> getFriendStats({required String friendId}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '$_sharingStats/$friendId',
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle both wrapped and unwrapped responses
    final statsData = data['stats'] as Map<String, dynamic>? ?? data;
    return FriendStatsModel.fromJson(statsData);
  }

  @override
  Future<List<SharedUserModel>> searchUsers({required String query}) async {
    final response = await _client.get<Map<String, dynamic>>(
      _sharingSearch,
      queryParameters: {'query': query},
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }

    // Handle { users: [...] } or { data: [...] } response format
    final usersList = data['users'] ?? data['data'] ?? <dynamic>[];
    return SharedUserModel.fromJsonList(usersList);
  }
}
