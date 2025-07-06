import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'upload_resume_screen.dart';
import '../../../../core/services/api_service.dart';

class ApparentNeedsScreen extends StatefulWidget {
  const ApparentNeedsScreen({super.key});

  @override
  State<ApparentNeedsScreen> createState() => _ApparentNeedsScreenState();
}

class _ApparentNeedsScreenState extends State<ApparentNeedsScreen> {
  Set<String> _selectedNeeds = {};
  bool _noNeedsSelected = false;

  final Map<String, List<Map<String, String>>> _needsCategories = {
    'Physical Access': [
      {
        'id': 'accessible_entrances',
        'title': 'Accessible Entrances',
        'icon': '🚪',
        'description':
            'Wheelchair ramps, automatic doors, and other accessibility features for entering and navigating the building.',
      },
      {
        'id': 'accessible_restrooms',
        'title': 'Accessible Restrooms',
        'icon': '🚻',
        'description':
            'ADA-compliant restroom facilities with grab bars, adequate space for mobility aids, and accessible fixtures.',
      },
      {
        'id': 'accessible_parking',
        'title': 'Accessible Parking',
        'icon': '🅿️',
        'description':
            'Designated accessible parking spaces located close to building entrances with proper signage and access paths.',
      },
    ],
    'Mobility & Navigation': [
      {
        'id': 'clear_pathways',
        'title': 'Clear Pathways',
        'icon': '🛤️',
        'description':
            'Unobstructed hallways and work areas with sufficient space for mobility devices like wheelchairs or walkers.',
      },
      {
        'id': 'elevators_ramps',
        'title': 'Elevators/Ramps',
        'icon': '⬆️',
        'description':
            'Accessible elevators with proper dimensions and controls, or ramps as alternatives to stairs for multi-level workplaces.',
      },
      {
        'id': 'reachable_controls',
        'title': 'Reachable Controls',
        'icon': '✋',
        'description':
            'Light switches, thermostats, and other controls positioned at accessible heights for individuals with limited reach or mobility.',
      },
    ],
    'Visual & Auditory Accommodations': [
      {
        'id': 'screen_readers',
        'title': 'Screen Readers',
        'icon': '💻',
        'description':
            'Software that reads text aloud for individuals with visual impairments, allowing them to navigate digital content.',
      },
      {
        'id': 'magnification_tools',
        'title': 'Magnification Tools',
        'icon': '🔍',
        'description':
            'Digital or physical magnifiers that enlarge text and images for people with low vision or visual impairments.',
      },
      {
        'id': 'enhanced_audio',
        'title': 'Enhanced Audio',
        'icon': '🔊',
        'description':
            'Amplification devices, assistive listening systems, or visual alerts for individuals with hearing impairments.',
      },
    ],
    'Workplace Setup': [
      {
        'id': 'ergonomic_workstation',
        'title': 'Ergonomic Workstation',
        'icon': '🪑',
        'description':
            'Adjustable height desks, specialized chairs, and ergonomic equipment configured for physical comfort and accessibility.',
      },
      {
        'id': 'adaptive_equipment',
        'title': 'Adaptive Equipment',
        'icon': '⌨️',
        'description':
            'Specialized input devices, modified keyboards, switches, or other hardware adapted for individuals with limited dexterity or mobility.',
      },
      {
        'id': 'lighting_adjustments',
        'title': 'Lighting Adjustments',
        'icon': '💡',
        'description':
            'Task lighting, anti-glare screens, or modified lighting conditions to accommodate visual sensitivities or impairments.',
      },
    ],
    'Communication Support': [
      {
        'id': 'sign_language_interpreter',
        'title': 'Sign Language Interpreter',
        'icon': '🤟',
        'description':
            'Professional interpreters who facilitate communication between deaf or hard of hearing employees and others in meetings and group settings.',
      },
      {
        'id': 'captioning_services',
        'title': 'Captioning Services',
        'icon': '📝',
        'description':
            'Real-time captioning for meetings, presentations, and video content to support individuals with hearing impairments.',
      },
      {
        'id': 'alternative_formats',
        'title': 'Alternative Formats',
        'icon': '📄',
        'description':
            'Materials provided in braille, large print, digital accessible formats, or other alternative formats based on individual needs.',
      },
    ],
  };

