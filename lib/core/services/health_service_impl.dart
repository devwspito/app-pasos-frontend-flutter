import 'package:health/health.dart';

import 'health_service.dart';

/// Concrete implementation of [HealthService] using the health package.
///
/// Uses Apple HealthKit on iOS and Google Fit on Android to access health data.
final class HealthServiceImpl implements HealthService {
  /// Health plugin instance for accessing device health data.
  final Health _health = Health();

  /// Health data types to request access for.
  static const List<HealthDataType> _types = [HealthDataType.STEPS];

  /// Permission levels for health data access.
  static const List<HealthDataAccess> _permissions = [HealthDataAccess.READ];

  @override
  Future<bool> isAvailable() async {
    try {
      return await _health.hasPermissions(_types) ?? false;
    } catch (e) {
      // Health data not available on this platform
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      return await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
    } catch (e) {
      // Permission request failed
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      return await _health.hasPermissions(_types) ?? false;
    } catch (e) {
      // Could not check permissions
      return false;
    }
  }

  @override
  Future<int> readStepCount({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final steps = await _health.getTotalStepsInInterval(startDate, endDate);
      return steps ?? 0;
    } catch (e) {
      // Failed to read step count
      return 0;
    }
  }
}
