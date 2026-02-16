import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _history = [
    {'date': 'Today', 'activities': [
      {'name': 'Morning Walk', 'impact': '-0.5 kg', 'icon': Icons.directions_walk, 'time': '08:30'},
      {'name': 'Bus Commute', 'impact': '-0.8 kg', 'icon': Icons.directions_bus, 'time': '09:00'},
      {'name': 'Vegetarian Lunch', 'impact': '-0.5 kg', 'icon': Icons.restaurant, 'time': '12:30'},
    ]},
    {'date': 'Yesterday', 'activities': [
      {'name': 'Cycling', 'impact': '-0.7 kg', 'icon': Icons.directions_bike, 'time': '07:30'},
      {'name': 'LED Lighting', 'impact': '-0.2 kg', 'icon': Icons.lightbulb, 'time': '19:00'},
    ]},
    {'date': 'Jan 2, 2026', 'activities': [
      {'name': 'Carpool', 'impact': '-1.2 kg', 'icon': Icons.people, 'time': '08:00'},
      {'name': 'Recycling', 'impact': '-0.3 kg', 'icon': Icons.recycling, 'time': '18:00'},
    ]},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () => _showFilterSheet(context)),
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
        ],
      ),
      body: Column(
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
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final day = _history[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        day['date'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    ...((day['activities'] as List).map((activity) => Card(
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
                          child: Icon(activity['icon'], color: Colors.green),
                        ),
                        title: Text(activity['name']),
                        subtitle: Text(activity['time']),
                        trailing: Text(
                          activity['impact'],
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ))),
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
