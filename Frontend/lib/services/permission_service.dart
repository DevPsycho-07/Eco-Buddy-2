/// Permission Service
/// Handles all app permissions requests
library;

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../core/utils/app_logger.dart';
import 'dart:io';

class PermissionService {
  /// Request notification permission with callback
  static Future<bool> requestNotificationPermission({
    VoidCallback? onGranted,
    VoidCallback? onDenied,
  }) async {
    try {
      AppLogger.info('🔔 Requesting notification permission...');
      
      // For Android 13+ (API 33+)
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        
        AppLogger.info('Android Notification permission status: $status');
        
        if (status.isDenied) {
          AppLogger.warning('❌ Notification permission denied by user');
          onDenied?.call();
          return false;
        } else if (status.isGranted) {
          AppLogger.info('✅ Notification permission granted');
          onGranted?.call();
          return true;
        } else if (status.isPermanentlyDenied) {
          AppLogger.warning('⚠️ Notification permission permanently denied');
          _showPermissionSettingsDialog(
            title: 'Notification Permission Denied',
            message: 'Please enable notifications in app settings to receive updates about your eco activities.',
          );
          onDenied?.call();
          return false;
        } else if (status.isRestricted) {
          AppLogger.warning('⚠️ Notification permission restricted by parental controls');
          onDenied?.call();
          return false;
        }
      }
      
      // iOS - handle separately
      if (Platform.isIOS) {
        AppLogger.info('Requesting iOS notification permission');
        final status = await Permission.notification.request();
        
        if (status.isGranted) {
          AppLogger.info('✅ iOS Notification permission granted');
          onGranted?.call();
          return true;
        } else {
          AppLogger.warning('❌ iOS Notification permission denied');
          onDenied?.call();
          return false;
        }
      }
      
      AppLogger.info('✅ Notification permission request completed');
      onGranted?.call();
      return true;
    } catch (e) {
      AppLogger.error('Failed to request notification permission', error: e);
      onDenied?.call();
      return false;
    }
  }

  /// Check if notification permission is granted
  static Future<bool> isNotificationPermissionGranted() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        return status.isGranted;
      }
      // For iOS, assume granted (handled by Firebase)
      return true;
    } catch (e) {
      AppLogger.error('Failed to check notification permission', error: e);
      return false;
    }
  }

  /// Open app settings for notification permission
  static Future<bool> openNotificationSettings() async {
    try {
      AppLogger.info('Opening app notification settings...');
      return await openAppSettings();
    } catch (e) {
      AppLogger.error('Failed to open app settings', error: e);
      return false;
    }
  }

  /// Show dialog prompting user to enable notifications
  static void _showPermissionSettingsDialog({
    required String title,
    required String message,
  }) {
    AppLogger.info('Showing permission settings dialog');
    // This will be called from the UI context, so we just log for now
    // The actual dialog display will be handled in the app's root widget
  }

  /// Check all critical permissions
  static Future<Map<Permission, PermissionStatus>> checkAllPermissions() async {
    try {
      final permissions = [
        Permission.notification,
        if (Platform.isAndroid) Permission.camera,
        if (Platform.isAndroid) Permission.photos,
      ];
      
      final statuses = await permissions.request();
      
      statuses.forEach((permission, status) {
        AppLogger.info('${permission.toString()}: $status');
      });
      
      return statuses;
    } catch (e) {
      AppLogger.error('Failed to check permissions', error: e);
      return {};
    }
  }

  /// Request multiple permissions at once
  static Future<bool> requestMultiplePermissions(List<Permission> permissions) async {
    try {
      final statuses = await permissions.request();
      
      for (final status in statuses.values) {
        if (!status.isGranted) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      AppLogger.error('Failed to request permissions', error: e);
      return false;
    }
  }
}
