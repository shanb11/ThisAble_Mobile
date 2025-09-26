import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';

/// Job Detail Modal - Exact mirror of your web job detail modal
/// Shows complete job information with PWD accommodations
class JobDetailModal extends StatefulWidget {
  final Map<String, dynamic> job;
  final VoidCallback? onJobUpdated; // Callback when job is saved/applied

  const JobDetailModal({
    super.key,
    required this.job,
    this.onJobUpdated,
  });

  @override
  State<JobDetailModal> createState() => _JobDetailModalState();
}

class _JobDetailModalState extends State<JobDetailModal> {
  bool _showApplicationForm = false;
  bool _isLoading = false;
  late Map<String, dynamic> _currentJob;

  // TTS for reading job details
  FlutterTts? _flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _currentJob = Map<String, dynamic>.from(widget.job);
    _initializeTTS();
  }

  @override
  void dispose() {
    _flutterTts?.stop();
    super.dispose();
  }

  /// Initialize TTS for reading job details
  Future<void> _initializeTTS() async {
    _flutterTts = FlutterTts();
    await _flutterTts?.setLanguage("en-US");
    await _flutterTts?.setSpeechRate(0.9);
    await _flutterTts?.setVolume(0.8);

    _flutterTts?.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  /// Read entire job details using TTS
  Future<void> _readJobDetails() async {
    if (_flutterTts == null) return;

    await _flutterTts?.stop();

    final jobText = ApiService.formatJobForTTS(_currentJob);

    // Add additional details for modal reading
    String detailedText = jobText;

    // Add job description
    if (_currentJob['description'] != null &&
        _currentJob['description'].toString().isNotEmpty) {
      detailedText += ' Full job description: ${_currentJob['description']}';
    }

    // Add requirements
    if (_currentJob['requirements'] != null &&
        _currentJob['requirements'].toString().isNotEmpty) {
      detailedText += ' Job requirements: ${_currentJob['requirements']}';
    }

    await _flutterTts?.speak(detailedText);
    setState(() {
      _isSpeaking = true;
    });
  }

  /// Toggle save job
  Future<void> _toggleSaveJob() async {
    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.toggleSaveJob(_currentJob['job_id']);

    if (result['success']) {
      setState(() {
        _currentJob['user_saved'] = !_currentJob['user_saved'];
      });
      _showSnackBar(
          _currentJob['user_saved'] ? 'Job saved' : 'Job removed from saved');
      widget.onJobUpdated?.call(); // Notify parent to refresh
    } else {
      _showSnackBar('Failed to save job');
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Show snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child:
          _showApplicationForm ? _buildApplicationForm() : _buildJobDetails(),
    );
  }

  /// Build job details view (main modal content)
  Widget _buildJobDetails() {
    final accommodations =
        _currentJob['accommodations'] as List<dynamic>? ?? [];
    final features = _currentJob['features'] as List<dynamic>? ?? [];
    final isSaved = _currentJob['user_saved'] as bool? ?? false;
    final hasApplied = _currentJob['user_applied'] as bool? ?? false;

    return Column(
      children: [
        // Modal header with company info and controls
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.secondaryTeal, // Using your exact color naming
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              // Company logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    (_currentJob['company'] as String)
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentJob['title'] ?? 'Job Title',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentJob['company']} • ${_currentJob['location']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // TTS Button
              IconButton(
                onPressed:
                    _isSpeaking ? () => _flutterTts?.stop() : _readJobDetails,
                icon: Icon(
                  _isSpeaking ? Icons.stop : Icons.volume_up,
                  color: Colors.white,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),

              // Close Button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Information Section
                _buildSection(
                  'Job Information',
                  Icons.work_outline,
                  Column(
                    children: [
                      _buildInfoRow('Position', _currentJob['title'] ?? 'N/A'),
                      _buildInfoRow('Company', _currentJob['company'] ?? 'N/A'),
                      _buildInfoRow(
                          'Location', _currentJob['location'] ?? 'N/A'),
                      _buildInfoRow('Employment Type',
                          _currentJob['employment_type'] ?? 'N/A'),
                      _buildInfoRow('Salary Range',
                          _currentJob['salary_range'] ?? 'Competitive'),
                      _buildInfoRow(
                          'Department', _currentJob['department'] ?? 'N/A'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Job Description Section
                if (_currentJob['description'] != null &&
                    _currentJob['description'].toString().isNotEmpty)
                  _buildSection(
                    'Job Description',
                    Icons.description_outlined,
                    Text(
                      _currentJob['description'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Requirements Section
                if (_currentJob['requirements'] != null &&
                    _currentJob['requirements'].toString().isNotEmpty)
                  _buildSection(
                    'Requirements',
                    Icons.checklist_outlined,
                    Text(
                      _currentJob['requirements'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // PWD Accommodations & Support Section (KEY FEATURE)
                if (accommodations.isNotEmpty || features.isNotEmpty)
                  _buildSection(
                    'PWD Accommodations & Support',
                    Icons.accessible,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (accommodations.isNotEmpty) ...[
                          const Text(
                            'Workplace Accommodations:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.pwdGreen,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: accommodations
                                .map((acc) =>
                                    _buildAccommodationBadge(acc.toString()))
                                .toList(),
                          ),
                          if (features.isNotEmpty) const SizedBox(height: 20),
                        ],
                        if (features.isNotEmpty) ...[
                          const Text(
                            'Additional Benefits:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.pwdBlue,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: features
                                .map((feature) =>
                                    _buildFeatureBadge(feature.toString()))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Job Statistics Section
                _buildSection(
                  'Job Statistics',
                  Icons.bar_chart_outlined,
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          Icons.visibility,
                          '${_currentJob['views'] ?? 0} views',
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          Icons.people,
                          '${_currentJob['applications'] ?? 0} applications',
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          Icons.schedule,
                          'Posted ${_currentJob['posted_time'] ?? 'recently'}',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Action buttons (matching web modal footer)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              // Save button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _toggleSaveJob,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved
                              ? AppColors.primaryOrange
                              : AppColors.secondaryTeal,
                        ),
                  label: Text(
                    isSaved ? 'Saved' : 'Save',
                    style: TextStyle(
                      color: isSaved
                          ? AppColors.primaryOrange
                          : AppColors.secondaryTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isSaved
                          ? AppColors.primaryOrange
                          : AppColors.secondaryTeal,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Apply button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: hasApplied
                      ? null
                      : () {
                          setState(() {
                            _showApplicationForm = true;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasApplied ? Colors.grey : AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    hasApplied ? 'Applied' : 'Apply Now',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build application form (placeholder for now)
  Widget _buildApplicationForm() {
    return Column(
      children: [
        // Application form header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.secondaryTeal,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showApplicationForm = false;
                  });
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Apply for Position',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),

        // Application form content (placeholder)
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Application Form',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Coming soon! This will include resume upload,\ncover letter, and accessibility needs.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showApplicationForm = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryTeal,
                  ),
                  child: const Text(
                    'Back to Job Details',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build section with title and icon
  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.secondaryTeal, size: 22),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  /// Build info row for job details
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build PWD accommodation badge (green styling)
  Widget _buildAccommodationBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.pwdGreenLight,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.pwdGreenBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.pwdGreen,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.pwdGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build feature badge (blue styling)
  Widget _buildFeatureBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.pwdBlueLight,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.pwdBlueBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 16,
            color: AppColors.pwdBlue,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.pwdBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build stat item
  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
