// ignore_for_file: dangling_library_doc_comments

/// In-memory cache manager for HTTP responses
/// 
/// Provides temporary caching of API responses to improve performance
/// and enable offline functionality.
/// 
/// Example:
/// ```dart
/// await cacheManager.set('user_profile', userData, duration: Duration(minutes: 5));
/// final cachedData = await cacheManager.get('user_profile');
/// ```
library;

import 'dart:async';
import '../utils/app_logger.dart';

/// Cache entry with expiration time
class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  _CacheEntry(this.data, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Manages caching of API responses
class CacheManager {
  final Map<String, _CacheEntry> _cache = {};
  final Duration defaultDuration = const Duration(minutes: 5);

  /// Store data in cache with optional duration
  /// 
  /// [key] - Unique identifier for cached data (typically the URL)
  /// [data] - Data to cache
  /// [duration] - How long to keep the data (default: 5 minutes)
  Future<void> set(
    String key,
    dynamic data, {
    Duration? duration,
  }) async {
    final expiresAt = DateTime.now().add(duration ?? defaultDuration);
    _cache[key] = _CacheEntry(data, expiresAt);
    AppLogger.debug('Cached: $key (expires: $expiresAt)');
  }

  /// Retrieve data from cache
  /// 
  /// Returns null if key doesn't exist or data has expired
  Future<dynamic> get(String key) async {
    final entry = _cache[key];
    
    if (entry == null) {
      AppLogger.debug('Cache miss: $key');
      return null;
    }

    if (entry.isExpired) {
      _cache.remove(key);
      AppLogger.debug('Cache expired: $key');
      return null;
    }

    AppLogger.debug('Cache hit: $key');
    return entry.data;
  }

  /// Check if a key exists and is not expired
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// Remove a specific cache entry
  Future<void> remove(String key) async {
    _cache.remove(key);
    AppLogger.debug('Cache removed: $key');
  }

  /// Clear all cached data
  Future<void> clear() async {
    _cache.clear();
    AppLogger.info('Cache cleared');
  }

  /// Remove all expired entries
  Future<void> cleanExpired() async {
    final expiredKeys = <String>[];
    
    _cache.forEach((key, entry) {
      if (entry.isExpired) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      AppLogger.debug('Removed ${expiredKeys.length} expired cache entries');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    var validEntries = 0;
    var expiredEntries = 0;

    _cache.forEach((key, entry) {
      if (entry.isExpired) {
        expiredEntries++;
      } else {
        validEntries++;
      }
    });

    return {
      'total': _cache.length,
      'valid': validEntries,
      'expired': expiredEntries,
    };
  }
}
