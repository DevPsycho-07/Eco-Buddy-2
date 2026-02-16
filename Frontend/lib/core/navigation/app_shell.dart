import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_drawer.dart';
import '../../services/notification_service.dart';
import '../../services/fcm_service.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  
  const AppShell({
    super.key,
    required this.child,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    // Load unread count once on initialization
    _loadUnreadCount();
    
    // Set up FCM callback to refresh count when notification received
    FCMService.setNotificationCallback(_loadUnreadCount);
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      // Silently fail - not critical
    }
  }
  
  int get _currentIndex {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/activities')) return 1;
    if (location.startsWith('/analytics')) return 2;
    if (location.startsWith('/achievements')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  final List<String> _titles = [
    'Dashboard',
    'Log Activity',
    'Analytics',
    'Achievements',
    'Profile',
  ];

  String get _currentTitle {
    if (_currentIndex >= 0 && _currentIndex < _titles.length) {
      return _titles[_currentIndex];
    }
    return 'Eco Daily Score';
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/activities');
        break;
      case 2:
        context.go('/analytics');
        break;
      case 3:
        context.go('/achievements');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode 
          ? const Color(0xFF1A1A1A)  // Slightly lighter than pure black
          : const Color(0xFFE8EDF2),  // Much softer gray-blue, easier on eyes
      appBar: AppBar(
        title: Text(_currentTitle),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () async {
                  await context.push('/notifications');
                  // Reload count after returning from notifications page
                  _loadUnreadCount();
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _unreadCount > 99 ? '99+' : '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(
        onPageSelected: _onDestinationSelected,
        currentIndex: _currentIndex,
      ),
      body: widget.child, // Use the child passed from go_router
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
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
