 import 'package:flutter/material.dart';

class PrivacyDashboardPage extends StatefulWidget {
  const PrivacyDashboardPage({super.key});

  @override
  State<PrivacyDashboardPage> createState() => _PrivacyDashboardPageState();
}

class _PrivacyDashboardPageState extends State<PrivacyDashboardPage> {
  final List<Map<String, dynamic>> _dataCategories = [
    {
      'id': 'location',
      'icon': Icons.location_on,
      'title': 'Location Data',
      'description': 'GPS coordinates and travel routes',
      'records': 2847,
      'size': '12.4 MB',
      'lastUpdated': '2 min ago',
      'enabled': true,
      'retention': '30 days',
    },
    {
      'id': 'activity',
      'icon': Icons.directions_walk,
      'title': 'Activity Data',
      'description': 'Steps, transport modes, activities',
      'records': 1245,
      'size': '3.2 MB',
      'lastUpdated': '5 min ago',
      'enabled': true,
      'retention': '90 days',
    },
    {
      'id': 'device',
      'icon': Icons.smartphone,
      'title': 'Device Info',
      'description': 'Device model, OS version',
      'records': 1,
      'size': '< 1 KB',
      'lastUpdated': 'On install',
      'enabled': true,
      'retention': 'Until deletion',
    },
    {
      'id': 'health',
      'icon': Icons.favorite,
      'title': 'Health Data',
      'description': 'Steps from health apps',
      'records': 0,
      'size': '0 MB',
      'lastUpdated': 'Never',
      'enabled': false,
      'retention': 'N/A',
    },
    {
      'id': 'calendar',
      'icon': Icons.calendar_today,
      'title': 'Calendar Events',
      'description': 'Travel-related events only',
      'records': 0,
      'size': '0 MB',
      'lastUpdated': 'Never',
      'enabled': false,
      'retention': 'N/A',
    },
  ];

  final Map<String, bool> _sharingSettings = {
    'analytics': false,
    'leaderboard': true,
    'challenges': true,
    'crash_reports': true,
  };

