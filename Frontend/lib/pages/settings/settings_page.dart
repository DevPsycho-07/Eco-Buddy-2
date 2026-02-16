import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notifications = true;
  String _units = 'Metric';

  @override
  Widget build(BuildContext context) {
    // Get the current theme mode from provider
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSection('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: isDarkMode,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).toggleTheme(value);
            },
          ),
          
          _buildSection('Units & Preferences'),
          ListTile(
            title: const Text('Units'),
            subtitle: Text(_units),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showUnitsDialog(),
          ),
          
          _buildSection('Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Daily reminders and tips'),
            value: _notifications,
            onChanged: (value) => setState(() => _notifications = value),
          ),
          ListTile(
            title: const Text('Notification Schedule'),
            subtitle: const Text('9:00 AM daily'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          
          _buildSection('Data & Sync'),
          ListTile(
            title: const Text('Background Services'),
            subtitle: const Text('GPS tracking, sync, performance'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/background-settings'),
          ),
          ListTile(
            title: const Text('Sync Frequency'),
            subtitle: const Text('Every 15 minutes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage space'),
            onTap: () => _showClearCacheDialog(),
          ),
          
          _buildSection('About'),
          const ListTile(
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showUnitsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Metric', 'Imperial'].map((unit) => ListTile(
            title: Text(unit),
            leading: Icon(
              _units == unit ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: _units == unit ? Colors.green : Colors.grey,
            ),
            onTap: () {
              setState(() => _units = unit);
              Navigator.pop(context);
            },
            )).toList(),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Clear')),
        ],
      ),
    );
  }
}
