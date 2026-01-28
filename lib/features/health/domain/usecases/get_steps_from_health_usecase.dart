/// Get steps from health platform use case.
///
/// This use case retrieves step data from the native health platform
/// (Apple Health or Google Fit) for a specific date range.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:equatable/equatable.dart';

import 'package:app_pasos_frontend/features/health/domain/entities/health_data.dart';
import 'package:app_pasos_frontend/features/health/domain/repositories/health_repository.dart';

/// Parameters required for getting steps from health platform.
///
/// Uses Equatable for value comparison in tests and state management.
class GetStepsFromHealthParams extends Equatable {
  /// Creates get steps from health parameters.
  ///
  /// [start] - The start date/time for the query.
  /// [end] - The end date/time for the query.
  const GetStepsFromHealthParams({
    required this.start,
    required this.end,
  });

  /// The start date/time for the health data query.
  final DateTime start;

  /// The end date/time for the health data query.
  final DateTime end;

  @override
  List<Object?> get props => [start, end];
}

/// Use case for getting steps from the native health platform.
///
/// This follows the Single Responsibility Principle - it only handles
/// retrieving steps from health platforms. It also follows Dependency
/// Inversion Principle by depending on the HealthRepository interface
/// rather than a concrete implementation.
///
/// Example usage:
/// ```dart
/// final useCase = GetStepsFromHealthUseCase(repository: healthRepository);
/// final healthData = await useCase(
///   GetStepsFromHealthParams(
///     start: DateTime(2024, 1, 1),
///     end: DateTime(2024, 1, 31),
///   ),
/// );
/// print('Total steps: ${healthData.totalSteps}');
/// ```
class GetStepsFromHealthUseCase {
  /// Creates a [GetStepsFromHealthUseCase] instance.
  ///
  /// [repository] - The health repository interface.
  GetStepsFromHealthUseCase({required HealthRepository repository})
      : _repository = repository;

  final HealthRepository _repository;

  /// Executes the use case to get steps from health platform.
  ///
  /// [params] - The parameters containing start and end dates.
  ///
  /// Returns [HealthData] containing total steps and individual samples.
  /// Throws [PermissionDeniedException] if health permissions not granted.
  /// Throws [PlatformException] if the health platform is unavailable.
  /// Throws [HealthDataException] on data retrieval errors.
  Future<HealthData> call(GetStepsFromHealthParams params) async {
    return _repository.getStepsForDateRange(
      start: params.start,
      end: params.end,
    );
  }
}
