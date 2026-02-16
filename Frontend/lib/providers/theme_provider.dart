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

  /// Toggle between light and dark mode
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
