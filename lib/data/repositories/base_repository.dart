/// Base repository interface for CRUD operations.
/// Provides a standard contract for all repository implementations.
///
/// Type parameter [T] represents the entity type managed by the repository.
abstract class BaseRepository<T> {
  /// Retrieves all entities from the data source.
  ///
  /// Returns a [Future] that completes with a list of all entities.
  /// Returns an empty list if no entities are found.
  ///
  /// Throws an exception if the operation fails.
  Future<List<T>> getAll();

  /// Retrieves a single entity by its unique identifier.
  ///
  /// [id] - The unique identifier of the entity to retrieve.
  ///
  /// Returns a [Future] that completes with the entity if found,
  /// or `null` if no entity exists with the given id.
  ///
  /// Throws an exception if the operation fails.
  Future<T?> getById(String id);

  /// Creates a new entity in the data source.
  ///
  /// [entity] - The entity to create.
  ///
  /// Returns a [Future] that completes with the created entity,
  /// including any server-generated fields (like id, timestamps).
  ///
  /// Throws an exception if the operation fails or validation fails.
  Future<T> create(T entity);

  /// Updates an existing entity in the data source.
  ///
  /// [id] - The unique identifier of the entity to update.
  /// [entity] - The entity with updated values.
  ///
  /// Returns a [Future] that completes with the updated entity.
  ///
  /// Throws an exception if the entity is not found or the operation fails.
  Future<T> update(String id, T entity);

  /// Deletes an entity from the data source.
  ///
  /// [id] - The unique identifier of the entity to delete.
  ///
  /// Returns a [Future] that completes with `true` if the entity was deleted,
  /// or `false` if the entity was not found.
  ///
  /// Throws an exception if the operation fails.
  Future<bool> delete(String id);
}
