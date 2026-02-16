/// Permission Extensions
/// Convenient methods for requesting permissions from anywhere in the app
library;

import 'package:flutter/material.dart';
import '../../services/permission_service.dart';

extension PermissionExtension on BuildContext {
  /// Request notification permission with user feedback
  Future<bool> requestNotificationPermission() async {
    return await PermissionService.requestNotificationPermission(
      onGranted: () {
        // Notification silently enabled - no toast shown
      },
      onDenied: () {
        _showNotificationDisabledDialog();
      },
    );
  }

  /// Show dialog when notification permission is denied
  void _showNotificationDisabledDialog() {
    showDialog<void>(
      context: this,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Notifications?'),
          content: const Text(
            'You won\'t receive updates about eco activities, achievements, and challenges without notifications.',
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
              child: const Text('Enable Now'),
            ),
          ],
        );
      },
    );
  }

  /// Check if notifications are already enabled
  Future<bool> isNotificationEnabled() {
    return PermissionService.isNotificationPermissionGranted();
  }
}
