/// Use case for retrieving all goals belonging to the current user.
///
/// This use case follows the single responsibility principle - it has only
/// one method [call] that fetches the user's goals from the repository.
///
/// Example usage:
/// ```dart
/// final useCase = GetUserGoalsUseCase(goalsRepository);
/// final goals = await useCase();
/// ```
library;

// =============================================================================
// TEMPORARY INLINE DEFINITIONS
// TODO: Replace with imports when entity/repository files are created by their
// respective epic stories:
// - lib/features/goals/domain/entities/goal.dart
// - lib/features/goals/domain/repositories/goals_repository.dart
// =============================================================================

/// Entity representing a group goal.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/entities/goal.dart
class Goal {
  /// Unique identifier for the goal.
  final String id;

  /// Name of the goal.
  final String name;

  /// Optional description of the goal.
  final String? description;

  /// Target daily steps for the goal.
  final int targetSteps;

  /// Start date of the goal period.
  final DateTime startDate;

  /// End date of the goal period.
  final DateTime endDate;

  /// ID of the user who created the goal.
  final String ownerId;

  /// Username of the owner.
  final String? ownerUsername;

  /// When the goal was created.
  final DateTime createdAt;

  /// When the goal was last updated.
  final DateTime? updatedAt;

  /// Creates a new Goal instance.
  const Goal({
    required this.id,
    required this.name,
    this.description,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
    required this.ownerId,
    this.ownerUsername,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a Goal from a JSON map.
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      targetSteps: int.tryParse(json['targetSteps']?.toString() ?? '10000') ?? 10000,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'].toString())
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'].toString())
          : DateTime.now().add(const Duration(days: 30)),
      ownerId: json['ownerId']?.toString() ?? '',
      ownerUsername: json['ownerUsername']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Converts this Goal to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'targetSteps': targetSteps,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'ownerId': ownerId,
      if (ownerUsername != null) 'ownerUsername': ownerUsername,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Returns the number of days remaining until the goal ends.
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  /// Returns true if the goal has ended.
  bool get isEnded => DateTime.now().isAfter(endDate);

  /// Returns true if the goal is currently active.
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Goal(id: $id, name: $name, targetSteps: $targetSteps)';
}

/// Abstract interface for GoalsRepository.
///
/// TODO: Will be replaced with import from lib/features/goals/domain/repositories/goals_repository.dart
abstract class GoalsRepository {
  /// Fetches all goals belonging to the current user.
  Future<List<Goal>> getUserGoals();

  /// Creates a new goal.
  Future<Goal> createGoal({
    required String name,
    String? description,
    required int targetSteps,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Gets progress for all members of a goal.
  Future<List<dynamic>> getGoalProgress(String goalId);

  /// Invites a user to join a goal.
  Future<dynamic> inviteUser(String goalId, String userId);
}

// =============================================================================
// USE CASE IMPLEMENTATION
// =============================================================================

/// Use case for retrieving all goals belonging to the current user.
///
/// Follows the single responsibility principle with a single [call] method.
/// Inject [GoalsRepository] via constructor for dependency injection.
///
/// Example:
/// ```dart
/// final useCase = GetUserGoalsUseCase(repository);
/// final goals = await useCase();
/// for (final goal in goals) {
///   print('${goal.name}: ${goal.daysRemaining} days remaining');
/// }
/// ```
class GetUserGoalsUseCase {
  /// The repository used to fetch goals data.
  final GoalsRepository _repository;

  /// Creates a new [GetUserGoalsUseCase] with the given repository.
  ///
  /// [repository] - The goals repository implementation to use.
  GetUserGoalsUseCase(this._repository);

  /// Fetches all goals belonging to the current user.
  ///
  /// Returns a [Future] that completes with a list of [Goal] entities.
  /// The list may be empty if the user has no goals.
  ///
  /// Throws an [Exception] if the network request fails.
  Future<List<Goal>> call() => _repository.getUserGoals();
}
