import 'package:equatable/equatable.dart';

/// Enum representing the source of step data
enum StepSource {
  manual,
  healthkit,
  googlefit,
}

/// Domain entity representing a step record
final class StepRecord extends Equatable {
  final String id;
  final String userId;
  final int stepCount;
  final DateTime recordedAt;
  final StepSource source;

  const StepRecord({
    required this.id,
    required this.userId,
    required this.stepCount,
    required this.recordedAt,
    required this.source,
  });

  @override
  List<Object?> get props => [id, userId, stepCount, recordedAt, source];

  /// Creates a copy of this StepRecord with the given fields replaced
  StepRecord copyWith({
    String? id,
    String? userId,
    int? stepCount,
    DateTime? recordedAt,
    StepSource? source,
  }) {
    return StepRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stepCount: stepCount ?? this.stepCount,
      recordedAt: recordedAt ?? this.recordedAt,
      source: source ?? this.source,
    );
  }
}
