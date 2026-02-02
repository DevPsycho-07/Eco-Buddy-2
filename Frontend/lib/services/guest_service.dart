import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';

/// Service to manage guest mode with unique device identification
class GuestService {
  static const _storage = FlutterSecureStorage();
  static const _guestIdKey = 'guest_device_id';
  static const _guestSessionKey = 'guest_session_active';
  static const _guestCreatedAtKey = 'guest_created_at';
  
  static String? _cachedGuestId;
  
  /// Generate a unique guest ID for this device
  /// This ID persists across app restarts and is unique per device installation
  static Future<String> getOrCreateGuestId() async {
    // Return cached ID if available
    if (_cachedGuestId != null) {
      return _cachedGuestId!;
    }
    
    try {
      // Check if we already have a guest ID stored
      String? existingId = await _storage.read(key: _guestIdKey);
      
      if (existingId != null && existingId.isNotEmpty) {
        Logger.debug('🎭 [Guest] Found existing guest ID: ${_maskId(existingId)}');
        _cachedGuestId = existingId;
        return existingId;
      }
      
      // Generate a new unique guest ID
      final newGuestId = _generateUniqueId();
      
      // Store it persistently
      await _storage.write(key: _guestIdKey, value: newGuestId);
      await _storage.write(
        key: _guestCreatedAtKey, 
        value: DateTime.now().toIso8601String()
      );
      
      Logger.debug('🎭 [Guest] Created new guest ID: ${_maskId(newGuestId)}');
      _cachedGuestId = newGuestId;
      return newGuestId;
      
    } catch (e) {
      Logger.error('❌ [Guest] Error getting/creating guest ID: $e');
      // Fallback to a temporary ID if storage fails
      final fallbackId = _generateUniqueId();
      _cachedGuestId = fallbackId;
      return fallbackId;
    }
  }
  
  /// Generate a unique ID combining timestamp, random values, and platform info
  static String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _generateRandomString(16);
    final platform = Platform.operatingSystem.substring(0, 3).toUpperCase();
    
    // Format: GUEST_PLT_TIMESTAMP_RANDOM
    // Example: GUEST_AND_1706464800000_a1b2c3d4e5f6g7h8
    return 'GUEST_${platform}_${timestamp}_$random';
  }
  
  /// Generate a random alphanumeric string
  static String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    final buffer = StringBuffer();
    
    for (int i = 0; i < length; i++) {
      final index = (random + i * 7) % chars.length;
      buffer.write(chars[index]);
    }
    
    return buffer.toString();
  }
  
  /// Mask the guest ID for logging (show only first and last 4 characters)
  static String _maskId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 8)}...${id.substring(id.length - 4)}';
  }
  
  /// Start a guest session
  static Future<void> startGuestSession() async {
    final guestId = await getOrCreateGuestId();
    await _storage.write(key: _guestSessionKey, value: 'true');
    Logger.debug('🎭 [Guest] Started guest session with ID: ${_maskId(guestId)}');
  }
  
  /// Check if currently in guest mode
  static Future<bool> isGuestSession() async {
    final value = await _storage.read(key: _guestSessionKey);
    return value == 'true';
  }
  
  /// End the guest session (when user signs up or logs in)
  static Future<void> endGuestSession() async {
    await _storage.delete(key: _guestSessionKey);
    Logger.debug('🎭 [Guest] Ended guest session');
  }
  
  /// Get the current guest ID (returns null if no guest ID exists)
  static Future<String?> getCurrentGuestId() async {
    if (_cachedGuestId != null) {
      return _cachedGuestId;
    }
    return await _storage.read(key: _guestIdKey);
  }
  
  /// Get when the guest account was created
  static Future<DateTime?> getGuestCreatedAt() async {
    final dateStr = await _storage.read(key: _guestCreatedAtKey);
    if (dateStr != null) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }
  
  /// Get guest profile data (for display purposes)
  static Future<Map<String, dynamic>> getGuestProfile() async {
    final guestId = await getOrCreateGuestId();
    final createdAt = await getGuestCreatedAt();
    
    // Extract a short display ID from the full guest ID
    final displayId = guestId.length > 10 
        ? guestId.substring(guestId.length - 8).toUpperCase()
        : guestId;
    
    return {
      'id': guestId,
      'display_id': displayId,
      'username': 'Guest_$displayId',
      'email': null,
      'is_guest': true,
      'eco_score': 0,
      'total_co2_saved': 0.0,
      'current_streak': 0,
      'level': 1,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  
  /// Clear all guest data (use when converting to full account or resetting)
  static Future<void> clearGuestData() async {
    await _storage.delete(key: _guestIdKey);
    await _storage.delete(key: _guestSessionKey);
    await _storage.delete(key: _guestCreatedAtKey);
    _cachedGuestId = null;
    Logger.debug('🎭 [Guest] Cleared all guest data');
  }
  
  /// Check if the device has been used as guest before
  static Future<bool> hasGuestHistory() async {
    final guestId = await _storage.read(key: _guestIdKey);
    return guestId != null && guestId.isNotEmpty;
  }
}
