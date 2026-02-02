import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/http_client.dart';
import '../../utils/logger.dart';
import '../../core/config/api_config.dart';

class NotificationsPage extends StatefulWidget {
  final bool notificationsEnabled;
  
  const NotificationsPage({super.key, required this.notificationsEnabled});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late bool _notificationsEnabled;
  bool _dailyReminders = true;
  bool _achievementAlerts = true;
  bool _weeklyReports = true;
  bool _tipsAndSuggestions = true;
  bool _communityUpdates = false;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.notificationsEnabled;
  }

  Future<void> _saveNotificationSettings() async {
    try {
      const baseUrl = ApiConfig.baseUrl;
      
      final response = await ApiClient.patch(
        Uri.parse('$baseUrl/users/notification-settings/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'notifications_enabled': _notificationsEnabled,
        }),
      );

      if (response.statusCode == 200) {
        Logger.debug('✅ [Notifications] Settings saved');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification settings saved!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to save settings');
      }
    } catch (e) {
      Logger.error('❌ [Notifications] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Master toggle
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.teal[500]!],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Push Notifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _notificationsEnabled ? 'Enabled' : 'Disabled',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _saveNotificationSettings();
                    },
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.white.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),

            // Notification categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'NOTIFICATION TYPES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildNotificationOption(
                    icon: Icons.alarm,
                    title: 'Daily Reminders',
                    subtitle: 'Get reminded to log your activities',
                    value: _dailyReminders,
                    onChanged: _notificationsEnabled
                        ? (value) => setState(() => _dailyReminders = value)
                        : null,
                  ),
                  const Divider(height: 1),
                  _buildNotificationOption(
                    icon: Icons.emoji_events,
                    title: 'Achievement Alerts',
                    subtitle: 'Celebrate when you unlock achievements',
                    value: _achievementAlerts,
                    onChanged: _notificationsEnabled
                        ? (value) => setState(() => _achievementAlerts = value)
                        : null,
                  ),
                  const Divider(height: 1),
                  _buildNotificationOption(
                    icon: Icons.bar_chart,
                    title: 'Weekly Reports',
                    subtitle: 'Get your weekly eco impact summary',
                    value: _weeklyReports,
                    onChanged: _notificationsEnabled
                        ? (value) => setState(() => _weeklyReports = value)
                        : null,
                  ),
                  const Divider(height: 1),
                  _buildNotificationOption(
                    icon: Icons.lightbulb_outline,
                    title: 'Tips & Suggestions',
                    subtitle: 'Receive eco-friendly tips',
                    value: _tipsAndSuggestions,
                    onChanged: _notificationsEnabled
                        ? (value) => setState(() => _tipsAndSuggestions = value)
                        : null,
                  ),
                  const Divider(height: 1),
                  _buildNotificationOption(
                    icon: Icons.groups,
                    title: 'Community Updates',
                    subtitle: 'News from the eco community',
                    value: _communityUpdates,
                    onChanged: _notificationsEnabled
                        ? (value) => setState(() => _communityUpdates = value)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can also manage notification permissions in your device settings.',
                      style: TextStyle(color: Colors.blue[700], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    final isEnabled = onChanged != null;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.green[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isEnabled ? Colors.green : Colors.grey, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isEnabled ? null : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      trailing: Switch(
        value: value && _notificationsEnabled,
        onChanged: onChanged,
        activeThumbColor: Colors.green,
      ),
    );
  }
}
