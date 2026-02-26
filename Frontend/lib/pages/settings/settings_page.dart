import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../services/http_client.dart';
import '../../services/background_services.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/app_logger.dart';
import '../../core/di/service_locator.dart' show sl;
import '../../core/storage/offline_storage.dart';
import '../../core/providers/units_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _backgroundService = BackgroundTrackingService();
  final _offlineService = OfflineSyncService();
  
  String _units = 'metric';
  bool _isTracking = false;
  bool _imageCachingEnabled = true;
  int _pendingChanges = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final offlineStorage = sl<OfflineStorage>();
      final settingsBox = offlineStorage.getSettingsBox();
      
      setState(() {
        _units = settingsBox.get('units', defaultValue: 'metric') as String;
        _isTracking = _backgroundService.isTracking;
        _pendingChanges = _offlineService.pendingChangesCount;
      });
    } catch (e) {
      AppLogger.error('Failed to load settings', error: e);
    }
  }

  Future<void> _saveUnitsToBackend(String units) async {
    try {
      const baseUrl = ApiConfig.baseUrl;
      final response = await ApiClient.patch(
        Uri.parse('$baseUrl/users/profile/'),
        headers: {'Content-Type': 'application/json'},
        body: '{"units": "$units"}',
      );

      if (response.statusCode == 200) {
        final offlineStorage = sl<OfflineStorage>();
        final settingsBox = offlineStorage.getSettingsBox();
        await settingsBox.put('units', units);
        
        // Update the units provider to propagate change across the app
        ref.read(unitsProvider.notifier).setUnits(units);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Units updated'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Failed to update units');
      }
    } catch (e) {
      AppLogger.error('Failed to save units', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to update units: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleBackgroundTracking(bool value) async {
    if (value) {
      await _backgroundService.startTracking();
    } else {
      await _backgroundService.stopTracking();
    }
    setState(() {
      _isTracking = value;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value 
            ? '✅ Background tracking enabled' 
            : '⏹️ Background tracking disabled'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _syncPendingChanges() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final result = await _offlineService.syncPendingChanges();
    
    if (mounted) {
      Navigator.pop(context);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sync Complete'),
          content: Text(
            'Successful: ${result['successful']}\n'
            'Failed: ${result['failed']}\n'
            'Remaining: ${result['remaining']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      _loadSettings();
    }
  }

  void _clearImageCache() {
    PerformanceOptimizationService.clearImageCache();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗑️ Image cache cleared'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCacheInfo() {
    final info = PerformanceOptimizationService.getCacheInfo();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Cache Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current size: ${info['currentSize']} images'),
            Text('Maximum size: ${info['maximumSize']} images'),
            const SizedBox(height: 8),
            Text('Current bytes: ${(info['currentSizeBytes']! / 1024 / 1024).toStringAsFixed(2)} MB'),
            Text('Maximum bytes: ${(info['maximumSizeBytes']! / 1024 / 1024).toStringAsFixed(2)} MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme mode from provider
    final themeMode = ref.watch(themeModeProvider);
    
    // Determine if dark mode is active (considering system theme)
    bool isDarkMode;
    if (themeMode == ThemeMode.system) {
      // Follow system brightness
      isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    } else {
      // Use the explicitly set theme
      isDarkMode = themeMode == ThemeMode.dark;
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSection('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(themeMode == ThemeMode.system 
              ? 'Following system preference' 
              : 'Use dark theme (overrides system setting)'),
            value: isDarkMode,
            onChanged: (value) {
              if (themeMode == ThemeMode.system) {
                // Show dialog if currently following system
                _showThemeDialog(themeMode);
              } else {
                // Allow quick toggle if manually set
                ref.read(themeModeProvider.notifier).toggleTheme(value);
              }
            },
          ),
          ListTile(
            title: const Text('Theme Settings'),
            subtitle: Text(themeMode == ThemeMode.system 
              ? 'Follow system' 
              : themeMode == ThemeMode.dark 
                ? 'Dark (manual)' 
                : 'Light (manual)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(themeMode),
          ),
          
          _buildSection('Units & Preferences'),
          ListTile(
            title: const Text('Units'),
            subtitle: Text(_units == 'metric' ? 'Metric (km, kg)' : 'Imperial (mi, lbs)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showUnitsDialog(),
          ),
          
          _buildSection('Background Services'),
          SwitchListTile(
            title: const Text('Enable Background Tracking'),
            subtitle: const Text('Track GPS, steps, and activities'),
            value: _isTracking,
            onChanged: _toggleBackgroundTracking,
          ),
          if (_isTracking) 
            const ListTile(
              leading: Icon(Icons.info_outline, color: Colors.blue),
              title: Text('Note'),
              subtitle: Text(
                'Background tracking is currently simulated. '
                'For true background execution, native platform code is required.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          
          _buildSection('Offline Sync'),
          ListTile(
            title: const Text('Pending Changes'),
            subtitle: Text('$_pendingChanges items waiting to sync'),
            trailing: _pendingChanges > 0
                ? Badge(
                    label: Text('$_pendingChanges'),
                    child: const Icon(Icons.cloud_upload),
                  )
                : const Icon(Icons.cloud_done, color: Colors.green),
          ),
          if (_pendingChanges > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _syncPendingChanges,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Now'),
                ),
              ),
            ),
          
          _buildSection('Performance'),
          SwitchListTile(
            title: const Text('Image Caching'),
            subtitle: const Text('Cache images for faster loading'),
            value: _imageCachingEnabled,
            onChanged: (value) {
              setState(() {
                _imageCachingEnabled = value;
              });
              if (value) {
                PerformanceOptimizationService.enableImageCaching();
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Clear Image Cache'),
            subtitle: const Text('Free up storage space'),
            trailing: const Icon(Icons.delete_outline),
            onTap: _clearImageCache,
          ),
          ListTile(
            title: const Text('Cache Info'),
            subtitle: const Text('View cache statistics'),
            trailing: const Icon(Icons.info_outline),
            onTap: _showCacheInfo,
          ),
          
          _buildSection('About'),
          const ListTile(
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/terms-of-service'),
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/privacy-policy'),
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

  void _showThemeDialog(ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Follow System'),
              subtitle: const Text('Automatically match device theme'),
              leading: Icon(
                currentMode == ThemeMode.system 
                  ? Icons.radio_button_checked 
                  : Icons.radio_button_unchecked,
                color: currentMode == ThemeMode.system ? Colors.green : Colors.grey,
              ),
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Light Mode'),
              subtitle: const Text('Always use light theme'),
              leading: Icon(
                currentMode == ThemeMode.light 
                  ? Icons.radio_button_checked 
                  : Icons.radio_button_unchecked,
                color: currentMode == ThemeMode.light ? Colors.green : Colors.grey,
              ),
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Always use dark theme'),
              leading: Icon(
                currentMode == ThemeMode.dark 
                  ? Icons.radio_button_checked 
                  : Icons.radio_button_unchecked,
                color: currentMode == ThemeMode.dark ? Colors.green : Colors.grey,
              ),
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
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
          children: [
            ListTile(
              title: const Text('Metric (km, kg)'),
              leading: Icon(
                _units == 'metric' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _units == 'metric' ? Colors.green : Colors.grey,
              ),
              onTap: () {
                setState(() => _units = 'metric');
                _saveUnitsToBackend('metric');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Imperial (mi, lbs)'),
              leading: Icon(
                _units == 'imperial' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _units == 'imperial' ? Colors.green : Colors.grey,
              ),
              onTap: () {
                setState(() => _units = 'imperial');
                _saveUnitsToBackend('imperial');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _backgroundService.dispose();
    super.dispose();
  }
}
