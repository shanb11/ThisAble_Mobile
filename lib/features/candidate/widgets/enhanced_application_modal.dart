import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import 'dart:convert';
import '../../../config/dynamic_api_config.dart';
import 'package:url_launcher/url_launcher.dart';

class EnhancedApplicationModal extends StatefulWidget {
  final Map<String, dynamic> job;

  const EnhancedApplicationModal({
    super.key,
    required this.job,
  });

  @override
  State<EnhancedApplicationModal> createState() =>
      _EnhancedApplicationModalState();
}

class _EnhancedApplicationModalState extends State<EnhancedApplicationModal> {
  // Loading states
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Application data
  Map<String, dynamic>? _applicationData;
  String? _errorMessage;

  // Form controllers
  final _coverLetterController = TextEditingController();
  final _accessibilityNeedsController = TextEditingController();

  // Form state
  int? _selectedResumeId;
  bool _includeCoverLetter = false;
  bool _includePortfolio = false;
  bool _includeReferences = false;

  @override
  void initState() {
    super.initState();
    _loadApplicationData();
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _accessibilityNeedsController.dispose();
    super.dispose();
  }

  Future<void> _loadApplicationData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call the new API endpoint
      final response =
          await ApiService.getApplicationData(widget.job['job_id']);

      print('🔧 [Modal] API Response: ${response['success']}');

