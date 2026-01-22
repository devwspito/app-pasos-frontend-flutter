import '../entities/sharing_permission.dart';
import '../entities/sharing_relationship.dart';
import '../repositories/sharing_repository.dart';

/// Use case for sending a sharing request to another user.
///
/// Single responsibility: Send a sharing invitation to a user
/// identified by their email address, with specified permissions.
///
/// Example:
/// ```dart
/// final useCase = SendSharingRequestUseCase(repository: sharingRepository);
/// final relationship = await useCase(
///   'friend@example.com',
///   [SharingPermission.viewSteps, SharingPermission.viewTrends],
/// );
/// print('Request sent to ${relationship.friendEmail}');
/// ```
final class SendSharingRequestUseCase {
  SendSharingRequestUseCase({required SharingRepository repository})
      : _repository = repository;

  final SharingRepository _repository;

  /// Executes the use case to send a sharing request.
  ///
  /// [email] The email address of the user to send the request to.
  /// [permissions] The permissions to grant in this sharing relationship.
  ///   If empty, defaults to basic step viewing permission.
  ///
  /// Returns the created [SharingRelationship] with status 'pending'.
  /// The relationship becomes active once the recipient accepts.
  ///
  /// Throws:
  /// - [ServerException] on API errors
  /// - [NetworkException] on connectivity issues
  /// - [UserNotFoundException] if no user exists with that email
  /// - [DuplicateRelationshipException] if a relationship already exists
  Future<SharingRelationship> call(
    String email,
    List<SharingPermission> permissions,
  ) {
    return _repository.sendRequest(email, permissions);
  }
}
