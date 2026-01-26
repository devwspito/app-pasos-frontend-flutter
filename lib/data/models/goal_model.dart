import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'goal_model.g.dart';

/// Goal model representing a group step goal.
/// Maps to backend IGroupGoal interface.
@JsonSerializable()
class GoalModel extends Equatable {
  /// Unique goal identifier (maps from backend _id)
  @JsonKey(name: '_id')
  final String id;

  /// Title of the group goal (max 100 chars)
  final String title;

  /// Optional description of the goal (max 500 chars)
  final String? description;

  /// Target number of steps for the goal (min 1)
  final int targetSteps;

  /// Start date of the goal period
  final DateTime startDate;

  /// End date of the goal period (must be > startDate)
  final DateTime endDate;

  /// Reference to the user who created this goal
  final String creatorId;

  /// Document creation timestamp
  final DateTime createdAt;

  /// Document update timestamp
  final DateTime updatedAt;

  const GoalModel({
    required this.id,
    required this.title,
    this.description,
    required this.targetSteps,
    required this.startDate,
    required this.endDate,
    required this.creatorId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a GoalModel from JSON map
  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);

  /// Converts GoalModel to JSON map
  Map<String, dynamic> toJson() => _$GoalModelToJson(this);

  /// Creates a copy of GoalModel with optional field updates
  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    int? targetSteps,
    DateTime? startDate,
    DateTime? endDate,
    String? creatorId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetSteps: targetSteps ?? this.targetSteps,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        targetSteps,
        startDate,
        endDate,
        creatorId,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;
}
