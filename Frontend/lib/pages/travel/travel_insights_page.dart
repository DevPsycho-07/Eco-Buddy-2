import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/units_provider.dart';
import '../../core/utils/unit_converter.dart';
import '../../services/travel_service.dart';

class TravelInsightsPage extends ConsumerStatefulWidget {
  const TravelInsightsPage({super.key});

  @override
  ConsumerState<TravelInsightsPage> createState() => _TravelInsightsPageState();
}

class _TravelInsightsPageState extends ConsumerState<TravelInsightsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _gpsEnabled = true;
  String _selectedPeriod = 'Today';
  
  // Loading state and data
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _todayTrips = [];
  Map<String, dynamic> _travelStats = {};
  List<Map<String, dynamic>> _transportModes = [];

  // Trip form state
  late TextEditingController _fromController;
  late TextEditingController _toController;
  late TextEditingController _distanceController;
  String _selectedTransportMode = 'Walking';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fromController = TextEditingController();
    _toController = TextEditingController();
    _distanceController = TextEditingController();
    _loadTravelData();
  }

  Future<void> _loadTravelData() async {
    try {
      // Load today's trips and travel stats in parallel with timeout
      final tripsResult = await Future.wait([
        TravelService.getTodayTrips().timeout(
          const Duration(seconds: 5),
          onTimeout: () => [],
        ),
        TravelService.getTravelStats(days: 7).timeout(
          const Duration(seconds: 5),
          onTimeout: () => {},
        ),
      ]);

      final todayTrips = tripsResult[0] as List<Map<String, dynamic>>;
      final stats = tripsResult[1] as Map<String, dynamic>;

      setState(() {
        _todayTrips = todayTrips;
        _travelStats = stats;
        _transportModes = _buildTransportModesList(stats);
        _isLoading = false;
        _errorMessage = null;
      });
      // Travel data loaded successfully
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection timeout. Using offline mode. Tap retry to fetch fresh data.';
        _isLoading = false;
        // Keep existing data, show empty state with retry option
        _todayTrips = [];
        _travelStats = {};
        _transportModes = [];
      });
      // Failed to load travel data
    }
  }

  List<Map<String, dynamic>> _buildTransportModesList(Map<String, dynamic> stats) {
    final byMode = (stats['by_mode'] as Map<String, dynamic>?) ?? {};
    final modes = <String, Map<String, dynamic>>{
      'Walking': {'icon': '🚶', 'color': Colors.green},
      'Cycling': {'icon': '🚴', 'color': Colors.teal},
      'Bus': {'icon': '🚌', 'color': Colors.blue},
      'Train': {'icon': '🚆', 'color': Colors.indigo},
      'Car': {'icon': '🚗', 'color': Colors.orange},
      'Flight': {'icon': '✈️', 'color': Colors.red},
    };

    final result = <Map<String, dynamic>>[];
    modes.forEach((mode, config) {
      final modeData = byMode[mode] ?? {};
      result.add({
        'mode': mode,
        'icon': config['icon'],
        'distance': ((modeData['distance_km'] as num?) ?? 0.0).toDouble(),
        'co2': ((modeData['co2_emitted'] as num?) ?? 0.0).toDouble(),
        'color': config['color'],
        'trips': (modeData['trips'] as int?) ?? 0,
      });
    });

    return result;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Insights'),
        actions: [
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
    if (_errorMessage != null && _todayTrips.isEmpty && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.signal_cellular_null, size: 64, color: Colors.orange[400]),
              const SizedBox(height: 16),
              const Text(
                'Connection Issue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadTravelData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
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
                        selectedColor: Colors.green,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.grey[700],
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (v) => setState(() => _selectedPeriod = period),
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
                      value: UnitConverter.formatDistance(
                        ((_travelStats['total_distance'] as num?) ?? 0.0).toDouble(),
                        isMetric: ref.watch(unitsProvider) == 'metric',
                      ),
                      label: 'Distance',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.cloud_off,
                      value: UnitConverter.formatWeight(
                        ((_travelStats['total_co2_saved'] as num?) ?? 0.0).toDouble(),
                        isMetric: ref.watch(unitsProvider) == 'metric',
                      ),
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
                      value: UnitConverter.formatWeight(
                        ((_travelStats['total_co2_emitted'] as num?) ?? 0.0).toDouble(),
                        isMetric: ref.watch(unitsProvider) == 'metric',
                      ),
                      label: 'CO₂ Emitted',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.route,
                      value: '${_travelStats['total_trips'] ?? 0}',
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
                  TextButton(
                    onPressed: _showAllTransportModes,
                    child: const Text('See All'),
                  ),
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
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '92/100',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Loading overlay
        if (_isLoading)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Loading...',
                    style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTripsTab() {
    if (_todayTrips.isEmpty && _errorMessage != null && !_isLoading) {
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
                child: Icon(Icons.directions_walk, size: 64, color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),
              const Text(
                'Unable to Load Trips',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Connection error',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadTravelData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_todayTrips.isEmpty && !_isLoading) {
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
                child: Icon(Icons.directions_walk, size: 64, color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Trips Recorded',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Log your first eco-friendly trip!',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showAddTripDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Trip'),
              ),
            ],
          ),
        ),
      );
    }

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
      ],
    );
  }

  Widget _buildAnalysisTab() {
    // Calculate transport distribution percentages
    final totalTrips = (_travelStats['total_trips'] as int?) ?? 0;
    final transportDistribution = <String, double>{};
    
    if (totalTrips > 0) {
      for (final mode in _transportModes) {
        if ((mode['trips'] as int) > 0) {
          transportDistribution[mode['mode']] = (mode['trips'] as int) / totalTrips;
        }
      }
    }
    
    // Calculate total CO₂ emitted and saved
    final totalCO2Emitted = ((_travelStats['total_co2_emitted'] as num?) ?? 0.0).toDouble();
    final totalCO2Saved = ((_travelStats['total_co2_saved'] as num?) ?? 0.0).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly CO₂ Impact
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
                        _buildDayBar('Mon', totalCO2Emitted * 0.12, totalCO2Saved * 0.15),
                        _buildDayBar('Tue', totalCO2Emitted * 0.08, totalCO2Saved * 0.22),
                        _buildDayBar('Wed', totalCO2Emitted * 0.15, totalCO2Saved * 0.12),
                        _buildDayBar('Thu', totalCO2Emitted * 0.05, totalCO2Saved * 0.28),
                        _buildDayBar('Fri', totalCO2Emitted * 0.10, totalCO2Saved * 0.18),
                        _buildDayBar('Sat', totalCO2Emitted * 0.03, totalCO2Saved * 0.32),
                        _buildDayBar('Sun', totalCO2Emitted * 0.02, totalCO2Saved * 0.12),
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
                  if (transportDistribution.isEmpty)
                    Text(
                      'No transport data available',
                      style: TextStyle(color: Colors.grey[600]),
                    )
                  else
                    ...transportDistribution.entries.map((entry) =>
                        _buildDistributionBar(entry.key, entry.value, Colors.blue[400]!)),
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
            Icons.trending_down,
            Colors.green,
            'Eco Friendly Travel',
            totalCO2Saved > 0
                ? 'You saved ${UnitConverter.formatWeight(totalCO2Saved, isMetric: ref.watch(unitsProvider) == 'metric')} of CO₂ this week!'
                : 'Start logging trips to track your CO₂ savings!',
          ),
          _buildInsightCard(
            Icons.directions_walk,
            Colors.teal,
            'Top Transport Mode',
            _transportModes.isNotEmpty && (_transportModes.first['trips'] as int) > 0
                ? '${_transportModes.first['mode']} is your most used mode (${_transportModes.first['trips']} trips)'
                : 'Log your trips to see your favorite transport mode!',
          ),
          _buildInsightCard(
            Icons.lightbulb,
            Colors.amber,
            'Improvement Suggestion',
            totalTrips > 0
                ? 'Switch more trips to walking or cycling to increase your eco score!'
                : 'Start tracking your trips to get personalized suggestions!',
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
                        'Your CO₂ Performance',
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
                              'CO₂ Emitted',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              UnitConverter.formatWeight(totalCO2Emitted, isMetric: ref.watch(unitsProvider) == 'metric'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
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
                              'CO₂ Saved',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              UnitConverter.formatWeight(totalCO2Saved, isMetric: ref.watch(unitsProvider) == 'metric'),
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: totalCO2Saved > totalCO2Emitted ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      totalCO2Saved > totalCO2Emitted
                          ? '🌟 Saving more than emitting!'
                          : '📈 Keep improving! Aim to save more.',
                      style: const TextStyle(
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
                      '${mode['trips']} trip(s) • ${UnitConverter.formatDistance(mode['distance'], isMetric: ref.watch(unitsProvider) == 'metric')}',
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

  void _showAllTransportModes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
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
                    'All Transport Modes',
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _transportModes.length,
                itemBuilder: (context, index) => _buildTransportModeCard(_transportModes[index]),
              ),
            ),
          ],
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
                      '${trip['time']} • ${trip['mode']} • ${UnitConverter.formatDistance(trip['distance'], isMetric: ref.watch(unitsProvider) == 'metric')} • ${trip['duration']}',
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
                      '+${UnitConverter.formatWeight(trip['co2'], isMetric: ref.watch(unitsProvider) == 'metric')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 13,
                      ),
                    ),
                  if (trip['co2'] == 0.0 && trip['co2Saved'] == 0.0)
                    Text(
                      UnitConverter.formatWeight(0, isMetric: ref.watch(unitsProvider) == 'metric'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  void _showAddTripDialog() {
    // Reset form
    _fromController.clear();
    _toController.clear();
    _distanceController.clear();
    _selectedTransportMode = 'Walking';

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
        child: StatefulBuilder(
          builder: (context, setModalState) => Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Log Trip Manually',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _fromController,
                    decoration: const InputDecoration(
                      labelText: 'From',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _toController,
                    decoration: const InputDecoration(
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
                      final isSelected = _selectedTransportMode == mode['mode'];
                      return ChoiceChip(
                        label: Text('${mode['icon']} ${mode['mode']}'),
                        selected: isSelected,
                        onSelected: (v) {
                          setModalState(() {
                            _selectedTransportMode = mode['mode'];
                          });
                        },
                        selectedColor: Colors.green,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _distanceController,
                    decoration: InputDecoration(
                      labelText: 'Distance (${UnitConverter.getDistanceUnit(ref.watch(unitsProvider) == 'metric')})',
                      prefixIcon: const Icon(Icons.straighten),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveTrip(context),
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
        ),
      ),
    );
  }

  Future<void> _saveTrip(BuildContext context) async {
    // Validate inputs
    if (_fromController.text.isEmpty || _toController.text.isEmpty || _distanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final distance = double.parse(_distanceController.text);
      
      // Create trip data
      final tripData = {
        'from': _fromController.text,
        'to': _toController.text,
        'mode': _selectedTransportMode,
        'distance_km': distance,
      };

      // Call API to create trip
      await TravelService.createTrip(tripData);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip logged successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload travel data to reflect new trip
        _loadTravelData();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            _buildDetailRow('Distance', UnitConverter.formatDistance(trip['distance'], isMetric: ref.watch(unitsProvider) == 'metric')),
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
            _buildDetailRow('Total Distance', UnitConverter.formatDistance(mode['distance'], isMetric: ref.watch(unitsProvider) == 'metric')),
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
