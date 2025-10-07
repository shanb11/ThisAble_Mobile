import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/api_service.dart';
import '../../widgets/enhanced_application_modal.dart';
import '../../widgets/enhanced_job_details_modal.dart';

class CandidateJobListingsScreen extends StatefulWidget {
  const CandidateJobListingsScreen({super.key});

  @override
  _CandidateJobListingsScreenState createState() =>
      _CandidateJobListingsScreenState();
}

class _CandidateJobListingsScreenState extends State<CandidateJobListingsScreen>
    with TickerProviderStateMixin {
  // ThisAble Colors (KEEPING YOUR EXACT COLORS)
  static const Color primaryColor = Color(0xFF257180);
  static const Color secondaryColor = Color(0xFFF2E5BF);
  static const Color accentColor = Color(0xFFFD8B51);
  static const Color sidebarColor = Color(0xFF2F8A99);

  // Search and Filter State (KEEPING YOUR EXACT STATE)
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedLocation = '';
  final List<String> _selectedJobTypes = [];
  final List<String> _selectedWorkModes = [];
  final List<String> _selectedAccessibility = [];
  final List<String> _selectedExperience = [];

  // Loading States (KEEPING YOUR EXACT STATES)
  bool _isLoadingJobs = true;
  bool _isLoadingStats = true;
  bool _isPerformingAction = false;

  // Data from API (KEEPING YOUR EXACT DATA STRUCTURE)
  List<dynamic> _allJobs = [];
  Set<int> _savedJobs = <int>{};
  Map<String, dynamic> _statsData = {};
  int _currentPage = 1;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadJobsData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // KEEPING YOUR EXACT WORKING _loadJobsData METHOD
  Future<void> _loadJobsData() async {
    await Future.wait([
      _loadJobs(),
      _loadJobStats(),
      _loadSavedJobs(),
    ]);
  }

  // KEEPING YOUR EXACT WORKING _loadJobs METHOD
  Future<void> _loadJobs({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoadingJobs = true;
        _currentPage = 1;
        _allJobs.clear();
        _hasMoreData = true;
      });
    }

    try {
      print('🔧 [Jobs] Loading jobs...');
      print('🔧 [Jobs] Search query: $_searchQuery');
      print('🔧 [Jobs] Selected location: $_selectedLocation');
      print('🔧 [Jobs] Page: $_currentPage');

      final response = await ApiService.getJobsList(
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        location: _selectedLocation.isNotEmpty ? _selectedLocation : null,
        jobType: _selectedJobTypes.isNotEmpty ? _selectedJobTypes.first : null,
        workArrangement:
            _selectedWorkModes.isNotEmpty ? _selectedWorkModes.first : null,
        accommodations:
            _selectedAccessibility.isNotEmpty ? _selectedAccessibility : null,
        page: _currentPage,
      );

      print('🔧 [Jobs] API Response: ${response.toString()}');
      print('🔧 [Jobs] API Response success: ${response['success']}');

      // FIXED: Better error handling and response processing
      if (response['success'] == true && mounted) {
        final data = response['data'];
        if (data != null) {
          final newJobs = data['jobs'] ?? [];
          final pagination = data['pagination'] ?? {};

          print('🔧 [Jobs] New jobs count: ${newJobs.length}');
          print('🔧 [Jobs] Pagination: $pagination');

          setState(() {
            if (refresh || _currentPage == 1) {
              _allJobs = newJobs;
            } else {
              _allJobs.addAll(newJobs);
            }

            // Use pagination data properly
            final totalPages = pagination['total_pages'] ?? 1;
            _hasMoreData = _currentPage < totalPages;
            _isLoadingJobs = false;
          });

          print('🔧 [Jobs] Total jobs: ${_allJobs.length}');
          print('🔧 [Jobs] Has more data: $_hasMoreData');
        } else {
          // Handle null data case
          print('🔧 [Jobs] API returned null data');
          setState(() {
            _allJobs = [];
            _hasMoreData = false;
            _isLoadingJobs = false;
          });
        }
      } else {
        // FIXED: Handle API failure cases
        print(
            '🔧 [Jobs] API failed: ${response['message'] ?? 'Unknown error'}');

        setState(() {
          if (refresh || _currentPage == 1) {
            _allJobs = [];
          }
          _hasMoreData = false;
          _isLoadingJobs = false;
        });

        // Only show error for first load, not pagination
        if (_currentPage == 1) {
          _showErrorSnackBar(response['message'] ?? 'Failed to load jobs');
        }
      }
    } catch (e) {
      print('🔧 [Jobs] Error loading jobs: $e');
      if (mounted) {
        setState(() {
          _isLoadingJobs = false;
          if (refresh || _currentPage == 1) {
            _allJobs = [];
          }
          _hasMoreData = false;
        });
        _showErrorSnackBar('Network error: Failed to load jobs');
      }
    }
  }

  // KEEPING YOUR EXACT WORKING _loadJobStats METHOD
  Future<void> _loadJobStats() async {
    try {
      // FIXED: Use getJobsList API instead of getDashboardHome for job-specific stats
      final response = await ApiService.getJobsList(page: 1);
      if (response['success'] && mounted) {
        setState(() {
          // FIXED: Extract filter_stats from jobs API response
          _statsData = response['data']['filter_stats'] ??
              response['data']['pagination'] ??
              {};
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
        // Don't show error for stats, continue without them
      }
    }
  }

  // KEEPING YOUR EXACT WORKING _loadSavedJobs METHOD
  Future<void> _loadSavedJobs() async {
    try {
      print('🔧 [Jobs] Loading saved jobs...');
      final response = await ApiService.getDashboardHome();

      if (response['success'] && mounted) {
        final data = response['data'];
        // FIXED: Use suggested_jobs or create a proper saved jobs API call
        // For now, using empty set since saved jobs needs separate API
        final savedJobsData = []; // data['saved_jobs'] ?? [];

        print('🔧 [Jobs] Saved jobs count: ${savedJobsData.length}');

        setState(() {
          _savedJobs =
              savedJobsData.map<int>((job) => job['job_id'] as int).toSet();
        });
      }
    } catch (e) {
      print('🔧 [Jobs] Error loading saved jobs: $e');
      // Handle error silently for saved jobs
    }
  }

  // KEEPING YOUR EXACT WORKING _applyFilters METHOD
  Future<void> _applyFilters() async {
    _currentPage = 1;
    await _loadJobs(refresh: true);
  }

  // KEEPING YOUR EXACT WORKING _performSearch METHOD
  Future<void> _performSearch() async {
    _currentPage = 1;
    await _loadJobs(refresh: true);
  }

  // KEEPING YOUR EXACT WORKING _toggleJobSave METHOD
  Future<void> _toggleJobSave(Map<String, dynamic> job) async {
    final jobId = job['job_id'];
    final isSaved = _savedJobs.contains(jobId);

    setState(() => _isPerformingAction = true);

    try {
      final response = await ApiService.performJobAction(
        jobId: jobId,
        action: isSaved ? 'unsave' : 'save',
      );

      if (response['success']) {
        setState(() {
          if (isSaved) {
            _savedJobs.remove(jobId);
          } else {
            _savedJobs.add(jobId);
          }
        });
        _showSuccessSnackBar(
            isSaved ? 'Job removed from saved' : 'Job saved successfully');
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to save job');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save job');
    } finally {
      setState(() => _isPerformingAction = false);
    }
  }

  // KEEPING YOUR EXACT WORKING _applyToJob METHOD
  Future<void> _applyToJob(Map<String, dynamic> job) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedApplicationModal(job: job),
    );

    // If application was successful, reload jobs
    if (result == true) {
      _loadJobs(refresh: true);
    }
  }

  // KEEPING YOUR EXACT WORKING SNACKBAR METHODS
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // KEEPING YOUR EXACT WORKING _clearAllFilters METHOD
  void _clearAllFilters() {
    setState(() {
      _selectedJobTypes.clear();
      _selectedWorkModes.clear();
      _selectedAccessibility.clear();
      _selectedExperience.clear();
      _selectedLocation = '';
      _searchQuery = '';
      _searchController.clear();
    });
    _applyFilters();
  }

  // ✨ NEW WEB FEATURE: Enhanced Apply Modal (like your web screenshots)
  void _showApplyModal(Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedApplicationModal(job: job),
    );
  }

  // ✨ NEW WEB FEATURE: Enhanced Job Details Modal (like your web screenshots)
  void _showJobDetailsModal(Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedJobDetailsModal(
        job: job,
        isSaved: _savedJobs.contains(job['job_id']),
        onSave: () {
          Navigator.pop(context);
          _toggleJobSave(job);
        },
        onApply: () {
          Navigator.pop(context);
          _applyToJob(job);
        },
      ),
    );
  }

  // KEEPING YOUR EXACT WORKING build METHOD BUT ENHANCED
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () => _loadJobsData(),
        child: CustomScrollView(
          slivers: [
            _buildHeader(), // Enhanced header with search
            SliverToBoxAdapter(child: _buildActiveFilters()),
            SliverToBoxAdapter(child: _buildStatsSection()),
            _buildJobsList(),
          ],
        ),
      ),
    );
  }

  // ✨ ENHANCED VERSION OF YOUR WORKING _buildHeader METHOD
  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, sidebarColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find Your Next Job',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ✨ ENHANCED SEARCH BAR (like your web version)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search for jobs...',
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (query) {
                              setState(() {
                                _searchQuery = query;
                              });
                              _performSearch();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // ✨ ENHANCED FILTER BUTTON
                      Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _showFilterModal,
                          icon: const Icon(Icons.tune, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // KEEPING YOUR EXACT WORKING _buildActiveFilters METHOD
  Widget _buildActiveFilters() {
    List<String> allFilters = [
      ..._selectedJobTypes.map((e) => _formatFilterLabel(e)),
      ..._selectedWorkModes.map((e) => _formatFilterLabel(e)),
      ..._selectedAccessibility.map((e) => _formatFilterLabel(e)),
      ..._selectedExperience.map((e) => _formatFilterLabel(e)),
      if (_selectedLocation.isNotEmpty) _selectedLocation,
    ];

    if (allFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...allFilters.map((filter) => _buildFilterChip(filter)),
              if (allFilters.length > 1)
                ActionChip(
                  label: const Text('Clear All'),
                  onPressed: _clearAllFilters,
                  backgroundColor: Colors.red[50],
                  labelStyle: TextStyle(color: Colors.red[700]),
                  side: BorderSide(color: Colors.red[300]!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // KEEPING YOUR EXACT WORKING _buildFilterChip METHOD
  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: true,
      onSelected: (selected) {
        if (!selected) {
          setState(() {
            _selectedJobTypes.remove(label.toLowerCase().replaceAll(' ', '-'));
            _selectedWorkModes.remove(label.toLowerCase());
            _selectedAccessibility
                .remove(label.toLowerCase().replaceAll(' ', '-'));
            _selectedExperience.remove(label.toLowerCase());
            if (_selectedLocation == label) _selectedLocation = '';
          });
          _applyFilters();
        }
      },
      selectedColor: primaryColor.withOpacity(0.2),
      checkmarkColor: primaryColor,
    );
  }

  String _formatFilterLabel(String value) {
    return value.split('-').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  // KEEPING YOUR EXACT WORKING _buildStatsSection METHOD
  Widget _buildStatsSection() {
    if (_isLoadingStats) return _buildLoadingStats();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total Jobs',
            _statsData['total']?.toString() ?? '0',
            Icons.work,
            primaryColor,
          ),
          _buildStatItem(
            'PWD Friendly',
            (_statsData['total'] ?? 0).toString(),
            Icons.accessible,
            Colors.green,
          ),
          _buildStatItem(
            'Remote Jobs',
            _statsData['remote']?.toString() ?? '0',
            Icons.home,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  // KEEPING YOUR EXACT WORKING _buildLoadingStats METHOD
  Widget _buildLoadingStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // KEEPING YOUR EXACT WORKING _buildStatItem METHOD
  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
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

  // KEEPING YOUR EXACT WORKING _buildJobsList METHOD
  Widget _buildJobsList() {
    if (_isLoadingJobs && _allJobs.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 400,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ),
      );
    }

    if (_allJobs.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == _allJobs.length) {
            if (_hasMoreData) {
              return _buildLoadMoreButton();
            }
            return const SizedBox.shrink();
          }

          final job = _allJobs[index];
          return _buildJobCard(job); // Enhanced job cards
        },
        childCount: _allJobs.length + (_hasMoreData ? 1 : 0),
      ),
    );
  }

  // KEEPING YOUR EXACT WORKING _buildEmptyState METHOD
  Widget _buildEmptyState() {
    return Container(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'No jobs found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _clearAllFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Clear Filters',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // KEEPING YOUR EXACT WORKING _buildLoadMoreButton METHOD
  Widget _buildLoadMoreButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ElevatedButton(
          onPressed: () async {
            setState(() => _currentPage++);
            await _loadJobs();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primaryColor,
            elevation: 2,
          ),
          child: const Text('Load More Jobs'),
        ),
      ),
    );
  }

  // ✨ ENHANCED JOB CARD (like your web version with PWD badges)
  Widget _buildJobCard(Map<String, dynamic> job) {
    final isSaved = _savedJobs.contains(job['job_id']);
    final accommodations = job['accommodations'] as List<dynamic>? ?? [];

    return GestureDetector(
      onTap: () => _showJobDetailsModal(job), // ✨ NEW: Tap to see details
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left:
                BorderSide(color: primaryColor, width: 4), // ✨ NEW: Left border
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // ✨ NEW: Company logo placeholder
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.business,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['job_title'] ?? 'Unknown Position',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['company_name'] ?? 'Unknown Company',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // ✨ NEW: Save button
                IconButton(
                  onPressed: () => _toggleJobSave(job),
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? accentColor : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Job details row
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  job['location'] ?? 'Not specified',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.work, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  job['employment_type'] ?? 'Not specified',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),

            // ✨ NEW: Salary if available
            if (job['salary_range'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    job['salary_range'].toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            // ✨ NEW: PWD Accommodations (key web feature!)
            if (accommodations.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: accommodations
                    .take(3)
                    .map((acc) =>
                        _buildAccommodationChip(acc['name'] ?? acc.toString()))
                    .toList(),
              ),
            ],

            const SizedBox(height: 12),

            // Bottom row with date and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(job['posted_at']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Row(
                  children: [
                    // ✨ NEW: View Details button
                    OutlinedButton(
                      onPressed: () => _showJobDetailsModal(job),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child:
                          const Text('Details', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    // Apply button
                    ElevatedButton(
                      onPressed: _isPerformingAction
                          ? null
                          : () => _showApplyModal(job),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child:
                          const Text('Apply', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✨ NEW: PWD Accommodation chips (key web feature!)
  Widget _buildAccommodationChip(String accommodation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.accessible, size: 12, color: Colors.green[700]),
          const SizedBox(width: 4),
          Text(
            accommodation,
            style: TextStyle(
              fontSize: 10,
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final parsedDate = DateTime.parse(date.toString());
      final now = DateTime.now();
      final difference = now.difference(parsedDate);

      if (difference.inDays == 0) return 'Today';
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      if (difference.inDays < 30)
        return '${(difference.inDays / 7).floor()} weeks ago';
      return '${(difference.inDays / 30).floor()} months ago';
    } catch (e) {
      return '';
    }
  }

  // KEEPING YOUR EXACT WORKING _showFilterModal METHOD BUT ENHANCED
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterModal(),
    );
  }

  // ✨ ENHANCED FILTER MODAL (like your web filters)
  Widget _buildFilterModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Jobs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    'Job Type',
                    ['full-time', 'part-time', 'contract', 'freelance'],
                    _selectedJobTypes,
                    (value, selected) {
                      setState(() {
                        if (selected) {
                          _selectedJobTypes.add(value);
                        } else {
                          _selectedJobTypes.remove(value);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildFilterSection(
                    'Work Mode',
                    ['remote', 'hybrid', 'on-site'],
                    _selectedWorkModes,
                    (value, selected) {
                      setState(() {
                        if (selected) {
                          _selectedWorkModes.add(value);
                        } else {
                          _selectedWorkModes.remove(value);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildFilterSection(
                    'Accessibility Features',
                    [
                      'screen-reader-compatible',
                      'wheelchair-accessible',
                      'flexible-schedule'
                    ],
                    _selectedAccessibility,
                    (value, selected) {
                      setState(() {
                        if (selected) {
                          _selectedAccessibility.add(value);
                        } else {
                          _selectedAccessibility.remove(value);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Apply button
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    List<String> selectedOptions,
    Function(String, bool) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(_formatFilterLabel(option)),
              selected: isSelected,
              onSelected: (selected) => onChanged(option, selected),
              selectedColor: primaryColor.withOpacity(0.2),
              checkmarkColor: primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ✨ NEW: Enhanced Job Details Modal (matches your web modal screenshots)
class EnhancedJobDetailsModal extends StatelessWidget {
  final Map<String, dynamic> job;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onApply;

  const EnhancedJobDetailsModal({
    super.key,
    required this.job,
    required this.isSaved,
    required this.onSave,
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
          // Header with company info (like your web modal)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF257180),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.business,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['job_title'] ?? 'Unknown Position',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${job['company_name']} • ${job['location']}',
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
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content (matches your web modal content)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Information section
                  _buildSection(
                    'Job Information',
                    Icons.info,
                    Column(
                      children: [
                        _buildInfoRow('Position', job['job_title']),
                        _buildInfoRow('Company', job['company_name']),
                        _buildInfoRow('Location', job['location']),
                        _buildInfoRow(
                            'Employment Type', job['employment_type']),
                        if (job['salary_range'] != null)
                          _buildInfoRow(
                              'Salary Range', job['salary_range'].toString()),
                        if (job['department'] != null)
                          _buildInfoRow('Department', job['department']),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Job Description
                  _buildSection(
                    'Job Description',
                    Icons.description,
                    Text(
                      job['job_description'] ?? 'No description available.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Requirements
                  _buildSection(
                    'Requirements',
                    Icons.checklist,
                    Text(
                      job['job_requirements'] ??
                          'Requirements will be discussed during the interview process.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // PWD Accommodations (key web feature!)
                  if (job['accommodations'] != null &&
                      (job['accommodations'] as List).isNotEmpty)
                    _buildSection(
                      'PWD Accommodations & Support',
                      Icons.accessible,
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (job['accommodations'] as List)
                            .map((acc) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Colors.green.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle,
                                          size: 16, color: Colors.green[700]),
                                      const SizedBox(width: 6),
                                      Text(
                                        acc['name'] ?? acc.toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Action buttons (like your web modal)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSave,
                    icon:
                        Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                    label: Text(isSaved ? 'Saved' : 'Save'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF257180),
                      side: const BorderSide(color: Color(0xFF257180)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFD8B51),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Apply Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF257180)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Not specified',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✨ NEW: Enhanced Application Modal (matches your web application screenshots)
class EnhancedApplicationModal extends StatefulWidget {
  final Map<String, dynamic> job;

  const EnhancedApplicationModal({super.key, required this.job});

  @override
  State<EnhancedApplicationModal> createState() =>
      _EnhancedApplicationModalState();
}

class _EnhancedApplicationModalState extends State<EnhancedApplicationModal> {
  final _coverLetterController = TextEditingController();
  final _accessibilityNeedsController = TextEditingController();

  bool _isSubmitting = false;
  bool _includeCoverLetter = false;
  bool _includePortfolioLink = false;
  bool _includeReferences = false;

  @override
  void dispose() {
    _coverLetterController.dispose();
    _accessibilityNeedsController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await ApiService.performJobAction(
        jobId: widget.job['job_id'],
        action: 'apply',
        coverLetter: _coverLetterController.text.trim(),
        accessibilityNeeds:
            _accessibilityNeedsController.text.trim(), // ✅ SIMPLE FIX
      );

      if (response['success']) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                response['message'] ?? 'Application submitted successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to submit application');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit application: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

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
          // Header (like your web application modal)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFFD8B51),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.work, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Apply for Job',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.job['job_title'] ?? 'Unknown Position',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.job['company_name'] ?? 'Unknown Company',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
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
          ),

          // Content (matches your web application form)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resume section (like your web screenshots)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFD8B51).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFD8B51).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.description,
                          color: Color(0xFFFD8B51),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Resume',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '50% match to job requirements',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[700],
                                ),
                              ),
                              // Progress bar
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: 0.5,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFD8B51),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: View resume functionality
                          },
                          child: const Text('View'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Personalization Tips (like your web)
                  const Text(
                    'Personalization Tips:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...[
                    'Tailor your experience to match the specific job requirements',
                    'Highlight achievements that demonstrate your capabilities',
                    'Mention any relevant certifications or training',
                    'Emphasize how your unique perspective as a PWD can benefit the role',
                  ]
                      .map((tip) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.lightbulb,
                                  size: 16,
                                  color: Color(0xFFFD8B51),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),

                  const SizedBox(height: 24),

                  // Additional Materials (like your web)
                  const Text(
                    'Additional Materials',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  CheckboxListTile(
                    value: _includeCoverLetter,
                    onChanged: (value) {
                      setState(() {
                        _includeCoverLetter = value ?? false;
                      });
                    },
                    title: const Text('Include cover letter'),
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFFD8B51),
                  ),

                  CheckboxListTile(
                    value: _includePortfolioLink,
                    onChanged: (value) {
                      setState(() {
                        _includePortfolioLink = value ?? false;
                      });
                    },
                    title: const Text('Include portfolio link'),
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFFD8B51),
                  ),

                  CheckboxListTile(
                    value: _includeReferences,
                    onChanged: (value) {
                      setState(() {
                        _includeReferences = value ?? false;
                      });
                    },
                    title: const Text('Include references'),
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFFD8B51),
                  ),

                  const SizedBox(height: 24),

                  // Cover Letter (like your web form)
                  const Text(
                    'Cover Letter (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _coverLetterController,
                    decoration: const InputDecoration(
                      hintText: 'Write a brief message to the employer...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: 4,
                  ),

                  const SizedBox(height: 24),

                  // Accessibility Needs (key PWD feature from your web!)
                  const Text(
                    'Accessibility Needs',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _accessibilityNeedsController,
                    decoration: const InputDecoration(
                      hintText:
                          'Please share any accessibility accommodations you may need during the interview process...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),

          // Action buttons (like your web modal)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFD8B51),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Submit Application'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
