import 'package:flutter/material.dart';

/// PHASE 1: Basic Application Details Modal
/// This will be enhanced in subsequent phases
class ApplicationDetailsModal extends StatelessWidget {
  final Map<String, dynamic> application;
  final VoidCallback? onWithdraw;

  const ApplicationDetailsModal({
    super.key,
    required this.application,
    this.onWithdraw,
  });

  // ThisAble Colors
  static const Color primaryColor = Color(0xFF257180);
  static const Color secondaryColor = Color(0xFFF2E5BF);
  static const Color accentColor = Color(0xFFFD8B51);
  static const Color sidebarColor = Color(0xFF2F8A99);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildModalHeader(context),
          Expanded(
            child: _buildModalContent(),
          ),
        ],
      ),
    );
  }

  /// Modal header with close button
  Widget _buildModalHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Application Details',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  application['job_title']?.toString() ?? 'Job Application',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// PHASE 1: Basic modal content (will be enhanced in Phase 3)
  Widget _buildModalContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicJobInfo(),
          const SizedBox(height: 24),
          _buildBasicApplicationInfo(),
          const SizedBox(height: 24),
          _buildPlaceholderSections(),
          const SizedBox(height: 100), // Space for bottom actions
        ],
      ),
    );
  }

  /// Basic job information
  Widget _buildBasicJobInfo() {
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
              'Position', application['job_title']?.toString() ?? 'Unknown'),
          _buildInfoRow(
              'Company', application['company_name']?.toString() ?? 'Unknown'),
          if (application['location'] != null)
            _buildInfoRow('Location', application['location'].toString()),
          if (application['employment_type'] != null)
            _buildInfoRow('Type', application['employment_type'].toString()),
        ],
      ),
    );
  }

  /// Basic application information
  Widget _buildBasicApplicationInfo() {
    final status = application['application_status']?.toString() ?? 'submitted';
    final appliedDate = application['applied_at']?.toString() ??
        application['application_date']?.toString() ??
        '';

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
            'Application Status',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Status', _getStatusDisplayName(status)),
          _buildInfoRow('Applied Date', _formatDate(appliedDate)),
          _buildInfoRow('Application ID',
              application['application_id']?.toString() ?? 'Unknown'),
        ],
      ),
    );
  }

  /// Placeholder for future enhancements
  Widget _buildPlaceholderSections() {
    return Column(
      children: [
        _buildPlaceholderSection('Job Description', 'Will be added in Phase 3'),
        const SizedBox(height: 16),
        _buildPlaceholderSection('Requirements', 'Will be added in Phase 3'),
        const SizedBox(height: 16),
        _buildPlaceholderSection(
            'Contact Information', 'Will be added in Phase 3'),
        const SizedBox(height: 16),
        _buildPlaceholderSection(
            'Application Timeline', 'Will be added in Phase 3'),
      ],
    );
  }

  /// Placeholder section widget
  Widget _buildPlaceholderSection(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.construction, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper: Build info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not specified' : value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper: Get status display name
  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'submitted':
        return 'Applied';
      case 'under_review':
        return 'Under Review';
      case 'interview_scheduled':
        return 'Interview Scheduled';
      case 'hired':
        return 'Offered';
      case 'rejected':
        return 'Rejected';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return status;
    }
  }

  /// Helper: Format date
  String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return 'Unknown';

      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
