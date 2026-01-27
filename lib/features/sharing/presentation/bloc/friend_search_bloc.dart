/// Friend search BLoC for managing user search state.
///
/// This BLoC handles all friend search-related state management using
/// flutter_bloc. It processes search events and emits corresponding
/// states following Clean Architecture principles.
library;

import 'dart:async';

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/features/sharing/domain/usecases/search_users_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/friend_search_event.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/friend_search_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Duration to wait before executing search after typing stops.
const Duration _debounceDuration = Duration(milliseconds: 300);

/// Minimum query length to trigger a search.
const int _minQueryLength = 2;

/// BLoC for managing friend search state.
///
/// This BLoC processes [FriendSearchEvent]s and emits [FriendSearchState]s.
/// It uses the search users use case for business logic, following the
/// Dependency Inversion Principle.
///
/// Features:
/// - Debounces search queries to avoid excessive API calls
/// - Requires minimum query length before searching
/// - Handles empty results gracefully
///
/// Example usage:
/// ```dart
/// final bloc = FriendSearchBloc(
///   searchUsersUseCase: searchUsersUseCase,
/// );
///
/// // Perform a search
/// bloc.add(FriendSearchQueryChanged(query: 'john'));
///
/// // Clear search
/// bloc.add(const FriendSearchCleared());
/// ```
class FriendSearchBloc extends Bloc<FriendSearchEvent, FriendSearchState> {
  /// Creates a [FriendSearchBloc] instance.
  ///
  /// [searchUsersUseCase] - The use case for searching users.
  FriendSearchBloc({
    required SearchUsersUseCase searchUsersUseCase,
  })  : _searchUsersUseCase = searchUsersUseCase,
        super(const FriendSearchInitial()) {
    on<FriendSearchQueryChanged>(_onQueryChanged);
    on<FriendSearchCleared>(_onCleared);
  }

  final SearchUsersUseCase _searchUsersUseCase;

  /// Timer for debouncing search queries.
  Timer? _debounceTimer;

  /// The current search query being processed.
  String _currentQuery = '';

  /// Handles [FriendSearchQueryChanged] events.
  ///
  /// Debounces the search to avoid excessive API calls while the user
  /// is still typing. Only searches if the query meets the minimum length.
  Future<void> _onQueryChanged(
    FriendSearchQueryChanged event,
    Emitter<FriendSearchState> emit,
  ) async {
    final query = event.query.trim();
    _currentQuery = query;

    // Cancel any pending search
    _debounceTimer?.cancel();

    // If query is empty, return to initial state
    if (query.isEmpty) {
      emit(const FriendSearchInitial());
      return;
    }

    // If query is too short, stay in initial state
    if (query.length < _minQueryLength) {
      emit(const FriendSearchInitial());
      return;
    }

    // Show loading state while waiting for debounce
    emit(const FriendSearchLoading());

    // Create a completer to wait for the debounced search
    final completer = Completer<void>();

    // Debounce the search
    _debounceTimer = Timer(_debounceDuration, () async {
      // Verify the query hasn't changed during debounce
      if (_currentQuery != query) {
        completer.complete();
        return;
      }

      await _performSearch(query, emit);
      completer.complete();
    });

    // Wait for the search to complete
    await completer.future;
  }

  /// Handles [FriendSearchCleared] events.
  ///
  /// Cancels any pending search and resets to initial state.
  Future<void> _onCleared(
    FriendSearchCleared event,
    Emitter<FriendSearchState> emit,
  ) async {
    _debounceTimer?.cancel();
    _currentQuery = '';
    emit(const FriendSearchInitial());
  }

  /// Performs the actual search API call.
  ///
  /// [query] - The search query string.
  /// [emit] - The emitter to emit states.
  Future<void> _performSearch(
    String query,
    Emitter<FriendSearchState> emit,
  ) async {
    try {
      final users = await _searchUsersUseCase(query: query);

      if (users.isEmpty) {
        emit(FriendSearchEmpty(query: query));
      } else {
        emit(FriendSearchLoaded(users: users, query: query));
      }
    } on AppException catch (e) {
      emit(FriendSearchError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(FriendSearchError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Converts an [AppException] to a user-friendly error message.
  ///
  /// Provides specific, actionable messages based on the exception type.
  String _getErrorMessage(AppException exception) {
    return switch (exception) {
      NetworkException(:final isNoConnection, :final isTimeout) =>
        isNoConnection
            ? 'No internet connection. Please check your network.'
            : isTimeout
                ? 'Connection timed out. Please try again.'
                : exception.message,
      ServerException(:final statusCode) => statusCode == 500
          ? 'Server error. Please try again later.'
          : exception.message,
      ValidationException(:final fieldErrors) => fieldErrors.isNotEmpty
          ? fieldErrors.values.expand((e) => e).join('. ')
          : exception.message,
      UnauthorizedException(:final isTokenExpired) => isTokenExpired
          ? 'Your session has expired. Please log in again.'
          : exception.message,
      CacheException() => exception.message,
    };
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
