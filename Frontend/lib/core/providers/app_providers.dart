// ignore_for_file: dangling_library_doc_comments

/// Riverpod state management providers
/// 
/// Centralized state management for the app using Riverpod.
/// Provides reactive state that automatically rebuilds UI when data changes.
/// 
/// Example:
/// ```dart
/// // In widget:
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final userProfile = ref.watch(userProfileProvider);
///     
///     return userProfile.when(
///       data: (profile) => Text(profile.username),
///       loading: () => CircularProgressIndicator(),
///       error: (error, stack) => Text('Error: $error'),
///     );
///   }
/// }
/// ```
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/activity_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/analytics_service.dart';
import '../../services/achievements_service.dart';
import '../di/service_locator.dart';
import '../network/connectivity_service.dart';
import '../utils/app_logger.dart';

// ==================== Service Providers ====================

/// Activity service provider
final activityServiceProvider = Provider<ActivityService>((ref) {
  return sl<ActivityService>();
});

/// Dashboard service provider
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return sl<DashboardService>();
});

/// Analytics service provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return sl<AnalyticsService>();
});

/// Achievements service provider
final achievementsServiceProvider = Provider<AchievementsService>((ref) {
  return sl<AchievementsService>();
});

// ==================== User State ====================

/// User profile provider
final userProfileProvider = FutureProvider<UserDashboard>((ref) async {
  AppLogger.info('Loading user profile...');
  return await DashboardService.getUserProfile();
});

/// User profile state notifier
final userProfileNotifierProvider = 
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserDashboard>>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserDashboard>> {
  final Ref ref;

  UserProfileNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await DashboardService.getUserProfile();
      state = AsyncValue.data(profile);
      AppLogger.info('User profile loaded');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      AppLogger.error('Failed to load user profile', error: error);
    }
  }

  Future<void> refresh() => loadProfile();
}

// ==================== Activity State ====================

/// Activity categories provider
final categoriesProvider = FutureProvider<List<ActivityCategory>>((ref) async {
  AppLogger.info('Loading activity categories...');
  return await ActivityService.getCategories();
});

/// Recent activities provider
final recentActivitiesProvider = FutureProvider<List<Activity>>((ref) async {
  AppLogger.info('Loading recent activities...');
  return await ActivityService.getTodayActivities();
});

/// Activity summary provider
final activitySummaryProvider = FutureProvider.family<ActivitySummary, int>(
  (ref, days) async {
    AppLogger.info('Loading activity summary for $days days...');
    return await ActivityService.getSummary(days: days);
  },
);

// ==================== Search and Filter State ====================

/// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Selected category filter
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Sort option state
final sortOptionProvider = StateProvider<String>((ref) => 'date_desc');

/// Filtered activities provider
final filteredActivitiesProvider = Provider<List<Activity>>((ref) {
  final activities = ref.watch(recentActivitiesProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return activities.when(
    data: (list) {
      var filtered = list;

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((activity) {
          return activity.activityTypeName
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              activity.categoryName
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
        }).toList();
      }

      // Filter by category
      if (selectedCategory != null && selectedCategory.isNotEmpty) {
        filtered = filtered.where((activity) {
          return activity.categoryName == selectedCategory;
        }).toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ==================== Analytics State ====================

/// Analytics stats provider
final analyticsStatsProvider = FutureProvider.family<AnalyticsStats, int>(
  (ref, days) async {
    AppLogger.info('Loading analytics stats for $days days...');
    return await AnalyticsService.getStats(days.toString());
  },
);

// ==================== Achievements State ====================

/// User achievements provider
final achievementsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  AppLogger.info('Loading achievements...');
  final summary = await AchievementsService.getSummary();
  return summary != null ? [summary] : [];
});

// ==================== UI State ====================

/// Loading state provider
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Error message provider
final errorMessageProvider = StateProvider<String?>((ref) => null);

/// Bottom navigation index
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Theme mode provider
final themeModeProvider = StateProvider<bool>((ref) => false); // false = light, true = dark

// ==================== Connectivity State ====================

/// Network connectivity provider
final connectivityProvider = StreamProvider<bool>((ref) {
  return sl<ConnectivityService>().connectivityStream;
});
