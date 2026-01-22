import '../../domain/entities/friend_stats.dart';
import '../../domain/entities/relationship.dart';
import '../../domain/repositories/sharing_repository.dart';
import '../datasources/sharing_remote_datasource.dart';

/// Implementation of [SharingRepository] using remote data source.
///
/// This implementation delegates all operations to the remote data source.
/// Future enhancements could add local caching for offline support.
class SharingRepositoryImpl implements SharingRepository {
  SharingRepositoryImpl({
    required SharingRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final SharingRemoteDataSource _remoteDataSource;

  @override
  Future<List<Relationship>> getRelationships() async {
    return _remoteDataSource.getRelationships();
  }

  @override
  Future<List<Relationship>> getPendingRequests() async {
    return _remoteDataSource.getPendingRequests();
  }

  @override
  Future<List<Relationship>> getAcceptedFriends() async {
    return _remoteDataSource.getAcceptedFriends();
  }

  @override
  Future<Relationship> sendFriendRequest(String usernameOrEmail) async {
    return _remoteDataSource.sendFriendRequest(usernameOrEmail);
  }

  @override
  Future<Relationship> acceptFriendRequest(String relationshipId) async {
    return _remoteDataSource.acceptFriendRequest(relationshipId);
  }

  @override
  Future<Relationship> rejectFriendRequest(String relationshipId) async {
    return _remoteDataSource.rejectFriendRequest(relationshipId);
  }

  @override
  Future<void> removeFriend(String relationshipId) async {
    return _remoteDataSource.removeFriend(relationshipId);
  }

  @override
  Future<List<FriendStats>> getAllFriendsStats() async {
    return _remoteDataSource.getAllFriendsStats();
  }

  @override
  Future<FriendStats> getFriendStats(String friendUserId) async {
    return _remoteDataSource.getFriendStats(friendUserId);
  }
}
