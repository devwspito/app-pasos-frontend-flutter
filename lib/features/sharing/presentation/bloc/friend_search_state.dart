/// Friend search states for the FriendSearchBloc.
///
/// This file defines all possible states that the FriendSearchBloc can emit.
/// States are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/shared_user.dart';
import 'package:equatable/equatable.dart';

/// Base class for all friend search states.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all state types are handled.
///
/// Example usage:
/// ```dart
/// BlocBuilder<FriendSearchBloc, FriendSearchState>(
///   builder: (context, state) {
///     return switch (state) {
///       FriendSearchInitial() => const SearchPrompt(),
///       FriendSearchLoading() => const LoadingIndicator(),
///       FriendSearchLoaded(:final users) => UserList(users: users),
///       FriendSearchEmpty(:final query) => EmptyResults(query: query),
///       FriendSearchError(:final message) => ErrorWidget(message: message),
///     };
///   },
/// )
/// ```
sealed class FriendSearchState extends Equatable {
  /// Creates a [FriendSearchState] instance.
  const FriendSearchState();
}

/// Initial state before any search has been performed.
///
/// This is the default state when the FriendSearchBloc is first created
/// or after the search has been cleared.
///
/// Example:
/// ```dart
/// if (state is FriendSearchInitial) {
///   return const Text('Search for friends by name or email');
/// }
/// ```
final class FriendSearchInitial extends FriendSearchState {
  /// Creates a [FriendSearchInitial] state.
  const FriendSearchInitial();

  @override
  List<Object?> get props => [];
}

/// State indicating that a search is in progress.
///
/// This state is emitted when a search query is being processed.
///
/// Example:
/// ```dart
/// if (state is FriendSearchLoading) {
///   return const CircularProgressIndicator();
/// }
/// ```
final class FriendSearchLoading extends FriendSearchState {
  /// Creates a [FriendSearchLoading] state.
  const FriendSearchLoading();

  @override
  List<Object?> get props => [];
}

/// State indicating that search results have been loaded.
///
/// This state is emitted when search results are available.
///
/// Contains:
/// - [users] - The list of users matching the search query
/// - [query] - The search query that produced these results
///
/// Example:
/// ```dart
/// if (state is FriendSearchLoaded) {
///   return ListView.builder(
///     itemCount: state.users.length,
///     itemBuilder: (context, index) => UserTile(user: state.users[index]),
///   );
/// }
/// ```
final class FriendSearchLoaded extends FriendSearchState {
  /// Creates a [FriendSearchLoaded] state.
  ///
  /// [users] - The list of users matching the search query.
  /// [query] - The search query that produced these results.
  const FriendSearchLoaded({
    required this.users,
    required this.query,
  });

  /// The list of users matching the search query.
  final List<SharedUser> users;

  /// The search query that produced these results.
  final String query;

  /// Whether there are any search results.
  bool get hasResults => users.isNotEmpty;

  /// The number of search results.
  int get resultCount => users.length;

  @override
  List<Object?> get props => [users, query];
}

/// State indicating that no results were found for the search query.
///
/// This state is emitted when a search completes but returns no results.
///
/// Contains:
/// - [query] - The search query that produced no results
///
/// Example:
/// ```dart
/// if (state is FriendSearchEmpty) {
///   return Text('No users found for "${state.query}"');
/// }
/// ```
final class FriendSearchEmpty extends FriendSearchState {
  /// Creates a [FriendSearchEmpty] state.
  ///
  /// [query] - The search query that produced no results.
  const FriendSearchEmpty({
    required this.query,
  });

  /// The search query that produced no results.
  final String query;

  @override
  List<Object?> get props => [query];
}

/// State indicating that a search operation has failed.
///
/// This state is emitted when an error occurs during search.
///
/// Contains an error [message] describing what went wrong.
///
/// Example:
/// ```dart
/// if (state is FriendSearchError) {
///   return Text('Error: ${state.message}');
/// }
/// ```
final class FriendSearchError extends FriendSearchState {
  /// Creates a [FriendSearchError] state.
  ///
  /// [message] - A human-readable error message.
  const FriendSearchError({required this.message});

  /// The error message describing what went wrong.
  final String message;

  @override
  List<Object?> get props => [message];
}
