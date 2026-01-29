/// Background worker for syncing native health steps.
///
/// This file provides the callback dispatcher for workmanager to execute
/// background step synchronization tasks. The callback runs in a separate
/// isolate, so it must re-initialize dependencies before accessing services.
library;

import 'package:app_pasos_frontend/core/di/injection_container.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/usecases/sync_native_steps_usecase.dart';
import 'package:workmanager/workmanager.dart';

/// Unique task name for step synchronization.
///
/// This identifier is used to register and identify the background task
/// with the workmanager. Use this constant when scheduling the task.
const String stepSyncTaskName = 'com.apppasos.stepSync';

/// Callback dispatcher for workmanager background tasks.
///
/// This is the entry point for background execution. It must be a top-level
/// function (not inside a class) and annotated with `@pragma('vm:entry-point')`
/// to ensure it's not removed by tree-shaking in release builds.
///
/// The workmanager will call this function when a background task is triggered.
/// It sets up the task execution handler that routes to the appropriate
/// task based on the task name.
///
/// **Important**: This runs in a separate isolate with fresh memory, so
/// all dependencies must be re-initialized before use.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // Route to appropriate handler based on task name
    switch (taskName) {
      case stepSyncTaskName:
        return _executeStepSync();
      case Workmanager.iOSBackgroundTask:
        // iOS uses a generic background task identifier
        // We treat it the same as our step sync task
        return _executeStepSync();
      default:
        // Unknown task - log and return success to avoid retries
        return Future.value(true);
    }
  });
}

/// Executes the step synchronization task.
///
/// This function:
/// 1. Initializes dependencies (required because background isolate has fresh memory)
/// 2. Retrieves the [SyncNativeStepsUseCase] from the service locator
/// 3. Executes the sync operation
/// 4. Returns success/failure status
///
/// Returns `true` if sync completed successfully or if there were no steps to sync.
/// Returns `false` if sync failed, which may trigger a retry based on workmanager config.
Future<bool> _executeStepSync() async {
  try {
    // Initialize dependencies - background isolate has fresh memory
    // Check if already initialized to avoid duplicate registration errors
    if (!sl.isRegistered<SyncNativeStepsUseCase>()) {
      await initializeDependencies();
    }

    // Get the sync use case from the service locator
    final syncUseCase = sl<SyncNativeStepsUseCase>();

    // Execute the sync operation
    // We ignore the result intentionally - sync returning null (no permission)
    // or 0 (no steps) is still considered "task completed" to avoid
    // unnecessary retries for permission issues
    await syncUseCase();

    return Future.value(true);
  } catch (e) {
    // Log error for debugging (in production, use proper logging)
    // Return false to indicate failure - workmanager may retry
    return Future.value(false);
  }
}
