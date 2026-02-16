import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _globalLeaders = [
    {'rank': 1, 'name': 'EcoWarrior', 'score': 98, 'saved': '450 kg', 'avatar': '🌿', 'streak': 45},
    {'rank': 2, 'name': 'GreenHero', 'score': 95, 'saved': '420 kg', 'avatar': '🌱', 'streak': 38},
    {'rank': 3, 'name': 'NatureLover', 'score': 92, 'saved': '390 kg', 'avatar': '🍃', 'streak': 32},
    {'rank': 4, 'name': 'TreeHugger', 'score': 89, 'saved': '365 kg', 'avatar': '🌳', 'streak': 28},
    {'rank': 5, 'name': 'EarthSaver', 'score': 87, 'saved': '340 kg', 'avatar': '🌍', 'streak': 25},
    {'rank': 6, 'name': 'ClimateChamp', 'score': 85, 'saved': '320 kg', 'avatar': '☀️', 'streak': 22},
    {'rank': 7, 'name': 'EcoNinja', 'score': 83, 'saved': '300 kg', 'avatar': '🥷', 'streak': 20},
    {'rank': 8, 'name': 'GreenGuru', 'score': 80, 'saved': '280 kg', 'avatar': '🧘', 'streak': 18},
    {'rank': 156, 'name': 'You', 'score': 72, 'saved': '145 kg', 'avatar': '👤', 'isUser': true, 'streak': 15},
  ];

  final List<Map<String, dynamic>> _challenges = [
    {'title': 'Car-Free Week', 'participants': 1245, 'ends': '3 days', 'prize': '🏆 Gold Badge', 'joined': true},
    {'title': 'Zero Waste Weekend', 'participants': 892, 'ends': '5 days', 'prize': '♻️ Recycler Pro', 'joined': false},
    {'title': 'Plant-Based February', 'participants': 3421, 'ends': '25 days', 'prize': '🌱 Vegan Master', 'joined': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                    // 2nd Place
                    _buildPodiumItem(_globalLeaders[1], 2, 80),
                    const SizedBox(width: 8),
                    // 1st Place
                    _buildPodiumItem(_globalLeaders[0], 1, 100),
                    const SizedBox(width: 8),
                    // 3rd Place
                    _buildPodiumItem(_globalLeaders[2], 3, 60),
                  ],
                ),
              ],
            ),
          ),
        ),
        // User Position Card
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 0,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF252525) 
                  : Colors.green[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Text('👤', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Position',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Rank #156 • Score: 72',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.green),
                        Text(
                          '+12',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Leaderboard List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= _globalLeaders.length - 1) return null; // Skip user entry shown separately
              final leader = _globalLeaders[index];
              if (leader['rank'] <= 3) return const SizedBox.shrink(); // Already in podium
              return _buildLeaderboardItem(leader);
            },
            childCount: _globalLeaders.length,
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> leader, int position, double height) {
    final colors = {1: Colors.amber, 2: Colors.grey[400], 3: Colors.brown[300]};
    final medals = {1: '🥇', 2: '🥈', 3: '🥉'};
    
    return Column(
      children: [
        Text(leader['avatar'], style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(
          leader['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          '${leader['score']} pts',
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
    final isUser = leader['isUser'] == true;
    
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF252525) 
          : (isUser ? Colors.green[50] : Colors.white),
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
                '#${leader['rank']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUser ? Colors.green : Colors.grey[600],
                ),
              ),
            ),
            CircleAvatar(
              backgroundColor: isUser ? Colors.green[100] : Colors.grey[200],
              child: Text(leader['avatar'], style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
        title: Text(
          leader['name'],
          style: TextStyle(
            fontWeight: isUser ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        subtitle: Row(
          children: [
            Text('Saved: ${leader['saved']}'),
            const SizedBox(width: 8),
            const Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
            Text(' ${leader['streak']}d', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isUser ? Colors.green : Colors.green[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${leader['score']}',
            style: TextStyle(
              color: isUser ? Colors.white : Colors.green[700],
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
              onPressed: () {},
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
              onPressed: () {},
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
              onPressed: () {},
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
            onPressed: () {},
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
              onPressed: () {},
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
                      onPressed: () {},
                      child: const Text('View Progress'),
                    )
                  : ElevatedButton(
                      onPressed: () {},
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
