import 'package:equatable/equatable.dart';

/// Data model representing a single day's step trend for weekly view
final class WeeklyTrendModel extends Equatable {
  final String dayOfWeek;
  final int steps;
  final DateTime date;
  final bool isToday;

  const WeeklyTrendModel({
    required this.dayOfWeek,
    required this.steps,
    required this.date,
    required this.isToday,
  });

  @override
  List<Object?> get props => [dayOfWeek, steps, date, isToday];

  /// Creates a WeeklyTrendModel from a JSON map
  factory WeeklyTrendModel.fromJson(Map<String, dynamic> json) {
    return WeeklyTrendModel(
      dayOfWeek: json['dayOfWeek'] as String,
      steps: json['steps'] as int,
      date: DateTime.parse(json['date'] as String),
      isToday: json['isToday'] as bool,
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'steps': steps,
      'date': date.toIso8601String(),
      'isToday': isToday,
    };
  }

  /// Creates a copy of this WeeklyTrendModel with the given fields replaced
  WeeklyTrendModel copyWith({
    String? dayOfWeek,
    int? steps,
    DateTime? date,
    bool? isToday,
  }) {
    return WeeklyTrendModel(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      steps: steps ?? this.steps,
      date: date ?? this.date,
      isToday: isToday ?? this.isToday,
    );
  }

  /// Returns true if this day has any steps recorded
  bool get hasSteps => steps > 0;
}
