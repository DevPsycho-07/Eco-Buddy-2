// ignore_for_file: dangling_library_doc_comments

/// Offline storage service using Hive
/// 
/// Provides persistent local storage for offline functionality.
/// Data is stored locally and synchronized when connection is restored.
/// 
/// Example:
/// ```dart
/// // Store data
/// await offlineStorage.saveUserProfile(userProfile);
/// 
/// // Retrieve data
/// final profile = await offlineStorage.getUserProfile();
/// 
/// // Queue offline actions
/// await offlineStorage.queueAction(OfflineAction(
///   type: 'log_activity',
///   data: activityData,
/// ));
/// ```
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_logger.dart';

/// Offline storage manager
class OfflineStorage {
  static const String _userBoxName = 'user_data';
  static const String _cacheBoxName = 'api_cache';
  static const String _actionsBoxName = 'offline_actions';
  static const String _settingsBoxName = 'settings';
  static const String _appCacheBoxName = 'app_cache';

  late Box _userBox;
  late Box _cacheBox;
  late Box _actionsBox;
  late Box _settingsBox;
  late Box _appCacheBox;

  /// Initialize Hive and open boxes
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      
      _userBox = await Hive.openBox(_userBoxName);
      _cacheBox = await Hive.openBox(_cacheBoxName);
      _actionsBox = await Hive.openBox(_actionsBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
      _appCacheBox = await Hive.openBox(_appCacheBoxName);
      
      AppLogger.info('Offline storage initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize offline storage', error: e);
      rethrow;
    }
  }

  // ==================== User Data ====================

  /// Save user profile data
  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _userBox.put('profile', jsonEncode(profile));
    AppLogger.debug('User profile saved offline');
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    final data = _userBox.get('profile');
    if (data != null) {
      return jsonDecode(data as String) as Map<String, dynamic>;
    }
    return null;
  }

  /// Save recent activities
  Future<void> saveRecentActivities(List<Map<String, dynamic>> activities) async {
    await _userBox.put('recent_activities', jsonEncode(activities));
    AppLogger.debug('Recent activities saved offline');
  }

  /// Get recent activities
  Future<List<Map<String, dynamic>>?> getRecentActivities() async {
    final data = _userBox.get('recent_activities');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data as String);
      return decoded.cast<Map<String, dynamic>>();
    }
    return null;
  }

  /// Clear all user data
  Future<void> clearUserData() async {
    await _userBox.clear();
    AppLogger.info('User data cleared from offline storage');
  }

  // ==================== Settings ====================

  /// Get settings box for direct access
  Box getSettingsBox() => _settingsBox;

  /// Get app cache box for direct access
  Box getAppCacheBox() => _appCacheBox;

  // ==================== Theme Settings ====================

  /// Save theme mode preference
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _userBox.put('theme_mode', mode.index);
    AppLogger.debug('Theme mode saved: $mode');
  }

  /// Get saved theme mode
  ThemeMode? getThemeMode() {
    final index = _userBox.get('theme_mode');
    if (index != null) {
      return ThemeMode.values[index as int];
    }
    return null;
  }

  // ==================== API Cache ====================

  /// Save API response to cache
  Future<void> cacheResponse(String key, dynamic data, {Duration? ttl}) async {
    final expiresAt = ttl != null 
        ? DateTime.now().add(ttl).millisecondsSinceEpoch 
        : null;
    
    await _cacheBox.put(key, {
      'data': jsonEncode(data),
      'expiresAt': expiresAt,
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
    });
    
    AppLogger.debug('Response cached: $key');
  }

  /// Get cached API response
  Future<dynamic> getCachedResponse(String key) async {
    final cached = _cacheBox.get(key);
    if (cached == null) return null;

    final expiresAt = cached['expiresAt'] as int?;
    if (expiresAt != null && DateTime.now().millisecondsSinceEpoch > expiresAt) {
      await _cacheBox.delete(key);
      AppLogger.debug('Cached response expired: $key');
      return null;
    }

    AppLogger.debug('Retrieved cached response: $key');
    return jsonDecode(cached['data'] as String);
  }

  /// Clear all cached responses
  Future<void> clearCache() async {
    await _cacheBox.clear();
    AppLogger.info('Cache cleared from offline storage');
  }

  // ==================== Offline Actions Queue ====================

  /// Queue an action to be performed when online
  Future<void> queueAction(OfflineAction action) async {
    final actions = await getPendingActions();
    actions.add(action);
    await _actionsBox.put('pending', actions.map((a) => a.toJson()).toList());
    AppLogger.info('Action queued for sync: ${action.type}');
  }

  /// Get all pending offline actions
  Future<List<OfflineAction>> getPendingActions() async {
    final data = _actionsBox.get('pending', defaultValue: <dynamic>[]);
    return (data as List<dynamic>)
        .map((item) => OfflineAction.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Remove a completed action from queue
  Future<void> removeAction(String actionId) async {
    final actions = await getPendingActions();
    actions.removeWhere((a) => a.id == actionId);
    await _actionsBox.put('pending', actions.map((a) => a.toJson()).toList());
    AppLogger.debug('Action removed from queue: $actionId');
  }

  /// Clear all pending actions
  Future<void> clearPendingActions() async {
    await _actionsBox.delete('pending');
    AppLogger.info('All pending actions cleared');
  }

  // ==================== Utility ====================

  /// Get storage statistics
  Map<String, dynamic> getStats() {
    return {
      'userDataSize': _userBox.length,
      'cacheSize': _cacheBox.length,
      'pendingActions': _actionsBox.get('pending', defaultValue: []).length,
    };
  }

  /// Close all boxes
  Future<void> close() async {
    await _userBox.close();
    await _cacheBox.close();
    await _actionsBox.close();
    AppLogger.info('Offline storage closed');
  }
}

/// Represents an action to be performed when online
class OfflineAction {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  OfflineAction({
    String? id,
    required this.type,
    required this.data,
    DateTime? timestamp,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };

  factory OfflineAction.fromJson(Map<String, dynamic> json) => OfflineAction(
        id: json['id'] as String,
        type: json['type'] as String,
        data: json['data'] as Map<String, dynamic>,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
