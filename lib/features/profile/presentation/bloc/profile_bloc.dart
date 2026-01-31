/// Profile BLoC for managing profile state.
///
/// This BLoC handles all profile-related state management using
/// flutter_bloc. It processes profile events and emits corresponding
/// states following Clean Architecture principles.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';
import 'package:app_pasos_frontend/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:app_pasos_frontend/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:app_pasos_frontend/features/profile/presentation/bloc/profile_event.dart';
import 'package:app_pasos_frontend/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC for managing profile state.
///
/// This BLoC processes [ProfileEvent]s and emits [ProfileState]s. It uses use cases
/// for business logic, following the Dependency Inversion Principle.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  /// Creates a [ProfileBloc] instance.
  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileEditModeToggled>(_onEditModeToggled);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileCancelEditRequested>(_onCancelEditRequested);
  }

  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  /// Stores the last known user data for error recovery
  User? _lastKnownUser;

  /// Handles [ProfileLoadRequested] events.
  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = await _getProfileUseCase();
      _lastKnownUser = user;
      emit(ProfileLoaded(user: user));
    } on AppException catch (e) {
      emit(ProfileError(message: _getErrorMessage(e), user: _lastKnownUser));
    } catch (e) {
      emit(ProfileError(
        message: 'An unexpected error occurred: $e',
        user: _lastKnownUser,
      ));
    }
  }

  /// Handles [ProfileEditModeToggled] events.
  Future<void> _onEditModeToggled(
    ProfileEditModeToggled event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileEditing(user: currentState.user));
    } else if (currentState is ProfileUpdateSuccess) {
      emit(ProfileEditing(user: currentState.user));
    } else if (currentState is ProfileEditing) {
      // If already editing, go back to loaded state
      emit(ProfileLoaded(user: currentState.user));
    }
  }

  /// Handles [ProfileUpdateRequested] events.
  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = await _updateProfileUseCase(
        UpdateProfileParams(
          name: event.name,
          email: event.email,
        ),
      );
      _lastKnownUser = user;
      emit(ProfileUpdateSuccess(user: user));
    } on AppException catch (e) {
      emit(ProfileError(message: _getErrorMessage(e), user: _lastKnownUser));
    } catch (e) {
      emit(ProfileError(
        message: 'An unexpected error occurred: $e',
        user: _lastKnownUser,
      ));
    }
  }

  /// Handles [ProfileCancelEditRequested] events.
  Future<void> _onCancelEditRequested(
    ProfileCancelEditRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileEditing) {
      emit(ProfileLoaded(user: currentState.user));
    } else if (_lastKnownUser != null) {
      emit(ProfileLoaded(user: _lastKnownUser!));
    }
  }

  /// Converts an [AppException] to a user-friendly error message.
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
}
