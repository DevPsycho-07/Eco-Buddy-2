import 'package:flutter/material.dart';
import '../../pages/tips/tips_page.dart';
import '../../pages/history/history_page.dart';
import '../../pages/leaderboard/leaderboard_page.dart';
import '../../pages/settings/settings_page.dart';
import '../../pages/permissions/permissions_page.dart';
import '../../pages/travel/travel_insights_page.dart';
import '../../pages/privacy/privacy_dashboard_page.dart';

class AppDrawer extends StatelessWidget {
  final Function(int) onPageSelected;
  final int currentIndex;

  const AppDrawer({
    super.key,
    required this.onPageSelected,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: isSmallScreen ? 24 : 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.eco, 
                    size: isSmallScreen ? 28 : 36, 
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  'Eco Daily Score',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track your carbon footprint',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: isSmallScreen ? 11 : 13,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerSection('MAIN NAVIGATION'),
          _buildDrawerItem(context, Icons.home, 'Dashboard', () => onPageSelected(0), currentIndex == 0),
          _buildDrawerItem(context, Icons.add_circle, 'Log Activity', () => onPageSelected(1), currentIndex == 1),
          _buildDrawerItem(context, Icons.bar_chart, 'Analytics', () => onPageSelected(2), currentIndex == 2),
          _buildDrawerItem(context, Icons.emoji_events, 'Achievements', () => onPageSelected(3), currentIndex == 3),
          _buildDrawerItem(context, Icons.person, 'Profile', () => onPageSelected(4), currentIndex == 4),
          const Divider(),
          _buildDrawerSection('MORE'),
          _buildDrawerItem(context, Icons.lightbulb_outline, 'Tips & Suggestions', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TipsPage()));
          }, false),
          _buildDrawerItem(context, Icons.leaderboard, 'Leaderboard', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardPage()));
          }, false),
          _buildDrawerItem(context, Icons.history, 'History', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
          }, false),
          _buildDrawerItem(context, Icons.directions_car, 'Travel Insights', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TravelInsightsPage()));
          }, false),
          const Divider(),
          _buildDrawerSection('SETTINGS'),
          _buildDrawerItem(context, Icons.security, 'Permissions', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PermissionsPage()));
          }, false),
          _buildDrawerItem(context, Icons.privacy_tip, 'Privacy Dashboard', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyDashboardPage()));
          }, false),
          _buildDrawerItem(context, Icons.settings, 'Settings', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
          }, false),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap, bool isSelected) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      minVerticalPadding: 0,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
      leading: Icon(
        icon,
        size: 24,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }
}
