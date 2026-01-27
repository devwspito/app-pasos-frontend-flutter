/// Search users use case.
///
/// This use case searches for users to share with.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/shared_user.dart';
import 'package:app_pasos_frontend/features/sharing/domain/repositories/sharing_repository.dart';

/// Use case for searching users to share with.
///
/// This follows the Single Responsibility Principle - it only handles
/// user search operations. It also follows Dependency Inversion Principle
/// by depending on the SharingRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = SearchUsersUseCase(repository: sharingRepository);
/// final users = await useCase(query: 'john');
/// for (final user in users) {
///   print('Found user: ${user.name}');
/// }
/// ```
class SearchUsersUseCase {
  /// Creates a [SearchUsersUseCase] instance.
  ///
  /// [repository] - The sharing repository interface.
  SearchUsersUseCase({required SharingRepository repository})
      : _repository = repository;

  final SharingRepository _repository;

  /// Executes the use case to search for users.
  ///
  /// [query] - The search query (name or email).
  ///
  /// Returns a list of [SharedUser] objects matching the query.
  /// Throws exceptions from the repository on failure.
  Future<List<SharedUser>> call({required String query}) async {
    return _repository.searchUsers(query: query);
  }
}
