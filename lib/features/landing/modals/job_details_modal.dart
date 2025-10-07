import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_button.dart';

/// Job Details Modal - Shows complete job information
/// Appears when user taps on a job card
class JobDetailsModal extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onApply;

  const JobDetailsModal({
    super.key,
    required this.job,
    required this.onApply,
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
          // Header with close button
          _buildHeader(context),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompanySection(),
                  const SizedBox(height: 24),
                  _buildJobTitle(),
                  const SizedBox(height: 16),
                  _buildJobBadges(),
                  const SizedBox(height: 24),
                  _buildSection('Job Description', job['description']),
                  const SizedBox(height: 24),
                  _buildSection('Requirements', job['requirements']),
                  const SizedBox(height: 24),
                  _buildJobDetails(),
                  const SizedBox(height: 32),
                  _buildApplyButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Job Details',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanySection() {
    return Row(
      children: [
        // Company Logo
        _buildCompanyLogo(),
        const SizedBox(width: 16),

        // Company Name & Location
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job['company'] ?? 'Company Name',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job['location'] ?? 'Remote',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    job['posted'] ?? 'Recently posted',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyLogo() {
    final logoPath = job['company_logo'];

    if (logoPath != null && logoPath.toString().isNotEmpty) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            logoPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildLogoFallback();
            },
          ),
        ),
      );
    }

    return _buildLogoFallback();
  }

  Widget _buildLogoFallback() {
    final companyName = job['company'] ?? 'Company';
    final initials = companyName
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange.withOpacity(0.8),
            AppColors.secondaryTeal.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildJobTitle() {
    return Text(
      job['title'] ?? 'Job Title',
      style: AppTextStyles.sectionTitle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildJobBadges() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(
          icon: Icons.work_outline,
          label: job['type'] ?? 'Full-time',
          color: AppColors.primaryOrange,
        ),
        if (job['salary'] != null && job['salary'].toString().isNotEmpty)
          _buildBadge(
            icon: Icons.payments,
            label: job['salary'],
            color: Colors.green,
          ),
        if (job['remote_available'] == true || job['remote_available'] == 1)
          _buildBadge(
            icon: Icons.home,
            label: 'Remote Available',
            color: Colors.blue,
          ),
        if (job['flexible_schedule'] == true || job['flexible_schedule'] == 1)
          _buildBadge(
            icon: Icons.schedule,
            label: 'Flexible Schedule',
            color: Colors.purple,
          ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, dynamic content) {
    if (content == null || content.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 12),
        Text(
          content.toString(),
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.6,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildJobDetails() {
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
            'Job Information',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.category,
            label: 'Department',
            value: job['department'] ?? 'Not specified',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.event,
            label: 'Application Deadline',
            value: job['deadline'] != null
                ? _formatDate(job['deadline'])
                : 'No deadline',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.visibility,
            label: 'Views',
            value: '${job['views'] ?? 0} views',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.people,
            label: 'Applications',
            value: '${job['applications'] ?? 0} applicants',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryOrange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onApply,
        icon: const Icon(Icons.send, size: 20),
        label: const Text(
          'Apply for this Job',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'No deadline';

    try {
      final parsedDate = DateTime.parse(date);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[parsedDate.month - 1]} ${parsedDate.day}, ${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }
}
