import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/shared_user_stats_model.dart';
import '../models/sharing_relationship_model.dart';

/// Remote data source for sharing feature.
///
/// Handles all HTTP calls related to sharing relationships
/// and shared user statistics using the ApiClient.
class SharingRemoteDataSource {
  final ApiClient _apiClient;

  SharingRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Fetches all sharing relationships for the current user.
  ///
  /// Returns list of [SharingRelationshipModel].
  /// Throws [ServerException] on API errors.
  Future<List<SharingRelationshipModel>> getRelationships() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.sharingRelationships,
      );

      if (response.statusCode != 200) {
        throw ServerException.fromStatusCode(
          response.statusCode ?? 500,
          endpoint: ApiEndpoints.sharingRelationships,
        );
      }

      final data = response.data;
      if (data == null) {
        return [];
      }

      return data
          .map((json) =>
              SharingRelationshipModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to fetch sharing relationships: ${e.toString()}',
        endpoint: ApiEndpoints.sharingRelationships,
        requestMethod: 'GET',
      );
    }
  }

  /// Sends a sharing request to another user.
  ///
  /// [targetEmail] The email address of the user to share with.
  ///
  /// Returns the created [SharingRelationshipModel].
  /// Throws [ServerException] on API errors.
  Future<SharingRelationshipModel> sendRequest({
    required String targetEmail,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.sharingRequest,
        data: {'targetEmail': targetEmail},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException.fromStatusCode(
          response.statusCode ?? 500,
          endpoint: ApiEndpoints.sharingRequest,
        );
      }

      final data = response.data;
      if (data == null) {
        throw const ServerException(
          message: 'Empty response from server',
          endpoint: ApiEndpoints.sharingRequest,
          requestMethod: 'POST',
        );
      }

      return SharingRelationshipModel.fromJson(data);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to send sharing request: ${e.toString()}',
        endpoint: ApiEndpoints.sharingRequest,
        requestMethod: 'POST',
      );
    }
  }

  /// Accepts a pending sharing request.
  ///
  /// [relationshipId] The ID of the relationship to accept.
  ///
  /// Returns the updated [SharingRelationshipModel].
  /// Throws [ServerException] on API errors.
  Future<SharingRelationshipModel> acceptRequest({
    required String relationshipId,
  }) async {
    final endpoint = ApiEndpoints.acceptSharingRequest(relationshipId);
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(endpoint);

      if (response.statusCode != 200) {
        throw ServerException.fromStatusCode(
          response.statusCode ?? 500,
          endpoint: endpoint,
        );
      }

      final data = response.data;
      if (data == null) {
        throw ServerException(
          message: 'Empty response from server',
          endpoint: endpoint,
          requestMethod: 'POST',
        );
      }

      return SharingRelationshipModel.fromJson(data);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to accept sharing request: ${e.toString()}',
        endpoint: endpoint,
        requestMethod: 'POST',
      );
    }
  }

  /// Rejects a pending sharing request.
  ///
  /// [relationshipId] The ID of the relationship to reject.
  ///
  /// Returns the updated [SharingRelationshipModel].
  /// Throws [ServerException] on API errors.
  Future<SharingRelationshipModel> rejectRequest({
    required String relationshipId,
  }) async {
    final endpoint = ApiEndpoints.rejectSharingRequest(relationshipId);
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(endpoint);

      if (response.statusCode != 200) {
        throw ServerException.fromStatusCode(
          response.statusCode ?? 500,
          endpoint: endpoint,
        );
      }

      final data = response.data;
      if (data == null) {
        throw ServerException(
          message: 'Empty response from server',
          endpoint: endpoint,
          requestMethod: 'POST',
        );
      }

      return SharingRelationshipModel.fromJson(data);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to reject sharing request: ${e.toString()}',
        endpoint: endpoint,
        requestMethod: 'POST',
      );
    }
  }

  /// Removes an existing sharing relationship.
  ///
  /// [relationshipId] The ID of the relationship to remove.
  ///
  /// Throws [ServerException] on API errors.
  Future<void> removeRelationship({required String relationshipId}) async {
    final endpoint = ApiEndpoints.removeSharingRelationship(relationshipId);
    try {
      final response = await _apiClient.delete<void>(endpoint);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException.fromStatusCode(
          response.statusCode ?? 500,
          endpoint: endpoint,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to remove sharing relationship: ${e.toString()}',
        endpoint: endpoint,
        requestMethod: 'DELETE',
      );
    }
  }

  /// Fetches statistics for a specific shared user.
  ///
  /// [friendId] The ID of the friend to get stats for.
  ///
  /// Returns [SharedUserStatsModel] for the specified friend.
  /// Throws [ServerException] on API errors.
  Future<SharedUserStatsModel> getSharedStats({required String friendId}) async {
    final endpoint = ApiEndpoints.sharedStats(friendId);
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(endpoint);

      if (response.statusCode != 200) {
        throw ServerException.fromStatusCode(
          response.statusCode ?? 500,
          endpoint: endpoint,
        );
      }

      final data = response.data;
      if (data == null) {
        throw ServerException(
          message: 'Empty response from server',
          endpoint: endpoint,
          requestMethod: 'GET',
        );
      }

      return SharedUserStatsModel.fromJson(data);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to fetch shared stats: ${e.toString()}',
        endpoint: endpoint,
        requestMethod: 'GET',
      );
    }
  }

  /// Fetches statistics for all shared users (friends).
  ///
  /// Returns list of [SharedUserStatsModel] for all friends.
  /// Throws [ServerException] on API errors.
  Future<List<SharedUserStatsModel>> getAllSharedStats() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.allSharedStats,
      );

      if (response.statusCode != 200) {
        throw ServerException.fromStatusCode(
          response.statusCode ?? 500,
          endpoint: ApiEndpoints.allSharedStats,
        );
      }

      final data = response.data;
      if (data == null) {
        return [];
      }

      return data
          .map((json) =>
              SharedUserStatsModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to fetch all shared stats: ${e.toString()}',
        endpoint: ApiEndpoints.allSharedStats,
        requestMethod: 'GET',
      );
    }
  }
}
