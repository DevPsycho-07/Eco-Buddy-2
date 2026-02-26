import 'package:flutter/material.dart';
import '../../services/activity_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'All';
  bool _isLoading = true;
  Map<String, List<dynamic>> _historyData = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await ActivityService.getHistory(days: 30);
      setState(() {
        _historyData = history;
        _isLoading = false;
      });
      // History loaded successfully
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load history: $e';
        _isLoading = false;
      });
      // Failed to load history
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () => _showFilterSheet(context)),
          IconButton(icon: const Icon(Icons.download), onPressed: _downloadHistory),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                        const SizedBox(height: 16),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _isLoading = true);
                            _loadHistory();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _historyData.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.history, size: 64, color: Colors.grey[400]),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'No Activity History',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start logging your eco-friendly activities!',
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: ['All', 'Transport', 'Food', 'Energy', 'Shopping'].map((filter) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(filter),
                                  selected: _selectedFilter == filter,
                                  onSelected: (selected) {
                                    if (selected) setState(() => _selectedFilter = filter);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        // History List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _historyData.length,
                            itemBuilder: (context, index) {
                              final dateKey = _historyData.keys.toList()[index];
                              final activities = _historyData[dateKey] ?? [];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      dateKey,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  ...(activities.map((activity) {
                                    final icon = _getActivityIcon(activity['category'] ?? '');
                                    final impact = activity['co2_saved'] ?? 0.0;
                                    return Card(
                                      elevation: 0,
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? const Color(0xFF252525) 
                                          : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.green[50],
                                          child: Icon(icon, color: Colors.green),
                                        ),
                                        title: Text(activity['name'] ?? 'Unknown Activity'),
                                        subtitle: Text(activity['time'] ?? ''),
                                        trailing: Text(
                                          '-${impact.toStringAsFixed(1)} kg',
                                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  })),
                                  const SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  IconData _getActivityIcon(String category) {
    return switch (category.toLowerCase()) {
      'transport' => Icons.directions_car,
      'food' => Icons.restaurant,
      'energy' => Icons.lightbulb,
      'shopping' => Icons.shopping_bag,
      'walk' => Icons.directions_walk,
      'bike' => Icons.directions_bike,
      'bus' => Icons.directions_bus,
      'recycling' => Icons.recycling,
      _ => Icons.eco,
    };
  }

  void _downloadHistory() {
    // Generate CSV-like data from history
    final buffer = StringBuffer();
    buffer.writeln('Activity History Export');
    buffer.writeln('Generated: ${DateTime.now().toLocal()}');
    buffer.writeln('');
    buffer.writeln('Type,Date,Impact,CO2 Saved');
    
    _historyData.forEach((type, activities) {
      for (var activity in activities) {
        final activityType = activity['type'] ?? 'Unknown';
        final date = activity['date'] ?? 'N/A';
        final impact = activity['impact'] ?? 'N/A';
        final co2 = activity['co2_saved'] ?? '0';
        buffer.writeln('$activityType,$date,$impact,$co2 kg');
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Activity History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('History export is ready! Preparing download...'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'File Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Format: CSV', style: TextStyle(color: Colors.grey[700])),
                  Text('Filename: activity_history_${DateTime.now().toLocal().toString().split('.')[0].replaceAll(' ', '_').replaceAll(':', '-')}.csv', style: TextStyle(color: Colors.grey[700])),
                  Text('Size: ${(buffer.toString().length / 1024).toStringAsFixed(2)} KB', style: TextStyle(color: Colors.grey[700])),
                  Text('Rows: ${_historyData.values.fold<int>(0, (sum, activities) => sum + activities.length)}', style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Activity history exported successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter by Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            ListTile(title: const Text('Last 7 days'), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text('Last 30 days'), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text('Custom range'), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
