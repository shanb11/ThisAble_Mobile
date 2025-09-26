import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../widgets/job_detail_modal.dart';

/// Enhanced Jobs Screen - Exact mirror of your web jobs page
/// FIXED: Uses your exact class name and color conventions
class CandidateJobListingsScreen extends StatefulWidget {
  const CandidateJobListingsScreen({super.key});

  @override
  State<CandidateJobListingsScreen> createState() =>
      _CandidateJobListingsScreenState();
}

class _CandidateJobListingsScreenState
    extends State<CandidateJobListingsScreen> {
  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedLocation = '';
  String _selectedJobType = '';

  // Data state
  List<Map<String, dynamic>> _jobs = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMoreData = true;

  // TTS and Voice Search
  FlutterTts? _flutterTts;
  stt.SpeechToText? _speech;
  bool _isListening = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _initializeVoiceSearch();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _flutterTts?.stop();
    super.dispose();
  }

  /// Initialize TTS (matching your web TTS functionality)
  Future<void> _initializeTTS() async {
    _flutterTts = FlutterTts();

    await _flutterTts?.setLanguage("en-US");
    await _flutterTts?.setSpeechRate(0.9); // Match web default speed
    await _flutterTts?.setVolume(0.8);
    await _flutterTts?.setPitch(1.0);

    _flutterTts?.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  /// Initialize Voice Search (matching your web voice search)
  Future<void> _initializeVoiceSearch() async {
    _speech = stt.SpeechToText();
    await _speech?.initialize();
  }

  /// Load jobs from enhanced API
  Future<void> _loadJobs({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _jobs.clear();
        _hasMoreData = true;
        _hasError = false;
      });
    }

    try {
      final response = await ApiService.getEnhancedJobListings(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        location: _selectedLocation.isNotEmpty ? _selectedLocation : null,
        jobType: _selectedJobType.isNotEmpty ? _selectedJobType : null,
        page: _currentPage,
        limit: 20,
      );

      if (response['success']) {
        final jobsData = response['data']['jobs'] as List<dynamic>;
        final pagination =
            response['data']['pagination'] as Map<String, dynamic>;
        final stats = response['data']['statistics'] as Map<String, dynamic>;

        setState(() {
          if (refresh || _currentPage == 1) {
            _jobs = jobsData.cast<Map<String, dynamic>>();
          } else {
            _jobs.addAll(jobsData.cast<Map<String, dynamic>>());
          }
          _statistics = stats;
          _hasMoreData = pagination['has_more'] ?? false;
          _isLoading = false;
          _hasError = false;
        });

        // Read summary if TTS is enabled (matching web behavior)
        if (_currentPage == 1 && _jobs.isNotEmpty) {
          _readPageSummary();
        }
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = response['message'] ?? 'Failed to load jobs';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Connection error. Please try again.';
      });
    }
  }

  /// Read page summary using TTS (matching web functionality)
  Future<void> _readPageSummary() async {
    if (_flutterTts == null) return;

    final summaryText = ApiService.formatJobsSummaryForTTS({
      'statistics': _statistics,
    });

    await _flutterTts?.speak(summaryText);
    setState(() {
      _isSpeaking = true;
    });
  }

  /// Read individual job using TTS (matching web job card TTS)
  Future<void> _readJob(Map<String, dynamic> job) async {
    if (_flutterTts == null) return;

    await _flutterTts?.stop(); // Stop any current speech

    final jobText = ApiService.formatJobForTTS(job);

    await _flutterTts?.speak(jobText);
    setState(() {
      _isSpeaking = true;
    });

    // Record view for analytics
    ApiService.recordJobView(job['job_id']);
  }

  /// Start voice search (matching web voice search)
  Future<void> _startVoiceSearch() async {
    if (_speech == null) return;

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showSnackBar('Microphone permission required for voice search');
      return;
    }

    setState(() {
      _isListening = true;
    });

    await _speech?.listen(
      onResult: (result) {
        if (result.finalResult) {
          setState(() {
            _searchController.text = result.recognizedWords;
            _searchQuery = result.recognizedWords;
            _isListening = false;
          });
          _loadJobs(refresh: true);
          _showSnackBar('Searching for: "${result.recognizedWords}"');
        }
      },
      localeId: 'en_US',
    );
  }

  /// Stop voice search
  Future<void> _stopVoiceSearch() async {
    await _speech?.stop();
    setState(() {
      _isListening = false;
    });
  }

  /// Handle search
  void _handleSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
    _loadJobs(refresh: true);
  }

  /// Toggle save job
  Future<void> _toggleSaveJob(Map<String, dynamic> job) async {
    final result = await ApiService.toggleSaveJob(job['job_id']);

    if (result['success']) {
      setState(() {
        job['user_saved'] = !job['user_saved'];
      });
      _showSnackBar(job['user_saved'] ? 'Job saved' : 'Job removed from saved');
    } else {
      _showSnackBar('Failed to save job');
    }
  }

  /// Show snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Show job detail modal
  void _showJobDetail(Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobDetailModal(
        job: job,
        onJobUpdated: () {
          // Refresh jobs list when job is saved/unsaved
          _loadJobs(refresh: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // Search Header (matching web search bar)
          _buildSearchHeader(),

          // Statistics Cards (matching web stats: 13 Total, 13 PWD Friendly, 1 Remote)
          if (!_isLoading && !_hasError) _buildStatisticsCards(),

          // Active Filters
          if (_hasActiveFilters()) _buildActiveFilters(),

          // Job Listings
          Expanded(
            child: _buildJobsList(),
          ),
        ],
      ),
    );
  }

  /// Build search header (matching web design)
  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // FIXED: Using your exact color naming convention
        color: AppColors.secondaryTeal, // #257180 - your primary brand color
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40), // Status bar padding
          const Text(
            'Find Your Next Job',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins', // Matching web font
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search for jobs...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _handleSearch(),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Voice Search Button (matching web)
              Container(
                decoration: BoxDecoration(
                  color: _isListening
                      ? AppColors.voiceActive
                      : AppColors.voiceBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed:
                      _isListening ? _stopVoiceSearch : _startVoiceSearch,
                  icon: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // TTS Control Button (matching web)
              Container(
                decoration: BoxDecoration(
                  color: _isSpeaking
                      ? AppColors.ttsActive
                      : AppColors.ttsBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _isSpeaking
                      ? () => _flutterTts?.stop()
                      : _readPageSummary,
                  icon: Icon(
                    _isSpeaking ? Icons.stop : Icons.volume_up,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build statistics cards (matching web: 13 Total, 13 PWD Friendly, 1 Remote)
  Widget _buildStatisticsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Jobs',
              _statistics['total_jobs']?.toString() ?? '0',
              Icons.work,
              AppColors.statTotalJobs,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'PWD Friendly',
              _statistics['pwd_friendly']?.toString() ?? '0',
              Icons.accessible,
              AppColors.statPwdFriendly,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Remote Jobs',
              _statistics['remote_jobs']?.toString() ?? '0',
              Icons.home,
              AppColors.statRemoteJobs,
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual stat card (matching web design)
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Matching web border-radius
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight, // Using your web shadow
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Check if there are active filters
  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
        _selectedLocation.isNotEmpty ||
        _selectedJobType.isNotEmpty;
  }

  /// Build active filters chips (matching web)
  Widget _buildActiveFilters() {
    List<Widget> filterChips = [];

    if (_searchQuery.isNotEmpty) {
      filterChips.add(_buildFilterChip('Search: $_searchQuery', () {
        setState(() {
          _searchQuery = '';
          _searchController.clear();
        });
        _loadJobs(refresh: true);
      }));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: filterChips,
      ),
    );
  }

  /// Build individual filter chip
  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      // FIXED: Using your exact color naming convention
      backgroundColor: AppColors.secondaryTeal.withOpacity(0.1),
      deleteIconColor: AppColors.secondaryTeal,
    );
  }

  /// Build jobs list
  Widget _buildJobsList() {
    if (_isLoading && _jobs.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadJobs(refresh: true),
              // FIXED: Using your exact color naming convention
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryTeal),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No jobs found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search criteria',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!_isLoading &&
            _hasMoreData &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _currentPage++;
          _loadJobs();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _jobs.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _jobs.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final job = _jobs[index];
          return _buildJobCard(job);
        },
      ),
    );
  }

  /// Build job card - EXACT mirror of web design (UPDATED with modal integration)
  Widget _buildJobCard(Map<String, dynamic> job) {
    final accommodations = job['accommodations'] as List<dynamic>? ?? [];
    final features = job['features'] as List<dynamic>? ?? [];
    final hasApplied = job['user_applied'] as bool? ?? false;
    final isSaved = job['user_saved'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15), // Matching web design
        border: const Border(
          left: BorderSide(
            color: AppColors.secondaryTeal, // Matching web left border
            width: 5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight, // Using web shadow
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        // ✅ NEW: Add tap functionality to show modal
        onTap: () => _showJobDetail(job),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with company logo, save, and TTS buttons
              Row(
                children: [
                  // Company logo (matching web circular logos)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.companyLogoBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        (job['company'] as String)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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
                          job['title'] ?? 'Unknown Position',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                AppColors.secondaryTeal, // Matching web primary
                            fontFamily: 'Poppins', // Matching web font
                          ),
                        ),
                        Text(
                          job['company'] ?? 'Unknown Company',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontFamily: 'Inter', // Matching web font
                          ),
                        ),
                      ],
                    ),
                  ),

                  // TTS Button (KEY ACCESSIBILITY FEATURE)
                  IconButton(
                    onPressed: () => _readJob(job),
                    icon: const Icon(Icons.volume_up),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.ttsBackground,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  // Save Button
                  IconButton(
                    onPressed: () => _toggleSaveJob(job),
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? AppColors.primaryOrange : Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Location pill (matching web styling)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.locationPillBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: AppColors.primaryOrange),
                    const SizedBox(width: 4),
                    Text(
                      job['location'] ?? 'Remote',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Job details
              Row(
                children: [
                  Icon(Icons.work, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(job['employment_type'] ?? 'Full-time'),
                  const SizedBox(width: 16),
                  Icon(Icons.monetization_on,
                      size: 16, color: AppColors.salaryTextColor),
                  const SizedBox(width: 4),
                  Text(
                    job['salary_range'] ?? 'Competitive',
                    style: const TextStyle(color: AppColors.salaryTextColor),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // PWD Accommodations (KEY FEATURE - matching web green styling)
              if (accommodations.isNotEmpty) ...[
                const Text(
                  '🛡️ PWD Accommodations & Support',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.pwdGreen,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: accommodations
                      .map((acc) => _buildAccommodationChip(acc.toString()))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Additional Features (blue styling)
              if (features.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: features
                      .map((feature) => _buildFeatureChip(feature.toString()))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Footer with apply button and metadata (matching web)
              Row(
                children: [
                  Text(
                    job['posted_time'] ?? 'Recently',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ✅ NEW: Add "View Details" text to encourage tapping
                  Text(
                    'Tap to view details',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryTeal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (hasApplied)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.statusHired.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Applied',
                        style: TextStyle(
                          color: AppColors.statusHired,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () =>
                          _showJobDetail(job), // ✅ NEW: Also opens modal
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primaryOrange, // Web accent color
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              30), // Matching web roundness
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                      ),
                      child: const Text(
                        'View Details', // ✅ NEW: Changed from "Apply Now" to "View Details"
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build PWD accommodation chip (matching web green styling)
  Widget _buildAccommodationChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pwdGreenLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pwdGreenBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.pwdGreen,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Build feature chip (matching web blue styling)
  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pwdBlueLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pwdBlueBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.pwdBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
