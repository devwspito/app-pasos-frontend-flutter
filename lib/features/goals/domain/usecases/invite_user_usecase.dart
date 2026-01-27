/// Invite user use case.
///
/// This use case invites a user to join a group goal.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/goals/domain/repositories/goals_repository.dart';

/// Use case for inviting a user to join a group goal.
///
/// This follows the Single Responsibility Principle - it only handles
/// inviting users. It also follows Dependency Inversion Principle
/// by depending on the GoalsRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = InviteUserUseCase(repository: goalsRepository);
/// await useCase(goalId: 'goal123', userId: 'user456');
/// print('User invited successfully');
/// ```
class InviteUserUseCase {
  /// Creates an [InviteUserUseCase] instance.
  ///
  /// [repository] - The goals repository interface.
  InviteUserUseCase({required GoalsRepository repository})
      : _repository = repository;

  final GoalsRepository _repository;

  /// Executes the use case to invite a user to a goal.
  ///
  /// [goalId] - The ID of the goal to invite to.
  /// [userId] - The ID of the user to invite.
  ///
  /// Throws exceptions from the repository on failure.
  Future<void> call({required String goalId, required String userId}) async {
    return _repository.inviteUser(goalId: goalId, userId: userId);
  }
}
