/// Dependency injection container for App Pasos.
///
/// This file configures and initializes all application dependencies using
/// the get_it service locator pattern. All services should be registered
/// here and accessed via the [sl] global instance.
library;

import 'package:app_pasos_frontend/core/errors/error_handler.dart';
import 'package:app_pasos_frontend/core/network/api_client.dart';
import 'package:app_pasos_frontend/core/services/background_sync_service.dart';
import 'package:app_pasos_frontend/core/services/background_sync_service_impl.dart';
import 'package:app_pasos_frontend/core/services/connectivity_service.dart';
import 'package:app_pasos_frontend/core/services/notification_handler.dart';
import 'package:app_pasos_frontend/core/services/notification_service.dart';
import 'package:app_pasos_frontend/core/services/notification_service_impl.dart';
import 'package:app_pasos_frontend/core/services/sync_service.dart';
import 'package:app_pasos_frontend/core/services/websocket_event_handler.dart';
import 'package:app_pasos_frontend/core/services/websocket_service.dart';
import 'package:app_pasos_frontend/core/services/websocket_service_impl.dart';
import 'package:app_pasos_frontend/core/services/health_service.dart';
import 'package:app_pasos_frontend/core/services/health_service_impl.dart';
import 'package:app_pasos_frontend/core/storage/boxes/steps_box.dart';
import 'package:app_pasos_frontend/core/storage/hive_service.dart';
import 'package:app_pasos_frontend/core/storage/secure_storage_service.dart';
import 'package:app_pasos_frontend/core/storage/sync_queue.dart';
import 'package:app_pasos_frontend/core/utils/logger.dart';
import 'package:app_pasos_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_pasos_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app_pasos_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_pasos_frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:app_pasos_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_pasos_frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app_pasos_frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:app_pasos_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app_pasos_frontend/features/dashboard/data/datasources/steps_remote_datasource.dart';
import 'package:app_pasos_frontend/features/dashboard/data/repositories/steps_repository_impl.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/repositories/steps_repository.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/usecases/get_hourly_peaks_usecase.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/usecases/get_stats_usecase.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/usecases/get_today_steps_usecase.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/usecases/get_weekly_trend_usecase.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/usecases/record_steps_usecase.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/usecases/sync_native_steps_usecase.dart';
import 'package:app_pasos_frontend/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:app_pasos_frontend/features/goals/data/datasources/goals_remote_datasource.dart';
import 'package:app_pasos_frontend/features/goals/data/repositories/goals_repository_impl.dart';
import 'package:app_pasos_frontend/features/goals/domain/repositories/goals_repository.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/create_goal_usecase.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/get_goal_details_usecase.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/get_goal_progress_usecase.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/get_user_goals_usecase.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/invite_user_usecase.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/join_goal_usecase.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/leave_goal_usecase.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/update_goal_usecase.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/create_goal_bloc.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/edit_goal_bloc.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_bloc.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goals_list_bloc.dart';
import 'package:app_pasos_frontend/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:app_pasos_frontend/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:app_pasos_frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:app_pasos_frontend/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:app_pasos_frontend/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:app_pasos_frontend/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:app_pasos_frontend/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:app_pasos_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:app_pasos_frontend/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:app_pasos_frontend/features/sharing/data/datasources/sharing_remote_datasource.dart';
import 'package:app_pasos_frontend/features/sharing/data/repositories/sharing_repository_impl.dart';
import 'package:app_pasos_frontend/features/sharing/domain/repositories/sharing_repository.dart';
import 'package:app_pasos_frontend/features/sharing/domain/usecases/accept_request_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/domain/usecases/get_friend_stats_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/domain/usecases/get_relationships_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/domain/usecases/reject_request_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/domain/usecases/revoke_sharing_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/domain/usecases/search_users_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/domain/usecases/send_request_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/friend_search_bloc.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/sharing_bloc.dart';
import 'package:get_it/get_it.dart';

/// Global service locator instance.
///
/// Use this to access registered dependencies throughout the application:
/// ```dart
/// final apiClient = sl<ApiClient>();
/// final storage = sl<SecureStorageService>();
/// ```
final GetIt sl = GetIt.instance;

