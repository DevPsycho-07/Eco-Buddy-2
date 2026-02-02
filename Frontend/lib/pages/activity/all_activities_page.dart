import 'package:flutter/material.dart';
import '../../services/activity_service.dart';

class AllActivitiesPage extends StatefulWidget {
  const AllActivitiesPage({super.key});

  @override
  State<AllActivitiesPage> createState() => _AllActivitiesPageState();
}

class _AllActivitiesPageState extends State<AllActivitiesPage> {
  Map<String, List<Activity>> _groupedActivities = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllActivities();
  }

  Future<void> _loadAllActivities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final activities = await ActivityService.getHistory(days: 30);
      if (mounted) {
        setState(() {
          _groupedActivities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Activities'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAllActivities,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _groupedActivities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No activities logged yet',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAllActivities,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _groupedActivities.length,
                        itemBuilder: (context, index) {
                          final date = _groupedActivities.keys.elementAt(index);
                          final activities = _groupedActivities[date]!;
                          return _buildDateSection(date, activities);
                        },
                      ),
                    ),
    );
  }

  Widget _buildDateSection(String date, List<Activity> activities) {
    final DateTime dateTime = DateTime.parse(date);
    final String formattedDate = _formatDate(dateTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
        ...activities.map((activity) => _buildActivityCard(activity)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final isPositive = activity.co2Impact < 0;
    final color = _getCategoryColor(activity.categoryName);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(_getCategoryIcon(activity.categoryName), color: color),
        ),
        title: Text(
          activity.activityTypeName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${activity.categoryName} • ${activity.quantity} ${activity.unit}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (activity.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  activity.notes,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11, fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isPositive ? Colors.green[50] : Colors.orange[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${isPositive ? '' : '+'}${activity.co2Impact.toStringAsFixed(1)} kg',
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return Icons.directions_car;
      case 'food':
        return Icons.restaurant;
      case 'energy':
        return Icons.bolt;
      case 'waste':
        return Icons.delete_outline;
      case 'water':
        return Icons.water_drop;
      default:
        return Icons.eco;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return Colors.blue;
      case 'food':
        return Colors.orange;
      case 'energy':
        return Colors.amber;
      case 'waste':
        return Colors.purple;
      case 'water':
        return Colors.cyan;
      default:
        return Colors.green;
    }
  }
}
