import 'package:flutter/material.dart';
import '../../services/background_services.dart';

class BackgroundSettingsPage extends StatefulWidget {
  const BackgroundSettingsPage({super.key});

  @override
  State<BackgroundSettingsPage> createState() => _BackgroundSettingsPageState();
}

class _BackgroundSettingsPageState extends State<BackgroundSettingsPage> {
  final _backgroundService = BackgroundTrackingService();
  final _offlineService = OfflineSyncService();
  
  bool _isTracking = false;
  bool _imageCachingEnabled = true;
  int _pendingChanges = 0;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _isTracking = _backgroundService.isTracking;
      _pendingChanges = _offlineService.pendingChangesCount;
    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Services'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Background Tracking Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Background Tracking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Automatically track your activities in the background',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Background Tracking'),
                    subtitle: const Text('Track GPS, steps, and activities'),
                    value: _isTracking,
                    onChanged: _toggleBackgroundTracking,
                  ),
                  if (_isTracking) ...[
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.info_outline, color: Colors.blue),
                      title: Text('Note'),
                      subtitle: Text(
                        'Background tracking is currently simulated. '
                        'For true background execution, native platform code is required.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Offline Sync Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sync,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Offline Sync',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage offline changes and synchronization',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
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
                  if (_pendingChanges > 0) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _syncPendingChanges,
                        icon: const Icon(Icons.sync),
                        label: const Text('Sync Now'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Performance Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.speed,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Performance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Optimize app performance and storage',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _backgroundService.dispose();
    super.dispose();
  }
}
