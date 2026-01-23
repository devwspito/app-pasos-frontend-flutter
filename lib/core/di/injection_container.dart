import 'package:get_it/get_it.dart';

import 'modules/network_module.dart';
import 'modules/storage_module.dart';

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
Future<void> configureDependencies() async {
  // Register storage dependencies first (may be needed by network)
  StorageModule.register(sl);

  // Register network dependencies
  NetworkModule.register(sl);
}
