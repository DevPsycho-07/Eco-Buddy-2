/// Permissions Initialization Utility
/// Call this during app startup to request necessary permissions
library;

import 'package:flutter/material.dart';
import '../../services/permission_service.dart';
import 'app_logger.dart';

class PermissionsInit {
  /// Initialize all required permissions on app startup
  /// Call this in your main.dart or in a splash screen
  static Future<void> initializePermissions({
    BuildContext? context,
    bool requestAllAtOnce = false,
  }) async {
    try {
      AppLogger.info('🔐 Initializing app permissions...');
      
      if (requestAllAtOnce) {
        // Request all permissions at once
        await PermissionService.requestAllPermissions(
          onAllGranted: () {
            AppLogger.info('✅ All permissions granted');
            _showPermissionGrantedNotification(context);
          },
        );
      } else {
        // Request permissions individually for better UX
        await _requestPermissionsSequentially(context);
      }
      
      AppLogger.info('✅ Permission initialization completed');
    } catch (e) {
      AppLogger.error('Failed to initialize permissions', error: e);
    }
  }

  /// Request permissions one by one with proper handling
  static Future<void> _requestPermissionsSequentially(BuildContext? context) async {
    try {
      // Request notification permission first (background notifications need this)
      await PermissionService.requestNotificationPermission(
        onGranted: () => AppLogger.info('✅ Notifications enabled'),
        onDenied: () => AppLogger.warning('⚠️ Notifications disabled'),
      );
      
      // Request location permission
      await PermissionService.requestLocationPermission(
        onGranted: () => AppLogger.info('✅ Location enabled'),
        onDenied: () => AppLogger.warning('⚠️ Location disabled'),
      );
      
      // Request activity recognition on Android
      await PermissionService.requestActivityRecognitionPermission(
        onGranted: () => AppLogger.info('✅ Activity recognition enabled'),
        onDenied: () => AppLogger.warning('⚠️ Activity recognition disabled'),
      );
      
      // Request camera permission
      await PermissionService.requestCameraPermission(
        onGranted: () => AppLogger.info('✅ Camera enabled'),
        onDenied: () => AppLogger.warning('⚠️ Camera disabled'),
      );
      
      // Request photos permission
      await PermissionService.requestPhotosPermission(
        onGranted: () => AppLogger.info('✅ Photos enabled'),
        onDenied: () => AppLogger.warning('⚠️ Photos disabled'),
      );
    } catch (e) {
      AppLogger.error('Error during sequential permission requests', error: e);
    }
  }

  /// Show a notification that permissions were granted
  static void _showPermissionGrantedNotification(BuildContext? context) {
    if (context == null) return;
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📱 All permissions granted! Your app is ready to track eco activities.'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      AppLogger.warning('Could not show permission notification: $e');
    }
  }

  /// Check and log all permission statuses
  static Future<void> logAllPermissionStatuses() async {
    try {
      AppLogger.info('📋 Checking all permission statuses...');
      
      final isNotificationGranted = await PermissionService.isNotificationPermissionGranted();
      AppLogger.info('Notifications: ${isNotificationGranted ? '✅ Granted' : '❌ Denied'}');
      
      final isLocationGranted = await PermissionService.isLocationPermissionGranted();
      AppLogger.info('Location: ${isLocationGranted ? '✅ Granted' : '❌ Denied'}');
      
      final isActivityGranted = await PermissionService.isActivityRecognitionPermissionGranted();
      AppLogger.info('Activity Recognition: ${isActivityGranted ? '✅ Granted' : '❌ Denied'}');
      
      AppLogger.info('📋 Permission status check completed');
    } catch (e) {
      AppLogger.error('Failed to log permission statuses', error: e);
    }
  }
}
