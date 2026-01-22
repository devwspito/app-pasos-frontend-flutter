import '../repositories/goals_repository.dart';

/// Use case for inviting a user to join a goal.
///
/// Single responsibility: Send an invitation to a user via email
/// to join a specific goal.
///
/// Example:
/// ```dart
/// final useCase = InviteUserUseCase(repository: goalsRepository);
/// await useCase(goalId: 'goal-123', email: 'friend@example.com');
/// print('Invitation sent!');
/// ```
final class InviteUserUseCase {
  InviteUserUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to invite a user to a goal.
  ///
  /// [goalId] The unique identifier of the goal.
  /// [email] The email address of the user to invite.
  ///
  /// Sends an invitation email containing a link/code for the
  /// recipient to join the goal.
  ///
  /// Note: Requires network connectivity and owner/admin permissions.
  ///
  /// Throws:
  /// - [ServerException] on API errors (e.g., invalid email, no permission)
  /// - [NetworkException] on connectivity issues
  Future<void> call({
    required String goalId,
    required String email,
  }) {
    return _repository.inviteUser(goalId, email);
  }
}
