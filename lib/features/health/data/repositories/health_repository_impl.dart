import '../datasources/health_datasource.dart';

/// Abstract interface for health repository operations.
///
/// Defines the contract for accessing health data from the device's health store.
/// This interface lives in the domain layer and should be implemented by a
/// concrete class in the data layer.
///
/// TODO: Move this to lib/features/health/domain/repositories/ when that story is created.
///
/// Example usage:
/// ```dart
/// final repository = HealthRepositoryImpl();
///
/// // Get today's steps
/// final steps = await repository.getTodaySteps();
/// print('Today\'s steps: ${steps.fold<int>(0, (sum, d) => sum + d.intValue)}');
///
/// // Check permissions
/// if (!await repository.hasPermission()) {
///   final granted = await repository.requestPermission();
///   if (!granted) {
///     print('Permission denied');
///   }
/// }
/// ```
abstract class HealthRepository {
  /// Fetches today's step count data.
  ///
  /// Returns a list of [HealthData] entities containing step count data
  /// from midnight today until the current time.
  /// May return an empty list if no data is available.
  ///
  /// Throws an exception if authorization has not been granted or on
  /// platform-specific errors.
  Future<List<HealthData>> getTodaySteps();

  /// Fetches step count data within the specified time range.
  ///
  /// [start] - The start of the time range to fetch data for.
  /// [end] - The end of the time range to fetch data for.
  ///
  /// Returns a list of [HealthData] entities containing step count data.
  /// May return an empty list if no data is available for the time range.
  Future<List<HealthData>> getSteps(DateTime start, DateTime end);

  /// Requests permission to read step data from the health store.
  ///
  /// Returns true if permission was granted, false otherwise.
  Future<bool> requestPermission();

  /// Checks if the app has permission to read step data.
  ///
  /// Returns true if permission has been granted, false otherwise.
  Future<bool> hasPermission();
}

/// Implementation of [HealthRepository] that connects the domain layer to the data layer.
///
/// This repository acts as a bridge between the domain layer (which works with entities)
/// and the data layer (which works with data sources). It delegates all data operations
/// to the [HealthDataSource].
///
/// Example usage:
/// ```dart
/// // Default usage (creates its own datasource)
/// final repository = HealthRepositoryImpl();
///
/// // With injected datasource (for testing)
/// final mockDataSource = MockHealthDataSource();
/// final repository = HealthRepositoryImpl(dataSource: mockDataSource);
///
/// // Get today's total steps
/// final steps = await repository.getTodaySteps();
/// final totalSteps = steps.fold<int>(0, (sum, data) => sum + data.intValue);
/// print('Today\'s steps: $totalSteps');
/// ```
class HealthRepositoryImpl implements HealthRepository {
  final HealthDataSource _dataSource;

  /// Creates a [HealthRepositoryImpl] instance.
  ///
  /// [dataSource] - Optional datasource instance. Uses default implementation if not provided.
  HealthRepositoryImpl({HealthDataSource? dataSource})
      : _dataSource = dataSource ?? HealthDataSourceImpl();

  @override
  Future<List<HealthData>> getTodaySteps() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _dataSource.fetchSteps(startOfDay, now);
  }

  @override
  Future<List<HealthData>> getSteps(DateTime start, DateTime end) async {
    return _dataSource.fetchSteps(start, end);
  }

  @override
  Future<bool> requestPermission() async {
    return _dataSource.requestAuthorization();
  }

  @override
  Future<bool> hasPermission() async {
    return _dataSource.hasAuthorization();
  }
}
