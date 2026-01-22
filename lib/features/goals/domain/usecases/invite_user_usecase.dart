import '../repositories/goals_repository.dart';

/// Use case for inviting a user to a group goal.
///
/// Single responsibility: Send an invitation to join a goal.
///
/// Example:
/// ```dart
/// final useCase = InviteUserUseCase(repository: goalsRepository);
/// final success = await useCase(goalId: 'goal-123', email: 'user@example.com');
/// if (success) print('Invitation sent!');
/// ```
final class InviteUserUseCase {
  InviteUserUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to invite a user.
  ///
  /// [goalId] The goal to invite the user to.
  /// [email] Email address of the user to invite.
  ///
  /// Returns true if invitation was sent successfully.
  ///
  /// Throws:
  /// - [ServerException] on API errors
  /// - [NetworkException] on connectivity issues
  /// - [ValidationException] if goal is not a group goal
  Future<bool> call({
    required String goalId,
    required String email,
  }) {
    return _repository.inviteUser(
      goalId: goalId,
      email: email,
    );
  }
}
