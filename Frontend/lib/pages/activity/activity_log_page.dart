import 'package:flutter/material.dart';
import '../../services/activity_service.dart';
import '../../services/guest_service.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  String? _selectedCategoryName;
  final TextEditingController _searchController = TextEditingController();

  // Loading and error states
  bool _isLoadingCategories = true;
  bool _isLoggingActivity = false;
  String? _categoriesError;
  bool _isGuestMode = false;

  // Data from backend
  List<ActivityCategory> _categories = [];
  List<Activity> _recentlyLogged = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    try {
      // Check if in guest mode first
      final isGuest = await GuestService.isGuestSession();
      
      if (isGuest) {
        // Provide sample categories for guest exploration
        if (mounted) {
          setState(() {
            _isGuestMode = true;
            _categories = _getGuestCategories();
            if (_categories.isNotEmpty) {
              _selectedCategoryName = _categories.first.name;
            }
            _isLoadingCategories = false;
          });
        }
        return;
      }

      // Load categories for authenticated users only
      final categories = await ActivityService.getCategories();

      if (mounted) {
        setState(() {
          _isGuestMode = false;
          _categories = categories;
          if (categories.isNotEmpty) {
            _selectedCategoryName = categories.first.name;
          }
          _isLoadingCategories = false;
        });
        // Load recent activities only for authenticated users
        _loadRecentActivities();
      }
    } on ActivityException catch (e) {
      if (mounted) {
        setState(() {
          _categoriesError = e.message;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoriesError = 'Failed to load categories: ${e.toString()}';
          _isLoadingCategories = false;
        });
      }
    }
  }

  /// Sample categories for guest mode exploration
  List<ActivityCategory> _getGuestCategories() {
    return [
      ActivityCategory(
        id: 1,
        name: 'Transport',
        icon: '🚗',
        color: '#4CAF50',
        description: 'Track your transportation choices',
        activityTypes: [],
      ),
      ActivityCategory(
        id: 2,
        name: 'Energy',
        icon: '⚡',
        color: '#FF9800',
        description: 'Monitor your energy consumption',
        activityTypes: [],
      ),
      ActivityCategory(
        id: 3,
        name: 'Food',
        icon: '🥗',
        color: '#8BC34A',
        description: 'Track your food choices',
        activityTypes: [],
      ),
      ActivityCategory(
        id: 4,
        name: 'Waste',
        icon: '🗑️',
        color: '#2196F3',
        description: 'Reduce and recycle waste',
        activityTypes: [],
      ),
      ActivityCategory(
        id: 5,
        name: 'Water',
        icon: '💧',
        color: '#03A9F4',
        description: 'Conserve water resources',
        activityTypes: [],
      ),
    ];
  }

  Future<void> _loadRecentActivities() async {
    if (_isGuestMode) return; // Don't load for guests
    
    try {
      final activities = await ActivityService.getTodayActivities();
      if (mounted) {
        setState(() {
          _recentlyLogged = activities.take(3).toList();
        });
      }
    } catch (e) {
      // Silently fail for recent activities
    }
  }

  Future<void> _logActivity(ActivityType activityType, {double quantity = 1.0, String? notes}) async {
    // Block logging for guest users
    if (_isGuestMode) {
      _showGuestModeDialog();
      return;
    }

    setState(() => _isLoggingActivity = true);

    try {
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await ActivityService.logActivity(
        activityTypeId: activityType.id,
        quantity: quantity,
        activityDate: dateStr,
        notes: notes,
      );

      if (mounted) {
        setState(() => _isLoggingActivity = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('${activityType.name} logged successfully!')),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        _loadRecentActivities();
      }
    } on ActivityException catch (e) {
      if (mounted) {
        setState(() => _isLoggingActivity = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(e.message)),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingActivity = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log activity: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showGuestModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text('Guest Mode'),
          ],
        ),
        content: const Text(
          'You\'re exploring as a guest. Create an account to log activities and track your eco impact!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to signup page
              Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCategories) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text('Loading activities...'),
          ],
        ),
      );
    }

    if (_categoriesError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 64),
              const SizedBox(height: 16),
              Text(
                _categoriesError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700], fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadCategories,
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

    // Get current category's activity types
    final currentCategory = _categories.firstWhere(
      (c) => c.name == _selectedCategoryName,
      orElse: () => _categories.first,
    );

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await _loadCategories();
            await _loadRecentActivities();
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
                          ? Colors.green.shade900.withValues(alpha: 0.3)
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.green.shade700 
                            : Colors.green.shade200
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.eco, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Exploring activities - Sign up to start logging!',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.green.shade300 
                                  : Colors.green.shade800,
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
                
                // Header
                Text(
                  'Log Your Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your daily activities to monitor your carbon footprint',
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search activities...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[800] 
                        : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 20),

                // Quick Add - Recently Logged
                if (_recentlyLogged.isNotEmpty) ...[
                  Text(
                    'Quick Add (Recent)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recentlyLogged.length,
                      itemBuilder: (context, index) {
                        final activity = _recentlyLogged[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: Icon(_getCategoryIcon(activity.categoryName), size: 18),
                            label: Text(activity.activityTypeName),
                            onPressed: () {
                              // Find the activity type and log it
                              for (final cat in _categories) {
                                final type = cat.activityTypes.where((t) => t.id == activity.activityTypeId).firstOrNull;
                                if (type != null) {
                                  _logActivity(type);
                                  break;
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Category Selection
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategoryName == category.name;
                      final color = _parseColor(category.color);

                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedCategoryName = category.name;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 90,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? color : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.grey[50]),
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected ? null : Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[200]!),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ] : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getCategoryEmoji(category.name),
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[700]),
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Activity Options based on category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_selectedCategoryName Activities',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showCustomActivityDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Custom'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Filter by search
                ..._filterActivityTypes(currentCategory.activityTypes).map((activityType) =>
                  _buildActivityOption(context, activityType)
                ),

                if (_filterActivityTypes(currentCategory.activityTypes).isEmpty)
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
                            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No activities found',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Impact Calculator Card
                Card(
                  elevation: 2,
                  color: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
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
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.calculate, color: Colors.blue),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Impact Calculator',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Calculate the CO₂ impact of any activity with our detailed calculator.',
                          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[800], fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _showImpactCalculator(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                            ),
                            child: const Text('Open Calculator'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Loading overlay
        if (_isLoggingActivity)
          Container(
            color: Colors.black26,
            child: const Center(
              child: Card(
                elevation: 0,
                color: Color(0xFF252525),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.green),
                      SizedBox(height: 16),
                      Text('Logging activity...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<ActivityType> _filterActivityTypes(List<ActivityType> types) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return types;
    return types.where((t) => t.name.toLowerCase().contains(query)).toList();
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.green;
    }
  }

  String _getCategoryEmoji(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'transport':
        return '🚗';
      case 'food':
        return '🍽️';
      case 'energy':
        return '⚡';
      case 'shopping':
        return '🛍️';
      case 'home':
        return '🏠';
      case 'waste':
        return '🗑️';
      case 'water':
        return '💧';
      default:
        return '🌱';
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
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

  Widget _buildActivityOption(BuildContext context, ActivityType activityType) {
    final isGreen = activityType.isEcoFriendly;
    final impactColor = isGreen ? Colors.green : Colors.orange;
    final impactText = activityType.co2Impact >= 0
        ? '+${activityType.co2Impact.toStringAsFixed(1)} kg'
        : '${activityType.co2Impact.toStringAsFixed(1)} kg';

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
        onTap: () => _showActivityDetailDialog(context, activityType),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: impactColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getActivityIcon(activityType.icon), color: impactColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activityType.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activityType.impactUnit,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: impactColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      impactText,
                      style: TextStyle(
                        color: impactColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGreen ? Icons.thumb_up : Icons.thumb_down,
                        size: 14,
                        color: impactColor,
                      ),
                      if (activityType.points > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '+${activityType.points} pts',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                onPressed: () => _logActivity(activityType),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getActivityIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'directions_walk':
        return Icons.directions_walk;
      case 'directions_bike':
        return Icons.directions_bike;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'directions_car':
        return Icons.directions_car;
      case 'electric_car':
        return Icons.electric_car;
      case 'people':
        return Icons.people;
      case 'eco':
        return Icons.eco;
      case 'grass':
        return Icons.grass;
      case 'restaurant':
        return Icons.restaurant;
      case 'lunch_dining':
        return Icons.lunch_dining;
      case 'store':
        return Icons.store;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'local_laundry_service':
        return Icons.local_laundry_service;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'whatshot':
        return Icons.whatshot;
      case 'solar_power':
        return Icons.solar_power;
      case 'recycling':
        return Icons.recycling;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'checkroom':
        return Icons.checkroom;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'compost':
        return Icons.compost;
      case 'delete_outline':
        return Icons.delete_outline;
      case 'water_drop':
        return Icons.water_drop;
      case 'park':
        return Icons.park;
      default:
        return Icons.eco;
    }
  }

  void _showActivityDetailDialog(BuildContext context, ActivityType activityType) {
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    final isGreen = activityType.isEcoFriendly;
    final impactColor = isGreen ? Colors.green : Colors.orange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: impactColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_getActivityIcon(activityType.icon), size: 32, color: impactColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activityType.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Impact: ${activityType.co2Impact >= 0 ? '+' : ''}${activityType.co2Impact.toStringAsFixed(2)} kg CO₂',
                        style: TextStyle(color: impactColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Quantity (${activityType.impactUnit})', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '1',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Notes (optional)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add any notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  final qty = double.tryParse(quantityController.text) ?? 1.0;
                  _logActivity(
                    activityType,
                    quantity: qty,
                    notes: notesController.text.isEmpty ? null : notesController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Log Activity', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCustomActivityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Custom Activity'),
          ],
        ),
        content: const Text(
          'Custom activities can be added through the admin dashboard. '
          'Please contact your administrator to add new activity types.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showImpactCalculator(BuildContext context) {
    String? selectedCategory;
    ActivityType? selectedActivityType;
    final valueController = TextEditingController();
    double calculatedImpact = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) => Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '🧮 Impact Calculator',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text('Select Category', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _categories.map((c) => DropdownMenuItem(
                    value: c.name,
                    child: Text(c.name),
                  )).toList(),
                  onChanged: (v) {
                    setModalState(() {
                      selectedCategory = v;
                      selectedActivityType = null;
                      calculatedImpact = 0;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (selectedCategory != null) ...[
                  const Text('Select Activity', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: selectedActivityType?.id,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _categories
                        .firstWhere((c) => c.name == selectedCategory)
                        .activityTypes
                        .map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.name),
                        ))
                        .toList(),
                    onChanged: (v) {
                      setModalState(() {
                        selectedActivityType = _categories
                            .firstWhere((c) => c.name == selectedCategory)
                            .activityTypes
                            .firstWhere((t) => t.id == v);
                        calculatedImpact = selectedActivityType!.co2Impact;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                if (selectedActivityType != null) ...[
                  Text('Enter Quantity (${selectedActivityType!.impactUnit})', 
                       style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: valueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '1',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (v) {
                      final qty = double.tryParse(v) ?? 1;
                      setModalState(() {
                        calculatedImpact = selectedActivityType!.co2Impact * qty;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                Card(
                  elevation: 0,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF252525) 
                      : (calculatedImpact >= 0 ? Colors.orange[50] : Colors.green[50]),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('Estimated Impact', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(
                          '${calculatedImpact >= 0 ? '+' : ''}${calculatedImpact.toStringAsFixed(2)} kg CO₂',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: calculatedImpact >= 0 ? Colors.orange[700] : Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          calculatedImpact >= 0
                              ? 'Equivalent to ${(calculatedImpact / 21.77).toStringAsFixed(1)} trees needed for a day'
                              : 'Saving equivalent to ${(calculatedImpact.abs() / 21.77).toStringAsFixed(1)} tree-days',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedActivityType != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final qty = double.tryParse(valueController.text) ?? 1.0;
                        _logActivity(selectedActivityType!, quantity: qty);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Log This Activity'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