  @override
  Widget build(BuildContext context) {
    final enabledCategories = _dataCategories.where((c) => c['enabled']).length;
    int totalRecords = 0;
    for (final c in _dataCategories) {
      totalRecords += c['records'] as int;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showPrivacyInfo(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Privacy Score Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Privacy Score',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Row(
                                children: [
                                  Text(
                                    '85',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '/100',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '✓ Well Protected',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: 0.85,
                                strokeWidth: 10,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.3,
                                ),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.shield,
                              color: Colors.white,
                              size: 40,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildScoreStat('Data Types', '$enabledCategories/5'),
                        _buildScoreStat('Records', _formatNumber(totalRecords)),
                        _buildScoreStat('Shared', '0'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Data Visualization Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Data Being Collected',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton.icon(
                onPressed: () => _showDataVisualization(),
                icon: const Icon(Icons.pie_chart, size: 18),
                label: const Text('Visualize'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._dataCategories.map(
            (category) => _buildDataCategoryCard(category),
          ),
          const SizedBox(height: 24),

          // Data Storage Info
          Card(
            elevation: 0,
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF252525) 
                : Colors.blue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.storage, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Storage Summary',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStorageBar(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '15.6 MB used',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        'Local storage only',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Data Sharing Settings
          const Text(
            'Data Sharing Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF252525) 
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSharingSetting(
                  'analytics',
                  Icons.analytics,
                  'Anonymous Analytics',
                  'Help improve the app with usage data',
                ),
                const Divider(height: 1),
                _buildSharingSetting(
                  'leaderboard',
                  Icons.leaderboard,
                  'Leaderboard',
                  'Share score for ranking (username only)',
                ),
                const Divider(height: 1),
                _buildSharingSetting(
                  'challenges',
                  Icons.emoji_events,
                  'Challenges',
                  'Participate in community challenges',
                ),
                const Divider(height: 1),
                _buildSharingSetting(
                  'crash_reports',
                  Icons.bug_report,
                  'Crash Reports',
                  'Help fix bugs (no personal data)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Controls
          const Text(
            'Data Controls',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF252525) 
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.download, color: Colors.blue),
                  ),
                  title: const Text('Export My Data'),
                  subtitle: const Text('Download all your data as JSON'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showExportDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.history, color: Colors.orange),
                  ),
                  title: const Text('Data Retention'),
                  subtitle: const Text('Configure auto-deletion rules'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showRetentionSettings(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.cleaning_services,
                      color: Colors.purple,
                    ),
                  ),
                  title: const Text('Clear Old Data'),
                  subtitle: const Text('Remove data older than 30 days'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showClearOldDataDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.delete_forever, color: Colors.red[400]),
                  ),
                  title: Text(
                    'Delete All My Data',
                    style: TextStyle(color: Colors.red[600]),
                  ),
                  subtitle: const Text('Permanently remove everything'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDeleteAllDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Privacy Guarantee
          Card(
            elevation: 0,
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF252525) 
                : Colors.green[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_user, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Our Privacy Guarantee',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildGuaranteeItem(
                    Icons.check,
                    'All data stored locally on your device',
                  ),
                  _buildGuaranteeItem(
                    Icons.check,
                    'We never sell your personal information',
                  ),
                  _buildGuaranteeItem(
                    Icons.check,
                    'You can delete all data anytime',
                  ),
                  _buildGuaranteeItem(
                    Icons.check,
                    'No tracking without your consent',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Read Full Privacy Policy'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Last Audit
          Card(
            elevation: 0,
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF252525) 
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.security),
              ),
              title: const Text('Last Privacy Audit'),
              subtitle: const Text('Reviewed: Today at 3:45 PM'),
              trailing: TextButton(
                onPressed: () => _runPrivacyAudit(),
                child: const Text('Run Audit'),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildScoreStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDataCategoryCard(Map<String, dynamic> category) {
    final enabled = category['enabled'] as bool;

    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF252525) 
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _showDataCategoryDetail(category),
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
                  category['icon'],
                  color: enabled ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      enabled
                          ? '${category['records']} records • ${category['size']}'
                          : 'Not collecting',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    enabled ? Icons.check_circle : Icons.cancel,
                    color: enabled ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  if (enabled)
                    Text(
                      category['lastUpdated'],
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStorageBar() {
    return Row(
      children: [
        Expanded(
          flex: 80,
          child: Container(
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
            ),
          ),
        ),
        Expanded(
          flex: 20,
          child: Container(
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSharingSetting(
    String key,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: _sharingSettings[key]! ? Colors.green : Colors.grey,
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: _sharingSettings[key]!,
      onChanged: (value) => setState(() => _sharingSettings[key] = value),
      activeThumbColor: Colors.green,
    );
  }

  Widget _buildGuaranteeItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  void _showDataCategoryDetail(Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(category['icon'], color: Colors.green, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        category['description'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Records', '${category['records']}'),
            _buildDetailRow('Storage Used', category['size']),
            _buildDetailRow('Last Updated', category['lastUpdated']),
            _buildDetailRow('Retention Period', category['retention']),
            _buildDetailRow(
              'Status',
              category['enabled'] ? 'Active' : 'Disabled',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: category['enabled']
                        ? () {
                            Navigator.pop(context);
                            _showDeleteCategoryDialog(category['title']);
                          }
                        : null,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $category?'),
        content: Text(
          'This will permanently delete all your $category. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$category deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download, color: Colors.blue),
            SizedBox(width: 8),
            Text('Export Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose export format:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('JSON'),
              subtitle: const Text('Machine-readable format'),
              onTap: () {
                Navigator.pop(context);
                _startExport('JSON');
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV'),
              subtitle: const Text('Open in spreadsheet apps'),
              onTap: () {
                Navigator.pop(context);
                _startExport('CSV');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _startExport(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting data as $format...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showRetentionSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Retention Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Automatically delete old data after:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildRetentionOption('7 days', false),
            _buildRetentionOption('30 days', true),
            _buildRetentionOption('90 days', false),
            _buildRetentionOption('1 year', false),
            _buildRetentionOption('Never (manual only)', false),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetentionOption(String label, bool selected) {
    return ListTile(
      title: Text(label),
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? Colors.green : Colors.grey,
      ),
      onTap: () {},
    );
  }

  void _showClearOldDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Old Data?'),
        content: const Text(
          'This will delete all data older than 30 days. Recent data will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Old data cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[400]),
            const SizedBox(width: 8),
            const Text('Delete All Data?'),
          ],
        ),
        content: const Text(
          'This will permanently delete ALL your data including:\n\n'
          '• Location history\n'
          '• Activity records\n'
          '• Achievements\n'
          '• Score history\n\n'
          'This action CANNOT be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }

  void _showDataVisualization() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              const Text(
                'Data Breakdown',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Pie Chart Placeholder
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: _PieChartPainter(),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '15.6 MB',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildLegendItem(Colors.green, 'Location', '12.4 MB', '80%'),
              _buildLegendItem(Colors.blue, 'Activity', '3.2 MB', '20%'),
              _buildLegendItem(Colors.orange, 'Other', '< 1 KB', '<1%'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    Color color,
    String label,
    String size,
    String percent,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(size, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 8),
          Text(percent, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showPrivacyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('About Privacy'),
          ],
        ),
        content: const Text(
          'Eco Daily Score is designed with privacy in mind:\n\n'
          '• All data is stored locally on your device\n'
          '• We use minimal permissions\n'
          '• You have full control over your data\n'
          '• Sharing is always opt-in\n'
          '• We follow GDPR guidelines',
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

  void _runPrivacyAudit() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Running privacy audit...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Privacy audit completed. All looks good!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}

class _PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;

    // Location - 80%
    paint.color = Colors.green;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57,
      5.03,
      false,
      paint,
    );

    // Activity - 20%
    paint.color = Colors.blue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.46,
      1.26,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
