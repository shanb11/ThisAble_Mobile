import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';

/// Work Preferences Edit Bottom Sheet
/// Matches web's profile_work_preferences_edit.php functionality
class WorkPreferencesBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentPreferences;
  final Function() onSaved;

  const WorkPreferencesBottomSheet({
    Key? key,
    required this.currentPreferences,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<WorkPreferencesBottomSheet> createState() =>
      _WorkPreferencesBottomSheetState();
}

class _WorkPreferencesBottomSheetState
    extends State<WorkPreferencesBottomSheet> {
  // Form values
  String? _workStyle;
  String? _jobType;
  String? _salaryRange;
  String? _availability;

  bool _isSaving = false;

  // Dropdown options (matches web exactly)
  final List<Map<String, String>> _workStyleOptions = [
    {'value': 'remote', 'label': 'Remote'},
    {'value': 'hybrid', 'label': 'Hybrid'},
    {'value': 'onsite', 'label': 'Onsite'},
  ];

  final List<Map<String, String>> _jobTypeOptions = [
    {'value': 'fulltime', 'label': 'Full-Time'},
    {'value': 'parttime', 'label': 'Part-Time'},
    {'value': 'freelance', 'label': 'Freelance'},
  ];

  final List<Map<String, String>> _salaryRangeOptions = [
    {'value': 'Below ₱20,000', 'label': 'Below ₱20,000'},
    {'value': '₱20,000 - ₱30,000', 'label': '₱20,000 - ₱30,000'},
    {'value': '₱30,000 - ₱40,000', 'label': '₱30,000 - ₱40,000'},
    {'value': '₱40,000 - ₱50,000', 'label': '₱40,000 - ₱50,000'},
    {'value': 'Above ₱50,000', 'label': 'Above ₱50,000'},
  ];

  final List<Map<String, String>> _availabilityOptions = [
    {'value': 'Immediate', 'label': 'Immediate'},
    {'value': '2 Weeks Notice', 'label': '2 Weeks Notice'},
    {'value': '1 Month Notice', 'label': '1 Month Notice'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with current values
    _workStyle = widget.currentPreferences['work_style'];
    _jobType = widget.currentPreferences['job_type'];
    _salaryRange = widget.currentPreferences['salary_range'];
    _availability = widget.currentPreferences['availability'];
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final response = await ApiService.updateWorkPreferences(
        workStyle: _workStyle,
        jobType: _jobType,
        salaryRange: _salaryRange,
        availability: _availability,
      );

      if (response['success']) {
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  response['message'] ?? 'Preferences updated successfully'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Close bottom sheet and refresh parent
          Navigator.pop(context);
          widget.onSaved();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(response['message'] ?? 'Failed to update preferences'),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.work_outline,
                  color: AppColors.secondaryTeal,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Edit Work Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryTeal,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Form Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Work Style Dropdown
                  _buildDropdownField(
                    label: 'Work Style',
                    value: _workStyle,
                    options: _workStyleOptions,
                    icon: Icons.laptop_chromebook,
                    onChanged: (value) {
                      setState(() {
                        _workStyle = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Job Type Dropdown
                  _buildDropdownField(
                    label: 'Job Type',
                    value: _jobType,
                    options: _jobTypeOptions,
                    icon: Icons.business_center,
                    onChanged: (value) {
                      setState(() {
                        _jobType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Expected Salary Dropdown
                  _buildDropdownField(
                    label: 'Expected Salary',
                    value: _salaryRange,
                    options: _salaryRangeOptions,
                    icon: Icons.payments,
                    onChanged: (value) {
                      setState(() {
                        _salaryRange = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Availability Dropdown
                  _buildDropdownField(
                    label: 'Availability',
                    value: _availability,
                    options: _availabilityOptions,
                    icon: Icons.event_available,
                    onChanged: (value) {
                      setState(() {
                        _availability = value;
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _isSaving ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                                color: AppColors.secondaryTeal),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.secondaryTeal,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _savePreferences,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryTeal,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
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
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, String>> options,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.secondaryTeal),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
            hint: Text('Select $label'),
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
