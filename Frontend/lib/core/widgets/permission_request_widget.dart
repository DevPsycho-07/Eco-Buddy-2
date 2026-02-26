/// Permission Request Widget
/// Shows permission request dialogs to users at app startup
library;

import 'package:flutter/material.dart';
import '../utils/app_logger.dart';
import '../../services/permission_service.dart';

/// Widget that handles permission requests at app startup
class PermissionRequestWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPermissionsChecked;

  const PermissionRequestWidget({
    super.key,
    required this.child,
    this.onPermissionsChecked,
  });

  @override
  State<PermissionRequestWidget> createState() => _PermissionRequestWidgetState();
}

class _PermissionRequestWidgetState extends State<PermissionRequestWidget> {
  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    AppLogger.info('🔐 Checking app permissions...');
    
    // Small delay to ensure UI is ready
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    // Request critical permissions for core app functionality
    // Request notification permission
    await PermissionService.requestNotificationPermission(
      onGranted: () => AppLogger.info('✅ Notification permission granted'),
      onDenied: () => AppLogger.warning('❌ Notification permission denied'),
    );
    
    if (!mounted) return;
    
    // Request location permission (critical for eco-activity tracking)
    bool locationGranted = false;
    await PermissionService.requestLocationPermission(
      onGranted: () {
        AppLogger.info('✅ Location permission granted');
        locationGranted = true;
      },
      onDenied: () {
        AppLogger.warning('❌ Location permission denied');
        if (mounted) {
          _showLocationPermissionDeniedDialog();
        }
      },
    );
    
    if (!mounted) return;
    
    // Request background location permission (Android 10+) if foreground location was granted
    if (locationGranted) {
      await Future.delayed(const Duration(milliseconds: 300)); // Small delay between requests
      
      await PermissionService.requestBackgroundLocationPermission(
        onGranted: () => AppLogger.info('✅ Background location permission granted'),
        onDenied: () {
          AppLogger.warning('❌ Background location permission denied');
          if (mounted) {
            _showBackgroundLocationDialog();
          }
        },
      );
    }
    
    if (!mounted) return;
    
    // Request activity recognition permission (for step counting on Android)
    await PermissionService.requestActivityRecognitionPermission(
      onGranted: () => AppLogger.info('✅ Activity recognition permission granted'),
      onDenied: () => AppLogger.warning('❌ Activity recognition permission denied'),
    );
    
    // Note: Camera and photos permissions will be requested when user tries to upload profile picture
    // This provides better UX by requesting permissions just-in-time
    
    widget.onPermissionsChecked?.call();
  }

  void _showLocationPermissionDeniedDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('📍 Location Access Required'),
          content: const Text(
            'Eco Buddy needs location access to track your eco-friendly activities like walking, cycling, and public transport usage. Without this permission, we won\'t be able to accurately calculate your carbon footprint.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await PermissionService.openNotificationSettings();
              },
              child: const Text('Enable in Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showBackgroundLocationDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🌍 Background Location'),
          content: const Text(
            'For accurate activity tracking even when the app is closed, please select "Allow all the time" for location access. This helps us track your eco-friendly activities continuously.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe Later'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await PermissionService.openNotificationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
