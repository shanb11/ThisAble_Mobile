import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';

/// Post Job Modal - Mobile version of modals/landing/landing_post_job_modal.php
/// Matches your web post job form structure and functionality exactly
class PostJobModal extends StatefulWidget {
  const PostJobModal({super.key});

  @override
  State<PostJobModal> createState() => _PostJobModalState();
}

class _PostJobModalState extends State<PostJobModal> {
  // Form key for validation (matches your web form validation)
  final _formKey = GlobalKey<FormState>();

  // Form controllers (matches your web form fields exactly)
  final _jobTitleController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _jobLocationController = TextEditingController();
  final _jobSalaryController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _jobRequirementsController = TextEditingController();

  // Dropdown selections (matches your web select options)
  String? selectedJobType;
  String? selectedCategory;

  // Loading state
  bool isSubmitting = false;

  @override
  void dispose() {
    // Clean up controllers
    _jobTitleController.dispose();
    _companyNameController.dispose();
    _jobLocationController.dispose();
    _jobSalaryController.dispose();
    _jobDescriptionController.dispose();
    _jobRequirementsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9, // 90% of screen height
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Modal Header (matches your web modal header)
          _buildModalHeader(),

          // Form Content (matches your web #job-post-form)
          Expanded(
            child: _buildFormContent(),
          ),
        ],
      ),
    );
  }

  /// Modal Header - matches your web modal close button and title
  Widget _buildModalHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Modal Title (matches your web h2)
          Expanded(
            child: Text(
              'Post a Job',
              style: AppTextStyles.cardTitle,
            ),
          ),

          // Close Button (matches your web .close)
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColors.textLight,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Form Content - matches your web form structure exactly
  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Title Field (matches your web #job-title)
            CustomTextField(
              label: 'Job Title',
              controller: _jobTitleController,
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Job title is required';
                }
                return null;
              },
            ),

            const SizedBox(
                height: 20), // matches .form-group margin-bottom: 20px

            // Company Name Field (matches your web #company-name)
            CustomTextField(
              label: 'Company Name',
              controller: _companyNameController,
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Company name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Job Location Field (matches your web #job-location)
            CustomTextField(
              label: 'Location',
              controller: _jobLocationController,
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Location is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Job Type Dropdown (matches your web #job-type)
            _buildJobTypeDropdown(),

            const SizedBox(height: 20),

            // Job Category Dropdown (matches your web #job-category)
            _buildCategoryDropdown(),

            const SizedBox(height: 20),

            // Salary Range Field (matches your web #job-salary)
            CustomTextField(
              label: 'Salary Range',
              controller: _jobSalaryController,
              hintText: 'e.g. \$45,000 - \$60,000',
            ),

            const SizedBox(height: 20),

            // Job Description Field (matches your web #job-description)
            TextAreaField(
              label: 'Job Description',
              controller: _jobDescriptionController,
              required: true,
              maxLines: 5,
            ),

            const SizedBox(height: 20),

            // Job Requirements Field (matches your web #job-requirements)
            TextAreaField(
              label: 'Requirements',
              controller: _jobRequirementsController,
              hintText: 'List the requirements for this position',
              maxLines: 5,
            ),

            const SizedBox(height: 30),

            // Submit Button (matches your web submit button)
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// Job Type Dropdown - matches your web job type select options
  Widget _buildJobTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        Row(
          children: [
            Text(
              'Job Type',
              style: AppTextStyles.formLabel,
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: AppColors.errorRed,
                fontSize: 16,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Dropdown
        DropdownButtonFormField<String>(
          value: selectedJobType,
          decoration: InputDecoration(
            hintText: 'Select Job Type',
            hintStyle: AppTextStyles.formPlaceholder,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  const BorderSide(color: AppColors.borderColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  const BorderSide(color: AppColors.borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  const BorderSide(color: AppColors.primaryOrange, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
          items: AppConstants.jobTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type, style: AppTextStyles.formInput),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedJobType = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Job type is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Category Dropdown - matches your web category select options
  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        Row(
          children: [
            Text(
              'Category',
              style: AppTextStyles.formLabel,
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: AppColors.errorRed,
                fontSize: 16,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Dropdown
        DropdownButtonFormField<String>(
          value: selectedCategory,
          decoration: InputDecoration(
            hintText: 'Select Category',
            hintStyle: AppTextStyles.formPlaceholder,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  const BorderSide(color: AppColors.borderColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  const BorderSide(color: AppColors.borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  const BorderSide(color: AppColors.primaryOrange, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
          items: AppConstants.jobCategories.map((category) {
            return DropdownMenuItem<String>(
              value: category['id'],
              child: Text(category['name']!, style: AppTextStyles.formInput),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Category is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Submit Button - matches your web form submit button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: isSubmitting ? 'Submitting...' : 'Submit Job',
        onPressed: isSubmitting ? null : _handleSubmit,
        type: CustomButtonType.primary,
        isLoading: isSubmitting,
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  /// Handle Form Submission - matches your web form submission logic
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      // Show validation error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Simulate API call (matches your web form submission)
      await Future.delayed(const Duration(seconds: 2));

      // Get form data
      final jobData = {
        'title': _jobTitleController.text.trim(),
        'company': _companyNameController.text.trim(),
        'location': _jobLocationController.text.trim(),
        'type': selectedJobType,
        'category': selectedCategory,
        'salary': _jobSalaryController.text.trim(),
        'description': _jobDescriptionController.text.trim(),
        'requirements': _jobRequirementsController.text.trim(),
      };

      // Close modal
      if (mounted) {
        Navigator.of(context).pop();

        // Show success message (matches your web success alert)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thank you! Your job listing for "${jobData['title']}" at "${jobData['company']}" has been submitted for review and will appear on our site soon.',
            ),
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (error) {
      // Handle error (matches your web error handling)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit job. Please try again.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }
}
