/// Sharing repository implementation.
///
/// This file implements the [SharingRepository] interface, coordinating
/// data operations through the remote datasource.
library;

import 'package:app_pasos_frontend/features/sharing/data/datasources/sharing_remote_datasource.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/friend_stats.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/shared_user.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/sharing_relationship.dart';
import 'package:app_pasos_frontend/features/sharing/domain/repositories/sharing_repository.dart';

/// Implementation of [SharingRepository] using the remote datasource.
///
/// This class implements the sharing business logic, making API calls
/// through the datasource and returning domain entities.
///
/// Example usage:
/// ```dart
/// final repository = SharingRepositoryImpl(
///   datasource: sharingDatasource,
/// );
///
/// final relationships = await repository.getRelationships();
/// ```
class SharingRepositoryImpl implements SharingRepository {
  /// Creates a [SharingRepositoryImpl] with the required dependencies.
  ///
  /// [datasource] - The remote datasource for API calls.
  SharingRepositoryImpl({
    required SharingRemoteDatasource datasource,
  }) : _datasource = datasource;

  /// The remote datasource for API operations.
  final SharingRemoteDatasource _datasource;

  @override
  Future<List<SharingRelationship>> getRelationships() async {
    // The datasource returns List<SharingRelationshipModel> which extends
    // SharingRelationship
    return _datasource.getRelationships();
  }

  @override
  Future<SharingRelationship> sendRequest({required String toUserId}) async {
    // The datasource returns SharingRelationshipModel which extends
    // SharingRelationship
    return _datasource.sendRequest(toUserId: toUserId);
  }

  @override
  Future<SharingRelationship> acceptRequest({
    required String relationshipId,
  }) async {
    // The datasource returns SharingRelationshipModel which extends
    // SharingRelationship
    return _datasource.acceptRequest(relationshipId: relationshipId);
  }

  @override
  Future<void> rejectRequest({required String relationshipId}) async {
    // Delegate to datasource - no return value needed
    await _datasource.rejectRequest(relationshipId: relationshipId);
  }

  @override
  Future<void> revokeSharing({required String relationshipId}) async {
    // Delegate to datasource - no return value needed
    await _datasource.revokeSharing(relationshipId: relationshipId);
  }

  @override
  Future<FriendStats> getFriendStats({required String friendId}) async {
    // The datasource returns FriendStatsModel which extends FriendStats
    return _datasource.getFriendStats(friendId: friendId);
  }

  @override
  Future<List<SharedUser>> searchUsers({required String query}) async {
    // The datasource returns List<SharedUserModel> which extends SharedUser
    return _datasource.searchUsers(query: query);
  }
}
