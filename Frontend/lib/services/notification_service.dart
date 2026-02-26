import 'dart:convert';
import '../core/config/api_config.dart';
import '../core/utils/app_logger.dart';
import 'http_client.dart';

/// Notification model
class UserNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  UserNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    return '${(difference.inDays / 30).floor()}mo ago';
  }
}

/// Service for notification-related API calls
class NotificationService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Get notification preferences (per-category toggles)
  static Future<Map<String, bool>> getNotificationPreferences() async {
    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/users/notification-preferences/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return {
          'daily_reminders': data['daily_reminders'] as bool? ?? true,
          'achievement_alerts': data['achievement_alerts'] as bool? ?? true,
          'weekly_reports': data['weekly_reports'] as bool? ?? true,
          'tips_and_suggestions': data['tips_and_suggestions'] as bool? ?? true,
          'community_updates': data['community_updates'] as bool? ?? false,
        };
      } else {
        throw Exception('Failed to load preferences: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Failed to load notification preferences', error: e);
      // Return defaults
      return {
        'daily_reminders': true,
        'achievement_alerts': true,
        'weekly_reports': true,
        'tips_and_suggestions': true,
        'community_updates': false,
      };
    }
  }

  /// Update notification preferences (per-category toggles)
  static Future<bool> updateNotificationPreferences(Map<String, bool> prefs) async {
    try {
      final response = await ApiClient.patch(
        Uri.parse('$baseUrl/users/notification-preferences/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(prefs),
      );

      if (response.statusCode == 200) {
        AppLogger.info('Notification preferences updated');
        return true;
      } else {
        throw Exception('Failed to update preferences: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Failed to update notification preferences', error: e);
      return false;
    }
  }

  /// Get all notifications for current user
  static Future<List<UserNotification>> getNotifications() async {
    try {
      final response = await ApiClient.get(Uri.parse('$baseUrl/users/notifications/'));
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Handle paginated response from backend
        final List<dynamic> data = responseData is Map 
            ? (responseData['notifications'] as List<dynamic>)
            : (responseData as List<dynamic>);
            
        return data.map((json) => UserNotification.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Failed to load notifications', error: e);
      rethrow;
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadCount() async {
    try {
      final response = await ApiClient.get(Uri.parse('$baseUrl/users/notifications/unread-count/'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['count'] as int;
      } else {
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } catch (e) {
      // Silently handle timeout and network errors - return 0 as fallback
      // This prevents error logs from timeout exceptions during app startup
      return 0; // Return 0 on error (no unread notifications shown)
    }
  }

  /// Mark notification as read
  static Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await ApiClient.post(
        Uri.parse('$baseUrl/users/notifications/$notificationId/mark-as-read/'),
      );
      
      if (response.statusCode == 200) {
        AppLogger.info('Notification $notificationId marked as read');
        return true;
      } else {
        throw Exception('Failed to mark as read: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Failed to mark notification as read', error: e);
      return false;
    }
  }

  /// Mark all notifications as read
  static Future<bool> markAllAsRead() async {
    try {
      final response = await ApiClient.post(
        Uri.parse('$baseUrl/users/notifications/mark-all-as-read/'),
      );
      
      if (response.statusCode == 200) {
        AppLogger.info('All notifications marked as read');
        return true;
      } else {
        throw Exception('Failed to mark all as read: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Failed to mark all notifications as read', error: e);
      return false;
    }
  }

  /// Delete all read notifications
  static Future<bool> deleteAllRead() async {
    try {
      final response = await ApiClient.delete(
        Uri.parse('$baseUrl/users/notifications/delete-read/'),
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info('All read notifications deleted');
        return true;
      } else {
        throw Exception('Failed to delete read notifications: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Failed to delete read notifications', error: e);
      return false;
    }
  }

  /// Delete a single notification
  static Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await ApiClient.delete(
        Uri.parse('$baseUrl/users/notifications/$notificationId/'),
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info('Notification $notificationId deleted');
        return true;
      } else {
        throw Exception('Failed to delete notification: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Failed to delete notification', error: e);
      return false;
    }
  }
}
