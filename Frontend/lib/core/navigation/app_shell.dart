import 'package:flutter/material.dart';
import '../../pages/home/home_page.dart';
import '../../pages/activity/activity_log_page.dart';
import '../../pages/analytics/analytics_page.dart';
import '../../pages/achievements/achievements_page.dart';
import '../../pages/profile/profile_page.dart';
import 'app_drawer.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ActivityLogPage(),
    AnalyticsPage(),
    AchievementsPage(),
    ProfilePage(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Log Activity',
    'Analytics',
    'Achievements',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: AppDrawer(
        onPageSelected: (index) {
          setState(() => _currentIndex = index);
          Navigator.pop(context);
        },
        currentIndex: _currentIndex,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 70,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 32),
            selectedIcon: Icon(Icons.home, size: 32),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline, size: 32),
            selectedIcon: Icon(Icons.add_circle, size: 32),
            label: 'Log Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined, size: 32),
            selectedIcon: Icon(Icons.bar_chart, size: 32),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined, size: 32),
            selectedIcon: Icon(Icons.emoji_events, size: 32),
            label: 'Achievements',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, size: 32),
            selectedIcon: Icon(Icons.person, size: 32),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
