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
    
    // Request notification permission
    await PermissionService.requestNotificationPermission(
      onGranted: () {
        AppLogger.info('✅ Permission granted by user');
        // Notification silently enabled - no toast shown
      },
      onDenied: () {
        AppLogger.warning('❌ Permission denied by user');
        if (mounted) {
          _showPermissionDeniedDialog();
        }
      },
    );
    
    widget.onPermissionsChecked?.call();
  }

  void _showPermissionDeniedDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Notifications'),
          content: const Text(
            'Notifications are disabled. You won\'t receive updates about your eco activities, achievements, and challenges. You can enable them anytime from app settings.',
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

  @override
  Widget build(BuildContext context) => widget.child;
}
