/// Dashboard events for the DashboardBloc.
///
/// This file defines all possible events that can be dispatched to the
/// DashboardBloc. Events are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_record.dart';
import 'package:equatable/equatable.dart';

/// Base class for all dashboard events.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all event types are handled.
sealed class DashboardEvent extends Equatable {
  /// Creates a [DashboardEvent] instance.
  const DashboardEvent();
}

/// Event dispatched when the dashboard needs to load initial data.
///
/// This event triggers fetching of all dashboard data including:
/// - Today's step count
/// - Step statistics (today, week, month, all-time)
/// - Weekly trend data
/// - Hourly peaks
final class DashboardLoadRequested extends DashboardEvent {
  /// Creates a [DashboardLoadRequested] event.
  const DashboardLoadRequested();

  @override
  List<Object?> get props => [];
}

/// Event dispatched when the user requests to refresh dashboard data.
///
/// This event is typically triggered by a pull-to-refresh gesture
/// and re-fetches all dashboard data from the server.
final class DashboardRefreshRequested extends DashboardEvent {
  /// Creates a [DashboardRefreshRequested] event.
  const DashboardRefreshRequested();

  @override
  List<Object?> get props => [];
}

/// Event dispatched when the user wants to record new steps.
///
/// This event is used for manual step entry or syncing steps from
/// device sensors.
final class DashboardRecordStepsRequested extends DashboardEvent {
  /// Creates a [DashboardRecordStepsRequested] event.
  ///
  /// [count] - The number of steps to record.
  /// [source] - The source of the steps (native, manual, web).
  const DashboardRecordStepsRequested({
    required this.count,
    required this.source,
  });

  /// The number of steps to record.
  final int count;

  /// The source of the steps.
  final StepSource source;

  @override
  List<Object?> get props => [count, source];
}

/// Event dispatched when user requests to sync steps from native health.
///
/// This event triggers the native health sync process, which fetches
/// steps from HealthKit (iOS) or Health Connect (Android) and records
/// them to the backend.
final class DashboardSyncHealthRequested extends DashboardEvent {
  /// Creates a [DashboardSyncHealthRequested] event.
  const DashboardSyncHealthRequested();

  @override
  List<Object?> get props => [];
}

/// Event dispatched when health sync completes (success or failure).
///
/// This event is emitted after a health sync operation finishes,
/// providing the result of the sync attempt.
final class DashboardHealthSyncCompleted extends DashboardEvent {
  /// Creates a [DashboardHealthSyncCompleted] event.
  ///
  /// [stepsSynced] - The number of steps synced, or null if sync failed.
  const DashboardHealthSyncCompleted({required this.stepsSynced});

  /// The number of steps synced from the native health platform.
  ///
  /// This value is `null` if the sync failed due to:
  /// - Health platform not available on device
  /// - User denied permission to access health data
  /// - Sync operation failed for any other reason
  final int? stepsSynced;

  @override
  List<Object?> get props => [stepsSynced];
}
