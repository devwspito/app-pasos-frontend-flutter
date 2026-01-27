/// Goals list events for the GoalsListBloc.
///
/// This file defines all possible events that can be dispatched to the
/// GoalsListBloc. Events are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:equatable/equatable.dart';

/// Base class for all goals list events.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all event types are handled.
sealed class GoalsListEvent extends Equatable {
  /// Creates a [GoalsListEvent] instance.
  const GoalsListEvent();
}

/// Event dispatched when the goals list needs to be loaded.
///
/// This event triggers fetching of all group goals for the current user,
/// including both created and joined goals.
final class GoalsListLoadRequested extends GoalsListEvent {
  /// Creates a [GoalsListLoadRequested] event.
  const GoalsListLoadRequested();

  @override
  List<Object?> get props => [];
}

/// Event dispatched when the user requests to refresh the goals list.
///
/// This event is typically triggered by a pull-to-refresh gesture
/// and re-fetches all group goals from the server.
final class GoalsListRefreshRequested extends GoalsListEvent {
  /// Creates a [GoalsListRefreshRequested] event.
  const GoalsListRefreshRequested();

  @override
  List<Object?> get props => [];
}
