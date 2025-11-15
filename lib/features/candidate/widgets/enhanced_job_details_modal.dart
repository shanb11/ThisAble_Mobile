import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import '../../../shared/widgets/tts_button.dart';
import '../../../core/services/tts_service.dart'; // ✨ ADD THIS

class EnhancedJobDetailsModal extends StatelessWidget {
  final Map<String, dynamic> job;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onApply;
  final String ttsText; // ✨ ADD THIS LINE - Field declaration

  const EnhancedJobDetailsModal({
    super.key,
    required this.job,
    required this.isSaved,
    required this.onSave,
    required this.onApply,
    required this.ttsText, // ✨ ADD THIS LINE - Constructor parameter
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildJobInfo(),
                  const SizedBox(height: 24),
                  _buildRequirements(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildPWDAccommodations(),
                  const SizedBox(height: 24),
                  _buildJobStatistics(),
                  const SizedBox(height: 80), // Space for footer
                ],
              ),
            ),
          ),

          // Footer
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryTeal,
            AppColors.secondaryTeal.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryTeal.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                    Text(
                      job['job_title'] ?? job['title'] ?? 'Job Title',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job['company_name'] ?? job['company'] ?? 'Company'} • ${job['location'] ?? 'Location'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // ✨ TTS BUTTON - ADD THIS
              IconButton(
                onPressed: () {
                  // Play TTS
                  final ttsService = TTSService();
                  ttsService.speak(_buildTTSText());
                },
                icon: const Icon(Icons.volume_up, color: Colors.white),
                iconSize: 28,
                tooltip: 'Read job details aloud',
              ),

              const SizedBox(width: 8),

              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
                iconSize: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobInfo() {
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
          Row(
            children: [
              const Icon(Icons.work_outline, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Job Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Position', job['job_title'] ?? job['title']),
          _buildInfoRow(
              'Employment Type', job['employment_type'] ?? 'Full-time'),
          if (job['salary_range'] != null)
            _buildInfoRow('Salary Range', job['salary_range']),
          _buildInfoRow('Posted', job['posted_time'] ?? 'Recently'),
          if (job['deadline'] != null)
            _buildInfoRow('Deadline', job['deadline']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirements() {
    final requirements = job['requirements'] ?? job['job_requirements'];
    if (requirements == null || requirements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.checklist, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Requirements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            requirements,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    final description = job['description'] ?? job['job_description'];
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description_outlined, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Job Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            description,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildPWDAccommodations() {
    final accommodations =
        job['accommodations'] ?? job['pwd_accommodations'] ?? [];
    if (accommodations is! List || accommodations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.accessible, size: 20, color: AppColors.pwdGreen),
            const SizedBox(width: 8),
            const Text(
              'PWD Accommodations & Support',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: accommodations.map((accommodation) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.pwdGreenLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.pwdGreen),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getAccommodationIcon(accommodation),
                    size: 16,
                    color: AppColors.pwdGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    accommodation,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.pwdGreen,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getAccommodationIcon(String accommodation) {
    final lower = accommodation.toLowerCase();
    if (lower.contains('wheelchair')) return Icons.accessible;
    if (lower.contains('flexible')) return Icons.schedule;
    if (lower.contains('assistive') || lower.contains('technology'))
      return Icons.computer;
    if (lower.contains('remote')) return Icons.home;
    if (lower.contains('screen reader')) return Icons.visibility;
    if (lower.contains('sign language')) return Icons.sign_language;
    if (lower.contains('workspace')) return Icons.desk;
    if (lower.contains('transport')) return Icons.directions_car;
    return Icons.check_circle;
  }

  Widget _buildJobStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bar_chart, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Job Statistics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.visibility,
                '${job['views'] ?? job['views_count'] ?? 0}',
                'Views',
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _buildStatItem(
                Icons.people,
                '${job['applications'] ?? job['applications_count'] ?? 0}',
                'Applications',
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _buildStatItem(
                Icons.calendar_today,
                job['posted_time'] ?? 'Recently',
                'Posted',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.secondaryTeal),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final hasApplied = job['has_applied'] ?? job['user_applied'] ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Share button
          IconButton(
            onPressed: () => _shareJob(context),
            icon: const Icon(Icons.share),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          // Save button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onSave,
              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
              label: Text(isSaved ? 'Saved' : 'Save'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: isSaved
                      ? AppColors.primaryOrange
                      : AppColors.secondaryTeal,
                ),
                foregroundColor:
                    isSaved ? AppColors.primaryOrange : AppColors.secondaryTeal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Apply button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: hasApplied ? null : onApply,
              icon: Icon(hasApplied ? Icons.check_circle : Icons.send),
              label: Text(hasApplied ? 'Applied' : 'Apply Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    hasApplied ? Colors.grey : AppColors.secondaryTeal,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareJob(BuildContext context) {
    // Option 1: Native share (recommended for mobile)
    final jobTitle = job['job_title'] ?? job['title'] ?? 'Job';
    final company = job['company_name'] ?? job['company'] ?? 'Company';
    final jobId = job['job_id'] ?? job['id'];

    final shareText = 'Check out this job opportunity!\n\n'
        '$jobTitle at $company\n\n'
        'Apply now on ThisAble: https://thisable.org/jobs/$jobId';

    Share.share(shareText, subject: 'Job Opportunity: $jobTitle');

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share dialog opened'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Build TTS text for this modal
  String _buildTTSText() {
    String text = "Job details. ";
    text += "Position: ${job['job_title'] ?? job['title']}. ";
    text += "Company: ${job['company_name'] ?? job['company']}. ";

    if (job['location'] != null) {
      text += "Location: ${job['location']}. ";
    }

    if (job['employment_type'] != null) {
      text += "Employment type: ${job['employment_type']}. ";
    }

    if (job['salary_range'] != null) {
      text += "Salary range: ${job['salary_range']}. ";
    }

    final description = job['description'] ?? job['job_description'];
    if (description != null && description.toString().isNotEmpty) {
      text += "Job description: $description. ";
    }

    final requirements = job['requirements'] ?? job['job_requirements'];
    if (requirements != null && requirements.toString().isNotEmpty) {
      text += "Requirements: $requirements. ";
    }

    final accommodations =
        job['accommodations'] ?? job['pwd_accommodations'] ?? [];
    if (accommodations is List && accommodations.isNotEmpty) {
      text += "Accessibility accommodations: ";
      final accNames = accommodations.map((acc) {
        return acc is String
            ? acc
            : (acc['name']?.toString() ?? acc.toString());
      }).join(', ');
      text += "$accNames. ";
    }

    return text;
  }
}
