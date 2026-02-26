// ignore_for_file: dangling_library_doc_comments

/// Dependency Injection Container using GetIt
/// 
/// Centralizes service instantiation and dependency management.
/// All services should be registered here and accessed via the [sl] locator.
/// 
/// Example:
/// ```dart
/// // Access a service
/// final authService = sl<AuthService>();
/// 
/// // Or inject in widget
/// class MyWidget extends StatelessWidget {
///   final ActivityService activityService = sl<ActivityService>();
/// }
/// ```
library;

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../services/auth_service.dart';
import '../../services/activity_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/analytics_service.dart';
import '../../services/achievements_service.dart';
import '../../services/guest_service.dart';
import '../network/dio_client.dart';
import '../network/cache_manager.dart';
import '../network/connectivity_service.dart';
import '../storage/offline_storage.dart';
import '../utils/app_logger.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
/// 
/// Call this before running the app in main.dart:
/// ```dart
/// await setupServiceLocator();
/// runApp(MyApp());
/// ```
Future<void> setupServiceLocator() async {
  AppLogger.info('Setting up service locator...');

  // Initialize offline storage first (needed by other services)
  final offlineStorage = OfflineStorage();
  await offlineStorage.init();
  sl.registerSingleton<OfflineStorage>(offlineStorage);

  // External dependencies
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<Connectivity>(
    () => Connectivity(),
  );

  // Core services
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(sl<Connectivity>()),
  );

  sl.registerLazySingleton<CacheManager>(
    () => CacheManager(),
  );

  // Network client
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      storage: sl<FlutterSecureStorage>(),
      connectivityService: sl<ConnectivityService>(),
      cacheManager: sl<CacheManager>(),
    ),
  );

  sl.registerLazySingleton<Dio>(
    () => sl<DioClient>().dio,
  );

  // Application services
  sl.registerLazySingleton<GuestService>(
    () => GuestService(),
  );

  sl.registerLazySingleton<AuthService>(
    () => AuthService(),
  );

  sl.registerLazySingleton<ActivityService>(
    () => ActivityService(),
  );

  sl.registerLazySingleton<DashboardService>(
    () => DashboardService(),
  );

  sl.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService(),
  );

  sl.registerLazySingleton<AchievementsService>(
    () => AchievementsService(),
  );

  AppLogger.info('Service locator setup completed');
}

/// Reset all dependencies (useful for testing)
Future<void> resetServiceLocator() async {
  await sl.reset();
  AppLogger.info('Service locator reset');
}
