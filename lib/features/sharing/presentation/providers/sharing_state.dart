import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../../domain/entities/friend_stats.dart';
import '../../domain/entities/relationship.dart';

/// Represents the possible sharing data loading statuses.
enum SharingStatus {
  /// Initial state before any data fetch.
  initial,

  /// Currently loading sharing data.
  loading,

  /// Sharing data loaded successfully.
  loaded,

  /// Error occurred while loading sharing data.
  error,
}

/// Immutable state class for sharing/friends feature.
///
/// Uses [Equatable] for value-based equality comparison.
/// State transitions should use [copyWith] to maintain immutability.
///
/// Example:
/// ```dart
/// final state = SharingState.initial();
/// final loadingState = state.copyWith(status: SharingStatus.loading, isLoading: true);
/// final loadedState = loadingState.copyWith(
///   status: SharingStatus.loaded,
///   relationships: relationships,
///   isLoading: false,
/// );
/// ```
@immutable
final class SharingState extends Equatable {
  const SharingState({
    this.status = SharingStatus.initial,
    this.isLoading = false,
    this.relationships = const [],
    this.pendingRequests = const [],
    this.acceptedFriends = const [],
    this.sharedStats = const [],
    this.selectedFriendStats,
    this.errorMessage,
    this.lastUpdated,
  });

  /// Current data loading status.
  final SharingStatus status;

  /// Whether an async operation is in progress.
  final bool isLoading;

  /// All relationships for the current user.
  final List<Relationship> relationships;

  /// Pending friend requests received by the current user.
  final List<Relationship> pendingRequests;

  /// Accepted friends (active friendships).
  final List<Relationship> acceptedFriends;

  /// Step statistics from all friends.
  final List<FriendStats> sharedStats;

  /// Currently selected friend's detailed stats.
  final FriendStats? selectedFriendStats;

  /// Error message from the last failed operation.
  final String? errorMessage;

  /// Timestamp of the last successful data update.
  final DateTime? lastUpdated;

  /// Factory constructor for initial state.
  const SharingState.initial()
      : status = SharingStatus.initial,
        isLoading = false,
        relationships = const [],
        pendingRequests = const [],
        acceptedFriends = const [],
        sharedStats = const [],
        selectedFriendStats = null,
        errorMessage = null,
        lastUpdated = null;

  /// Factory constructor for loading state.
  const SharingState.loading()
      : status = SharingStatus.loading,
        isLoading = true,
        relationships = const [],
        pendingRequests = const [],
        acceptedFriends = const [],
        sharedStats = const [],
        selectedFriendStats = null,
        errorMessage = null,
        lastUpdated = null;

  /// Creates a copy with optional field overrides.
  ///
  /// This is the only way to create new state from existing state.
  /// Direct mutation is not allowed.
  ///
  /// Use [clearError] to explicitly set errorMessage to null.
  /// Use [clearRelationships] to explicitly clear all relationship lists.
  /// Use [clearSelectedFriend] to explicitly clear selected friend stats.
  /// Use [clearSharedStats] to explicitly clear shared stats list.
  SharingState copyWith({
    SharingStatus? status,
    bool? isLoading,
    List<Relationship>? relationships,
    List<Relationship>? pendingRequests,
    List<Relationship>? acceptedFriends,
    List<FriendStats>? sharedStats,
    FriendStats? selectedFriendStats,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearError = false,
    bool clearRelationships = false,
    bool clearSelectedFriend = false,
    bool clearSharedStats = false,
  }) {
    return SharingState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      relationships:
          clearRelationships ? const [] : (relationships ?? this.relationships),
      pendingRequests: clearRelationships
          ? const []
          : (pendingRequests ?? this.pendingRequests),
      acceptedFriends: clearRelationships
          ? const []
          : (acceptedFriends ?? this.acceptedFriends),
      sharedStats:
          clearSharedStats ? const [] : (sharedStats ?? this.sharedStats),
      selectedFriendStats: clearSelectedFriend
          ? null
          : (selectedFriendStats ?? this.selectedFriendStats),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Returns true if data has been loaded at least once.
  bool get hasData =>
      relationships.isNotEmpty ||
      pendingRequests.isNotEmpty ||
      acceptedFriends.isNotEmpty;

  /// Returns true if there's an error.
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Returns the number of pending friend requests.
  int get pendingCount => pendingRequests.length;

  /// Returns the number of accepted friends.
  int get friendsCount => acceptedFriends.length;

  /// Returns true if initial loading is in progress.
  bool get isInitialLoading => status == SharingStatus.loading && !hasData;

  /// Returns true if refreshing existing data.
  bool get isRefreshing => isLoading && hasData;

  @override
  List<Object?> get props => [
        status,
        isLoading,
        relationships,
        pendingRequests,
        acceptedFriends,
        sharedStats,
        selectedFriendStats,
        errorMessage,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'SharingState('
        'status: $status, '
        'isLoading: $isLoading, '
        'relationships: ${relationships.length}, '
        'pending: ${pendingRequests.length}, '
        'friends: ${acceptedFriends.length}, '
        'sharedStats: ${sharedStats.length}, '
        'error: $errorMessage'
        ')';
  }
}
