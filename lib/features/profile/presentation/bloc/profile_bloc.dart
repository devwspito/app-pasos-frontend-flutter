/// Profile BLoC for managing profile state.
///
/// This BLoC handles all profile-related state management using
/// flutter_bloc. It processes profile events and emits corresponding
/// states following Clean Architecture principles.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';
import 'package:app_pasos_frontend/features/profile/presentation/bloc/profile_event.dart';
import 'package:app_pasos_frontend/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// TODO(profile-epic): Replace stub types with actual imports when use cases
// are created. See:
// - get_profile_usecase.dart
// - update_profile_usecase.dart

/// Stub type for GetProfileUseCase until domain layer is implemented.
///
/// This will be replaced with the actual use case import from:
/// `package:app_pasos_frontend/features/profile/domain/usecases/get_profile_usecase.dart`
// ignore: one_member_abstracts
abstract class GetProfileUseCase {
  /// Fetches the current user's profile.
  Future<User> call();
}

/// Parameters for updating a user's profile.
///
/// This will be moved to the actual UpdateProfileUseCase file when created.
class UpdateProfileParams {
  /// Creates [UpdateProfileParams] instance.
  const UpdateProfileParams({
    required this.name,
    required this.email,
  });

  /// The updated name for the user.
  final String name;

  /// The updated email for the user.
  final String email;
}

/// Stub type for UpdateProfileUseCase until domain layer is implemented.
///
/// This will be replaced with the actual use case import from:
/// `package:app_pasos_frontend/features/profile/domain/usecases/update_profile_usecase.dart`
// ignore: one_member_abstracts
abstract class UpdateProfileUseCase {
  /// Updates the user's profile with the given parameters.
  Future<User> call(UpdateProfileParams params);
}

/// BLoC for managing profile state.
///
/// This BLoC processes [ProfileEvent]s and emits [ProfileState]s. It uses
/// use cases for business logic, following the Dependency Inversion Principle.
///
/// Example usage:
/// ```dart
/// // Create ProfileBloc with dependencies
/// final profileBloc = ProfileBloc(
///   getProfileUseCase: getIt<GetProfileUseCase>(),
///   updateProfileUseCase: getIt<UpdateProfileUseCase>(),
/// );
///
/// // Use in a BlocProvider
/// BlocProvider(
///   create: (context) => profileBloc..add(const ProfileLoadRequested()),
///   child: const ProfileScreen(),
/// )
/// ```
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  /// Creates a [ProfileBloc] instance.
  ///
  /// [getProfileUseCase] - Use case for fetching the user's profile.
  /// [updateProfileUseCase] - Use case for updating the user's profile.
  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
  }

  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  /// Handles [ProfileLoadRequested] events.
  ///
  /// Fetches the current user's profile from the server and emits
  /// the appropriate state based on the result.
  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = await _getProfileUseCase();
      emit(ProfileLoaded(user: user));
    } on AppException catch (e) {
      emit(ProfileError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(ProfileError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handles [ProfileUpdateRequested] events.
  ///
  /// Updates the user's profile with the provided name and email,
  /// preserving the current user data during the update process.
  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // Preserve current user data for updating state
    final currentUser = switch (state) {
      ProfileLoaded(:final user) => user,
      ProfileUpdating(:final user) => user,
      ProfileUpdateSuccess(:final user) => user,
      _ => null,
    };

    if (currentUser != null) {
      emit(ProfileUpdating(user: currentUser));
    } else {
      emit(const ProfileLoading());
    }

    try {
      final updatedUser = await _updateProfileUseCase(
        UpdateProfileParams(
          name: event.name,
          email: event.email,
        ),
      );
      emit(ProfileUpdateSuccess(user: updatedUser));
    } on AppException catch (e) {
      emit(ProfileError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(ProfileError(message: 'An unexpected error occurred: $e'));
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
