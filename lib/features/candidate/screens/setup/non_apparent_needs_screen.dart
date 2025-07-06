import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'upload_resume_screen.dart';
import '../../../../core/services/api_service.dart';

class NonApparentNeedsScreen extends StatefulWidget {
  const NonApparentNeedsScreen({super.key});

  @override
  State<NonApparentNeedsScreen> createState() => _NonApparentNeedsScreenState();
}

class _NonApparentNeedsScreenState extends State<NonApparentNeedsScreen> {
  Set<String> _selectedNeeds = {};
  bool _noNeedsSelected = false;

  final Map<String, List<Map<String, String>>> _needsCategories = {
    'Cognitive & Learning Accommodations': [
      {
        'id': 'written_instructions',
        'title': 'Written Instructions',
        'icon': '📄',
        'description':
            'Providing instructions, tasks, and feedback in written format alongside verbal communication.',
      },
      {
        'id': 'task_organization_tools',
        'title': 'Task Organization Tools',
        'icon': '📋',
        'description':
            'Access to digital or physical tools that help with organizing tasks, setting reminders, and tracking progress.',
      },
      {
        'id': 'reading_assistance',
        'title': 'Reading Assistance',
        'icon': '📖',
        'description':
            'Text-to-speech software, reading guides, or format modifications for written materials to support reading comprehension.',
      },
    ],
    'Sensory Environment Adjustments': [
      {
        'id': 'noise_reduction',
        'title': 'Noise Reduction',
        'icon': '🔇',
        'description':
            'Quieter work environment, noise-canceling headphones, or permission to use white noise machines to minimize auditory distractions.',
      },
      {
        'id': 'lighting_accommodations',
        'title': 'Lighting Accommodations',
        'icon': '💡',
        'description':
            'Alternative lighting options such as natural light, desk lamps, or reduced fluorescent lighting based on sensory needs.',
      },
      {
        'id': 'reduced_stimulation_space',
        'title': 'Reduced Stimulation Space',
        'icon': '🚪',
        'description':
            'Access to a quieter workspace, partitioned area, or private office to minimize sensory overload and distractions.',
      },
    ],
    'Work Schedule & Structure': [
      {
        'id': 'flexible_hours',
        'title': 'Flexible Hours',
        'icon': '🕐',
        'description':
            'Adjustable start/end times or modified work schedules to accommodate energy levels, medical appointments, or treatment schedules.',
      },
      {
        'id': 'remote_work_options',
        'title': 'Remote Work Options',
        'icon': '🏠',
        'description':
            'Ability to work from home part-time or full-time to manage symptoms, energy levels, or environmental sensitivities.',
      },
      {
        'id': 'additional_breaks',
        'title': 'Additional Breaks',
        'icon': '☕',
        'description':
            'Short, more frequent breaks throughout the workday to manage fatigue, medication timing, or prevent symptom flare-ups.',
      },
    ],
    'Communication & Social Support': [
      {
        'id': 'communication_preferences',
        'title': 'Communication Preferences',
        'icon': '💬',
        'description':
            'Accommodations for preferred communication methods such as email instead of phone calls, or advance notice before meetings.',
      },
      {
        'id': 'meeting_accommodations',
        'title': 'Meeting Accommodations',
        'icon': '👥',
        'description':
            'Advance meeting agendas, options to participate remotely, or alternative participation methods for group discussions.',
      },
      {
        'id': 'mentor_support_person',
        'title': 'Mentor or Support Person',
        'icon': '🤝',
        'description':
            'Access to a workplace mentor, job coach, or designated person for questions and support with workplace processes.',
      },
    ],
    'Health Management': [
      {
        'id': 'medication_management',
        'title': 'Medication Management',
        'icon': '💊',
        'description':
            'Allowances for taking medication during work hours or adjustments to accommodate medication effects and timing.',
      },
      {
        'id': 'medical_appointment_flexibility',
        'title': 'Medical Appointment Flexibility',
        'icon': '🏥',
        'description':
            'Flexible scheduling to accommodate regular medical appointments, therapy sessions, or treatments.',
      },
      {
        'id': 'rest_area_access',
        'title': 'Rest Area Access',
        'icon': '🛋️',
        'description':
            'Access to a private space for short rest periods, symptom management, or stress reduction during the workday.',
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
        disabilityType: 'non-apparent',
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
            color: isSelected ? AppColors.accent : Colors.transparent,
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
                      color: AppColors.primary,
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
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
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
      case 'Cognitive & Learning Accommodations':
        categoryIcon = Icons.psychology;
        break;
      case 'Sensory Environment Adjustments':
        categoryIcon = Icons.tune;
        break;
      case 'Work Schedule & Structure':
        categoryIcon = Icons.schedule;
        break;
      case 'Communication & Social Support':
        categoryIcon = Icons.chat;
        break;
      case 'Health Management':
        categoryIcon = Icons.favorite;
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
                color: AppColors.accent,
              ),
              const SizedBox(width: 10),
              Text(
                categoryTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
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
                            'Workplace Needs - Non-Apparent Disabilities',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
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
                            color: AppColors.accent,
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
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: AppColors.primary,
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
                          SizedBox(height: 10),
                          Text(
                            'Your privacy is important. You control what information is shared with potential employers.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF666666),
                              fontStyle: FontStyle.italic,
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
                                  ? AppColors.accent
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
                                      ? AppColors.accent
                                      : Colors.white,
                                  border: Border.all(
                                    color: _noNeedsSelected
                                        ? AppColors.accent
                                        : AppColors.primary,
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
              onPressed: (_selectedNeeds.isNotEmpty || _noNeedsSelected)
                  ? _continue
                  : null,
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
