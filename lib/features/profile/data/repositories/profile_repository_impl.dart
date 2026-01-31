/// Profile repository implementation.
///
/// This file implements the [ProfileRepository] interface, coordinating
/// with the remote datasource for profile operations.
library;

import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';
import 'package:app_pasos_frontend/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:app_pasos_frontend/features/profile/domain/repositories/profile_repository.dart';

/// Implementation of [ProfileRepository] using remote datasource.
///
/// This class implements the profile business logic, including:
/// - Making API calls through the datasource
/// - Converting data models to domain entities
///
/// Example usage:
/// ```dart
/// final repository = ProfileRepositoryImpl(
///   datasource: profileDatasource,
/// );
///
/// final user = await repository.getProfile();
/// ```
class ProfileRepositoryImpl implements ProfileRepository {
  /// Creates a [ProfileRepositoryImpl] with the required dependencies.
  ///
  /// [datasource] - The remote datasource for API calls.
  ProfileRepositoryImpl({
    required ProfileRemoteDatasource datasource,
  }) : _datasource = datasource;

  /// The remote datasource for API operations.
  final ProfileRemoteDatasource _datasource;

  @override
  Future<User> getProfile() async {
    return _datasource.getProfile();
  }

  @override
  Future<User> updateProfile({
    required String name,
    required String email,
  }) async {
    return _datasource.updateProfile(
      name: name,
      email: email,
    );
  }
}