  void _toggleNeed(String needId) {
    setState(() {
      if (_selectedNeeds.contains(needId)) {
        _selectedNeeds.remove(needId);
      } else {
        _selectedNeeds.add(needId);
        _noNeedsSelected =
            false; // Uncheck "no needs" if selecting specific needs
      }
    });
  }

  void _toggleNoNeeds() {
    setState(() {
      _noNeedsSelected = !_noNeedsSelected;
      if (_noNeedsSelected) {
        _selectedNeeds
            .clear(); // Clear all specific needs if "no needs" is selected
      }
    });
  }

  void _goBack() {
    Navigator.pop(context);
  }

  Future<void> _continue() async {
    if (_selectedNeeds.isEmpty && !_noNeedsSelected) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      // Save accommodations to database
      final response = await ApiService.saveAccommodations(
        disabilityType: 'apparent',
        accommodations: _selectedNeeds.toList(),
        noAccommodationsNeeded: _noNeedsSelected,
      );

      // Hide loading
      Navigator.pop(context);

      if (response['success']) {
        // Navigate to next screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UploadResumeScreen(),
          ),
        );
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response['message'] ?? 'Failed to save accommodations'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Hide loading
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildNeedCard(Map<String, String> need) {
    bool isSelected = _selectedNeeds.contains(need['id']);

    return GestureDetector(
      onTap: () => _toggleNeed(need['id']!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F8FA),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryTeal,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        need['icon']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      need['title']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryTeal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                need['description']!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      String categoryTitle, List<Map<String, String>> needs) {
    IconData categoryIcon;
    switch (categoryTitle) {
      case 'Physical Access':
        categoryIcon = Icons.business;
        break;
      case 'Mobility & Navigation':
        categoryIcon = Icons.accessible;
        break;
      case 'Visual & Auditory Accommodations':
        categoryIcon = Icons.visibility;
        break;
      case 'Workplace Setup':
        categoryIcon = Icons.chair;
        break;
      case 'Communication Support':
        categoryIcon = Icons.chat;
        break;
      default:
        categoryIcon = Icons.category;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category title
          Row(
            children: [
              Icon(
                categoryIcon,
                size: 20,
                color: AppColors.primaryOrange,
              ),
              const SizedBox(width: 10),
              Text(
                categoryTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Needs grid
          ...needs.map((need) => _buildNeedCard(need)).toList(),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Header text
                    Container(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: const Column(
                        children: [
                          Text(
                            'Workplace Needs - Apparent Disabilities',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryTeal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Select the accommodations that would help you perform at your best in the workplace.',
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

                    // Progress bar (95%)
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 600),
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1E1E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.95,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Guidance box
                    Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: AppColors.secondaryTeal,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You can select multiple options that apply to your situation. This information helps employers prepare appropriate accommodations for your interviews and potential employment.',
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

                    // Needs categories
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: _needsCategories.entries
                            .map((entry) =>
                                _buildCategorySection(entry.key, entry.value))
                            .toList(),
                      ),
                    ),

                    // No needs option
                    Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      margin: const EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                        onTap: _toggleNoNeeds,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _noNeedsSelected
                                  ? AppColors.primaryOrange
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'I don\'t require any specific accommodations at this time',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _noNeedsSelected
                                      ? AppColors.primaryOrange
                                      : Colors.white,
                                  border: Border.all(
                                    color: _noNeedsSelected
                                        ? AppColors.primaryOrange
                                        : AppColors.secondaryTeal,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: _noNeedsSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100), // Space for bottom navigation
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
          color: AppColors.backgroundColor,
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
              onPressed: (_selectedNeeds.isNotEmpty || _noNeedsSelected)
                  ? _continue
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
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
