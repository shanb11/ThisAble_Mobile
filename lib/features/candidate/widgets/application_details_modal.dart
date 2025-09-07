import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/api_service.dart';

/// PHASE 3: Comprehensive Application Details Modal
/// Web-parity modal with full application details, timeline, and professional styling
class ApplicationDetailsModal extends StatefulWidget {
  final Map<String, dynamic> application;
  final VoidCallback? onWithdraw;

  const ApplicationDetailsModal({
    super.key,
    required this.application,
    this.onWithdraw,
  });

  @override
  State<ApplicationDetailsModal> createState() =>
      _ApplicationDetailsModalState();
}

class _ApplicationDetailsModalState extends State<ApplicationDetailsModal> {
  // ThisAble Colors
  static const Color primaryColor = Color(0xFF257180);
  static const Color secondaryColor = Color(0xFFF2E5BF);
  static const Color accentColor = Color(0xFFFD8B51);
  static const Color sidebarColor = Color(0xFF2F8A99);

  bool _isLoadingDetails = false;
  Map<String, dynamic>? _detailedData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetailedApplicationData();
  }

  /// Load comprehensive application data from API
  Future<void> _loadDetailedApplicationData() async {
    setState(() {
      _isLoadingDetails = true;
      _errorMessage = null;
    });

    try {
      final applicationId = widget.application['application_id'];
      if (applicationId == null) {
        throw Exception('Application ID not found');
      }

      final result = await ApiService.getApplicationDetails(applicationId);

      if (result['success'] == true) {
        setState(() {
          _detailedData = result['data'];
          _isLoadingDetails = false;
        });
      } else {
        setState(() {
          _errorMessage =
              result['message'] ?? 'Failed to load application details';
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading application details: $e';
        _isLoadingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
          _buildModalActions(),
        ],
      ),
    );
  }

  /// Enhanced modal header with job title and company
  Widget _buildModalHeader(BuildContext context) {
    final jobTitle =
        widget.application['job_title']?.toString() ?? 'Application Details';
    final companyName = widget.application['company_name']?.toString() ?? '';

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
                  jobTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (companyName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    companyName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  /// Comprehensive modal content
  Widget _buildModalContent() {
    if (_isLoadingDetails) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading application details...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildApplicationStatusSection(),
          const SizedBox(height: 24),
          _buildJobInformationSection(),
          const SizedBox(height: 24),
          _buildJobDescriptionSection(),
          const SizedBox(height: 24),
          _buildRequirementsSection(),
          const SizedBox(height: 24),
          _buildContactInformationSection(),
          const SizedBox(height: 24),
          _buildApplicationTimelineSection(),
          const SizedBox(height: 24),
          _buildNextStepsSection(),
          const SizedBox(height: 100), // Space for bottom actions
        ],
      ),
    );
  }

  /// Error state widget
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadDetailedApplicationData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Application status with progress indicator
  Widget _buildApplicationStatusSection() {
    final status =
        widget.application['application_status']?.toString() ?? 'submitted';
    final appliedDate = widget.application['applied_at']?.toString() ??
        widget.application['application_date']?.toString() ??
        '';

    return _buildSection(
      title: 'Application Status',
      icon: Icons.timeline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildStatusProgress(status),
          const SizedBox(height: 20),
          _buildInfoGrid([
            _InfoItem('Status', _getStatusDisplayName(status)),
            _InfoItem('Applied Date', _formatDate(appliedDate)),
            _InfoItem('Application ID',
                widget.application['application_id']?.toString() ?? 'Unknown'),
            _InfoItem(
                'Last Updated',
                _formatDate(
                    widget.application['status_updated_at']?.toString() ?? '')),
          ]),
        ],
      ),
    );
  }

  /// UPDATED: Safe job information section
  Widget _buildJobInformationSection() {
    return _buildSection(
      title: 'Job Information',
      icon: Icons.work_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildInfoGrid([
            _InfoItem('Position',
                widget.application['job_title']?.toString() ?? 'Unknown'),
            _InfoItem('Company',
                widget.application['company_name']?.toString() ?? 'Unknown'),
            _InfoItem(
                'Location',
                _getDetailedValue('location') ??
                    widget.application['location']?.toString() ??
                    'Not specified'),
            _InfoItem(
                'Employment Type',
                _getDetailedValue('employment_type') ??
                    widget.application['employment_type']?.toString() ??
                    'Not specified'),
            _InfoItem('Salary Range', _buildSalaryRange()),
            _InfoItem('Department',
                _getDetailedValue('department') ?? 'Not specified'),
          ]),
        ],
      ),
    );
  }

  /// Job description section
  Widget _buildJobDescriptionSection() {
    final description = _getDetailedValue('job_description');

    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      title: 'Job Description',
      icon: Icons.description_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Requirements section
  Widget _buildRequirementsSection() {
    final requirements = _getDetailedValue('job_requirements');

    if (requirements == null || requirements.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      title: 'Requirements',
      icon: Icons.checklist_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            requirements,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// UPDATED: Safe contact information section
  Widget _buildContactInformationSection() {
    // Try multiple ways to get contact info
    final firstName = _getDetailedValue('hr_first_name') ??
        _detailedData?['contact']?['name']?.toString()?.split(' ')?.first;
    final lastName = _getDetailedValue('hr_last_name') ??
        _detailedData?['contact']?['name']?.toString()?.split(' ')?.last;

    final contactPerson =
        (firstName != null && lastName != null && firstName != lastName)
            ? '$firstName $lastName'
            : _detailedData?['contact']?['name']?.toString() ?? 'HR Team';

    final position = _getDetailedValue('hr_position') ??
        _detailedData?['contact']?['position']?.toString() ??
        'HR Manager';

    final email = _getDetailedValue('hr_email') ??
        _detailedData?['contact']?['email']?.toString() ??
        'Not available';

    final phone = _getDetailedValue('hr_phone') ??
        _detailedData?['contact']?['phone']?.toString() ??
        'Not available';

    return _buildSection(
      title: 'Contact Information',
      icon: Icons.contact_phone_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildInfoGrid([
            _InfoItem('Contact Person', contactPerson),
            _InfoItem('Position', position),
            _InfoItem('Email', email),
            _InfoItem('Phone', phone),
          ]),
        ],
      ),
    );
  }

  /// Application timeline section
  Widget _buildApplicationTimelineSection() {
    return _buildSection(
      title: 'Application Timeline',
      icon: Icons.history,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildTimelineItem(
            'Application Submitted',
            _formatDate(widget.application['applied_at']?.toString() ?? ''),
            'Your application has been successfully submitted.',
            isCompleted: true,
          ),
          if (_getCurrentStatusIndex() > 0) ...[
            _buildTimelineItem(
              'Under Review',
              _formatDate(
                  widget.application['status_updated_at']?.toString() ?? ''),
              'Your application is being reviewed by the hiring team.',
              isCompleted: _getCurrentStatusIndex() > 0,
            ),
          ],
          if (_getCurrentStatusIndex() > 1) ...[
            _buildTimelineItem(
              'Interview Scheduled',
              'Pending',
              'An interview will be scheduled if you meet the requirements.',
              isCompleted: _getCurrentStatusIndex() > 1,
            ),
          ],
        ],
      ),
    );
  }

  /// Next steps section
  Widget _buildNextStepsSection() {
    final status =
        widget.application['application_status']?.toString() ?? 'submitted';
    String nextStepsText;

    switch (status) {
      case 'submitted':
        nextStepsText =
            'Your application is being reviewed. You\'ll be notified once there\'s an update.';
        break;
      case 'under_review':
        nextStepsText =
            'Your application is under review. You\'ll be contacted if you meet the requirements.';
        break;
      case 'interview_scheduled':
        nextStepsText =
            'An interview has been scheduled. Check your email for details.';
        break;
      case 'hired':
        nextStepsText =
            'Congratulations! You\'ve been selected for this position.';
        break;
      case 'rejected':
        nextStepsText =
            'Unfortunately, you weren\'t selected for this position this time.';
        break;
      default:
        nextStepsText = 'Stay tuned for updates on your application status.';
    }

    return _buildSection(
      title: 'Next Steps',
      icon: Icons.arrow_forward_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: accentColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nextStepsText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Status progress indicator
  Widget _buildStatusProgress(String status) {
    final steps = ['submitted', 'under_review', 'interview_scheduled', 'hired'];
    final currentIndex = _getCurrentStatusIndex();

    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final stepStatus = entry.value;
        final isActive = index <= currentIndex;
        final isRejected = status == 'rejected';

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isRejected
                        ? Colors.red[300]
                        : isActive
                            ? primaryColor
                            : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (index < steps.length - 1) const SizedBox(width: 8),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Timeline item widget
  Widget _buildTimelineItem(String title, String date, String description,
      {required bool isCompleted}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isCompleted ? primaryColor : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.grey[800] : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section container widget
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(icon, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  /// Info grid widget
  Widget _buildInfoGrid(List<_InfoItem> items) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2) ...[
          Row(
            children: [
              Expanded(child: _buildInfoItem(items[i])),
              const SizedBox(width: 16),
              Expanded(
                child: i + 1 < items.length
                    ? _buildInfoItem(items[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          if (i + 2 < items.length) const SizedBox(height: 12),
        ],
      ],
    );
  }

  /// Individual info item
  Widget _buildInfoItem(_InfoItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.value.isEmpty ? 'Not specified' : item.value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Modal action buttons
  Widget _buildModalActions() {
    final status =
        widget.application['application_status']?.toString() ?? 'submitted';
    final canWithdraw =
        ['submitted', 'under_review', 'interview_scheduled'].contains(status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (canWithdraw) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onWithdraw,
                  icon: Icon(
                    Icons.cancel_outlined,
                    size: 18,
                    color: Colors.red[600],
                  ),
                  label: const Text('Withdraw'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    side: BorderSide(color: Colors.red[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// UPDATED: Safe detailed value getter
  String? _getDetailedValue(String key) {
    // Try multiple possible locations for the data
    if (_detailedData != null) {
      // Try direct key
      if (_detailedData!.containsKey(key)) {
        final value = _detailedData![key];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }

      // Try nested in job object
      if (_detailedData!['job'] != null && _detailedData!['job'][key] != null) {
        return _detailedData!['job'][key].toString();
      }

      // Try nested in company object
      if (_detailedData!['company'] != null &&
          _detailedData!['company'][key] != null) {
        return _detailedData!['company'][key].toString();
      }
    }

    // Fallback to original application data
    if (widget.application.containsKey(key)) {
      final value = widget.application[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }

    return null;
  }

  /// UPDATED: Safe salary range builder
  String _buildSalaryRange() {
    // Try multiple possible salary field names
    final salaryOptions = [
      _getDetailedValue('salary_range'),
      _getDetailedValue('salary'),
      _detailedData?['job']?['salary'],
      widget.application['salary_range'],
      widget.application['salary'],
    ];

    for (final salary in salaryOptions) {
      if (salary != null &&
          salary.toString().isNotEmpty &&
          salary.toString() != 'null') {
        final salaryStr = salary.toString();
        // If it's just a number, format it
        if (RegExp(r'^\d+$').hasMatch(salaryStr)) {
          return '₱${int.parse(salaryStr).toString()}';
        }
        return salaryStr;
      }
    }

    return 'Not specified';
  }

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

  int _getCurrentStatusIndex() {
    final status =
        widget.application['application_status']?.toString() ?? 'submitted';
    switch (status) {
      case 'submitted':
        return 0;
      case 'under_review':
        return 1;
      case 'interview_scheduled':
        return 2;
      case 'hired':
        return 3;
      default:
        return 0;
    }
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return 'Unknown';

      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }

// ADD THESE HELPER METHODS TO YOUR ApplicationDetailsModal class
// Place them at the bottom of the class, before the final closing brace

  /// SAFE HELPER: Get value from detailed data with multiple fallbacks
  String? _getDetailedValueSafe(String key) {
    // Try the detailed data first
    if (_detailedData != null && _detailedData!.containsKey(key)) {
      return _detailedData![key]?.toString();
    }

    // Fallback to the original application data
    if (widget.application.containsKey(key)) {
      return widget.application[key]?.toString();
    }

    return null;
  }

  /// SAFE HELPER: Build salary range with multiple fallbacks
  String _buildSalaryRangeSafe() {
    // Try multiple possible field names
    final candidates = [
      _getDetailedValueSafe('salary_range'),
      _getDetailedValueSafe('salary'),
      _getDetailedValueSafe('salary_min'),
      _getDetailedValueSafe('salary_max'),
      widget.application['salary_range']?.toString(),
      widget.application['salary']?.toString(),
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate.isNotEmpty && candidate != 'null') {
        // If it's just a number, add peso sign
        if (RegExp(r'^\d+$').hasMatch(candidate)) {
          return '₱${int.parse(candidate).toString()}';
        }
        return candidate;
      }
    }

    return 'Not specified';
  }

  /// SAFE HELPER: Get value with fallbacks
  String _getSafeValue(
      String primaryKey, String fallbackKey, String defaultValue) {
    return _getDetailedValueSafe(primaryKey) ??
        _getDetailedValueSafe(fallbackKey) ??
        widget.application[primaryKey]?.toString() ??
        widget.application[fallbackKey]?.toString() ??
        defaultValue;
  }
}

/// Data class for info items
class _InfoItem {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);
}
