import 'package:flutter/material.dart';
import '../../services/achievements_service.dart';
import '../../services/guest_service.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isGuestMode = false;
  
  // Backend data
  List<dynamic> _earnedBadges = [];
  List<dynamic> _notEarnedBadges = [];
  List<dynamic> _userChallenges = [];
  
  // Stats
  int _totalBadges = 0;
  int _currentStreak = 0;
  double _totalCo2Saved = 0;
  int _level = 0;
  int _ecoScore = 0;
  int _experiencePoints = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Check if in guest mode first
    final isGuest = await GuestService.isGuestSession();
    
    if (isGuest) {
      // Provide sample badges/challenges for guest exploration
      if (mounted) {
        setState(() {
          _isGuestMode = true;
          _earnedBadges = [];
          _notEarnedBadges = _getGuestSampleBadges();
          _userChallenges = _getGuestSampleChallenges();
          _isLoading = false;
        });
      }
      return;
    }
    
    try {
      // Load summary
      final summary = await AchievementsService.getSummary();
      if (summary != null) {
        _totalBadges = summary['total_badges'] ?? 0;
        _currentStreak = summary['current_streak'] ?? 0;
        _totalCo2Saved = (summary['total_co2_saved'] ?? 0).toDouble();
        _level = summary['level'] ?? 0;
        _ecoScore = summary['eco_score'] ?? 0;
        _experiencePoints = summary['total_points'] ?? 0;
      }
      
      // Load badges
      final badgesSummary = await AchievementsService.getBadgesSummary();
      if (badgesSummary != null) {
        _earnedBadges = badgesSummary['earned'] ?? [];
        _notEarnedBadges = badgesSummary['not_earned'] ?? [];
      }
      
      // Load user challenges
      _userChallenges = await AchievementsService.getAllUserChallenges();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load achievements: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showGuestModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guest Mode'),
        content: const Text(
          'This feature is not available in guest mode. Sign up to track your achievements and join challenges!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
            },
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }

  /// Sample badges for guest mode exploration
  List<dynamic> _getGuestSampleBadges() {
    return [
      {
        'id': 1,
        'name': 'First Step',
        'description': 'Log your first eco-friendly activity',
        'icon': '🌱',
        'required_count': 1,
        'category': 'general',
      },
      {
        'id': 2,
        'name': 'Green Commuter',
        'description': 'Use eco-friendly transport 10 times',
        'icon': '🚴',
        'required_count': 10,
        'category': 'transport',
      },
      {
        'id': 3,
        'name': 'Energy Saver',
        'description': 'Save 100 kWh of energy',
        'icon': '⚡',
        'required_count': 100,
        'category': 'energy',
      },
      {
        'id': 4,
        'name': 'Eco Warrior',
        'description': 'Save 50 kg of CO2',
        'icon': '🌍',
        'required_count': 50,
        'category': 'general',
      },
      {
        'id': 5,
        'name': 'Week Streak',
        'description': 'Log activities for 7 consecutive days',
        'icon': '🔥',
        'required_count': 7,
        'category': 'streak',
      },
    ];
  }

  /// Sample challenges for guest mode exploration
  List<Map<String, dynamic>> _getGuestSampleChallenges() {
    return [
      {
        'challenge': {
          'id': 1,
          'title': 'Zero Waste Week',
          'description': 'Reduce your waste output for a week',
          'target_value': 7,
          'reward_points': 100,
          'start_date': DateTime.now().toIso8601String(),
          'end_date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        },
        'progress_percentage': 0.0,
        'is_completed': false,
      },
      {
        'challenge': {
          'id': 2,
          'title': 'Green Transport Challenge',
          'description': 'Use only eco-friendly transportation',
          'target_value': 10,
          'reward_points': 150,
          'start_date': DateTime.now().toIso8601String(),
          'end_date': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
        },
        'progress_percentage': 0.0,
        'is_completed': false,
      },
      {
        'challenge': {
          'id': 3,
          'title': 'Energy Conservation',
          'description': 'Save 50 kWh of energy this month',
          'target_value': 50,
          'reward_points': 200,
          'start_date': DateTime.now().toIso8601String(),
          'end_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        },
        'progress_percentage': 0.0,
        'is_completed': false,
      },
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Column(
      children: [
        // Guest Mode Banner
        if (_isGuestMode)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.amber.shade900.withValues(alpha: 0.3)
                  : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.amber.shade700 
                    : Colors.amber.shade200
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events_outlined, color: Colors.amber.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sign up to earn badges and track progress!',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.amber.shade300 
                          : Colors.amber.shade800,
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false),
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        // Score Header Card
        Container(
          margin: const EdgeInsets.all(16),
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.cyan[500]!],
                  // or
                  // colors: [Color(0xFF2E7D32), Color(0xFF00897B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  // Score Circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: CircularProgressIndicator(
                          value: _ecoScore / 100,
                          strokeWidth: 10,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '$_ecoScore',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Score',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'LEVEL $_level',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              '🌟',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Eco Champion',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_experiencePoints XP to Level ${_level + 1}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_experiencePoints % 100) / 100,
                            minHeight: 6,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Stats Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: _buildStatCard('🏆', _totalBadges.toString(), 'Badges Earned', Colors.amber)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('🔥', _currentStreak.toString(), 'Day  Streak', Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('🌳', (_totalCo2Saved / 22).toStringAsFixed(0), 'Trees Saved', Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('⚡', _totalCo2Saved.toStringAsFixed(0), 'kg      Saved', Colors.blue)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Badges'),
              Tab(text: 'Goals'),
              Tab(text: 'Milestones'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBadgesTab(),
              _buildGoalsTab(),
              _buildMilestonesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF252525) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (_earnedBadges.isNotEmpty) ...[
          Text(
            'Earned (${_earnedBadges.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: _earnedBadges
                .where((badge) => badge != null)
                .map((badge) => _buildBadge(badge, true))
                .toList(),
          ),
          const SizedBox(height: 24),
        ],
        if (_notEarnedBadges.isNotEmpty) ...[
          Text(
            'In Progress (${_notEarnedBadges.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: _notEarnedBadges
                .where((badge) => badge != null)
                .map((badge) => _buildBadge(badge, false))
                .toList(),
          ),
        ],
        if (_earnedBadges.isEmpty && _notEarnedBadges.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No badges available yet'),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget  _buildBadge(Map<String, dynamic>? badgeData, bool earned) {
    if (badgeData == null) return const SizedBox.shrink();
    
    // Both earned and not_earned badges are returned as Badge objects directly from the backend
    final name = badgeData['name'] ?? 'Badge';
    final icon = badgeData['icon'] ?? '🏆';
    
    return GestureDetector(
      onTap: () => _showBadgeDetail(badgeData, earned),
      child: Container(
        decoration: BoxDecoration(
          color: earned ? Colors.green[50] : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: earned ? Colors.green : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!),
            width: earned ? 2 : 1,
          ),
          boxShadow: earned ? [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: 32,
                color: earned ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: earned ? FontWeight.bold : FontWeight.normal,
                color: earned 
                    ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.black)
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[800]),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (earned)
              Icon(Icons.verified, color: Colors.green[400], size: 16),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(Map<String, dynamic>? badge, bool earned) {
    if (badge == null) return;
    
    final name = badge['name'] ?? 'Badge';
    final icon = badge['icon'] ?? '🏆';
    final description = badge['description'] ?? '';
    final earnedAt = earned ? badge['earned_at'] : null;
    
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: earned ? Colors.green[50] : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Text(icon, style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (earned && earnedAt != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Earned on ${_formatDate(earnedAt)}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              )
            else if (!earned)
              Text(
                'Keep working to earn this badge!',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildGoalsTab() {
    final activeChallenges = _userChallenges.where((c) => c['is_completed'] == false).toList();
    final completedChallenges = _userChallenges.where((c) => c['is_completed'] == true).toList();
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (activeChallenges.isNotEmpty) ...[
          const Text('Active Goals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...activeChallenges.map((challenge) => _buildChallengeCard(challenge)),
        ],
        if (completedChallenges.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Completed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...completedChallenges.map((challenge) => _buildChallengeCard(challenge)),
        ],
        if (_userChallenges.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No active goals. Start a new challenge!'),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showAvailableChallenges,
            icon: const Icon(Icons.add),
            label: const Text('Browse Challenges'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _showAvailableChallenges() async {
    // Check guest mode first
    if (_isGuestMode) {
      _showGuestModeDialog();
      return;
    }
    
    final challenges = await AchievementsService.getActiveChallenges();
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Available Challenges',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: challenges.length,
                itemBuilder: (context, index) {
                  final challenge = challenges[index];
                  return Card(
                    elevation: 0,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF252525) 
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(challenge['title'] ?? ''),
                      subtitle: Text(challenge['description'] ?? ''),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          final nav = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final success = await AchievementsService.joinChallenge(challenge['id']);
                          if (success && mounted) {
                            nav.pop();
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Challenge joined!')),
                            );
                            _loadData();
                          }
                        },
                        child: const Text('Join'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> userChallenge) {
    final challenge = userChallenge['challenge'];
    final progress = (userChallenge['progress_percentage'] ?? 0.0) / 100;
    final isComplete = userChallenge['is_completed'] == true;
    final title = challenge['title'] ?? 'Challenge';
    final currentProgress = userChallenge['current_progress'] ?? 0.0;
    final targetValue = challenge['target_value'] ?? 100.0;
    final targetUnit = challenge['target_unit'] ?? 'units';
    
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF252525) 
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isComplete ? Colors.green[50] : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isComplete ? Icons.check_circle : Icons.flag,
                color: isComplete ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: isComplete ? TextDecoration.lineThrough : null,
                      color: isComplete ? Colors.grey : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress > 1 ? 1 : progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isComplete ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currentProgress.toStringAsFixed(0)} / ${targetValue.toStringAsFixed(0)} $targetUnit',
                    style: TextStyle(
                      fontSize: 12,
                      color: isComplete ? Colors.green : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isComplete ? Colors.green : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesTab() {
    // Milestones coming soon - showing available badges instead
    final allBadges = [
      ...(_earnedBadges.where((b) => b != null).map((b) => {'badge': b, 'earned': true})),
      ...(_notEarnedBadges.where((b) => b != null).map((b) => {'badge': b, 'earned': false}))
    ];
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
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
            child: Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Badge Milestones',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your progress towards earning all badges',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (allBadges.isNotEmpty)
          ...allBadges.map((item) {
            final badge = item['badge'] as Map<String, dynamic>?;
            final earned = item['earned'] as bool;
            return _buildBadgeMilestoneCard(badge, earned);
          })
        else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No badge milestones available yet'),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBadgeMilestoneCard(Map<String, dynamic>? badge, bool earned) {
    if (badge == null) return const SizedBox.shrink();
    
    final name = badge['name'] ?? 'Badge';
    final icon = badge['icon'] ?? '🏆';
    final description = badge['description'] ?? '';
    final requirementType = badge['requirement_type'] ?? '';
    final requirementValue = (badge['requirement_value'] as num?)?.toDouble() ?? 0.0;
    
    String requirementText = '';
    if (requirementType == 'co2_saved') {
      requirementText = 'Save ${requirementValue.toStringAsFixed(0)} kg CO₂';
    } else if (requirementType == 'activities_count') {
      requirementText = 'Log ${requirementValue.toStringAsFixed(0)} activities';
    } else if (requirementType.contains('streak')) {
      requirementText = '${requirementValue.toStringAsFixed(0)} day streak';
    } else {
      requirementText = description;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF252525) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: earned ? Colors.green[50] : (isDark ? Colors.grey[800] : Colors.grey[100]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                icon,
                style: TextStyle(
                  fontSize: 32,
                  color: earned ? null : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: earned ? Colors.green : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    requirementText,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (earned)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.green, size: 20),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock, color: Colors.grey[600], size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
