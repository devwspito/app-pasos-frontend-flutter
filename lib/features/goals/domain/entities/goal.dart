import 'package:equatable/equatable.dart';

/// Domain entity representing a goal.
///
/// A goal is a target step count that users can work towards,
/// either individually or as a group with other members.
final class Goal extends Equatable {
  final String id;
  final String name;
  final String description;
  final int targetSteps;
  final DateTime startDate;
  final DateTime endDate;
  final String ownerId;
  final bool isPublic;
  final List<String> memberIds;

  const Goal({
    required this.id,
    required this.name,
    required this.description,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
    required this.ownerId,
    required this.isPublic,
    required this.memberIds,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        targetSteps,
        startDate,
        endDate,
        ownerId,
        isPublic,
        memberIds,
      ];

  /// Creates a copy of this Goal with the given fields replaced
  Goal copyWith({
    String? id,
    String? name,
    String? description,
    int? targetSteps,
    DateTime? startDate,
    DateTime? endDate,
    String? ownerId,
    bool? isPublic,
    List<String>? memberIds,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetSteps: targetSteps ?? this.targetSteps,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      ownerId: ownerId ?? this.ownerId,
      isPublic: isPublic ?? this.isPublic,
      memberIds: memberIds ?? this.memberIds,
    );
  }

  /// Returns true if the goal is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Returns the duration of the goal in days
  int get durationDays => endDate.difference(startDate).inDays;

  /// Returns true if the current user is the owner
  bool isOwner(String userId) => ownerId == userId;

  /// Returns true if a user is a member of this goal
  bool hasMember(String userId) => memberIds.contains(userId);
}
