import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/eco_score_card.dart';
import '../../core/widgets/quick_stats_card.dart';
import '../../core/widgets/daily_tip_card.dart';
import '../../services/dashboard_service.dart';
import '../../services/activity_service.dart';
import '../../services/guest_service.dart';
import '../../services/eco_profile_service.dart';
import '../../core/providers/units_provider.dart';
import '../../core/utils/unit_converter.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Loading and error states
  bool _isLoading = true;
  String? _error;
  bool _isGuestMode = false;

  // Data from backend
  UserDashboard? _userProfile;
  ActivitySummary? _activitySummary;
  List<Activity> _recentActivities = [];
  Tip? _dailyTip;
  List<Challenge> _activeChallenges = [];
  Map<String, dynamic>? _predictionData;
  bool _isPredictionLoading = false;
  bool _hasLoggedToday = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadPrediction();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check if in guest mode first
      final isGuest = await GuestService.isGuestSession();
      
      if (isGuest) {
        // Show dashboard with zero stats for guest exploration
        if (mounted) {
          setState(() {
            _isGuestMode = true;
            _userProfile = UserDashboard(
              id: 0,
              username: 'Guest',
              email: '',
              firstName: 'Guest',
              lastName: '',
              bio: '',
              ecoScore: 0,
              totalCo2Saved: 0.0,
              currentStreak: 0,
              longestStreak: 0,
              level: 1,
              experiencePoints: 0,
            );
            _activitySummary = ActivitySummary(
              startDate: DateTime.now().toIso8601String().split('T')[0],
              endDate: DateTime.now().toIso8601String().split('T')[0],
              totalActivities: 0,
              totalPoints: 0,
              totalCo2Saved: 0.0,
              totalCo2Emitted: 0.0,
              byCategory: {},
            );
            _recentActivities = [];
            _dailyTip = Tip(
              id: 0,
              title: 'Welcome to Eco Daily Score!',
              content: 'Sign up to get personalized eco tips based on your activities!',
              impactDescription: 'Track your environmental impact and earn rewards.',
            );
            _activeChallenges = [];
            _isLoading = false;
          });
        }
        return;
      }

      // Load all data in parallel for authenticated users
      final results = await Future.wait([
        DashboardService.getUserProfile(),
        ActivityService.getSummary(days: 1),
        ActivityService.getTodayActivities(),
        ActivityService.getDailyTip(),
        DashboardService.getActiveChallenges(),
      ]);

      if (mounted) {
        setState(() {
          _isGuestMode = false;
          _userProfile = results[0] as UserDashboard;
          _activitySummary = results[1] as ActivitySummary;
          _recentActivities = results[2] as List<Activity>;
          _dailyTip = results[3] as Tip?;
          _activeChallenges = results[4] as List<Challenge>;
          _isLoading = false;
        });
      }
    } on DashboardException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } on ActivityException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load dashboard: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text('Loading dashboard...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 64),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700], fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
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

    final userName = _userProfile?.displayName ?? 'User';
    final todayPoints = _activitySummary?.totalPoints ?? 0; // Today's points, not cumulative
    final streak = _userProfile?.currentStreak ?? 0;
    final totalCo2Saved = _activitySummary?.totalCo2Saved ?? 0.0;
    final totalActivities = _activitySummary?.totalActivities ?? 0;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([_loadDashboardData(), _loadPrediction()]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guest Mode Banner
            if (_isGuestMode)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.orange.shade900.withValues(alpha: 0.3)
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.orange.shade700 
                        : Colors.orange.shade200
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.explore, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Exploring as Guest - Sign up to track your impact!',
                        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.orange.shade300 
                            : Colors.orange.shade800),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ),
            // Greeting with dynamic time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()}, $userName! 👋',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Let\'s make today eco-friendly',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Daily Eco Score Summary Card
            EcoScoreCard(
              score: todayPoints,
              predictedScore: _predictionData != null
                  ? (_predictionData!['predicted_score'] as num).toDouble()
                  : null,
              scoreCategory: _predictionData?['score_category'] as String?,
              isPredictionLoading: _isPredictionLoading && !_isGuestMode,
              hasLoggedToday: _hasLoggedToday,
            ),
            const SizedBox(height: 16),

            // Progress to Goal Card
            _buildGoalProgressCard(),
            const SizedBox(height: 16),

            // Quick Stats Grid
            Text(
              'Today\'s Stats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: QuickStatsCard(
                  icon: Icons.checklist,
                  label: 'Activities',
                  value: '$totalActivities',
                  color: Colors.blue,
                )),
                const SizedBox(width: 12),
                Expanded(child: QuickStatsCard(
                  icon: Icons.co2,
                  label: 'CO₂ Saved',
                  value: UnitConverter.formatWeight(totalCo2Saved, isMetric: ref.watch(unitsProvider) == 'metric'),
                  color: Colors.green,
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: QuickStatsCard(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '$streak days',
                  color: Colors.orange,
                )),
                const SizedBox(width: 12),
                Expanded(child: QuickStatsCard(
                  icon: Icons.eco,
                  label: 'Trees Equiv.',
                  value: _calculateTreesEquivalent(totalCo2Saved),
                  color: Colors.teal,
                )),
              ],
            ),
            const SizedBox(height: 20),

            // Daily Tip
            if (_dailyTip != null)
              DailyTipCard(tip: _dailyTip!.content)
            else
              const DailyTipCard(
                tip: 'Try taking public transport today instead of driving. You could save up to 2.5 kg of CO₂!',
              ),
            const SizedBox(height: 16),

            // Weekly Challenge Card
            if (_activeChallenges.isNotEmpty)
              _buildChallengeCard(_activeChallenges.first),
            const SizedBox(height: 20),

            // Recent Activity Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/all-activities');
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_recentActivities.isEmpty)
              Card(
                elevation: 0,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFF252525) 
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No activities logged today',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start logging your eco-friendly activities!',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ..._recentActivities.take(4).map((activity) => _buildRecentActivity(
                context,
                _getActivityIcon(activity.categoryName),
                activity.activityTypeName,
                '${activity.co2Impact >= 0 ? '+' : ''}${UnitConverter.formatWeight(activity.co2Impact.abs(), isMetric: ref.watch(unitsProvider) == 'metric')} CO₂',
                _formatTimeAgo(activity.createdAt),
                _getCategoryColor(activity.categoryName),
              )),
            const SizedBox(height: 16),

            // Quick Actions Section
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context,
                    Icons.add_circle,
                    'Log Activity',
                    Colors.green,
                    () => _logActivity(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    Icons.directions_car,
                    'Track Trip',
                    Colors.blue,
                    () => _trackTrip(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    Icons.restaurant,
                    'Log Meal',
                    Colors.orange,
                    () => _logMeal(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _loadPrediction() async {
    if (_isGuestMode) return;
    if (mounted) setState(() => _isPredictionLoading = true);
    try {
      final prediction = await EcoProfileService.getPrediction();
      if (mounted) {
        setState(() {
          _predictionData = prediction;
          _isPredictionLoading = false;
          final sources = prediction?['data_sources'];
          _hasLoggedToday = sources?['daily_log'] == true ||
              sources?['activities_today'] == true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isPredictionLoading = false);
    }
  }

  String _calculateTreesEquivalent(double co2Saved) {
    // A tree absorbs about 21 kg of CO2 per year, or ~0.06 kg per day
    final trees = co2Saved / 21;
    return trees.toStringAsFixed(1);
  }

  Widget _buildGoalProgressCard() {
    // Calculate progress based on today's activity
    final totalCo2Saved = _activitySummary?.totalCo2Saved ?? 0.0;
    final dailyGoal = 5.0; // kg CO2 saved target
    final progress = (totalCo2Saved / dailyGoal).clamp(0.0, 1.0);
    final remaining = (dailyGoal - totalCo2Saved).clamp(0.0, dailyGoal);

    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF252525) 
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🎯 Daily Goal Progress',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              progress >= 1.0
                  ? '🎉 Daily goal achieved! Great job!'
                  : 'Save ${UnitConverter.formatWeight(remaining, isMetric: ref.watch(unitsProvider) == 'metric')} more CO₂ to reach your daily goal!',
              style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final progress = (challenge.userProgress ?? 0) / challenge.targetValue;

    return Card(
      elevation: 2,
      color: Colors.purple[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.purple.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('🏆', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color.fromARGB(255, 0, 0, 0)
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.description,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: Colors.purple[100],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[400]!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(challenge.userProgress ?? 0).toInt()}/${challenge.targetValue.toInt()} ${challenge.targetUnit}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return Icons.directions_car;
      case 'food':
        return Icons.restaurant;
      case 'energy':
        return Icons.bolt;
      case 'shopping':
        return Icons.shopping_bag;
      case 'home':
        return Icons.home;
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
      case 'shopping':
        return Colors.purple;
      case 'home':
        return Colors.teal;
      default:
        return Colors.green;
    }
  }

  String _formatTimeAgo(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hours ago';
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays} days ago';
    } catch (e) {
      return dateTimeStr;
    }
  }
  Widget _buildRecentActivity(BuildContext context, IconData icon, String title, String impact, String time, Color color) {
    final isPositive = impact.contains('+') || !impact.contains('-');
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
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isPositive ? Colors.orange[50] : Colors.green[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            impact,
            style: TextStyle(
              color: isPositive ? Colors.orange : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _logActivity() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Log Activity feature coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _trackTrip() {
    // Navigate to travel insights page
    DefaultTabController.of(context).animateTo(2);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Travel Insights'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _logMeal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Meal'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose a meal type:'),
            SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Log Meal'),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF252525) 
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
