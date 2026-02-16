import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../core/utils/app_logger.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;
  List<UserNotification> _notifications = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await NotificationService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to load notifications', error: e);
      if (mounted) {
        setState(() {
          _error = 'Failed to load notifications';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    final success = await NotificationService.markAsRead(notificationId);
    if (success) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = UserNotification(
            id: _notifications[index].id,
            title: _notifications[index].title,
            message: _notifications[index].message,
            type: _notifications[index].type,
            isRead: true,
            createdAt: _notifications[index].createdAt,
          );
        }
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await NotificationService.markAllAsRead();
    if (success) {
      _loadNotifications(); // Reload to get updated data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteAllRead() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Read Notifications'),
        content: const Text('Are you sure you want to delete all read notifications? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await NotificationService.deleteAllRead();
      if (success) {
        _loadNotifications(); // Reload to get updated data
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Read notifications deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'achievement':
        return Icons.emoji_events;
      case 'challenge':
        return Icons.flag;
      case 'reminder':
        return Icons.alarm;
      case 'social':
        return Icons.people;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'achievement':
        return Colors.amber;
      case 'challenge':
        return Colors.blue;
      case 'reminder':
        return Colors.orange;
      case 'social':
        return Colors.purple;
      case 'system':
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    final readCount = _notifications.where((n) => n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  _markAllAsRead();
                } else if (value == 'delete_read') {
                  _deleteAllRead();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, size: 20),
                      SizedBox(width: 12),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                if (readCount > 0)
                  const PopupMenuItem(
                    value: 'delete_read',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete read', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: Colors.red[700])),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadNotifications,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 80,
                            color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications yet',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We\'ll notify you about achievements,\nchallenges, and updates',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                                ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: Column(
                        children: [
                          // Stats bar
                          if (unreadCount > 0 || readCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                                border: Border(
                                  bottom: BorderSide(
                                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (unreadCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        '$unreadCount unread',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '$readCount read',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Notifications list
                          Expanded(
                            child: ListView.builder(
                              itemCount: _notifications.length,
                              itemBuilder: (context, index) {
                                final notification = _notifications[index];
                                final color = _getNotificationColor(notification.type);
                                
                                return Dismissible(
                                  key: Key('notification_${notification.id}'),
                                  direction: notification.isRead 
                                      ? DismissDirection.endToStart 
                                      : DismissDirection.horizontal,
                                  background: Container(
                                    color: Colors.green,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: const Icon(Icons.done, color: Colors.white),
                                  ),
                                  secondaryBackground: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  confirmDismiss: (direction) async {
                                    if (direction == DismissDirection.startToEnd && !notification.isRead) {
                                      await _markAsRead(notification.id);
                                      return false;
                                    }
                                    // Delete the notification when swiping to delete
                                    if (direction == DismissDirection.endToStart) {
                                      final success = await NotificationService.deleteNotification(notification.id);
                                      return success;
                                    }
                                    return true;
                                  },
                                  onDismissed: (direction) {
                                    setState(() {
                                      _notifications.removeAt(index);
                                    });
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Notification deleted'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                  child: InkWell(
                                    onTap: notification.isRead ? null : () => _markAsRead(notification.id),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: notification.isRead
                                            ? (isDarkMode ? Colors.grey[900] : Colors.white)
                                            : (isDarkMode ? Colors.green.shade900.withValues(alpha: 0.2) : Colors.green.shade50),
                                        border: Border(
                                          bottom: BorderSide(
                                            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _getNotificationIcon(notification.type),
                                            color: color,
                                            size: 24,
                                          ),
                                        ),
                                        title: Text(
                                          notification.title,
                                          style: TextStyle(
                                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(notification.message),
                                            const SizedBox(height: 4),
                                            Text(
                                              notification.timeAgo,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: !notification.isRead
                                            ? Container(
                                                width: 10,
                                                height: 10,
                                                decoration: const BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
