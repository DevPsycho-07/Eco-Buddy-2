import 'package:flutter/material.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  String _selectedCategory = 'All';
  
  final List<Map<String, dynamic>> _tips = [
    // Transport Tips
    {'category': 'Transport', 'emoji': '🚗', 'title': 'Walk or Cycle Short Trips', 'description': 'For trips under 2km, walk or cycle instead of driving. You\'ll save up to 0.5 kg CO₂ per trip!', 'impact': 'High', 'difficulty': 'Easy'},
    {'category': 'Transport', 'emoji': '🚗', 'title': 'Use Public Transit', 'description': 'Taking the bus or train instead of driving alone can reduce your commute emissions by up to 65%.', 'impact': 'High', 'difficulty': 'Easy'},
    {'category': 'Transport', 'emoji': '🚗', 'title': 'Carpool When Possible', 'description': 'Sharing rides with colleagues can cut your transport emissions in half while saving money.', 'impact': 'Medium', 'difficulty': 'Easy'},
    {'category': 'Transport', 'emoji': '🚗', 'title': 'Maintain Tire Pressure', 'description': 'Properly inflated tires can improve fuel efficiency by up to 3%, saving both CO₂ and money.', 'impact': 'Low', 'difficulty': 'Easy'},
    {'category': 'Transport', 'emoji': '🚗', 'title': 'Plan Efficient Routes', 'description': 'Combine errands into one trip and avoid rush hour traffic to reduce idle time and emissions.', 'impact': 'Medium', 'difficulty': 'Easy'},
    // Food Tips
    {'category': 'Food', 'emoji': '🍽️', 'title': 'Try Meatless Mondays', 'description': 'Replacing one beef meal per week with plant-based options can save up to 150 kg CO₂ per year.', 'impact': 'High', 'difficulty': 'Easy'},
    {'category': 'Food', 'emoji': '🍽️', 'title': 'Buy Local Produce', 'description': 'Local food travels shorter distances, reducing transport emissions and supporting your community.', 'impact': 'Medium', 'difficulty': 'Easy'},
    {'category': 'Food', 'emoji': '🍽️', 'title': 'Reduce Food Waste', 'description': 'Plan meals and use leftovers creatively. Food waste accounts for 8-10% of global emissions!', 'impact': 'High', 'difficulty': 'Medium'},
    {'category': 'Food', 'emoji': '🍽️', 'title': 'Start Composting', 'description': 'Composting food scraps keeps them out of landfills where they produce methane gas.', 'impact': 'Medium', 'difficulty': 'Medium'},
    {'category': 'Food', 'emoji': '🍽️', 'title': 'Choose Seasonal Foods', 'description': 'Seasonal produce requires less energy for growing and transportation.', 'impact': 'Low', 'difficulty': 'Easy'},
    // Energy Tips
    {'category': 'Energy', 'emoji': '⚡', 'title': 'Switch to LED Bulbs', 'description': 'LED bulbs use 75% less energy than traditional bulbs and last 25 times longer.', 'impact': 'Medium', 'difficulty': 'Easy'},
    {'category': 'Energy', 'emoji': '⚡', 'title': 'Unplug Idle Devices', 'description': 'Phantom power from idle electronics can account for 10% of your electricity bill.', 'impact': 'Low', 'difficulty': 'Easy'},
    {'category': 'Energy', 'emoji': '⚡', 'title': 'Use Cold Water for Laundry', 'description': 'Washing clothes in cold water can save up to 500 lbs of CO₂ per year.', 'impact': 'Medium', 'difficulty': 'Easy'},
    {'category': 'Energy', 'emoji': '⚡', 'title': 'Adjust Thermostat', 'description': 'Lowering heating by 1°C can reduce energy use by 10% and save significant CO₂.', 'impact': 'High', 'difficulty': 'Easy'},
    {'category': 'Energy', 'emoji': '⚡', 'title': 'Air Dry Clothes', 'description': 'Skip the dryer when weather permits. It saves energy and extends clothing life.', 'impact': 'Medium', 'difficulty': 'Easy'},
    // Shopping Tips
    {'category': 'Shopping', 'emoji': '🛍️', 'title': 'Buy Second-hand', 'description': 'Pre-owned items require no new production energy. Fashion accounts for 10% of global emissions!', 'impact': 'High', 'difficulty': 'Easy'},
    {'category': 'Shopping', 'emoji': '🛍️', 'title': 'Choose Less Packaging', 'description': 'Products with minimal packaging reduce waste and the energy needed for production.', 'impact': 'Low', 'difficulty': 'Easy'},
    {'category': 'Shopping', 'emoji': '🛍️', 'title': 'Bring Reusable Bags', 'description': 'A reusable bag used 50 times has lower impact than 50 single-use plastic bags.', 'impact': 'Low', 'difficulty': 'Easy'},
    {'category': 'Shopping', 'emoji': '🛍️', 'title': 'Support Eco-Friendly Brands', 'description': 'Companies with sustainability practices often have lower carbon footprints.', 'impact': 'Medium', 'difficulty': 'Easy'},
    // Home Tips
    {'category': 'Home', 'emoji': '🏠', 'title': 'Install Low-Flow Fixtures', 'description': 'Low-flow showerheads and faucets can reduce water heating energy by up to 50%.', 'impact': 'Medium', 'difficulty': 'Medium'},
    {'category': 'Home', 'emoji': '🏠', 'title': 'Seal Air Leaks', 'description': 'Proper insulation and sealing can reduce heating/cooling needs by 20%.', 'impact': 'High', 'difficulty': 'Medium'},
    {'category': 'Home', 'emoji': '🏠', 'title': 'Use Natural Light', 'description': 'Open curtains during the day to reduce artificial lighting needs.', 'impact': 'Low', 'difficulty': 'Easy'},
    {'category': 'Home', 'emoji': '🏠', 'title': 'Plant Trees', 'description': 'Trees provide shade, absorb CO₂, and can reduce home cooling costs.', 'impact': 'High', 'difficulty': 'Medium'},
  ];

  final List<String> _categories = ['All', 'Transport', 'Food', 'Energy', 'Shopping', 'Home'];

  @override
  Widget build(BuildContext context) {
    final filteredTips = _selectedCategory == 'All' 
        ? _tips 
        : _tips.where((t) => t['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips & Suggestions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {},
            tooltip: 'Saved Tips',
          ),
        ],
      ),
      body: Column(
        children: [
          // Personalized Recommendation Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.teal[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('💡', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personalized for You',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Based on your transport habits, try carpooling this week!',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),

          // Category Filter
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: Colors.green,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = category);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Tips Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${filteredTips.length} tips available',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.shuffle, size: 18),
                  label: const Text('Random Tip'),
                ),
              ],
            ),
          ),

          // Tips List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredTips.length,
              itemBuilder: (context, index) {
                final tip = filteredTips[index];
                return _buildTipCard(tip);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    final impactColor = tip['impact'] == 'High' 
        ? Colors.green 
        : tip['impact'] == 'Medium' 
            ? Colors.orange 
            : Colors.blue;

    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF252525) 
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTipDetail(tip),
        borderRadius: BorderRadius.circular(12),
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
                    child: Text(tip['emoji'], style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border, size: 22),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tip['description'],
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTag('${tip['impact']} Impact', impactColor),
                  const SizedBox(width: 8),
                  _buildTag(tip['difficulty'], Colors.grey),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showTipDetail(tip),
                    child: const Text('Learn More'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showTipDetail(Map<String, dynamic> tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
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
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Text(tip['emoji'], style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tip['title'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTag('${tip['impact']} Impact', Colors.green),
                  const SizedBox(width: 8),
                  _buildTag(tip['difficulty'], Colors.grey),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                tip['description'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Why This Matters',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Small actions add up! If everyone adopted this tip, we could significantly reduce global carbon emissions and create a healthier planet for future generations.',
                style: TextStyle(color: Colors.grey[600], height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.bookmark_border),
                      label: const Text('Save'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to your goals!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add to Goals'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
