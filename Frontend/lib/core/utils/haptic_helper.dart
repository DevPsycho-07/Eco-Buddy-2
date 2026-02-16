// ignore_for_file: dangling_library_doc_comments

/// Haptic feedback utilities
/// 
/// Provides consistent haptic feedback across the app for better UX.
/// 
/// Example:
/// ```dart
/// // On button press
/// HapticHelper.lightImpact();
/// 
/// // On success
/// HapticHelper.success();
/// 
/// // On error
/// HapticHelper.error();
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_logger.dart';

/// Haptic feedback helper
class HapticHelper {
  /// Light impact feedback (for subtle interactions)
  /// 
  /// Use for: button taps, tab switches, checkbox toggles
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      AppLogger.error('Haptic feedback failed', error: e);
    }
  }

  /// Medium impact feedback (for normal interactions)
  /// 
  /// Use for: swipe actions, card dismissal, navigation
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      AppLogger.error('Haptic feedback failed', error: e);
    }
  }

  /// Heavy impact feedback (for important interactions)
  /// 
  /// Use for: important confirmations, deletions, major actions
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      AppLogger.error('Haptic feedback failed', error: e);
    }
  }

  /// Selection click feedback
  /// 
  /// Use for: picker wheels, dropdown selections
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      AppLogger.error('Haptic feedback failed', error: e);
    }
  }

  /// Success feedback pattern
  /// 
  /// Use for: successful operations, achievements unlocked
  static Future<void> success() async {
    await lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await lightImpact();
  }

  /// Error feedback pattern
  /// 
  /// Use for: errors, validation failures, denied actions
  static Future<void> error() async {
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await mediumImpact();
  }

  /// Warning feedback pattern
  /// 
  /// Use for: warnings, cautions, alerts
  static Future<void> warning() async {
    await lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await mediumImpact();
  }

  /// Long press feedback
  /// 
  /// Use for: long press detected on items
  static Future<void> longPress() async {
    await heavyImpact();
  }

  /// Vibrate pattern (Android only, may not work on iOS)
  static Future<void> vibrate() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      AppLogger.error('Vibration failed', error: e);
    }
  }
}

/// Widget wrapper that adds haptic feedback to any widget
class HapticFeedbackWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final HapticFeedbackType feedbackType;

  const HapticFeedbackWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.feedbackType = HapticFeedbackType.light,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null
          ? () {
              _triggerHaptic();
              onTap!();
            }
          : null,
      child: child,
    );
  }

  void _triggerHaptic() {
    switch (feedbackType) {
      case HapticFeedbackType.light:
        HapticHelper.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticHelper.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticHelper.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticHelper.selectionClick();
        break;
      case HapticFeedbackType.success:
        HapticHelper.success();
        break;
      case HapticFeedbackType.error:
        HapticHelper.error();
        break;
    }
  }
}

/// Types of haptic feedback
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  success,
  error,
}