      if (response['success']) {
        final data = response['data'];

        // ✅ DEBUG: Log the data structure
        print('🔧 [Modal] Resume data: ${data['resume']}');
        print('🔧 [Modal] All resumes: ${data['all_resumes']}');
        print('🔧 [Modal] Has resume: ${data['has_resume']}');

        setState(() {
          _applicationData = data;
          _isLoading = false;

          // ✅ FIXED: Safe resume selection with deduplication
          final allResumesList = (data['all_resumes'] as List?) ?? [];

          print(
              '🔧 [Modal] Total resumes in list (before dedup): ${allResumesList.length}');

          if (allResumesList.isNotEmpty) {
            // ✅ Remove duplicates - keep first occurrence of each resume_id
            final Map<int, Map<String, dynamic>> uniqueResumesMap = {};
            for (var resume in allResumesList) {
              final resumeId = resume['resume_id'] as int?;
              if (resumeId != null && !uniqueResumesMap.containsKey(resumeId)) {
                uniqueResumesMap[resumeId] = resume;
              }
            }

            final allResumes = uniqueResumesMap.values.toList();
            print('🔧 [Modal] Total resumes after dedup: ${allResumes.length}');

            // Update the data with deduplicated list
            _applicationData!['all_resumes'] = allResumes;

            // Get all resume IDs to verify no duplicates
            final resumeIds = allResumes.map((r) => r['resume_id']).toList();
            print('🔧 [Modal] Resume IDs (after dedup): $resumeIds');

            // Try to select current resume if it exists and is valid
            if (data['resume'] != null) {
              final currentResumeId = data['resume']['resume_id'];
              print('🔧 [Modal] Current resume ID: $currentResumeId');

              final resumeExists =
                  allResumes.any((r) => r['resume_id'] == currentResumeId);

              if (resumeExists) {
                _selectedResumeId = currentResumeId;
                print('✅ [Modal] Selected current resume: $currentResumeId');
              } else {
                // Fallback to first resume
                _selectedResumeId = allResumes.first['resume_id'];
                print(
                    '⚠️ [Modal] Current resume not in list, using first: $_selectedResumeId');
              }
            } else {
              // No current resume, select first available
              _selectedResumeId = allResumes.first['resume_id'];
              print(
                  '⚠️ [Modal] No current resume, using first: $_selectedResumeId');
            }
          } else {
            // No resumes available
            _selectedResumeId = null;
            print('❌ [Modal] No resumes available');
          }

          print('🔧 [Modal] Final selected resume ID: $_selectedResumeId');
        });
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? 'Failed to load application data';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [Modal] Error loading data: $e');
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitApplication() async {
    print('🔧 [Modal] ========== SUBMIT CLICKED ==========');
    print('🔧 [Modal] Selected resume ID: $_selectedResumeId');
    print('🔧 [Modal] Is submitting: $_isSubmitting');

    if (_selectedResumeId == null) {
      print('❌ [Modal] No resume selected!');
      _showSnackBar('Please select a resume', isError: true);
      return;
    }

    if (_isSubmitting) {
      print('⚠️ [Modal] Already submitting, ignoring duplicate click');
      return;
    }

    print('✅ [Modal] Starting submission...');
    setState(() => _isSubmitting = true);

    try {
      final jobId = widget.job['job_id'];
      final coverLetter =
          _includeCoverLetter ? _coverLetterController.text : null;
      final accessibilityNeeds = _accessibilityNeedsController.text;

      print('🔧 [Modal] Job ID: $jobId');
      print('🔧 [Modal] Resume ID: $_selectedResumeId');
      print('🔧 [Modal] Include cover letter: $_includeCoverLetter');
      print('🔧 [Modal] Cover letter length: ${coverLetter?.length ?? 0}');
      print(
          '🔧 [Modal] Accessibility needs length: ${accessibilityNeeds.length}');

      print('🔧 [Modal] Calling ApiService.applyToJob...');

      final response = await ApiService.applyToJob(
        jobId: jobId,
        resumeId: _selectedResumeId!,
        coverLetter: coverLetter,
        accessibilityNeeds: accessibilityNeeds,
      );

      print('🔧 [Modal] API Response: ${response['success']}');
      print('🔧 [Modal] API Message: ${response['message']}');

      if (response['success']) {
        print('✅ [Modal] Application submitted successfully!');
        if (mounted) {
          Navigator.pop(context, true);
          _showSnackBar('Application submitted successfully!');
        }
      } else {
        print('❌ [Modal] Application failed: ${response['message']}');
        throw Exception(response['message'] ?? 'Failed to submit application');
      }
    } catch (e) {
      print('❌ [Modal] Exception during submission: $e');
      if (mounted) {
        _showSnackBar('Error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
        print('🔧 [Modal] Submission complete, button re-enabled');
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red[600] : Colors.green[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _applicationData!['already_applied']
                        ? _buildAlreadyAppliedState()
                        : _buildApplicationForm(),
          ),

          // Footer
          if (!_isLoading &&
              _errorMessage == null &&
              !(_applicationData?['already_applied'] ?? false))
            _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryTeal,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Apply for Job',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.job['job_title'] ?? 'Position',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryTeal),
          ),
          SizedBox(height: 16),
          Text(
            'Loading application data...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadApplicationData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyAppliedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green[400]),
            const SizedBox(height: 24),
            const Text(
              'Already Applied',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have already applied for this position',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryTeal,
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationForm() {
    final hasResume = _applicationData!['has_resume'];
    final resume = _applicationData!['resume'];
    final allResumes = _applicationData!['all_resumes'] as List;
    final matchPercentage = _applicationData!['match_percentage'];
    final tips = _applicationData!['personalization_tips'] as List;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company info
          _buildJobOverview(),

          const SizedBox(height: 24),

          // Resume section
          if (hasResume) ...[
            _buildResumeSection(resume, matchPercentage, allResumes),
            const SizedBox(height: 16),
            _buildPersonalizationTips(tips),
          ] else
            _buildNoResumeWarning(),

          const SizedBox(height: 24),

          // Additional materials
          _buildAdditionalMaterials(),

          const SizedBox(height: 24),

          // Accessibility needs
          _buildAccessibilitySection(),

          const SizedBox(height: 80), // Space for footer
        ],
      ),
    );
  }

  Widget _buildJobOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.job['job_title'] ?? 'Position',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.job['company_name'] ?? 'Company',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeSection(
      Map<String, dynamic> resume, int matchPercentage, List allResumes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resume',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pwdGreenLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.description,
                      color: AppColors.secondaryTeal, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resume['file_name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$matchPercentage% match to job requirements',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.pwdGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ✅ FIXED: View button with action
                  TextButton(
                    onPressed: () => _viewResume(resume['file_path']),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondaryTeal,
                    ),
                    child: const Text('View'),
                  ),
                ],
              ),
              // Dropdown to select different resume if multiple exist
              if (allResumes.length > 1) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedResumeId,
                      isExpanded: true,
                      hint: const Text('Select a different resume'),
                      items: allResumes
                          .map((r) {
                            final resumeId = r['resume_id'] as int?;
                            final fileName =
                                r['file_name'] as String? ?? 'Unknown';
                            final isCurrent =
                                r['is_current'] == true || r['is_current'] == 1;

                            // ✅ Skip invalid items
                            if (resumeId == null) {
                              print(
                                  '⚠️ [Modal] Skipping resume with null ID: $fileName');
                              return null;
                            }

                            return DropdownMenuItem<int>(
                              value: resumeId,
                              child: Row(
                                children: [
                                  Icon(
                                    isCurrent
                                        ? Icons.check_circle
                                        : Icons.description,
                                    size: 16,
                                    color:
                                        isCurrent ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      fileName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                          .whereType<DropdownMenuItem<int>>()
                          .toList(), // ✅ Filter out nulls
                      onChanged: (int? resumeId) {
                        if (resumeId != null) {
                          setState(() {
                            _selectedResumeId = resumeId;
                            print('🔧 [Modal] User selected resume: $resumeId');
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

// ✅ ADD THIS METHOD to the class
  Future<void> _viewResume(String filePath) async {
    try {
      // Build the full URL to the resume
      // Your API returns path like: "uploads/resumes/4_687069b7b536b.pdf"
      final baseUrl =
          await DynamicApiConfig.getBaseUrl(); // Gets your server URL
      final resumeUrl = '$baseUrl/$filePath';

      print('🔧 Opening resume: $resumeUrl');

      // Open the PDF in browser
      final uri = Uri.parse(resumeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _showSnackBar('Opening resume...');
      } else {
        _showSnackBar('Could not open resume', isError: true);
      }
    } catch (e) {
      print('Error opening resume: $e');
      _showSnackBar('Error opening resume: $e', isError: true);
    }
  }

  Widget _buildPersonalizationTips(List tips) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Personalization Tips',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: Colors.blue[700])),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNoResumeWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange[700], size: 48),
          const SizedBox(height: 12),
          Text(
            'No Resume Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange[900],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please upload a resume in your profile before applying.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to profile - you can implement this
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Go to Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalMaterials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Materials',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: _includeCoverLetter,
          onChanged: (value) {
            setState(() => _includeCoverLetter = value ?? false);
          },
          title: const Text('Include cover letter'),
          activeColor: AppColors.secondaryTeal,
          contentPadding: EdgeInsets.zero,
        ),
        if (_includeCoverLetter) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _coverLetterController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write a brief message to the employer...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
        CheckboxListTile(
          value: _includePortfolio,
          onChanged: (value) {
            setState(() => _includePortfolio = value ?? false);
          },
          title: const Text('Include portfolio link'),
          activeColor: AppColors.secondaryTeal,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          value: _includeReferences,
          onChanged: (value) {
            setState(() => _includeReferences = value ?? false);
          },
          title: const Text('Include references'),
          activeColor: AppColors.secondaryTeal,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildAccessibilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accessibility Needs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _accessibilityNeedsController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'Please share any accessibility accommodations you may need during the interview process...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final hasResume = _applicationData?['has_resume'] ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  print('🔧 [Modal] Cancel button clicked');
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: !hasResume || _isSubmitting
                    ? () {
                        print('⚠️ [Modal] Submit button disabled');
                        print(
                            '⚠️ [Modal] hasResume: $hasResume, isSubmitting: $_isSubmitting');
                      }
                    : () {
                        print('🔧 [Modal] Submit button clicked!');
                        _submitApplication();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasResume && !_isSubmitting
                      ? AppColors.secondaryTeal
                      : Colors.grey,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(hasResume
                        ? 'Submit Application'
                        : 'Upload Resume First'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
