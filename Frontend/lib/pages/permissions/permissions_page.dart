import 'package:flutter/material.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  final Map<String, Map<String, dynamic>> _permissions = {
    'location': {
      'enabled': true,
      'title': 'Location',
      'icon': Icons.location_on,
      'description': 'Track travel mode and distance',
      'detail': 'Automatically detect walking, cycling, and driving',
      'importance': 'Required for auto-detecting transport mode',
      'dataUsage': 'Location data is stored locally and never shared',
      'settings': {
        'backgroundTracking': true,
        'highAccuracy': true,
        'trackFrequency': 'Every 5 minutes',
      },
    },
    'activityRecognition': {
      'enabled': true,
      'title': 'Activity Recognition',
      'icon': Icons.directions_walk,
      'description': 'Detect walking, cycling, driving',
      'detail': 'Motion sensors to identify your activity type',
      'importance': 'Automatically log your eco-friendly activities',
      'dataUsage': 'Activity data helps calculate your eco score',
      'settings': {
        'detectWalking': true,
        'detectCycling': true,
        'detectDriving': true,
        'detectStationary': false,
      },
    },
    'health': {
      'enabled': false,
      'title': 'Health & Fitness',
      'icon': Icons.favorite,
      'description': 'Access step count and workouts',
      'detail': 'Sync with Google Fit / Apple Health',
      'importance': 'More accurate step tracking and workout data',
      'dataUsage': 'Health data is processed locally only',
      'settings': {
        'syncSteps': true,
        'syncWorkouts': true,
        'syncDistance': true,
      },
    },
    'calendar': {
      'enabled': false,
      'title': 'Calendar',
      'icon': Icons.calendar_today,
      'description': 'Detect travel from events',
      'detail': 'Auto-detect flights and trips from calendar',
      'importance': 'Predict and log travel activities automatically',
      'dataUsage': 'Only event locations are accessed, not content',
      'settings': {
        'detectFlights': true,
        'detectMeetings': false,
        'autoLogTrips': true,
      },
    },
    'notifications': {
      'enabled': true,
      'title': 'Notifications',
      'icon': Icons.notifications,
      'description': 'Daily tips and reminders',
      'detail': 'Stay motivated on your eco journey',
      'importance': 'Receive personalized eco tips and goal reminders',
      'dataUsage': 'Notification preferences are stored in your profile',
      'settings': {
        'dailyTips': true,
        'goalReminders': true,
        'weeklyReport': true,
        'challengeAlerts': false,
      },
    },
    'backgroundRefresh': {
      'enabled': true,
      'title': 'Background Refresh',
      'icon': Icons.sync,
      'description': 'Track activities in background',
      'detail': 'Continuous monitoring for accurate tracking',
      'importance': 'Essential for automatic activity detection',
      'dataUsage': 'Battery optimized background processing',
      'settings': {
        'autoSync': true,
        'syncWifiOnly': false,
        'syncFrequency': 'Every 15 minutes',
      },
    },
    'bluetooth': {
      'enabled': false,
      'title': 'Bluetooth',
      'icon': Icons.bluetooth,
      'description': 'Detect car connection',
      'detail': 'Know when you\'re driving via car Bluetooth',
      'importance': 'More accurate driving detection',
      'dataUsage': 'Only connection status is checked',
      'settings': {'detectCarConnection': true, 'detectSmartDevices': false},
    },
    'battery': {
      'enabled': false,
      'title': 'Battery Info',
      'icon': Icons.battery_full,
      'description': 'Charging pattern analysis',
      'detail': 'Understand your charging habits',
      'importance': 'Optimize charging for energy efficiency',
      'dataUsage': 'Battery data is used for recommendations',
      'settings': {'trackCharging': true, 'nightChargingAlert': true},
    },
  };

  @override
  Widget build(BuildContext context) {
    final enabledCount = _permissions.values
        .where((p) => p['enabled'] == true)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
        actions: [
          TextButton(
            onPressed: () => _showPermissionInfo(),
            child: const Text('Why?'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Banner
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.info_outline, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Granular Permission Controls',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enable permissions to automatically track your eco-friendly activities. You control which sensors we use.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: enabledCount / _permissions.length,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      ),
                      Text(
                        '$enabledCount/${_permissions.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Permissions Enabled',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          enabledCount >= 4
                              ? '✅ Good tracking coverage'
                              : '⚠️ Enable more for better tracking',
                          style: TextStyle(
                            fontSize: 12,
                            color: enabledCount >= 4
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _enableAllPermissions(),
                    child: const Text('Enable All'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Essential Permissions Section
          _buildSectionHeader('Essential', 'Required for core functionality'),
          _buildPermissionTile('location'),
          _buildPermissionTile('activityRecognition'),
          _buildPermissionTile('notifications'),
          const SizedBox(height: 20),

          // Optional Permissions Section
          _buildSectionHeader('Optional', 'Enhance your experience'),
          _buildPermissionTile('health'),
          _buildPermissionTile('calendar'),
          _buildPermissionTile('backgroundRefresh'),
          _buildPermissionTile('bluetooth'),
          _buildPermissionTile('battery'),
          const SizedBox(height: 24),

          // System Settings Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.settings),
              label: const Text('Open System Settings'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Privacy Note
          Card(
            color: Colors.green[50],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.shield, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Privacy is Protected',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'All data is processed locally on your device. We never sell your personal information.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(String key) {
    final permission = _permissions[key]!;
    final enabled = permission['enabled'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _showPermissionDetail(key),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: enabled ? Colors.green[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  permission['icon'],
                  color: enabled ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          permission['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        if (enabled)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      permission['description'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (value) {
                  setState(() {
                    _permissions[key]!['enabled'] = value;
                  });
                  if (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${permission['title']} enabled'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                activeThumbColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPermissionDetail(String key) {
    final permission = _permissions[key]!;
    final settings = permission['settings'] as Map<String, dynamic>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      permission['icon'],
                      size: 32,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          permission['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          permission['detail'],
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow(
                Icons.star,
                'Why it\'s important',
                permission['importance'],
              ),
              _buildInfoRow(
                Icons.lock,
                'How we use your data',
                permission['dataUsage'],
              ),
              const SizedBox(height: 24),
              const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...settings.entries.map((entry) {
                if (entry.value is bool) {
                  return SwitchListTile(
                    title: Text(_formatSettingName(entry.key)),
                    value: entry.value,
                    onChanged: (permission['enabled'] as bool)
                        ? (value) {
                            setState(() {
                              settings[entry.key] = value;
                            });
                          }
                        : null,
                    activeThumbColor: Colors.green,
                  );
                } else {
                  return ListTile(
                    title: Text(_formatSettingName(entry.key)),
                    subtitle: Text(entry.value.toString()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: (permission['enabled'] as bool) ? () {} : null,
                  );
                }
              }),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _permissions[key]!['enabled'] = false;
                        });
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Text('Disable'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSettingName(String name) {
    return name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _enableAllPermissions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable All Permissions?'),
        content: const Text(
          'This will enable all permissions for the best tracking experience. You can disable individual permissions anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                for (var key in _permissions.keys) {
                  _permissions[key]!['enabled'] = true;
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All permissions enabled'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enable All'),
          ),
        ],
      ),
    );
  }

  void _showPermissionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('Why Permissions?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Eco Daily Score uses these permissions to:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildWhyItem('📍', 'Auto-detect your transport mode'),
            _buildWhyItem('🚶', 'Track walking, cycling, and driving'),
            _buildWhyItem('❤️', 'Sync with health apps for accuracy'),
            _buildWhyItem('📅', 'Predict trips from calendar events'),
            _buildWhyItem('🔔', 'Send helpful tips and reminders'),
            const SizedBox(height: 12),
            Text(
              'All data stays on your device and is never sold.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
