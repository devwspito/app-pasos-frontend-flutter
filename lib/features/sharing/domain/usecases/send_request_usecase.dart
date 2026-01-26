import '../repositories/sharing_repository.dart';

/// Use case for sending a friend request to another user.
///
/// Creates a new sharing relationship with pending status
/// between the current user and the target user.
///
/// Example usage:
/// ```dart
/// final sendRequest = SendRequestUseCase(repository);
/// final relationship = await sendRequest('target-user-id');
/// print('Request sent to ${relationship.receiverUsername}');
/// ```
class SendRequestUseCase {
  /// The repository instance for data operations.
  final SharingRepository _repository;

  /// Creates a [SendRequestUseCase] instance.
  ///
  /// [repository] - The repository to use for sending requests.
  SendRequestUseCase(this._repository);

  /// Executes the use case to send a friend request.
  ///
  /// [targetUserId] - The ID of the user to send the request to.
  /// Returns the created [SharingRelationship] with pending status.
  /// Throws an exception if:
  /// - The target user is not found
  /// - A relationship already exists
  /// - The operation fails
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final relationship = await sendRequestUseCase('user-123');
  ///   print('Request sent! Status: ${relationship.status}');
  /// } catch (e) {
  ///   print('Failed to send request: $e');
  /// }
  /// ```
  Future<SharingRelationship> call(String targetUserId) async {
    if (targetUserId.isEmpty) {
      throw ArgumentError('Target user ID cannot be empty');
    }
    return _repository.sendFriendRequest(targetUserId);
  }
}
