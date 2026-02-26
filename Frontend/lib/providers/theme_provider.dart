import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/offline_storage.dart';

/// Provider for managing theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Notifier for theme mode state
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  final _storage = OfflineStorage();

  /// Load theme mode from storage
  Future<void> _loadThemeMode() async {
    try {
      final savedMode = _storage.getThemeMode();
      if (savedMode != null) {
        state = savedMode;
      }
    } catch (e) {
      // If loading fails, keep default (system)
    }
  }

  /// Listen to system theme changes
  /// This is called from the main app widget when MediaQuery is available
  void listenToSystemThemeChanges(BuildContext context) {
    // Get initial brightness from system
    final brightness = MediaQuery.of(context).platformBrightness;
    
    // If the current state is 'system', reflect the system's brightness
    if (state == ThemeMode.system) {
      // Update to match system brightness but keep 'system' mode
      final isDark = brightness == Brightness.dark;
      _updateBasedOnSystemBrightness(isDark);
    }
  }

  /// Update theme based on system brightness
  void _updateBasedOnSystemBrightness(bool isDark) {
    // This helps reflect system changes in UI elements that depend on themeMode
    // even when the actual themeMode is 'system'
  }

  /// Toggle between light and dark mode
  /// This will override system preference
  void toggleTheme(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode();
  }

  /// Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    state = mode;
    _saveThemeMode();
  }

  /// Save theme mode to storage
  Future<void> _saveThemeMode() async {
    try {
      await _storage.saveThemeMode(state);
    } catch (e) {
      // Silently fail if storage is not available
    }
  }
}
