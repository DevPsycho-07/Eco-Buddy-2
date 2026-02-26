import 'package:flutter/material.dart';
import '../../services/dashboard_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _globalLeaders = [];
  String? _errorMessage;
  String _selectedLocation = 'San Francisco, CA';
  late List<Map<String, dynamic>> _challenges;
  final List<String> _availableLocations = [
    'San Francisco, CA',
    'New York, NY',
    'Los Angeles, CA',
    'Chicago, IL',
    'Austin, TX',
    'Seattle, WA',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _challenges = [
      {'title': 'Car-Free Week', 'participants': 1245, 'ends': '3 days', 'prize': '🏆 Gold Badge', 'joined': true},
      {'title': 'Zero Waste Weekend', 'participants': 892, 'ends': '5 days', 'prize': '♻️ Recycler Pro', 'joined': false},
      {'title': 'Plant-Based February', 'participants': 3421, 'ends': '25 days', 'prize': '🌱 Vegan Master', 'joined': false},
    ];
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final leaderboard = await DashboardService.getLeaderboard(limit: 50);
      setState(() {
        _globalLeaders = leaderboard;
        _isLoading = false;
      });
      // Leaderboard loaded successfully
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load leaderboard: $e';
        _isLoading = false;
      });
      // Failed to load leaderboard
    }
  }

  void _changeLocation() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Your Location',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _availableLocations.length,
              itemBuilder: (context, index) {
                final location = _availableLocations[index];
                return ListTile(
                  leading: location == _selectedLocation
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.circle_outlined),
                  title: Text(location),
                  onTap: () {
                    setState(() => _selectedLocation = location);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Location changed to $location')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAllChallenges() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Challenges',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _challenges.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildChallengeCard(_challenges[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _joinChallenge(int index) {
    setState(() {
      _challenges[index]['joined'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joined "${_challenges[index]['title']}" challenge!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewChallengeProgress(int index) {
    final challenge = _challenges[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(challenge['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Challenge Progress', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Status: Participating'),
            Text('Participants: ${challenge['participants']}'),
            Text('Time Remaining: ${challenge['ends']}'),
            Text('Prize: ${challenge['prize']}'),
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              value: 0.65,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            const Text('Progress: 65%', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Friends'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share your eco journey with friends! Your invite code:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'ECO-2024-ABCD',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(Icons.copy, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Friends who join using your code get 100 bonus EcoPoints!',
              style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invite code copied to clipboard!')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy Code'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite via QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Scan this QR code to join our eco community!'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share this QR code with your friends',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR code shared!')),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  void _viewFullLocalLeaderboard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.3,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Local Leaderboard - $_selectedLocation',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _globalLeaders.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _buildLeaderboardItem(_globalLeaders[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showShareDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Friends'),
            Tab(text: 'Local'),
            Tab(text: 'Challenges'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGlobalTab(),
          _buildFriendsTab(),
          _buildLocalTab(),
          _buildChallengesTab(),
        ],
      ),
    );
  }

  Widget _buildGlobalTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
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
                  _loadLeaderboard();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_globalLeaders.isEmpty) {
      return center(
        child: const Text('No leaderboard data available'),
      );
    }

    final topThree = _globalLeaders.take(3).toList();
    final rest = _globalLeaders.skip(3).toList();

    return CustomScrollView(
      slivers: [
        // Top 3 Podium
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  '🏆 Top Eco Champions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (topThree.length > 1)
                      _buildPodiumItem(topThree[1], 2, 80)
                    else
                      const SizedBox(width: 70),
                    const SizedBox(width: 8),
                    if (topThree.isNotEmpty)
                      _buildPodiumItem(topThree[0], 1, 100),
                    const SizedBox(width: 8),
                    if (topThree.length > 2)
                      _buildPodiumItem(topThree[2], 3, 60)
                    else
                      const SizedBox(width: 70),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Leaderboard List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildLeaderboardItem(rest[index]),
            childCount: rest.length,
          ),
        ),
      ],
    );
  }

  Widget center({required Widget child}) {
    return Center(child: child);
  }

  Widget _buildPodiumItem(Map<String, dynamic> leader, int position, double height) {
    final colors = {1: Colors.amber, 2: Colors.grey[400], 3: Colors.brown[300]};
    final medals = {1: '🥇', 2: '🥈', 3: '🥉'};
    final username = leader['username'] ?? 'Unknown';
    final ecoScore = leader['eco_score'] ?? 0;
    final avatar = username.isNotEmpty ? username[0].toUpperCase() : '?';
    
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: colors[position]?.withValues(alpha: 0.3),
          child: Text(avatar, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(
          username,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$ecoScore pts',
          style: TextStyle(color: Colors.grey[600], fontSize: 11),
        ),
        const SizedBox(height: 8),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors[position]!, colors[position]!.withValues(alpha: 0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(medals[position]!, style: const TextStyle(fontSize: 24)),
              Text(
                '#$position',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> leader) {
    final username = leader['username'] ?? 'Unknown';
    final ecoScore = leader['eco_score'] ?? 0;
    final totalCo2Saved = leader['total_co2_saved'] ?? 0;
    final rank = leader['rank'] ?? 0;
    final avatar = username.isNotEmpty ? username[0].toUpperCase() : '?';
    
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF252525) 
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Text(avatar, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
        title: Text(
          username,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Row(
          children: [
            Text('Saved: ${totalCo2Saved.toStringAsFixed(1)} kg CO₂'),
            const SizedBox(width: 8),
            Text('Level ${leader['level'] ?? 1}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$ecoScore',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Center(
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
              child: Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Compete with Friends!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add friends to see how your eco score compares and motivate each other!',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showInviteDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Invite Friends'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showQRCode,
              icon: const Icon(Icons.qr_code),
              label: const Text('Share Invite Code'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Location Info Card
        Card(
          color: Colors.blue[50],
          child: ListTile(
            leading: const Icon(Icons.location_on, color: Colors.blue),
            title: const Text('San Francisco, CA'),
            subtitle: const Text('Your local community'),
            trailing: TextButton(
              onPressed: _changeLocation,
              child: const Text('Change'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Top in Your Area',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ..._globalLeaders.take(5).map((leader) => _buildLeaderboardItem(leader)),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: _viewFullLocalLeaderboard,
            child: const Text('View Full Local Leaderboard'),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Active Challenges Header
        Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            const Text(
              'Active Challenges',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Spacer(),
            TextButton(
              onPressed: _showAllChallenges,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._challenges.map((challenge) => _buildChallengeCard(challenge)),
        const SizedBox(height: 24),

        // Past Winners
        const Text(
          '🏆 Recent Winners',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Text('🥇'),
            ),
            title: Text('EcoWarrior'),
            subtitle: Text('Won "Zero Waste Week" challenge'),
            trailing: Text('Jan 1', style: TextStyle(color: Colors.grey)),
          ),
        ),
        const Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Text('🥇'),
            ),
            title: Text('GreenHero'),
            subtitle: Text('Won "Plant More Trees" challenge'),
            trailing: Text('Dec 25', style: TextStyle(color: Colors.grey)),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    final joined = challenge['joined'] as bool;
    final index = _challenges.indexOf(challenge);
    
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    challenge['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (joined)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Joined',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${challenge['participants']} participants',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Ends in ${challenge['ends']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.emoji_events, size: 16, color: Colors.amber[700]),
                const SizedBox(width: 4),
                Text(
                  'Prize: ${challenge['prize']}',
                  style: TextStyle(color: Colors.amber[800], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: joined
                  ? OutlinedButton(
                      onPressed: () => _viewChallengeProgress(index),
                      child: const Text('View Progress'),
                    )
                  : ElevatedButton(
                      onPressed: () => _joinChallenge(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Join Challenge'),
                    ),
            ),
          ],
        ),
      ),
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
              'Share Your Rank',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Show off your #156 rank and inspire others!',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.message, 'Message', Colors.green),
                _buildShareOption(Icons.mail, 'Email', Colors.red),
                _buildShareOption(Icons.link, 'Link', Colors.blue),
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
}
