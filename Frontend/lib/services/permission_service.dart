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

  /// Request location permission
  static Future<bool> requestLocationPermission({
    VoidCallback? onGranted,
    VoidCallback? onDenied,
  }) async {
    try {
      AppLogger.info('📍 Requesting location permission...');
      
      final status = await Permission.location.request();
      
      if (status.isDenied) {
        AppLogger.warning('❌ Location permission denied by user');
        onDenied?.call();
        return false;
      } else if (status.isGranted) {
        AppLogger.info('✅ Location permission granted');
        onGranted?.call();
        return true;
      } else if (status.isPermanentlyDenied) {
        AppLogger.warning('⚠️ Location permission permanently denied');
        _showPermissionSettingsDialog(
          title: 'Location Permission Denied',
          message: 'Please enable location access to track your eco activities.',
        );
        onDenied?.call();
        return false;
      }
      
      onDenied?.call();
      return false;
    } catch (e) {
      AppLogger.error('Failed to request location permission', error: e);
      onDenied?.call();
      return false;
    }
  }

  /// Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      AppLogger.error('Failed to check location permission', error: e);
      return false;
    }
  }

  /// Request background location permission (Android 10+)
  /// Must be called AFTER regular location permission is granted
  static Future<bool> requestBackgroundLocationPermission({
    VoidCallback? onGranted,
    VoidCallback? onDenied,
  }) async {
    try {
      AppLogger.info('🌍 Requesting background location permission...');
      
      if (!Platform.isAndroid) {
        onGranted?.call();
        return true;
      }
      
      // First check if foreground location is granted
      final locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        AppLogger.warning('⚠️ Foreground location not granted, cannot request background location');
        onDenied?.call();
        return false;
      }
      
      final status = await Permission.locationAlways.request();
      
      if (status.isDenied) {
        AppLogger.warning('❌ Background location permission denied');
        onDenied?.call();
        return false;
      } else if (status.isGranted) {
        AppLogger.info('✅ Background location permission granted');
        onGranted?.call();
        return true;
      } else if (status.isPermanentlyDenied) {
        AppLogger.warning('⚠️ Background location permission permanently denied');
        _showPermissionSettingsDialog(
          title: 'Background Location Permission Denied',
          message: 'Enable "Allow all the time" location access to track activities in the background.',
        );
        onDenied?.call();
        return false;
      }
      
      onDenied?.call();
      return false;
    } catch (e) {
      AppLogger.error('Failed to request background location permission', error: e);
      onDenied?.call();
      return false;
    }
  }

  /// Check if background location permission is granted
  static Future<bool> isBackgroundLocationPermissionGranted() async {
    try {
      if (!Platform.isAndroid) return true;
      final status = await Permission.locationAlways.status;
      return status.isGranted;
    } catch (e) {
      AppLogger.error('Failed to check background location permission', error: e);
      return false;
    }
  }

  /// Request activity recognition permission (Android 10+)
  static Future<bool> requestActivityRecognitionPermission({
    VoidCallback? onGranted,
    VoidCallback? onDenied,
  }) async {
    try {
      AppLogger.info('🏃 Requesting activity recognition permission...');
      
      if (!Platform.isAndroid) {
        onGranted?.call();
        return true;
      }
      
      final status = await Permission.activityRecognition.request();
      
      if (status.isDenied) {
        AppLogger.warning('❌ Activity recognition permission denied');
        onDenied?.call();
        return false;
      } else if (status.isGranted) {
        AppLogger.info('✅ Activity recognition permission granted');
        onGranted?.call();
        return true;
      } else if (status.isPermanentlyDenied) {
        AppLogger.warning('⚠️ Activity recognition permission permanently denied');
        _showPermissionSettingsDialog(
          title: 'Activity Recognition Permission Denied',
          message: 'Enable activity recognition to track your steps and movement.',
        );
        onDenied?.call();
        return false;
      }
      
      onDenied?.call();
      return false;
    } catch (e) {
      AppLogger.error('Failed to request activity recognition permission', error: e);
      onDenied?.call();
      return false;
    }
  }

  /// Check if activity recognition permission is granted
  static Future<bool> isActivityRecognitionPermissionGranted() async {
    try {
      if (!Platform.isAndroid) return true;
      final status = await Permission.activityRecognition.status;
      return status.isGranted;
    } catch (e) {
      AppLogger.error('Failed to check activity recognition permission', error: e);
      return false;
    }
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission({
    VoidCallback? onGranted,
    VoidCallback? onDenied,
  }) async {
    try {
      AppLogger.info('📷 Requesting camera permission...');
      
      final status = await Permission.camera.request();
      
      if (status.isDenied) {
        AppLogger.warning('❌ Camera permission denied');
        onDenied?.call();
        return false;
      } else if (status.isGranted) {
        AppLogger.info('✅ Camera permission granted');
        onGranted?.call();
        return true;
      } else if (status.isPermanentlyDenied) {
        AppLogger.warning('⚠️ Camera permission permanently denied');
        _showPermissionSettingsDialog(
          title: 'Camera Permission Denied',
          message: 'Enable camera access to take profile photos.',
        );
        onDenied?.call();
        return false;
      }
      
      onDenied?.call();
      return false;
    } catch (e) {
      AppLogger.error('Failed to request camera permission', error: e);
      onDenied?.call();
      return false;
    }
  }

  /// Request storage permission for photos
  static Future<bool> requestPhotosPermission({
    VoidCallback? onGranted,
    VoidCallback? onDenied,
  }) async {
    try {
      AppLogger.info('🖼️ Requesting photos permission...');
      
      if (!Platform.isAndroid) {
        onGranted?.call();
        return true;
      }
      
      final status = await Permission.photos.request();
      
      if (status.isDenied) {
        AppLogger.warning('❌ Photos permission denied');
        onDenied?.call();
        return false;
      } else if (status.isGranted) {
        AppLogger.info('✅ Photos permission granted');
        onGranted?.call();
        return true;
      } else if (status.isPermanentlyDenied) {
        AppLogger.warning('⚠️ Photos permission permanently denied');
        _showPermissionSettingsDialog(
          title: 'Photos Permission Denied',
          message: 'Enable photos access to upload profile pictures.',
        );
        onDenied?.call();
        return false;
      }
      
      onDenied?.call();
      return false;
    } catch (e) {
      AppLogger.error('Failed to request photos permission', error: e);
      onDenied?.call();
      return false;
    }
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      AppLogger.error('Failed to check camera permission', error: e);
      return false;
    }
  }

  /// Check if photos permission is granted
  static Future<bool> isPhotosPermissionGranted() async {
    try {
      if (!Platform.isAndroid) return true;
      final status = await Permission.photos.status;
      return status.isGranted;
    } catch (e) {
      AppLogger.error('Failed to check photos permission', error: e);
      return false;
    }
  }

  /// Show dialog prompting user to enable permissions
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
        Permission.location,
        if (Platform.isAndroid) Permission.activityRecognition,
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

  /// Request all critical app permissions
  static Future<void> requestAllPermissions({
    VoidCallback? onAllGranted,
  }) async {
    try {
      AppLogger.info('Requesting all critical permissions...');
      
      // Request permissions sequentially to ensure user sees each request
      await requestNotificationPermission();
      
      final locationGranted = await requestLocationPermission();
      
      // Request background location only if foreground location was granted
      if (locationGranted && Platform.isAndroid) {
        await Future.delayed(const Duration(milliseconds: 300));
        await requestBackgroundLocationPermission();
      }
      
      if (Platform.isAndroid) {
        await requestActivityRecognitionPermission();
      }
      
      await requestCameraPermission();
      
      if (Platform.isAndroid) {
        await requestPhotosPermission();
      }
      
      AppLogger.info('✅ All permission requests completed');
      onAllGranted?.call();
    } catch (e) {
      AppLogger.error('Failed to request all permissions', error: e);
    }
  }
}
