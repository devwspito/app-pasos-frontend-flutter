/// Friend search events for the FriendSearchBloc.
///
/// This file defines all possible events that can be dispatched to the
/// FriendSearchBloc. Events are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:equatable/equatable.dart';

/// Base class for all friend search events.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all event types are handled.
sealed class FriendSearchEvent extends Equatable {
  /// Creates a [FriendSearchEvent] instance.
  const FriendSearchEvent();
}

/// Event dispatched when the search query changes.
///
/// This event is triggered when the user types in the search field.
/// It may be debounced to avoid excessive API calls.
final class FriendSearchQueryChanged extends FriendSearchEvent {
  /// Creates a [FriendSearchQueryChanged] event.
  ///
  /// [query] - The current search query string.
  const FriendSearchQueryChanged({
    required this.query,
  });

  /// The current search query string.
  ///
  /// This is the text the user has entered in the search field.
  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event dispatched when the search should be cleared.
///
/// This event is triggered when the user clears the search field
/// or navigates away from the search screen.
final class FriendSearchCleared extends FriendSearchEvent {
  /// Creates a [FriendSearchCleared] event.
  const FriendSearchCleared();

  @override
  List<Object?> get props => [];
}
