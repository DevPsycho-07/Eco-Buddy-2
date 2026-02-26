import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/analytics_service.dart';
import '../../services/guest_service.dart';
import '../../services/eco_profile_service.dart';
import '../../core/providers/units_provider.dart';
import '../../core/utils/unit_converter.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  String _selectedPeriod = 'Week';
  int _selectedChartType = 0; // 0 = bar, 1 = line

  // Loading and error states
  bool _isLoadingStats = true;
  bool _isLoadingComparison = true;
  String? _statsError;
  String? _comparisonError;
  bool _isGuestMode = false;
  Map<String, dynamic>? _predictionData;
  bool _isPredictionLoading = false;

  // Data from backend
  AnalyticsStats? _analyticsStats;
  ComparisonData? _comparisonData;

  // Map UI period names to backend period names
  final Map<String, String> _periodMapping = {
    'Day': 'day',
    'Week': 'week',
    'Month': 'month',
    'Year': 'year',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Check if in guest mode first
    final isGuest = await GuestService.isGuestSession();
    
    if (isGuest) {
      // Show analytics UI with zero stats for guest exploration
      if (mounted) {
        setState(() {
          _isGuestMode = true;
          _isLoadingStats = false;
          _isLoadingComparison = false;
          _analyticsStats = AnalyticsStats(
            period: 'week',
            startDate: DateTime.now().subtract(const Duration(days: 7)).toIso8601String().split('T')[0],
            endDate: DateTime.now().toIso8601String().split('T')[0],
            totalCo2Saved: 0,
            totalCo2Emitted: 0,
            netImpact: 0,
            totalActivities: 0,
            categories: [],
            trend: [],
          );
          _comparisonData = ComparisonData(
            userEcoScore: 0,
            userCo2Saved: 0,
            avgEcoScore: 45,
            avgCo2Saved: 8.5,
            percentile: 0,
            scoreDiff: -45,
            co2Diff: -8.5,
          );
        });
      }
      return;
    }

    await Future.wait([
      _loadStats(),
      _loadComparison(),
      _loadPrediction(),
    ]);
  }

  Future<void> _loadStats() async {
    if (_isGuestMode) return;
    
    setState(() {
      _isLoadingStats = true;
      _statsError = null;
    });

    try {
      final backendPeriod = _periodMapping[_selectedPeriod] ?? 'week';
      final stats = await AnalyticsService.getStats(backendPeriod);

      if (mounted) {
        setState(() {
          _analyticsStats = stats;
          _isLoadingStats = false;
        });
      }
    } on AnalyticsException catch (e) {
      if (mounted) {
        setState(() {
          _statsError = e.message;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statsError = 'Failed to load analytics: ${e.toString()}';
          _isLoadingStats = false;
        });
      }
    }
  }

  Future<void> _loadComparison() async {
    if (_isGuestMode) return;
    
    setState(() {
      _isLoadingComparison = true;
      _comparisonError = null;
    });

    try {
      final comparison = await AnalyticsService.getComparison();

      if (mounted) {
        setState(() {
          _comparisonData = comparison;
          _isLoadingComparison = false;
        });
      }
    } on AnalyticsException catch (e) {
      if (mounted) {
        setState(() {
          _comparisonError = e.message;
          _isLoadingComparison = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _comparisonError = 'Failed to load comparison: ${e.toString()}';
          _isLoadingComparison = false;
        });
      }
    }
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
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isPredictionLoading = false);
    }
  }

  void _onPeriodChanged(String period) {
    if (_selectedPeriod != period) {
      setState(() => _selectedPeriod = period);
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
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
                      ? Colors.blue.shade900.withValues(alpha: 0.3)
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.blue.shade700 
                        : Colors.blue.shade200
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.analytics_outlined, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sign up to track your real carbon footprint!',
                        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.blue.shade300 
                            : Colors.blue.shade800),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ),
            // Period Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Day', 'Week', 'Month', 'Year'].map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(period),
                      selected: isSelected,
                      selectedColor: Colors.green,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) _onPeriodChanged(period);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Main Stats Section
            if (_isLoadingStats)
              _buildLoadingCard('Loading analytics...')
            else if (_statsError != null)
              _buildErrorCard(_statsError!, onRetry: _loadStats)
            else if (_analyticsStats != null)
              ..._buildStatsWidgets(),

            const SizedBox(height: 20),

            // Comparison Cards Section
            if (_isLoadingComparison)
              _buildLoadingCard('Loading comparison data...')
            else if (_comparisonError != null)
              _buildErrorCard(_comparisonError!, onRetry: _loadComparison)
            else if (_comparisonData != null)
              _buildComparisonSection(),

            const SizedBox(height: 20),

            // Insights Section (only show if we have data)
            if (_analyticsStats != null) ...[
              Text(
                'Insights & Recommendations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._buildInsights(),
            ],

            const SizedBox(height: 20),

            // ML Prediction Section
            if (!_isGuestMode) _buildMlPredictionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMlPredictionSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isPredictionLoading) {
      return _buildLoadingCard('Loading ML prediction...');
    }

    if (_predictionData == null) {
      return Card(
        elevation: 0,
        color: isDark ? const Color(0xFF252525) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.model_training, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'Set up your eco profile to get ML predictions',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final predictedScore =
        (_predictionData!['predicted_score'] as num).toDouble();
    final scoreCategory =
        _predictionData!['score_category'] as String? ?? 'N/A';
    final recommendations =
        (_predictionData!['recommendations'] as List<dynamic>?)
            ?.cast<String>() ??
            [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ML Predicted Eco Score',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.indigo[700]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        value: predictedScore / 100,
                        strokeWidth: 9,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          predictedScore.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text('/100',
                            style:
                                TextStyle(fontSize: 10, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Random Forest Prediction',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          scoreCategory,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '🤖 Trained on eco behaviour data',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (recommendations.isNotEmpty) ...
          [
            const SizedBox(height: 12),
            Text(
              'AI Recommendations',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recommendations.map(
              (rec) => _buildInsightCard(
                Icons.tips_and_updates,
                rec.length > 60 ? '${rec.substring(0, 60)}…' : rec,
                rec.length > 60 ? rec : '',
                Colors.blue,
              ),
            ),
          ],
      ],
    );
  }

  List<Widget> _buildStatsWidgets() {
    final stats = _analyticsStats!;

    // Calculate trend percentage (comparing to average)
    int trendPercentage = 0;
    if (stats.trend.length > 1) {
      final recent = stats.trend.last.co2Impact;
      final previous = stats.trend.first.co2Impact;
      if (previous != 0) {
        trendPercentage = (((recent - previous) / previous) * 100).round();
      }
    }

    return [
      // Total Carbon Footprint Card
      Card(
        elevation: 0,
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF252525) 
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.green[400]!, Colors.green[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Carbon Impact',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendPercentage <= 0
                              ? Icons.trending_down
                              : Icons.trending_up,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trendPercentage > 0 ? '+' : ''}$trendPercentage%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    UnitConverter.formatWeight(stats.netImpact.abs(), isMetric: ref.watch(unitsProvider) == 'metric', decimals: 1).split(' ')[0],
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 4),
                    child: Text(
                      '${UnitConverter.getWeightUnit(ref.watch(unitsProvider) == 'metric')} CO₂ ${stats.netImpact < 0 ? 'saved' : 'emitted'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${stats.totalActivities} activities',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  Text(
                    '${stats.startDate} - ${stats.endDate}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),

      // Emitted vs Saved Row
      Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'CO₂ Emitted',
              UnitConverter.formatWeight(stats.totalCo2Emitted, isMetric: ref.watch(unitsProvider) == 'metric'),
              Icons.cloud_upload,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'CO₂ Saved',
              UnitConverter.formatWeight(stats.totalCo2Saved, isMetric: ref.watch(unitsProvider) == 'metric'),
              Icons.eco,
              Colors.green,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Chart Section
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Emissions Trend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          ToggleButtons(
            isSelected: [_selectedChartType == 0, _selectedChartType == 1],
            onPressed: (index) => setState(() => _selectedChartType = index),
            borderRadius: BorderRadius.circular(8),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 32),
            children: const [
              Icon(Icons.bar_chart, size: 20),
              Icon(Icons.show_chart, size: 20),
            ],
          ),
        ],
      ),
      const SizedBox(height: 12),
      Card(
        elevation: 0,
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF252525) 
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: 240,
          padding: const EdgeInsets.all(16),
          child: stats.trend.isEmpty
              ? const Center(
                  child: Text(
                    'No trend data available for this period',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : _buildChart(stats.trend),
        ),
      ),
      const SizedBox(height: 20),

      // Category Breakdown
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Breakdown by Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _buildCategoryBreakdownCard(stats.categories),
    ];
  }

  Widget _buildComparisonSection() {
    final comparison = _comparisonData!;

    // Calculate percentage difference from average
    String vsAvgText;
    String vsAvgSubtitle;
    
    if (comparison.avgCo2Saved < 0.1) {
      // Average is too low for meaningful percentage
      vsAvgText = '+${comparison.userCo2Saved.toStringAsFixed(1)} kg';
      vsAvgSubtitle = 'CO₂ saved';
    } else {
      final diffPercent = ((comparison.userCo2Saved - comparison.avgCo2Saved) / comparison.avgCo2Saved * 100);
      
      // Cap extreme percentages for better UX
      if (diffPercent > 500) {
        vsAvgText = '+${comparison.userCo2Saved.toStringAsFixed(1)} kg';
        vsAvgSubtitle = '${(diffPercent / 100).toStringAsFixed(1)}x average';
      } else if (diffPercent < -500) {
        vsAvgText = '${comparison.userCo2Saved.toStringAsFixed(1)} kg';
        vsAvgSubtitle = 'Below average';
      } else {
        final diff = diffPercent.round();
        vsAvgText = '${diff > 0 ? '+' : ''}$diff%';
        vsAvgSubtitle = comparison.co2Diff >= 0 ? 'Above avg user' : 'Below avg user';
      }
    }

    return Row(
      children: [
        Expanded(
          child: _buildComparisonCard(
            'vs Average',
            vsAvgText,
            Icons.people,
            comparison.co2Diff >= 0 ? Colors.green : Colors.orange,
            vsAvgSubtitle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildComparisonCard(
            'Percentile',
            '${comparison.percentile.round()}%',
            Icons.leaderboard,
            Colors.blue,
            'Top ${(100 - comparison.percentile).round()}% of users',
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInsights() {
    if (_analyticsStats == null) return [];

    final stats = _analyticsStats!;
    final insights = <Widget>[];

    // Find highest emission category
    if (stats.categories.isNotEmpty) {
      final highestCategory = stats.categories.reduce(
        (a, b) => a.co2Impact > b.co2Impact ? a : b,
      );

      insights.add(_buildInsightCard(
        _getCategoryIcon(highestCategory.name),
        '${highestCategory.name} is your highest emission source',
        'It accounts for ${highestCategory.percentage.toStringAsFixed(0)}% of your carbon footprint (${UnitConverter.formatWeight(highestCategory.co2Impact.abs(), isMetric: ref.watch(unitsProvider) == 'metric')} CO₂)',
        Colors.orange,
      ));
    }

    // Progress insight
    if (stats.totalCo2Saved > 0) {
      insights.add(_buildInsightCard(
        Icons.eco,
        'Great job saving CO₂!',
        'You\'ve saved ${UnitConverter.formatWeight(stats.totalCo2Saved, isMetric: ref.watch(unitsProvider) == 'metric')} CO₂ this $_selectedPeriod',
        Colors.green,
      ));
    }

    // Activity insight
    if (stats.totalActivities > 0) {
      insights.add(_buildInsightCard(
        Icons.checklist,
        '${stats.totalActivities} activities logged',
        'Keep tracking to improve your environmental impact!',
        Colors.blue,
      ));
    }

    if (insights.isEmpty) {
      insights.add(_buildInsightCard(
        Icons.lightbulb,
        'Start logging activities',
        'Log your daily activities to see personalized insights',
        Colors.grey,
      ));
    }

    return insights;
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('transport') || lower.contains('travel')) {
      return Icons.directions_car;
    } else if (lower.contains('food') || lower.contains('diet')) {
      return Icons.restaurant;
    } else if (lower.contains('energy') || lower.contains('electric')) {
      return Icons.bolt;
    } else if (lower.contains('shop') || lower.contains('consume')) {
      return Icons.shopping_bag;
    } else {
      return Icons.category;
    }
  }

  Widget _buildLoadingCard(String message) {
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF252525) 
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const CircularProgressIndicator(color: Colors.green),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error, {VoidCallback? onRetry}) {
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF252525) 
          : Colors.red[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 48),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(String title, String value, IconData icon, Color color, String subtitle) {
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(List<CategoryBreakdown> categories) {
    if (categories.isEmpty) {
      return Card(
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
            child: Text(
              'No category data available for this period',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    // Colors for categories
    final categoryColors = [
      Colors.blue,
      Colors.orange,
      Colors.yellow[700]!,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];

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
            // Visual breakdown bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: List.generate(categories.length, (index) {
                  final category = categories[index];
                  final flex = (category.percentage * 10).round().clamp(1, 100);
                  return Expanded(
                    flex: flex,
                    child: Container(
                      height: 24,
                      color: categoryColors[index % categoryColors.length],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            // Category list
            ...List.generate(categories.length, (index) {
              final category = categories[index];
              final color = categoryColors[index % categoryColors.length];
              return _buildCategoryBreakdownRow(
                category.name,
                category.percentage.round(),
                color,
                UnitConverter.formatWeight(category.co2Impact.abs(), isMetric: ref.watch(unitsProvider) == 'metric'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownRow(String category, int percentage, Color color, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(category, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$percentage%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<TrendData> trendData) {
    final values = trendData.map((e) => e.co2Impact).toList();
    final labels = trendData.map((e) => _formatDateLabel(e.date)).toList();

    double maxValue = 0;
    for (final v in values) {
      final absValue = v.abs();
      if (absValue > maxValue) {
        maxValue = absValue;
      }
    }
    if (maxValue == 0) maxValue = 1;

    if (_selectedChartType == 0) {
      // Bar chart
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length.clamp(0, 12), (index) {
          final value = values[index];
          final height = (value.abs() / maxValue) * 150;
          final isHighest = value.abs() == maxValue;
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
                    color: isHighest ? Colors.orange : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 20,
                  height: height.clamp(4.0, 150.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isHighest
                          ? [Colors.orange[300]!, Colors.orange[500]!]
                          : [Colors.green[300]!, Colors.green[500]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  labels[index],
                  style: const TextStyle(fontSize: 8),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }),
      );
    } else {
      // Line chart
      return CustomPaint(
        size: const Size(double.infinity, 180),
        painter: _LineChartPainter(
          values: values,
          labels: labels,
        ),
      );
    }
  }

  String _formatDateLabel(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      switch (_selectedPeriod) {
        case 'Day':
          return '${date.hour}:00';
        case 'Week':
          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          return days[date.weekday - 1];
        case 'Month':
          return '${date.day}';
        case 'Year':
          const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
          return months[date.month - 1];
        default:
          return '${date.day}/${date.month}';
      }
    } catch (e) {
      return dateStr.length > 5 ? dateStr.substring(5) : dateStr;
    }
  }

  Widget _buildInsightCard(IconData icon, String title, String description, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  _LineChartPainter({required this.values, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxValue = values.map((e) => e.abs()).reduce((a, b) => a > b ? a : b);
    final minValue = values.map((e) => e.abs()).reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.green.withValues(alpha: 0.3), Colors.green.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height - 20));

    final path = Path();
    final fillPath = Path();

    final displayCount = values.length.clamp(1, 12);
    final pointSpacing = size.width / (displayCount - 1).clamp(1, displayCount);
    final chartHeight = size.height - 30;

    for (var i = 0; i < displayCount; i++) {
      final x = i * pointSpacing;
      final normalizedValue = range > 0 ? (values[i].abs() - minValue) / range : 0.5;
      final y = chartHeight - (normalizedValue * (chartHeight - 20)) + 10;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo((displayCount - 1) * pointSpacing, chartHeight);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw points
    final dotPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    for (var i = 0; i < displayCount; i++) {
      final x = i * pointSpacing;
      final normalizedValue = range > 0 ? (values[i].abs() - minValue) / range : 0.5;
      final y = chartHeight - (normalizedValue * (chartHeight - 20)) + 10;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var i = 0; i < labels.length && i < displayCount; i++) {
      final x = i * pointSpacing;
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(color: Colors.grey[600], fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - 15));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
