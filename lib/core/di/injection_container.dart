import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

import 'modules/bloc_module.dart';

/// Global service locator instance.
///
/// Use this to access registered dependencies throughout the app:
/// ```dart
/// final dio = sl<Dio>();
/// final storage = sl<FlutterSecureStorage>();
/// ```
final GetIt sl = GetIt.instance;

/// Configures all dependencies for the application.
///
/// This function should be called once at app startup, typically
/// in `main()` before `runApp()`:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await configureDependencies();
///   runApp(const MyApp());
/// }
/// ```
///
/// The function is async to allow for future async initialization
/// requirements (e.g., loading environment variables).
///
/// Module registration order (add as they are created):
/// 1. StorageModule - base infrastructure, no dependencies
/// 2. NetworkModule - may depend on storage for tokens
/// 3. RouterModule - may depend on auth state
/// 4. BlocModule - depends on repositories/services from above modules
Future<void> configureDependencies() async {
  // Load environment variables first
  await dotenv.load(fileName: '.env');

  // Register modules in dependency order
  // TODO: Add StorageModule.register(sl) when created
  // TODO: Add NetworkModule.register(sl) when created
  // TODO: Add RouterModule.register(sl) when created
  BlocModule.register(sl);
}
