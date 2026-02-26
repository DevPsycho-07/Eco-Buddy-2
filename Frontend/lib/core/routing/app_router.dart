// ignore_for_file: dangling_library_doc_comments

/// App routing configuration using go_router
/// 
/// Provides declarative routing with deep linking support.
/// All routes are defined here for easy navigation throughout the app.
/// 
/// Example:
/// ```dart
/// // Navigate to a route
/// context.go('/profile');
/// 
/// // Navigate with parameters
/// context.push('/activity/${activityId}');
/// 
/// // Go back
/// context.pop();
/// ```
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../pages/auth/welcome_page.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/auth/register_page.dart';
import '../../pages/auth/forgot_password_page.dart';
import '../../pages/auth/reset_password_page.dart';
import '../../pages/auth/verify_email_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/activity/activity_log_page.dart';
import '../../pages/activity/all_activities_page.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/analytics/analytics_page.dart';
import '../../pages/leaderboard/leaderboard_page.dart';
import '../../pages/achievements/achievements_page.dart';
import '../../pages/settings/settings_page.dart';
import '../../pages/chat/eco_chat_page.dart';
import '../../pages/notifications/notifications_page.dart';
import '../../pages/profile/notifications_page.dart' as profile_notifications;
import '../../pages/profile/edit_profile_page.dart';
import '../../pages/profile/help_support_page.dart';
import '../../pages/profile/export_data_page.dart';
import '../../pages/legal/terms_of_service_page.dart';
import '../../pages/legal/privacy_policy_page.dart';
import '../navigation/app_shell.dart';
import '../utils/app_logger.dart';

/// Router configuration
class AppRouter {
  /// Update the cached auth state and refresh router (used for logout)
  static void updateAuthState(bool isLoggedIn) {
    _cachedAuthState = isLoggedIn;
    AppLogger.info('Auth state updated: isLoggedIn=$isLoggedIn');
    // Refresh router to trigger redirect check
    router.refresh();
  }

  /// Silently set auth state without refreshing router.
  /// Used during login/signup so the UI can check eco profile
  /// before the router redirect fires.
  static void setAuthState(bool isLoggedIn) {
    _cachedAuthState = isLoggedIn;
    AppLogger.info('Auth state set (no refresh): isLoggedIn=$isLoggedIn');
  }
  
  static final GoRouter router = GoRouter(
    initialLocation: '/welcome',
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    observers: [_RouterObserver()],
    routes: [
      // ============ Auth Routes ============
      GoRoute(

        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordPage(email: email, token: token);
        },
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final token = state.uri.queryParameters['token'] ?? '';
          return VerifyEmailPage(email: email, token: token);
        },
      ),

      // ============ Main App Shell ============
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/activities',
            name: 'activities',
            builder: (context, state) => const ActivityLogPage(),
          ),
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: '/leaderboard',
            name: 'leaderboard',
            builder: (context, state) => const LeaderboardPage(),
          ),
          GoRoute(
            path: '/achievements',
            name: 'achievements',
            builder: (context, state) => const AchievementsPage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const EcoChatPage(),
          ),
        ],
      ),

      // ============ Pages outside shell ============
      GoRoute(
        path: '/all-activities',
        name: 'all-activities',
        builder: (context, state) => const AllActivitiesPage(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) {
          final profileData = state.extra as Map<String, dynamic>?;
          return EditProfilePage(profileData: profileData ?? {});
        },
      ),
      GoRoute(
        path: '/notification-settings',
        name: 'notification-settings',
        builder: (context, state) {
          final notificationsEnabled = state.extra as bool? ?? true;
          return profile_notifications.NotificationsPage(
            notificationsEnabled: notificationsEnabled,
          );
        },
      ),
      GoRoute(
        path: '/help-support',
        name: 'help-support',
        builder: (context, state) => const HelpSupportPage(),
      ),
      GoRoute(
        path: '/export-data',
        name: 'export-data',
        builder: (context, state) => const ExportDataPage(),
      ),
      GoRoute(
        path: '/terms-of-service',
        name: 'terms-of-service',
        builder: (context, state) => const TermsOfServicePage(),
      ),
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
    ],
    errorBuilder: (context, state) => _ErrorPage(state.error.toString()),
  );
}

/// Router observer for logging navigation events
class _RouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.info('Navigation: ${previousRoute?.settings.name} → ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.info('Navigation: ${route.settings.name} ← ${previousRoute?.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    AppLogger.info('Navigation: ${oldRoute?.settings.name} ⇄ ${newRoute?.settings.name}');
  }
}

/// Error page for invalid routes
class _ErrorPage extends StatelessWidget {
  final String error;

  const _ErrorPage(this.error);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigation helpers
extension NavigationExtension on BuildContext {
  /// Navigate to home
  void goHome() => go('/home');

  /// Navigate to activities
  void goActivities() => go('/activities');

  /// Navigate to profile
  void goProfile() => go('/profile');

  /// Navigate to analytics
  void goAnalytics() => go('/analytics');

  /// Navigate to leaderboard
  void goLeaderboard() => go('/leaderboard');

  /// Navigate to achievements
  void goAchievements() => go('/achievements');

  /// Navigate to settings
  void goSettings() => go('/settings');

  /// Navigate to login
  void goLogin() => go('/login');

  /// Navigate to register
  void goRegister() => go('/register');

  /// Navigate to forgot password
  void goForgotPassword() => go('/forgot-password');

  /// Navigate to reset password
  void goResetPassword({required String email, required String token}) =>
      go('/reset-password?email=$email&token=$token');

  /// Navigate to verify email
  void goVerifyEmail({required String email, required String token}) =>
      go('/verify-email?email=$email&token=$token');
}

/// Handle route redirects based on authentication state
/// Note: This uses a cached auth state that gets updated during login/logout
String? _handleRedirect(BuildContext context, GoRouterState state) {
  // Get current location
  final String location = state.uri.path;
  
  // Auth routes that don't require login
  const List<String> authRoutes = [
    '/welcome',
    '/login',
    '/register',
    '/forgot-password',
    '/reset-password',
    '/verify-email',
  ];
  
  // Get cached auth state - this will be set by AuthService.login/logout
  final isLoggedIn = _cachedAuthState;
  
  // If on auth route and logged in, redirect to home
  if (authRoutes.contains(location) && isLoggedIn) {
    AppLogger.info('User is logged in, redirecting from $location to /home');
    return '/home';
  }
  
  // If on protected route and not logged in, redirect to welcome
  if (!authRoutes.contains(location) && !isLoggedIn) {
    AppLogger.info('User not logged in, redirecting from $location to /welcome');
    return '/welcome';
  }
  
  // No redirect needed
  return null;
}

/// Cached auth state - updated by AuthService.login/logout
bool _cachedAuthState = false;
