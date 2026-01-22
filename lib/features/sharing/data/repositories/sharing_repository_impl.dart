import '../../domain/entities/shared_user_stats.dart';
import '../../domain/entities/sharing_relationship.dart';
import '../../domain/repositories/sharing_repository.dart';
import '../datasources/sharing_remote_datasource.dart';

/// Implementation of [SharingRepository] that uses remote data source.
///
/// Delegates all operations to the remote data source and
/// performs model-to-entity conversion where needed.
class SharingRepositoryImpl implements SharingRepository {
  final SharingRemoteDataSource _remoteDataSource;

  SharingRepositoryImpl({required SharingRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<SharingRelationship>> getRelationships() async {
    final models = await _remoteDataSource.getRelationships();
    // Models already extend the entity, so they can be used directly
    return models;
  }

  @override
  Future<SharingRelationship> sendRequest({required String targetEmail}) async {
    return _remoteDataSource.sendRequest(targetEmail: targetEmail);
  }

  @override
  Future<SharingRelationship> acceptRequest({
    required String relationshipId,
  }) async {
    return _remoteDataSource.acceptRequest(relationshipId: relationshipId);
  }

  @override
  Future<SharingRelationship> rejectRequest({
    required String relationshipId,
  }) async {
    return _remoteDataSource.rejectRequest(relationshipId: relationshipId);
  }

  @override
  Future<void> removeRelationship({required String relationshipId}) async {
    await _remoteDataSource.removeRelationship(relationshipId: relationshipId);
  }

  @override
  Future<SharedUserStats> getSharedStats({required String friendId}) async {
    return _remoteDataSource.getSharedStats(friendId: friendId);
  }

  @override
  Future<List<SharedUserStats>> getAllSharedStats() async {
    final models = await _remoteDataSource.getAllSharedStats();
    // Models already extend the entity, so they can be used directly
    return models;
  }
}
