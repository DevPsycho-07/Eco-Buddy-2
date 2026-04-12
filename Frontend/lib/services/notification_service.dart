import '../core/config/api_config.dart';
import '../core/di/service_locator.dart';
import '../core/network/dio_client.dart';
import '../core/utils/app_logger.dart';

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
  static final _dio = sl<DioClient>().dio;
  static const String baseUrl = ApiConfig.baseUrl;

  /// Get notification preferences (per-category toggles)
  static Future<Map<String, bool>> getNotificationPreferences() async {
    try {
      final response = await _dio.get('$baseUrl/users/notification-preferences');

      final data = response.data as Map<String, dynamic>;
      return {
        'daily_reminders': data['daily_reminders'] as bool? ?? true,
        'achievement_alerts': data['achievement_alerts'] as bool? ?? true,
        'weekly_reports': data['weekly_reports'] as bool? ?? true,
        'tips_and_suggestions': data['tips_and_suggestions'] as bool? ?? true,
        'community_updates': data['community_updates'] as bool? ?? false,
      };
    } catch (e) {
      AppLogger.error('Failed to load notification preferences', error: e);
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
      await _dio.patch(
        '$baseUrl/users/notification-preferences',
        data: prefs,
      );
      AppLogger.info('Notification preferences updated');
      return true;
    } catch (e) {
      AppLogger.error('Failed to update notification preferences', error: e);
      return false;
    }
  }

  /// Get all notifications for current user
  static Future<List<UserNotification>> getNotifications() async {
    try {
      final response = await _dio.get('$baseUrl/users/notifications');

      final responseData = response.data;
      final List<dynamic> data = responseData is Map
          ? (responseData['notifications'] as List<dynamic>)
          : (responseData as List<dynamic>);

      return data.map((json) => UserNotification.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.error('Failed to load notifications', error: e);
      rethrow;
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('$baseUrl/users/notifications/unread-count');

      final data = response.data as Map<String, dynamic>;
      return data['count'] as int;
    } catch (e) {
      return 0;
    }
  }

  /// Mark notification as read
  static Future<bool> markAsRead(int notificationId) async {
    try {
      await _dio.post('$baseUrl/users/notifications/$notificationId/mark-as-read');
      AppLogger.info('Notification $notificationId marked as read');
      return true;
    } catch (e) {
      AppLogger.error('Failed to mark notification as read', error: e);
      return false;
    }
  }

  /// Mark all notifications as read
  static Future<bool> markAllAsRead() async {
    try {
      await _dio.post('$baseUrl/users/notifications/mark-all-as-read');
      AppLogger.info('All notifications marked as read');
      return true;
    } catch (e) {
      AppLogger.error('Failed to mark all notifications as read', error: e);
      return false;
    }
  }

  /// Delete all read notifications
  static Future<bool> deleteAllRead() async {
    try {
      await _dio.delete('$baseUrl/users/notifications/delete-read');
      AppLogger.info('All read notifications deleted');
      return true;
    } catch (e) {
      AppLogger.error('Failed to delete read notifications', error: e);
      return false;
    }
  }

  /// Delete a single notification
  static Future<bool> deleteNotification(int notificationId) async {
    try {
      await _dio.delete('$baseUrl/users/notifications/$notificationId');
      AppLogger.info('Notification $notificationId deleted');
      return true;
    } catch (e) {
      AppLogger.error('Failed to delete notification', error: e);
      return false;
    }
  }
}