/// Initializes all application dependencies.
///
/// This function must be called before [runApp] in [main.dart].
/// It registers all services as lazy singletons, meaning they are
/// created only when first accessed and reused thereafter.
///
/// Registration order matters for dependencies that depend on other services.
/// The order is:
/// 1. Core utilities (Logger, ErrorHandler)
/// 2. Storage services
/// 3. Network services (which depend on storage)
///
/// Example usage in main.dart:
/// ```dart
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await initializeDependencies();
///   runApp(const App());
/// }
/// ```
Future<void> initializeDependencies() async {
  // ============================================================
  // Core Utilities
  // ============================================================

  // Logger - Singleton pattern built into AppLogger
  sl.registerLazySingleton<AppLogger>(AppLogger.new);

  // Error Handler - Depends on Logger internally
  sl.registerLazySingleton<ErrorHandler>(ErrorHandler.new);

  // ============================================================
  // Storage Services
  // ============================================================

  // Secure Storage - For sensitive data like tokens
  sl.registerLazySingleton<SecureStorageService>(
    SecureStorageServiceImpl.new,
  );

  // ============================================================
  // Hive Storage Services
  // ============================================================

  // Hive Service - Must be initialized first for offline storage
  sl.registerLazySingleton<HiveService>(HiveServiceImpl.new);

  // Storage Boxes - Depend on HiveService being initialized
  sl.registerLazySingleton<StepsBox>(StepsBox.new);

  // Sync Queue - Persisted in Hive for offline operation queuing
  sl.registerLazySingleton<SyncQueue>(SyncQueueImpl.new);

  // ============================================================
  // Connectivity & Sync Services
  // ============================================================

  // Connectivity Service - For monitoring network status
  sl.registerLazySingleton<ConnectivityService>(ConnectivityServiceImpl.new);

  // ============================================================
  // Network Services
  // ============================================================

  // API Client - Depends on SecureStorageService for auth token management
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(storage: sl<SecureStorageService>()),
  );

  // Sync Service - For processing offline operations when online
  // Depends on SyncQueue, ConnectivityService, and ApiClient
  sl.registerLazySingleton<SyncService>(
    () => SyncServiceImpl(
      syncQueue: sl<SyncQueue>(),
      connectivityService: sl<ConnectivityService>(),
      apiClient: sl<ApiClient>(),
    ),
  );

  // ============================================================
  // Health Service
  // ============================================================

  sl.registerLazySingleton<HealthService>(HealthServiceImpl.new);

  // ============================================================
  // Core Services
  // ============================================================

  // Background Sync Service - For periodic data synchronization
  sl.registerLazySingleton<BackgroundSyncService>(
    () => BackgroundSyncServiceImpl(storageService: sl<SecureStorageService>()),
  );

  // ============================================================
  // WebSocket Services
  // ============================================================

  // WebSocket Service - For real-time communication with backend
  sl.registerLazySingleton<WebSocketService>(
    () => WebSocketServiceImpl(storageService: sl<SecureStorageService>()),
  );

  // WebSocket Event Handler - Routes WebSocket messages to appropriate BLoCs
  sl.registerLazySingleton<WebSocketEventHandler>(
    () => WebSocketEventHandler(webSocketService: sl<WebSocketService>()),
  );

  // ============================================================
  // Notification Services
  // ============================================================

  // Notification Service - For push notifications via FCM
  sl.registerLazySingleton<NotificationService>(NotificationServiceImpl.new);

  // Notification Handler - Routes notifications to appropriate screens
  sl.registerLazySingleton<NotificationHandler>(
    () => NotificationHandler(notificationService: sl<NotificationService>()),
  );

  // ============================================================
  // Auth Feature
  // ============================================================

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(client: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      datasource: sl<AuthRemoteDatasource>(),
      storage: sl<SecureStorageService>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(repository: sl<AuthRepository>()),
  );

  // Blocs (Factory - new instance per use)
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  // ============================================================
  // Dashboard Feature
  // ============================================================

  // Data Sources
  sl.registerLazySingleton<StepsRemoteDatasource>(
    () => StepsRemoteDatasourceImpl(client: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<StepsRepository>(
    () => StepsRepositoryImpl(
      datasource: sl<StepsRemoteDatasource>(),
      stepsBox: sl<StepsBox>(),
      syncQueue: sl<SyncQueue>(),
      connectivity: sl<ConnectivityService>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetTodayStepsUseCase>(
    () => GetTodayStepsUseCase(repository: sl<StepsRepository>()),
  );
  sl.registerLazySingleton<GetStatsUseCase>(
    () => GetStatsUseCase(repository: sl<StepsRepository>()),
  );
  sl.registerLazySingleton<GetWeeklyTrendUseCase>(
    () => GetWeeklyTrendUseCase(repository: sl<StepsRepository>()),
  );
  sl.registerLazySingleton<GetHourlyPeaksUseCase>(
    () => GetHourlyPeaksUseCase(repository: sl<StepsRepository>()),
  );
  sl.registerLazySingleton<RecordStepsUseCase>(
    () => RecordStepsUseCase(repository: sl<StepsRepository>()),
  );
  sl.registerLazySingleton<SyncNativeStepsUseCase>(
    () => SyncNativeStepsUseCase(
      healthService: sl<HealthService>(),
      stepsRepository: sl<StepsRepository>(),
    ),
  );

  // Blocs (Factory - new instance per use)
  sl.registerFactory<DashboardBloc>(
    () => DashboardBloc(
      getTodayStepsUseCase: sl<GetTodayStepsUseCase>(),
      getStatsUseCase: sl<GetStatsUseCase>(),
      getWeeklyTrendUseCase: sl<GetWeeklyTrendUseCase>(),
      getHourlyPeaksUseCase: sl<GetHourlyPeaksUseCase>(),
      recordStepsUseCase: sl<RecordStepsUseCase>(),
      syncNativeStepsUseCase: sl<SyncNativeStepsUseCase>(),
    ),
  );

  // ============================================================
  // Sharing Feature
  // ============================================================

  // Data Sources
  sl.registerLazySingleton<SharingRemoteDatasource>(
    () => SharingRemoteDatasourceImpl(client: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<SharingRepository>(
    () => SharingRepositoryImpl(datasource: sl<SharingRemoteDatasource>()),
  );

  // Use Cases
  sl.registerLazySingleton<GetRelationshipsUseCase>(
    () => GetRelationshipsUseCase(repository: sl<SharingRepository>()),
  );
  sl.registerLazySingleton<SendRequestUseCase>(
    () => SendRequestUseCase(repository: sl<SharingRepository>()),
  );
  sl.registerLazySingleton<AcceptRequestUseCase>(
    () => AcceptRequestUseCase(repository: sl<SharingRepository>()),
  );
  sl.registerLazySingleton<RejectRequestUseCase>(
    () => RejectRequestUseCase(repository: sl<SharingRepository>()),
  );
  sl.registerLazySingleton<RevokeSharingUseCase>(
    () => RevokeSharingUseCase(repository: sl<SharingRepository>()),
  );
  sl.registerLazySingleton<GetFriendStatsUseCase>(
    () => GetFriendStatsUseCase(repository: sl<SharingRepository>()),
  );
  sl.registerLazySingleton<SearchUsersUseCase>(
    () => SearchUsersUseCase(repository: sl<SharingRepository>()),
  );

  // Blocs (Factory - new instance per use)
  sl.registerFactory<SharingBloc>(
    () => SharingBloc(
      getRelationshipsUseCase: sl<GetRelationshipsUseCase>(),
      sendRequestUseCase: sl<SendRequestUseCase>(),
      acceptRequestUseCase: sl<AcceptRequestUseCase>(),
      rejectRequestUseCase: sl<RejectRequestUseCase>(),
      revokeSharingUseCase: sl<RevokeSharingUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
    ),
  );
  sl.registerFactory<FriendSearchBloc>(
    () => FriendSearchBloc(
      searchUsersUseCase: sl<SearchUsersUseCase>(),
    ),
  );

  // ============================================================
  // Goals Feature
  // ============================================================

  // Data Sources
  sl.registerLazySingleton<GoalsRemoteDatasource>(
    () => GoalsRemoteDatasourceImpl(client: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<GoalsRepository>(
    () => GoalsRepositoryImpl(datasource: sl<GoalsRemoteDatasource>()),
  );

  // Use Cases
  sl.registerLazySingleton<GetUserGoalsUseCase>(
    () => GetUserGoalsUseCase(repository: sl<GoalsRepository>()),
  );
  sl.registerLazySingleton<CreateGoalUseCase>(
    () => CreateGoalUseCase(repository: sl<GoalsRepository>()),
  );
  sl.registerLazySingleton<GetGoalDetailsUseCase>(
    () => GetGoalDetailsUseCase(repository: sl<GoalsRepository>()),
  );
  sl.registerLazySingleton<GetGoalProgressUseCase>(
    () => GetGoalProgressUseCase(repository: sl<GoalsRepository>()),
  );
  sl.registerLazySingleton<InviteUserUseCase>(
    () => InviteUserUseCase(repository: sl<GoalsRepository>()),
  );
  sl.registerLazySingleton<JoinGoalUseCase>(
    () => JoinGoalUseCase(repository: sl<GoalsRepository>()),
  );
  sl.registerLazySingleton<LeaveGoalUseCase>(
    () => LeaveGoalUseCase(repository: sl<GoalsRepository>()),
  );
  sl.registerLazySingleton<UpdateGoalUseCase>(
    () => UpdateGoalUseCase(repository: sl<GoalsRepository>()),
  );

  // Blocs (Factory - new instance per use)
  sl.registerFactory<GoalsListBloc>(
    () => GoalsListBloc(
      getUserGoalsUseCase: sl<GetUserGoalsUseCase>(),
    ),
  );
  sl.registerFactory<GoalDetailBloc>(
    () => GoalDetailBloc(
      getGoalDetailsUseCase: sl<GetGoalDetailsUseCase>(),
      getGoalProgressUseCase: sl<GetGoalProgressUseCase>(),
      inviteUserUseCase: sl<InviteUserUseCase>(),
      leaveGoalUseCase: sl<LeaveGoalUseCase>(),
    ),
  );
  sl.registerFactory<CreateGoalBloc>(
    () => CreateGoalBloc(
      createGoalUseCase: sl<CreateGoalUseCase>(),
    ),
  );
  sl.registerFactory<EditGoalBloc>(
    () => EditGoalBloc(
      updateGoalUseCase: sl<UpdateGoalUseCase>(),
      getGoalDetailsUseCase: sl<GetGoalDetailsUseCase>(),
    ),
  );

  // ============================================================
  // Profile Feature
  // ============================================================

  // Data Sources
  sl.registerLazySingleton<ProfileRemoteDatasource>(
    () => ProfileRemoteDatasourceImpl(client: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(datasource: sl<ProfileRemoteDatasource>()),
  );

  // Use Cases
  sl.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(repository: sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(repository: sl<ProfileRepository>()),
  );

  // ============================================================
  // Settings Feature
  // ============================================================

  // Data Sources
  sl.registerLazySingleton<SettingsRemoteDatasource>(
    () => SettingsRemoteDatasourceImpl(client: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(datasource: sl<SettingsRemoteDatasource>()),
  );

  // Blocs (Factory - new instance per use)
  sl.registerFactory<SettingsBloc>(
    () => SettingsBloc(
      repository: sl<SettingsRepository>(),
      authRepository: sl<AuthRepository>(),
    ),
  );
}

/// Resets all registered dependencies.
///
/// Use this for testing or when you need to reinitialize the app.
/// This will clear all registered singletons.
///
/// **Warning**: Only use this in tests or specific scenarios like
/// user logout where you want to clear all cached instances.
Future<void> resetDependencies() async {
  await sl.reset();
}
