import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/activity_service.dart';

class ActivitySearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  ActivitySearchDelegate(this.ref);

  @override
  String get searchFieldLabel => 'Search activities...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter a search term'),
      );
    }

    return FutureBuilder(
      future: ActivityService.searchActivities(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final activities = snapshot.data as List? ?? [];

        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No activities found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return ListTile(
              leading: _getActivityIcon(activity['type'] ?? ''),
              title: Text(activity['type'] ?? 'Unknown'),
              subtitle: Text(
                '${activity['date'] ?? ''} • ${activity['carbon_impact'] ?? 0} kg CO2',
              ),
              trailing: Text(
                '${activity['duration'] ?? 0} min',
                style: TextStyle(color: Colors.grey[600]),
              ),
              onTap: () {
                close(context, activity['id'].toString());
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearches();
    }

    return buildResults(context);
  }

  Widget _buildRecentSearches() {
    final recentSearches = [
      'Walking',
      'Cycling',
      'Public Transport',
      'Diet',
      'Energy',
    ];

    return ListView.builder(
      itemCount: recentSearches.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(recentSearches[index]),
          onTap: () {
            query = recentSearches[index];
            showResults(context);
          },
          trailing: IconButton(
            icon: const Icon(Icons.arrow_upward),
            onPressed: () {
              query = recentSearches[index];
            },
          ),
        );
      },
    );
  }

  Widget _getActivityIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'walking':
        icon = Icons.directions_walk;
        color = Colors.green;
        break;
      case 'cycling':
        icon = Icons.directions_bike;
        color = Colors.blue;
        break;
      case 'transport':
      case 'public transport':
        icon = Icons.directions_bus;
        color = Colors.orange;
        break;
      case 'diet':
        icon = Icons.restaurant;
        color = Colors.red;
        break;
      case 'energy':
        icon = Icons.bolt;
        color = Colors.amber;
        break;
      case 'shopping':
        icon = Icons.shopping_bag;
        color = Colors.purple;
        break;
      default:
        icon = Icons.eco;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color),
    );
  }
}
