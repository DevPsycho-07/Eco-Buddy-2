import 'package:flutter/material.dart';
import '../../services/eco_profile_service.dart';
import '../../core/navigation/app_shell.dart';
import '../../utils/logger.dart';

class EcoProfileSetupPage extends StatefulWidget {
  final bool isFirstTime;
  final Map<String, dynamic>? existingProfile;

  const EcoProfileSetupPage({
    super.key,
    this.isFirstTime = true,
    this.existingProfile,
  });

  @override
  State<EcoProfileSetupPage> createState() => _EcoProfileSetupPageState();
}

class _EcoProfileSetupPageState extends State<EcoProfileSetupPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Form values
  int _householdSize = 1;
  String _ageGroup = '26-35';
  String _lifestyleType = 'office_worker';
  String _locationType = 'urban';
  String _vehicleType = 'none';
  String _dietType = 'omnivore';
  bool _usesSolarPanels = false;
  bool _smartThermostat = false;
  bool _recyclingPracticed = false;
  bool _compostingPracticed = false;
  String _wasteBagSize = 'medium';
  String _socialActivity = 'sometimes';

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _loadExistingProfile();
    }
  }

  void _loadExistingProfile() {
    final profile = widget.existingProfile!;
    setState(() {
      _householdSize = profile['household_size'] ?? 1;
      _ageGroup = profile['age_group'] ?? '26-35';
      _lifestyleType = profile['lifestyle_type'] ?? 'office_worker';
      _locationType = profile['location_type'] ?? 'urban';
      _vehicleType = profile['vehicle_type'] ?? 'none';
      _dietType = profile['diet_type'] ?? 'omnivore';
      _usesSolarPanels = profile['uses_solar_panels'] ?? false;
      _smartThermostat = profile['smart_thermostat'] ?? false;
      _recyclingPracticed = profile['recycling_practiced'] ?? false;
      _compostingPracticed = profile['composting_practiced'] ?? false;
      _wasteBagSize = profile['waste_bag_size'] ?? 'medium';
      _socialActivity = profile['social_activity'] ?? 'sometimes';
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitProfile();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitProfile() async {
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;

      if (widget.isFirstTime) {
        result = await EcoProfileService.createProfile(
          householdSize: _householdSize,
          ageGroup: _ageGroup,
          lifestyleType: _lifestyleType,
          locationType: _locationType,
          vehicleType: _vehicleType,
          carFuelType: 'none',
          dietType: _dietType,
          usesSolarPanels: _usesSolarPanels,
          smartThermostat: _smartThermostat,
          recyclingPracticed: _recyclingPracticed,
          compostingPracticed: _compostingPracticed,
          wasteBagSize: _wasteBagSize,
          socialActivity: _socialActivity,
        );
      } else {
        result = await EcoProfileService.updateProfile(
          householdSize: _householdSize,
          ageGroup: _ageGroup,
          lifestyleType: _lifestyleType,
          locationType: _locationType,
          vehicleType: _vehicleType,
          carFuelType: 'none',
          dietType: _dietType,
          usesSolarPanels: _usesSolarPanels,
          smartThermostat: _smartThermostat,
          recyclingPracticed: _recyclingPracticed,
          compostingPracticed: _compostingPracticed,
          wasteBagSize: _wasteBagSize,
          socialActivity: _socialActivity,
        );
      }

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isFirstTime
                ? '🎉 Profile setup complete!'
                : '✅ Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.isFirstTime) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AppShell()),
          );
        } else {
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to save profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Logger.error('❌ [EcoProfileSetup] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F9F5),
      appBar: widget.isFirstTime
          ? null
          : AppBar(
              title: const Text('Edit Eco Profile'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.isFirstTime) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Icon(Icons.eco, size: 48, color: Colors.green),
                    const SizedBox(height: 12),
                    Text(
                      'Set Up Your Eco Profile',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Help us personalize your eco score by answering a few questions',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? Colors.green
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Step ${_currentPage + 1} of 5',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildPersonalInfoPage(),
                  _buildLifestylePage(),
                  _buildTransportPage(),
                  _buildEnergyHomePage(),
                  _buildHabitsPage(),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: _currentPage == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_currentPage < 4 ? 'Continue' : 'Complete Setup'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal Information', Icons.person),
          const SizedBox(height: 24),

          _buildLabel('Household Size'),
          const SizedBox(height: 8),
          _buildNumberSelector(
            value: _householdSize,
            min: 1,
            max: 10,
            onChanged: (val) => setState(() => _householdSize = val),
          ),
          const SizedBox(height: 24),

          _buildLabel('Age Group'),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _ageGroup,
            options: EcoProfileService.ageGroupOptions,
            onChanged: (val) => setState(() => _ageGroup = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestylePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Lifestyle', Icons.work),
          const SizedBox(height: 24),

          _buildLabel('Work Style'),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _lifestyleType,
            options: EcoProfileService.lifestyleOptions,
            onChanged: (val) => setState(() => _lifestyleType = val!),
          ),
          const SizedBox(height: 24),

          _buildLabel('Where do you live?'),
          const SizedBox(height: 8),
          _buildOptionChips(
            options: EcoProfileService.locationOptions,
            selectedValue: _locationType,
            onSelected: (val) => setState(() => _locationType = val),
          ),
          const SizedBox(height: 24),

          _buildLabel('Social Activity Level'),
          const SizedBox(height: 8),
          _buildOptionChips(
            options: EcoProfileService.socialActivityOptions,
            selectedValue: _socialActivity,
            onSelected: (val) => setState(() => _socialActivity = val),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Transportation', Icons.directions_car),
          const SizedBox(height: 24),

          _buildLabel('Primary Vehicle / Transport Mode'),
          const SizedBox(height: 8),
          Text(
            'Select your most frequently used personal vehicle',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            value: _vehicleType,
            options: EcoProfileService.vehicleOptions,
            onChanged: (val) => setState(() => _vehicleType = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Energy & Home', Icons.home),
          const SizedBox(height: 24),

          _buildSwitchTile(
            title: 'Solar Panels',
            subtitle: 'Do you have solar panels installed?',
            icon: Icons.solar_power,
            value: _usesSolarPanels,
            onChanged: (val) => setState(() => _usesSolarPanels = val),
          ),
          const SizedBox(height: 16),

          _buildSwitchTile(
            title: 'Smart Thermostat',
            subtitle: 'Do you use a smart thermostat?',
            icon: Icons.thermostat,
            value: _smartThermostat,
            onChanged: (val) => setState(() => _smartThermostat = val),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Diet & Habits', Icons.restaurant),
          const SizedBox(height: 24),

          _buildLabel('Diet Type'),
          const SizedBox(height: 8),
          _buildOptionChips(
            options: EcoProfileService.dietOptions,
            selectedValue: _dietType,
            onSelected: (val) => setState(() => _dietType = val),
          ),
          const SizedBox(height: 24),

          _buildSwitchTile(
            title: 'Recycling',
            subtitle: 'Do you practice recycling?',
            icon: Icons.recycling,
            value: _recyclingPracticed,
            onChanged: (val) => setState(() => _recyclingPracticed = val),
          ),
          const SizedBox(height: 16),

          _buildSwitchTile(
            title: 'Composting',
            subtitle: 'Do you compost organic waste?',
            icon: Icons.compost,
            value: _compostingPracticed,
            onChanged: (val) => setState(() => _compostingPracticed = val),
          ),
          const SizedBox(height: 24),

          _buildLabel('Typical Waste Bag Size'),
          const SizedBox(height: 8),
          _buildOptionChips(
            options: EcoProfileService.wasteBagSizeOptions,
            selectedValue: _wasteBagSize,
            onSelected: (val) => setState(() => _wasteBagSize = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.green, size: 24),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildNumberSelector({
    required int value,
    required int min,
    required int max,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: Colors.green,
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<Map<String, String>> options,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(option['label']!),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildOptionChips({
    required List<Map<String, String>> options,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option['value'] == selectedValue;
        return ChoiceChip(
          label: Text(option['label']!),
          selected: isSelected,
          onSelected: (_) => onSelected(option['value']!),
          selectedColor: Colors.green,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: value ? Colors.green : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
          color: value ? Colors.green.withValues(alpha: 0.05) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? Colors.green : Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
