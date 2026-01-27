/// Step record entity for the dashboard domain.
///
/// This is a pure domain entity representing a single step recording.
/// It's independent of any data layer implementation details.
library;

import 'package:equatable/equatable.dart';

/// Enum representing the source of step data.
///
/// - [native]: Steps recorded from device sensors (pedometer).
/// - [manual]: Steps manually entered by the user.
/// - [web]: Steps synced from web interface.
enum StepSource {
  /// Steps recorded from device sensors (pedometer).
  native,

  /// Steps manually entered by the user.
  manual,

  /// Steps synced from web interface.
  web,
}

/// Represents a single step recording in the application.
///
/// This entity captures when and how many steps were recorded,
/// along with metadata about the source and timing.
///
/// Example usage:
/// ```dart
/// final record = StepRecord(
///   id: '123',
///   userId: 'user-456',
///   count: 1500,
///   source: StepSource.native,
///   date: '2024-01-15',
///   hour: 14,
///   timestamp: DateTime.now(),
/// );
/// ```
class StepRecord extends Equatable {
  /// Creates a [StepRecord] instance.
  ///
  /// [id] - The unique identifier for this record.
  /// [userId] - The ID of the user who recorded these steps.
  /// [count] - The number of steps recorded.
  /// [source] - Where the steps came from (native, manual, web).
  /// [date] - The date of the recording (YYYY-MM-DD format).
  /// [hour] - The hour of the day when recorded (0-23).
  /// [timestamp] - The exact timestamp of the recording.
  const StepRecord({
    required this.id,
    required this.userId,
    required this.count,
    required this.source,
    required this.date,
    required this.hour,
    required this.timestamp,
  });

  /// The unique identifier for this step record.
  final String id;

  /// The ID of the user who recorded these steps.
  final String userId;

  /// The number of steps recorded.
  final int count;

  /// The source of the step data.
  final StepSource source;

  /// The date of the recording in YYYY-MM-DD format.
  final String date;

  /// The hour of the day when recorded (0-23).
  final int hour;

  /// The exact timestamp when the steps were recorded.
  final DateTime timestamp;

  /// Creates an empty step record for use in initial states.
  ///
  /// Useful for initializing state before data is loaded.
  factory StepRecord.empty() => StepRecord(
        id: '',
        userId: '',
        count: 0,
        source: StepSource.native,
        date: '',
        hour: 0,
        timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// Whether this is an empty/uninitialized record.
  bool get isEmpty => id.isEmpty;

  /// Whether this is a valid record with data.
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [id, userId, count, source, date, hour, timestamp];

  @override
  String toString() {
    return 'StepRecord(id: $id, userId: $userId, count: $count, source: $source, date: $date, hour: $hour, timestamp: $timestamp)';
  }
}
