/// Goals repository interface for the domain layer.
///
/// This file defines the contract for goals-related operations.
/// Implementations should handle all group goals data operations.
library;

import 'package:app_pasos_frontend/features/goals/domain/entities/goal_progress.dart';
import 'package:app_pasos_frontend/features/goals/domain/entities/group_goal.dart';

/// Abstract interface defining goals-related operations.
///
/// This interface follows the Clean Architecture pattern, allowing the domain
/// layer to define what operations are needed without knowing implementation
/// details. The data layer provides the concrete implementation.
///
/// Example usage:
/// ```dart
/// class GetUserGoalsUseCase {
///   final GoalsRepository repository;
///
///   GetUserGoalsUseCase(this.repository);
///
///   Future<List<GroupGoal>> call() {
///     return repository.getUserGoals();
///   }
/// }
/// ```
abstract interface class GoalsRepository {
  /// Gets all group goals for the current user.
  ///
  /// Returns a list of [GroupGoal] objects containing both created
  /// and joined goals.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<List<GroupGoal>> getUserGoals();

  /// Creates a new group goal.
  ///
  /// [name] - The name of the goal.
  /// [targetSteps] - The total step target for the group.
  /// [startDate] - When the goal period starts.
  /// [endDate] - When the goal period ends.
  /// [description] - An optional description of the goal.
  ///
  /// Returns the created [GroupGoal] with 'active' status.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [ValidationException] if required fields are invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<GroupGoal> createGoal({
    required String name,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  });

  /// Gets detailed information about a specific goal.
  ///
  /// [goalId] - The ID of the goal to retrieve.
  ///
  /// Returns the [GroupGoal] with full details.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NotFoundException] if goal not found.
  /// Throws [ForbiddenException] if user is not a member.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<GroupGoal> getGoalDetails({required String goalId});

  /// Gets the progress information for a specific goal.
  ///
  /// [goalId] - The ID of the goal to get progress for.
  ///
  /// Returns [GoalProgress] containing current and target steps.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NotFoundException] if goal not found.
  /// Throws [ForbiddenException] if user is not a member.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<GoalProgress> getGoalProgress({required String goalId});

  /// Invites a user to join a goal.
  ///
  /// [goalId] - The ID of the goal to invite to.
  /// [userId] - The ID of the user to invite.
  ///
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NotFoundException] if goal or user not found.
  /// Throws [ForbiddenException] if user is not the goal creator.
  /// Throws [ConflictException] if user is already a member.
  /// Throws [ValidationException] if userId is invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<void> inviteUser({required String goalId, required String userId});

  /// Joins a goal that the user has been invited to.
  ///
  /// [goalId] - The ID of the goal to join.
  ///
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NotFoundException] if goal not found.
  /// Throws [ForbiddenException] if user was not invited.
  /// Throws [ConflictException] if user is already a member.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<void> joinGoal({required String goalId});

  /// Leaves a goal that the user is a member of.
  ///
  /// [goalId] - The ID of the goal to leave.
  ///
  /// The goal creator cannot leave the goal.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NotFoundException] if goal not found.
  /// Throws [ForbiddenException] if user is the creator or not a member.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<void> leaveGoal({required String goalId});

  /// Updates an existing group goal.
  ///
  /// [goalId] - The ID of the goal to update (required).
  /// [name] - The new name of the goal (optional).
  /// [description] - The new description of the goal (optional).
  /// [targetSteps] - The new total step target for the group (optional).
  /// [startDate] - The new start date for the goal period (optional).
  /// [endDate] - The new end date for the goal period (optional).
  ///
  /// Only provided fields will be updated (partial update).
  /// Returns the updated [GroupGoal].
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NotFoundException] if goal not found.
  /// Throws [ForbiddenException] if user is not the goal creator.
  /// Throws [ValidationException] if provided fields are invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<GroupGoal> updateGoal({
    required String goalId,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? startDate,
    DateTime? endDate,
  });
}
