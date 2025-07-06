import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/api_service.dart';
import 'apparent_needs_screen.dart';
import 'non_apparent_needs_screen.dart';

class DisabilityTypeScreen extends StatefulWidget {
  const DisabilityTypeScreen({super.key});

  @override
  State<DisabilityTypeScreen> createState() => _DisabilityTypeScreenState();
}

class _DisabilityTypeScreenState extends State<DisabilityTypeScreen> {
  int? _selectedDisabilityId;
  String? _selectedCategory;

  List<Map<String, dynamic>> _disabilityTypes = [];
  Map<String, List<Map<String, dynamic>>> _groupedDisabilities = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDisabilityTypes();
  }

  Future<void> _loadDisabilityTypes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await ApiService.getDisabilityTypes();

      if (response['success']) {
        setState(() {
          _disabilityTypes = List<Map<String, dynamic>>.from(
              response['data']['disability_types']);
          _groupDisabilitiesByCategory();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load disability types';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _groupDisabilitiesByCategory() {
    _groupedDisabilities = {};

    for (var disability in _disabilityTypes) {
      String category = disability['category'];
      if (!_groupedDisabilities.containsKey(category)) {
        _groupedDisabilities[category] = [];
      }
      _groupedDisabilities[category]!.add(disability);
    }
  }

  void _selectDisabilityType(int disabilityId, String category) {
    setState(() {
      _selectedDisabilityId = disabilityId;
      _selectedCategory = category;
    });
  }

  void _goBack() {
    Navigator.pop(context);
  }

  void _continue() {
    if (_selectedDisabilityId != null && _selectedCategory != null) {
      if (_selectedCategory == 'apparent') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ApparentNeedsScreen(),
          ),
        );
      } else if (_selectedCategory == 'non-apparent') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NonApparentNeedsScreen(),
          ),
        );
      }
    }
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'apparent':
        return 'Apparent Disabilities';
      case 'non-apparent':
        return 'Non-Apparent Disabilities';
      default:
        return category;
    }
  }

  String _getCategoryDescription(String category) {
    switch (category) {
      case 'apparent':
        return 'Disabilities that are visible or immediately evident to others through physical characteristics, mobility devices, or other observable features.';
      case 'non-apparent':
        return 'Disabilities that are not immediately obvious or visible to others. These might include cognitive, neurological, psychological, or other conditions.';
      default:
        return '';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'apparent':
        return Icons.visibility;
      case 'non-apparent':
        return Icons.visibility_off;
      default:
        return Icons.help;
    }
  }

  Widget _buildDisabilityCard(Map<String, dynamic> disability) {
    bool isSelected = _selectedDisabilityId == disability['id'];
    String category = disability['category'];

    return GestureDetector(
      onTap: () => _selectDisabilityType(disability['id'], category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Selection indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.accent : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.accent : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),

              const SizedBox(width: 16),

              // Disability name
              Expanded(
                child: Text(
                  disability['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.accent : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      String category, List<Map<String, dynamic>> disabilities) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 24,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getCategoryTitle(category),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getCategoryDescription(category),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Disability options
          ...disabilities
              .map((disability) => _buildDisabilityCard(disability))
              .toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/thisablelogo.png',
                    width: 70,
                    height: 70,
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text('Loading disability types...'),
                        ],
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 48),
                              SizedBox(height: 16),
                              Text(_error!, textAlign: TextAlign.center),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadDisabilityTypes,
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              // Header text
                              Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 700),
                                child: const Column(
                                  children: [
                                    Text(
                                      'Your Disability Type',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      'Help us understand your needs better to match you with appropriate opportunities.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textSecondary,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Progress bar (90%)
                              Container(
                                width: double.infinity,
                                constraints:
                                    const BoxConstraints(maxWidth: 600),
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1E1E1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 0.90,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Guidance box
                              Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 600),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.info,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Your selection helps us provide relevant job matches and accommodations. All information is kept confidential and used only to enhance your job search experience.',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Disability type sections
                              Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 800),
                                child: Column(
                                  children: _groupedDisabilities.entries
                                      .map((entry) => _buildCategorySection(
                                          entry.key, entry.value))
                                      .toList(),
                                ),
                              ),

                              // Help text
                              Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 600),
                                child: const Text(
                                  'Not sure? Select the option that most closely represents your situation. You can always update this information later.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF666666),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(
                                  height: 100), // Space for bottom navigation
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            ElevatedButton.icon(
              onPressed: _goBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE1E1E1),
                foregroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Continue button
            ElevatedButton.icon(
              onPressed: _selectedDisabilityId != null ? _continue : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
