import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import '../../services/http_client.dart';
import '../../services/auth_service.dart';
import '../../services/guest_service.dart';
import '../../utils/logger.dart';
import '../../core/config/api_config.dart';
import '../auth/welcome_page.dart';
import 'edit_profile_page.dart';
import 'notifications_page.dart';
import 'help_support_page.dart';
import 'export_data_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileDataFuture;
  int? _userRank;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchProfileData();
  }

  Future<Map<String, dynamic>> _fetchProfileData() async {
    // Check if in guest mode first
    final isGuest = await GuestService.isGuestSession();
    
    if (isGuest) {
      // Return guest profile data for UI exploration
      return {
        'id': 0,
        'username': 'Guest',
        'email': 'guest@example.com',
        'first_name': 'Guest',
        'last_name': 'User',
        'bio': 'Exploring the app',
        'profile_picture': null,
        'eco_score': 0,
        'total_co2_saved': 0.0,
        'current_streak': 0,
        'longest_streak': 0,
        'level': 1,
        'experience_points': 0,
        'rank': null,
        'is_guest': true,
      };
    }
    
    try {
      const baseUrl = ApiConfig.baseUrl;
      
      Logger.debug('🔍 [Profile] Fetching profile from: $baseUrl/users/profile/');

      // Fetch user profile using ApiClient (handles token refresh on 401)
      final profileResponse = await ApiClient.get(
        Uri.parse('$baseUrl/users/profile/'),
      );

      Logger.debug('✅ [Profile] Response status code: ${profileResponse.statusCode}');
      Logger.debug('📋 [Profile] Response body: ${profileResponse.body}');

      if (profileResponse.statusCode != 200) {
        throw Exception(
            'Failed to load profile. Status: ${profileResponse.statusCode}');
      }

      final profileData = jsonDecode(profileResponse.body);
      
      // Normalize camelCase to snake_case for consistency
      if (profileData.containsKey('firstName')) {
        profileData['first_name'] = profileData['firstName'];
      }
      if (profileData.containsKey('lastName')) {
        profileData['last_name'] = profileData['lastName'];
      }
      if (profileData.containsKey('ecoScore')) {
        profileData['eco_score'] = profileData['ecoScore'];
      }
      if (profileData.containsKey('profilePicture')) {
        profileData['profile_picture'] = profileData['profilePicture'];
      }
      if (profileData.containsKey('totalCO2Saved')) {
        profileData['total_co2_saved'] = profileData['totalCO2Saved'];
      }
      if (profileData.containsKey('currentStreak')) {
        profileData['current_streak'] = profileData['currentStreak'];
      }
      if (profileData.containsKey('longestStreak')) {
        profileData['longest_streak'] = profileData['longestStreak'];
      }
      if (profileData.containsKey('experiencePoints')) {
        profileData['experience_points'] = profileData['experiencePoints'];
      }
      if (profileData.containsKey('notificationsEnabled')) {
        profileData['notifications_enabled'] = profileData['notificationsEnabled'];
      }
      if (profileData.containsKey('darkMode')) {
        profileData['dark_mode'] = profileData['darkMode'];
      }
      if (profileData.containsKey('createdAt')) {
        profileData['created_at'] = profileData['createdAt'];
      }
      
      Logger.debug('✅ [Profile] Successfully parsed profile data');

      // Fetch user rank
      Logger.debug('🔍 [Rank] Fetching rank from: $baseUrl/users/my-rank/');
      final rankResponse = await ApiClient.get(
        Uri.parse('$baseUrl/users/my-rank/'),
      );

      Logger.debug('✅ [Rank] Response status code: ${rankResponse.statusCode}');

      if (rankResponse.statusCode == 200) {
        final rankData = jsonDecode(rankResponse.body);
        _userRank = rankData['rank'];
        profileData['rank'] = rankData['rank'];
        Logger.debug('✅ [Rank] User rank: $_userRank');
      } else {
        Logger.debug('⚠️ [Rank] Failed to fetch rank. Status: ${rankResponse.statusCode}');
        profileData['rank'] = null;
      }

      Logger.debug('✅ [Profile] All data fetched successfully!');
      return profileData;
    } catch (e) {
      Logger.error('❌ [Profile] Error: $e');
      Logger.error('❌ [Profile] Stack trace: ${StackTrace.current}');
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(dynamic error) {
    setState(() {
      if (error is TimeoutException) {
        _errorMessage =
            'Connection timeout. Please check your internet connection.';
        Logger.debug('⏱️ [Error] Timeout: $_errorMessage');
      } else if (error.toString().contains('Session expired')) {
        _errorMessage = error.toString();
        Logger.debug('🔐 [Error] Session error: $_errorMessage');
      } else if (error.toString().contains('Failed to load')) {
        _errorMessage = error.toString();
        Logger.debug('❌ [Error] Load failed: $_errorMessage');
      } else {
        _errorMessage =
            'An error occurred while loading your profile. Please try again.';
        Logger.error('❌ [Error] Unknown error: ${error.toString()}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading your profile...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorScreen(context, _errorMessage ?? 'Unknown error');
        }

        if (!snapshot.hasData) {
          return _buildErrorScreen(context, 'No profile data available');
        }

        final profileData = snapshot.data!;
        
        return _buildProfileContent(context, profileData);
      },
    );
  }

  Widget _buildGuestBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.teal.shade900.withValues(alpha: 0.3)
            : Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.teal.shade700 
              : Colors.teal.shade200
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline, color: Colors.teal.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sign up to save your profile and track progress!',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.teal.shade300 
                    : Colors.teal.shade800,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false),
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String errorMessage) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                errorMessage,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _profileDataFuture = _fetchProfileData();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(
      BuildContext context, Map<String, dynamic> profileData) {
    final isGuest = profileData['is_guest'] == true;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Guest Mode Banner
          if (isGuest) _buildGuestBanner(context),
          
          // Profile Header Card - ID Card Style (Landscape)
          Card(
            elevation: 8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.teal[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  // Left Section - Profile Picture
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            backgroundImage: (profileData['profile_picture'] !=
                                    null)
                                ? NetworkImage('${ApiConfig.baseUrl.replaceAll('/api', '')}${profileData['profile_picture']}')
                                : null,
                            child: (profileData['profile_picture'] == null)
                                ? const Icon(Icons.person,
                                    size: 40, color: Colors.green)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right Section - User Info & Stats
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top info section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${profileData['first_name'] ?? ''} ${profileData['last_name'] ?? ''}'.trim().isEmpty 
                                    ? 'No Name Set' 
                                    : '${profileData['first_name'] ?? ''} ${profileData['last_name'] ?? ''}'.trim(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Eco ID: #${profileData['id'] ?? 'N/A'}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 14,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '🌟 Level ${profileData['level'] ?? 1} Eco Enthusiast',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Since ${_formatDate(profileData['created_at'])}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          // Stats Grid
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              _buildCompactStat(
                                  '${profileData['eco_score']}', 'Score'),
                              _buildCompactStat(
                                  '#${profileData['rank'] ?? '...'}', 'Rank'),
                              _buildCompactStat(
                                  '${profileData['level'] ?? 1}', 'Level'),
                              _buildCompactStat(
                                  '${(profileData['experience_points'] ?? 0)}', 'XP'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Impact Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            const Text('🌍', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Your Total Impact',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImpactCard(
                            '${profileData['total_co2_saved']?.toStringAsFixed(1) ?? '0'} kg',
                            'CO₂ Saved',
                            Icons.cloud_off,
                            Colors.green),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildImpactCard(
                            '${((profileData['total_co2_saved'] ?? 0) / 12).toStringAsFixed(1)}',
                            'Trees Equiv.',
                            Icons.park,
                            Colors.teal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImpactCard(
                            '${profileData['current_streak'] ?? 0}',
                            'Current Streak',
                            Icons.local_fire_department,
                            Colors.orange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildImpactCard(
                            '${profileData['longest_streak'] ?? 0}',
                            'Best Streak',
                            Icons.emoji_events,
                            Colors.blue.withValues(alpha: 1.0)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Bio Section
          if (profileData['bio'] != null && profileData['bio'].isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profileData['bio'],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Guest Mode Banner
          if (profileData['is_guest'] == true)
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You\'re in Guest Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create an account to save your progress, track activities, and compete with others!',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          GuestService.endGuestSession();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const WelcomePage(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Create Account'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (profileData['is_guest'] == true) const SizedBox(height: 20),

          // Account Options
          Card(
            child: Column(
              children: [
                if (profileData['is_guest'] != true) ...[
                  _buildOptionTile(Icons.edit, 'Edit Profile',
                      'Update your information', () => _navigateToEditProfile(profileData)),
                  const Divider(height: 1),
                  _buildOptionTile(Icons.notifications, 'Notifications',
                      'Manage alerts & reminders', () => _navigateToNotifications(profileData)),
                  const Divider(height: 1),
                  _buildOptionTile(Icons.share, 'Share Profile',
                      'Invite friends to join', () => _showShareDialog()),
                  const Divider(height: 1),
                  _buildOptionTile(Icons.download, 'Export Data',
                      'Download your eco history', () => _navigateToExportData()),
                  const Divider(height: 1),
                ],
                _buildOptionTile(Icons.help_outline, 'Help & Support',
                    'FAQs and contact us', () => _navigateToHelpSupport()),
                const Divider(height: 1),
                if (profileData['is_guest'] == true)
                  _buildOptionTile(
                      Icons.exit_to_app, 'Exit Guest Mode', 'Return to welcome screen', () => _showExitGuestDialog(),
                      color: Colors.orange)
                else
                  _buildOptionTile(
                      Icons.logout, 'Log Out', 'Sign out of your account', () => _showLogoutDialog(),
                      isDestructive: true),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.strMonth} ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildCompactStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 9,
          ),
        ),
      ],
    );
  }


  Widget _buildImpactCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, String subtitle,
      VoidCallback onTap,
      {bool isDestructive = false, Color? color}) {
    final iconColor = isDestructive ? Colors.red : (color ?? Colors.grey[700]);
    final bgColor = isDestructive ? Colors.red[50] : (color != null ? color.withValues(alpha: 0.1) : Colors.grey[100]);
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? Colors.red[300] : Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _showShareDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Your Impact',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Inspire others to join the eco-friendly journey!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.message, 'Message', Colors.green),
                _buildShareOption(Icons.mail, 'Email', Colors.red),
                _buildShareOption(Icons.link, 'Copy Link', Colors.blue),
                _buildShareOption(Icons.more_horiz, 'More', Colors.grey),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _navigateToEditProfile(Map<String, dynamic> profileData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(profileData: profileData),
      ),
    );
    
    // Refresh profile if edited
    if (result == true) {
      setState(() {
        _profileDataFuture = _fetchProfileData();
      });
    }
  }

  void _navigateToNotifications(Map<String, dynamic> profileData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsPage(
          notificationsEnabled: profileData['notifications_enabled'] ?? true,
        ),
      ),
    );
  }

  void _navigateToExportData() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExportDataPage(),
      ),
    );
  }

  void _navigateToHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpSupportPage(),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Show loading indicator
              showDialog(
                context: this.context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                await AuthService.logout();
                
                if (mounted) {
                  Navigator.pop(this.context); // Close loading
                  // Navigate to welcome page and clear stack
                  Navigator.of(this.context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const WelcomePage(),
                    ),
                    (route) => false,
                  );
                }
              } catch (e) {
                Logger.error('❌ [Logout] Error: $e');
                if (mounted) {
                  Navigator.pop(this.context); // Close loading
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showExitGuestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.exit_to_app, color: Colors.orange),
            SizedBox(width: 8),
            Text('Exit Guest Mode'),
          ],
        ),
        content: const Text('Would you like to create an account or exit guest mode?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () async {
              Navigator.pop(context);
              await GuestService.endGuestSession();
              if (mounted) {
                Navigator.of(this.context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const WelcomePage(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await GuestService.endGuestSession();
              if (mounted) {
                Navigator.of(this.context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const WelcomePage(),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}

extension on DateTime {
  String get strMonth {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
