import 'package:flutter/material.dart';

class TravelInsightsPage extends StatefulWidget {
  const TravelInsightsPage({super.key});

  @override
  State<TravelInsightsPage> createState() => _TravelInsightsPageState();
}

class _TravelInsightsPageState extends State<TravelInsightsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _gpsEnabled = true;
  String _selectedPeriod = 'Today';

  final List<Map<String, dynamic>> _todayTrips = [
    {
      'from': 'Home',
      'to': 'Office',
      'time': '08:30 AM',
      'mode': 'Bus',
      'modeIcon': '🚌',
      'distance': 8.5,
      'duration': '25 min',
      'co2': 0.42,
      'co2Saved': 1.28,
      'autoDetected': true,
    },
    {
      'from': 'Office',
      'to': 'Lunch Spot',
      'time': '12:15 PM',
      'mode': 'Walking',
      'modeIcon': '🚶',
      'distance': 0.5,
      'duration': '8 min',
      'co2': 0.0,
      'co2Saved': 0.1,
      'autoDetected': true,
    },
    {
      'from': 'Lunch Spot',
      'to': 'Office',
      'time': '01:00 PM',
      'mode': 'Walking',
      'modeIcon': '🚶',
      'distance': 0.5,
      'duration': '8 min',
      'co2': 0.0,
      'co2Saved': 0.1,
      'autoDetected': true,
    },
    {
      'from': 'Office',
      'to': 'Grocery Store',
      'time': '05:45 PM',
      'mode': 'Cycling',
      'modeIcon': '🚴',
      'distance': 2.3,
      'duration': '12 min',
      'co2': 0.0,
      'co2Saved': 0.46,
      'autoDetected': false,
    },
  ];

  final List<Map<String, dynamic>> _transportModes = [
    {
      'mode': 'Walking',
      'icon': '🚶',
      'distance': 2.3,
      'co2': 0.0,
      'color': Colors.green,
      'trips': 3,
    },
    {
      'mode': 'Cycling',
      'icon': '🚴',
      'distance': 4.5,
      'co2': 0.0,
      'color': Colors.teal,
      'trips': 2,
    },
    {
      'mode': 'Bus',
      'icon': '🚌',
      'distance': 8.5,
      'co2': 0.42,
      'color': Colors.blue,
      'trips': 1,
    },
    {
      'mode': 'Train',
      'icon': '🚆',
      'distance': 0.0,
      'co2': 0.0,
      'color': Colors.indigo,
      'trips': 0,
    },
    {
      'mode': 'Car',
      'icon': '🚗',
      'distance': 0.0,
      'co2': 0.0,
      'color': Colors.orange,
      'trips': 0,
    },
    {
      'mode': 'Flight',
      'icon': '✈️',
      'distance': 0.0,
      'co2': 0.0,
      'color': Colors.red,
      'trips': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Travel Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showDatePicker(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTripDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Trips'),
            Tab(text: 'Analysis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(), _buildTripsTab(), _buildAnalysisTab()],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GPS Tracking Status
          Card(
            elevation: 0,
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF252525) 
                : (_gpsEnabled ? Colors.green[50] : Colors.orange[50]),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _gpsEnabled ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _gpsEnabled ? Icons.gps_fixed : Icons.gps_off,
                  color: _gpsEnabled ? Colors.green : Colors.orange,
                ),
              ),
              title: Text(
                _gpsEnabled ? 'Auto-Detection Active' : 'Manual Mode',
              ),
              subtitle: Text(
                _gpsEnabled
                    ? 'Automatically detecting travel modes'
                    : 'Tap + to log trips manually',
              ),
              trailing: Switch(
                value: _gpsEnabled,
                onChanged: (value) => setState(() => _gpsEnabled = value),
                activeThumbColor: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Period Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Today', 'This Week', 'This Month', 'All Time'].map((
                period,
              ) {
                final selected = _selectedPeriod == period;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(period),
                    selected: selected,
                    onSelected: (value) =>
                        setState(() => _selectedPeriod = period),
                    selectedColor: Colors.green[100],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.straighten,
                  value: '15.3 km',
                  label: 'Distance',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.cloud_off,
                  value: '1.94 kg',
                  label: 'CO₂ Saved',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.cloud,
                  value: '0.42 kg',
                  label: 'CO₂ Emitted',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.route,
                  value: '6',
                  label: 'Trips',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Transport Mode Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transport Modes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
          const SizedBox(height: 12),
          ..._transportModes
              .where((m) => m['trips'] > 0)
              .map((mode) => _buildTransportModeCard(mode)),
          const SizedBox(height: 20),

          // Eco Score Impact
          Card(
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.eco, color: Colors.green),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Travel Eco Score',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Based on your transport choices',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '85/100',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.85,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '🌟 Great job! 82% of your trips were eco-friendly this week!',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: true,
                onSelected: (v) {},
                selectedColor: Colors.green[100],
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('🚶 Walking'),
                selected: false,
                onSelected: (v) {},
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('🚴 Cycling'),
                selected: false,
                onSelected: (v) {},
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('🚌 Transit'),
                selected: false,
                onSelected: (v) {},
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('🚗 Car'),
                selected: false,
                onSelected: (v) {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Today's Trips
        const Text(
          'Today',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ..._todayTrips.map((trip) => _buildTripCard(trip)),
        const SizedBox(height: 20),

        // Yesterday
        const Text(
          'Yesterday',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        _buildTripCard({
          'from': 'Home',
          'to': 'Gym',
          'time': '06:30 AM',
          'mode': 'Cycling',
          'modeIcon': '🚴',
          'distance': 3.2,
          'duration': '15 min',
          'co2': 0.0,
          'co2Saved': 0.64,
          'autoDetected': true,
        }),
        _buildTripCard({
          'from': 'Gym',
          'to': 'Home',
          'time': '07:45 AM',
          'mode': 'Cycling',
          'modeIcon': '🚴',
          'distance': 3.2,
          'duration': '15 min',
          'co2': 0.0,
          'co2Saved': 0.64,
          'autoDetected': true,
        }),
      ],
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Trend Chart Placeholder
          Card(
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
                  const Text(
                    'Weekly CO₂ Impact',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDayBar('Mon', 0.8, 1.2),
                        _buildDayBar('Tue', 0.5, 1.8),
                        _buildDayBar('Wed', 1.2, 0.9),
                        _buildDayBar('Thu', 0.3, 2.1),
                        _buildDayBar('Fri', 0.6, 1.5),
                        _buildDayBar('Sat', 0.2, 2.5),
                        _buildDayBar('Sun', 0.1, 1.0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend(Colors.orange, 'Emitted'),
                      const SizedBox(width: 24),
                      _buildLegend(Colors.green, 'Saved'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Transport Distribution
          Card(
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
                  const Text(
                    'Transport Distribution',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildDistributionBar('Walking', 0.35, Colors.green),
                  _buildDistributionBar('Cycling', 0.30, Colors.teal),
                  _buildDistributionBar('Public Transit', 0.25, Colors.blue),
                  _buildDistributionBar('Car', 0.08, Colors.orange),
                  _buildDistributionBar('Other', 0.02, Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Insights
          const Text(
            'Insights',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            Icons.trending_up,
            Colors.green,
            'Cycling Increased',
            'You cycled 45% more this week compared to last week!',
          ),
          _buildInsightCard(
            Icons.timer,
            Colors.blue,
            'Peak Travel Time',
            'Most of your trips are between 8-9 AM. Consider cycling!',
          ),
          _buildInsightCard(
            Icons.lightbulb,
            Colors.amber,
            'Suggestion',
            'Your office commute could save 1.2 kg CO₂/week if you bike.',
          ),
          const SizedBox(height: 20),

          // Comparison Card
          Card(
            elevation: 0,
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF252525) 
                : Colors.green[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.compare_arrows, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'You vs Average User',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Your CO₂',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '3.2 kg',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                            const Text('/week', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 60, color: Colors.green[200]),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Average',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '8.5 kg',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Text('/week', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '62% below average! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
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
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportModeCard(Map<String, dynamic> mode) {
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF252525) 
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _showTransportDetail(mode),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (mode['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    mode['icon'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode['mode'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${mode['trips']} trip(s) • ${mode['distance']} km',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${mode['co2']} kg',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: mode['co2'] == 0.0 ? Colors.green : Colors.orange,
                    ),
                  ),
                  Text(
                    mode['co2'] == 0.0 ? 'Zero emission' : 'CO₂',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF252525) 
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _showTripDetail(trip),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    trip['modeIcon'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${trip['from']} → ${trip['to']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (trip['autoDetected'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Auto',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${trip['time']} • ${trip['mode']} • ${trip['distance']} km • ${trip['duration']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (trip['co2Saved'] > 0)
                    Text(
                      '-${trip['co2Saved']} kg',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 13,
                      ),
                    ),
                  if (trip['co2'] > 0)
                    Text(
                      '+${trip['co2']} kg',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 13,
                      ),
                    ),
                  if (trip['co2'] == 0.0 && trip['co2Saved'] == 0.0)
                    const Text(
                      '0 kg',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayBar(String day, double emitted, double saved) {
    final maxValue = 3.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: (saved / maxValue) * 80,
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        Container(
          width: 20,
          height: (emitted / maxValue) * 80,
          decoration: const BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDistributionBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text(
                '${(value * 100).toInt()}%',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    IconData icon,
    Color color,
    String title,
    String description,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF252525) 
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
  }

  void _showAddTripDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Log Trip Manually',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'From',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'To',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Transport Mode',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _transportModes.map((mode) {
                  return ChoiceChip(
                    label: Text('${mode['icon']} ${mode['mode']}'),
                    selected: false,
                    onSelected: (v) {},
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Distance (km)',
                  prefixIcon: Icon(Icons.straighten),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Trip logged successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Save Trip'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTripDetail(Map<String, dynamic> trip) {
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
            Text(
              '${trip['modeIcon']} ${trip['mode']} Trip',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Route', '${trip['from']} → ${trip['to']}'),
            _buildDetailRow('Time', trip['time']),
            _buildDetailRow('Distance', '${trip['distance']} km'),
            _buildDetailRow('Duration', trip['duration']),
            _buildDetailRow('CO₂ Emitted', '${trip['co2']} kg'),
            _buildDetailRow('CO₂ Saved', '${trip['co2Saved']} kg'),
            _buildDetailRow(
              'Detection',
              trip['autoDetected'] ? 'Automatic' : 'Manual',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Trip deleted')),
                      );
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showTransportDetail(Map<String, dynamic> mode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(mode['icon'], style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Text(mode['mode']),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Total Distance', '${mode['distance']} km'),
            _buildDetailRow('Total Trips', '${mode['trips']}'),
            _buildDetailRow('Total CO₂', '${mode['co2']} kg'),
            const Divider(),
            Text(
              mode['co2'] == 0.0
                  ? '🌱 Great choice! Zero emissions!'
                  : 'Consider eco-friendly alternatives',
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
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
}
