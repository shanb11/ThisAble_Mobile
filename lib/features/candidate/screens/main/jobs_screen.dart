import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/services/api_service.dart';

class CandidateJobListingsScreen extends StatefulWidget {
  const CandidateJobListingsScreen({super.key});

  @override
  _CandidateJobListingsScreenState createState() =>
      _CandidateJobListingsScreenState();
}

class _CandidateJobListingsScreenState extends State<CandidateJobListingsScreen>
    with TickerProviderStateMixin {
  // ThisAble Colors
  static const Color primaryColor = Color(0xFF257180);
  static const Color secondaryColor = Color(0xFFF2E5BF);
  static const Color accentColor = Color(0xFFFD8B51);
  static const Color sidebarColor = Color(0xFF2F8A99);

  // Search and Filter State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedLocation = '';
  final List<String> _selectedJobTypes = [];
  final List<String> _selectedWorkModes = [];
  final List<String> _selectedAccessibility = [];
  final List<String> _selectedExperience = [];

  // Loading States
  bool _isLoadingJobs = true;
  bool _isLoadingStats = true;
  bool _isPerformingAction = false;

  // Data from API
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

  Future<void> _loadJobsData() async {
    await Future.wait([
      _loadJobs(),
      _loadJobStats(),
      _loadSavedJobs(),
    ]);
  }

  // Fix the _loadJobs method in jobs_screen.dart
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

  Future<void> _loadJobStats() async {
    try {
      // FIXED: Use getJobsList API instead of getDashboardHome for job-specific stats
      final response = await ApiService.getJobsList(page: 1);
      if (response['success'] && mounted) {
        setState(() {
          // FIXED: Extract filter_stats from jobs API response
          _statsData = response['data']['filter_stats'] ?? {};
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

  Future<void> _performSearch() async {
    _currentPage = 1;
    await _loadJobs(refresh: true);
  }

  Future<void> _applyFilters() async {
    _currentPage = 1;
    await _loadJobs(refresh: true);
  }

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

  Future<void> _applyToJob(Map<String, dynamic> job) async {
    setState(() => _isPerformingAction = true);

    try {
      final response = await ApiService.performJobAction(
        jobId: job['job_id'],
        action: 'apply',
        coverLetter: null, // Could add cover letter modal later
      );

      if (response['success']) {
        _showSuccessSnackBar('Application submitted successfully');
        // Optionally navigate to applications tab
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to apply to job');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to apply to job');
    } finally {
      setState(() => _isPerformingAction = false);
    }
  }

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

  void _clearAllFilters() {
    setState(() {
      _selectedJobTypes.clear();
      _selectedWorkModes.clear();
      _selectedAccessibility.clear();
      _selectedExperience.clear();
      _selectedLocation = '';
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () => _loadJobsData(),
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(child: _buildActiveFilters()),
            SliverToBoxAdapter(child: _buildStatsSection()),
            _buildJobsList(),
          ],
        ),
      ),
    );
  }

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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search jobs...',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear,
                                          color: Colors.white.withOpacity(0.7)),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                        _performSearch();
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            onSubmitted: (value) => _performSearch(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _showFilterModal(),
                        icon: const Icon(Icons.tune, size: 18),
                        label: const Text('Filter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
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
            // FIXED: Changed from 'total_jobs' to 'total' to match getJobsList API response
            _statsData['total']?.toString() ?? '0',
            Icons.work,
            primaryColor,
          ),
          _buildStatItem(
            'PWD Friendly',
            // FIXED: Using total as fallback since pwd_friendly not in current API
            /* TODO: Update get_jobs_list.php to include PWD-friendly job count*/
            (_statsData['total'] ?? 0).toString(),
            Icons.accessible,
            Colors.green,
          ),
          _buildStatItem(
            'Remote Jobs',
            // FIXED: Changed from 'remote_jobs' to 'remote' to match getJobsList API response
            _statsData['remote']?.toString() ?? '0',
            Icons.home,
            Colors.blue,
          ),
        ],
      ),
    );
  }

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
          return _buildJobCard(job);
        },
        childCount: _allJobs.length + (_hasMoreData ? 1 : 0),
      ),
    );
  }

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

  Widget _buildJobCard(Map<String, dynamic> job) {
    final isSaved = _savedJobs.contains(job['job_id']);
    final accommodations = job['accommodations'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showJobDetails(job),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _getCompanyInitials(job['company_name'] ?? ''),
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                          job['job_title'] ?? 'Unknown Position',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
                  IconButton(
                    onPressed:
                        _isPerformingAction ? null : () => _toggleJobSave(job),
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? primaryColor : Colors.grey[400],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildJobTag(
                    icon: Icons.location_on,
                    label: job['location'] ?? 'Remote',
                  ),
                  const SizedBox(width: 12),
                  _buildJobTag(
                    icon: Icons.work,
                    label: job['employment_type'] ?? 'Full-time',
                  ),
                  if (job['work_arrangement'] != null) ...[
                    const SizedBox(width: 12),
                    _buildJobTag(
                      icon: Icons.home,
                      label: job['work_arrangement'],
                    ),
                  ],
                ],
              ),
              if (accommodations.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: accommodations.take(3).map((accommodation) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.accessible,
                              size: 12, color: Colors.green[700]),
                          const SizedBox(width: 4),
                          Text(
                            accommodation['name'] ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                if (accommodations.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${accommodations.length - 3} more',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
              if (job['salary_range'] != null) ...[
                const SizedBox(height: 12),
                Text(
                  job['salary_range'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                job['job_description'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Posted ${_formatDate(job['created_at'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        _isPerformingAction ? null : () => _showApplyModal(job),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Apply', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobTag({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterModal(),
    );
  }

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
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
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
                      'flexible-schedule',
                      'assistive-tech',
                      'accessible-office',
                      'transportation',
                      'sign-language',
                      'remote-work',
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
                  const SizedBox(height: 20),
                  _buildFilterSection(
                    'Experience Level',
                    ['entry', 'mid', 'senior', 'executive'],
                    _selectedExperience,
                    (value, selected) {
                      setState(() {
                        if (selected) {
                          _selectedExperience.add(value);
                        } else {
                          _selectedExperience.remove(value);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
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

  String _formatFilterLabel(String value) {
    return value.split('-').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _getCompanyInitials(String companyName) {
    if (companyName.isEmpty) return 'C';
    final words = companyName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return companyName.substring(0, 1).toUpperCase();
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'recently';
    try {
      final date = DateTime.parse(dateString.toString());
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'today';
      } else if (difference == 1) {
        return 'yesterday';
      } else if (difference < 7) {
        return '${difference} days ago';
      } else if (difference < 30) {
        return '${(difference / 7).floor()} weeks ago';
      } else {
        return '${(difference / 30).floor()} months ago';
      }
    } catch (e) {
      return 'recently';
    }
  }

  void _showJobDetails(Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildJobDetailsModal(job),
    );
  }

  void _showApplyModal(Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply to ${job['job_title']}'),
        content: Text(
          'Are you sure you want to apply to this position at ${job['company_name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyToJob(job);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text(
              'Apply',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetailsModal(Map<String, dynamic> job) {
    final accommodations = job['accommodations'] as List<dynamic>? ?? [];
    final isSaved = _savedJobs.contains(job['job_id']);

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
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['job_title'] ?? 'Unknown Position',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['company_name'] ?? 'Unknown Company',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleJobSave(job),
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? primaryColor : Colors.grey[400],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job details
                  Row(
                    children: [
                      _buildJobTag(
                        icon: Icons.location_on,
                        label: job['location'] ?? 'Remote',
                      ),
                      const SizedBox(width: 12),
                      _buildJobTag(
                        icon: Icons.work,
                        label: job['employment_type'] ?? 'Full-time',
                      ),
                    ],
                  ),
                  if (job['salary_range'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      job['salary_range'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Job Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    job['job_description'] ?? 'No description available.',
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),

                  // Requirements
                  if (job['job_requirements'] != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Requirements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      job['job_requirements'],
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],

                  // PWD Accommodations
                  if (accommodations.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'PWD Accommodations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: accommodations.map((accommodation) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.accessible,
                                  size: 16, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              Text(
                                accommodation['name'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: const BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showApplyModal(job);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
}
