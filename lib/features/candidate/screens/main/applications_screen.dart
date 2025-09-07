import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/services/api_service.dart';
import '../../widgets/application_details_modal.dart';

/// FIXED: Complete Applications Screen - Works for ANY candidate account
/// Eliminates assertion error "child ==_ child is not true"
class CandidateApplicationsScreen extends StatefulWidget {
  const CandidateApplicationsScreen({super.key});

  @override
  State<CandidateApplicationsScreen> createState() =>
      _CandidateApplicationsScreenState();
}

class _CandidateApplicationsScreenState
    extends State<CandidateApplicationsScreen> {
  // ThisAble Colors
  static const Color primaryColor = Color(0xFF257180);
  static const Color secondaryColor = Color(0xFFF2E5BF);
  static const Color accentColor = Color(0xFFFD8B51);
  static const Color sidebarColor = Color(0xFF2F8A99);

  // FIXED: Simple state management - no complex animations
  bool _isLoadingApplications = true;
  bool _isLoadingStats = true;
  bool _isPerformingAction = false;
  bool _isDisposed = false;

  // FIXED: Stable data storage - no computed getters
  List<dynamic> _allApplications = [];
  List<dynamic> _filteredApplications = []; // FIXED: Stable list
  Map<String, dynamic> _statsData = {};

  // Filter and pagination
  String _selectedFilter = 'all';
  String _searchQuery = '';
  int _currentPage = 1;
  bool _hasMoreData = false;

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print('🔧 [Applications] Screen initializing...');
    _loadApplicationsData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    print('🔧 [Applications] Disposing...');
    _isDisposed = true;
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// FIXED: Safe state updates prevent assertion errors
  void _safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      setState(fn);
    }
  }

  /// Scroll listener for pagination
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMoreData && !_isLoadingApplications) {
        _loadMoreApplications();
      }
    }
  }

  /// FIXED: Load applications with stable data management
  Future<void> _loadApplicationsData() async {
    if (_isDisposed) return;

    try {
      final response = await ApiService.getApplicationsList(
        status: _selectedFilter == 'all' ? null : _selectedFilter,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: _currentPage,
      );

      if (response['success'] == true && !_isDisposed) {
        final data = response['data'];
        final newApplications = List<dynamic>.from(data['applications'] ?? []);

        _safeSetState(() {
          if (_currentPage == 1) {
            _allApplications = newApplications;
          } else {
            _allApplications.addAll(newApplications);
          }

          // FIXED: Update filtered applications immediately
          _updateFilteredApplications();

          final pagination = data['pagination'] ?? {};
          _hasMoreData = _currentPage < (pagination['total_pages'] ?? 1);
          _isLoadingApplications = false;
        });

        print(
            '🔧 [Applications] Loaded ${newApplications.length} applications');
      } else {
        _safeSetState(() {
          _allApplications = [];
          _updateFilteredApplications();
          _isLoadingApplications = false;
          _hasMoreData = false;
        });
      }
    } catch (e) {
      print('🚨 [Applications] Load error: $e');
      if (!_isDisposed) {
        _safeSetState(() {
          _allApplications = [];
          _updateFilteredApplications();
          _isLoadingApplications = false;
          _hasMoreData = false;
        });
      }
    }

    // Load stats
    await _loadApplicationStats();
  }

  /// FIXED: Update filtered applications - prevents dynamic changes
  void _updateFilteredApplications() {
    if (_selectedFilter == 'all') {
      _filteredApplications = List<dynamic>.from(_allApplications);
    } else {
      _filteredApplications = _allApplications.where((app) {
        final status = app['application_status']?.toString() ?? '';
        return status == _selectedFilter;
      }).toList();
    }

    // Apply search filter if needed
    if (_searchQuery.isNotEmpty) {
      _filteredApplications = _filteredApplications.where((app) {
        final jobTitle = app['job_title']?.toString().toLowerCase() ?? '';
        final companyName = app['company_name']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return jobTitle.contains(query) || companyName.contains(query);
      }).toList();
    }
  }

  /// Load application statistics
  Future<void> _loadApplicationStats() async {
    if (_isDisposed) return;

    try {
      final response = await ApiService.getDashboardHome();
      if (response['success'] == true && !_isDisposed) {
        _safeSetState(() {
          _statsData = response['data']['stats'] ?? {};
          _isLoadingStats = false;
        });
      } else {
        _safeSetState(() {
          _statsData = {};
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('🚨 [Applications] Stats error: $e');
      if (!_isDisposed) {
        _safeSetState(() {
          _statsData = {};
          _isLoadingStats = false;
        });
      }
    }
  }

  /// Load more applications (pagination)
  Future<void> _loadMoreApplications() async {
    if (_isDisposed || !_hasMoreData) return;

    _safeSetState(() {
      _currentPage++;
      _isLoadingApplications = true;
    });

    await _loadApplicationsData();
  }

  /// FIXED: Filter change with stable updates
  Future<void> _changeFilter(String newFilter) async {
    if (_isDisposed || _selectedFilter == newFilter) return;

    _safeSetState(() {
      _selectedFilter = newFilter;
      _currentPage = 1;
      _isLoadingApplications = true;
    });

    await _loadApplicationsData();
  }

  /// Search functionality
  Future<void> _performSearch() async {
    if (_isDisposed) return;

    _safeSetState(() {
      _currentPage = 1;
      _isLoadingApplications = true;
    });

    await _loadApplicationsData();
  }

  /// Refresh data
  Future<void> _refreshData() async {
    if (_isDisposed) return;

    _safeSetState(() {
      _currentPage = 1;
      _isLoadingApplications = true;
      _isLoadingStats = true;
    });

    await _loadApplicationsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildStatsSection()),
            SliverToBoxAdapter(child: _buildSearchSection()),
            SliverToBoxAdapter(child: _buildFiltersSection()),
            _buildApplicationsList(),
          ],
        ),
      ),
    );
  }

  /// App bar with gradient background
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'My Applications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, sidebarColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  /// FIXED: Simple statistics section without animations
  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _isLoadingStats ? _buildLoadingStats() : _buildStatsGrid(),
        ],
      ),
    );
  }

  /// Loading placeholder for statistics
  Widget _buildLoadingStats() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  /// FIXED: Single implementation of statistics grid
  Widget _buildStatsGrid() {
    final stats = [
      _StatItem(
        title: 'All Applications',
        value: _statsData['applications_count'] ?? 0,
        icon: Icons.assignment,
        color: primaryColor,
      ),
      _StatItem(
        title: 'Under Review',
        value: _statsData['under_review_count'] ?? 0,
        icon: Icons.hourglass_empty,
        color: Colors.orange,
      ),
      _StatItem(
        title: 'Interviews',
        value: _statsData['interview_scheduled_count'] ?? 0,
        icon: Icons.calendar_today,
        color: Colors.blue,
      ),
      _StatItem(
        title: 'Offers',
        value: _statsData['hired_count'] ?? 0,
        icon: Icons.check_circle,
        color: Colors.green,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: stat.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: stat.color.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(stat.icon, color: stat.color, size: 32),
              const SizedBox(height: 8),
              Text(
                stat.value.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: stat.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Search section
  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search applications...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _safeSetState(() => _searchQuery = '');
                    _performSearch();
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          _safeSetState(() => _searchQuery = value);
        },
        onSubmitted: (value) => _performSearch(),
      ),
    );
  }

  /// FIXED: Simple filters section
  Widget _buildFiltersSection() {
    final filters = [
      _FilterItem('all', 'All', _allApplications.length),
      _FilterItem('submitted', 'Applied', _getFilterCount('submitted')),
      _FilterItem(
          'under_review', 'Under Review', _getFilterCount('under_review')),
      _FilterItem('interview_scheduled', 'Interview',
          _getFilterCount('interview_scheduled')),
      _FilterItem('hired', 'Offered', _getFilterCount('hired')),
      _FilterItem('rejected', 'Rejected', _getFilterCount('rejected')),
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter.value;

          return GestureDetector(
            onTap: () => _changeFilter(filter.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (filter.count > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        filter.count.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Get count for specific filter
  int _getFilterCount(String filter) {
    return _allApplications.where((app) {
      final status = app['application_status']?.toString() ?? '';
      return status == filter;
    }).length;
  }

  /// FIXED: Stable applications list with fixed itemCount
  Widget _buildApplicationsList() {
    if (_isLoadingApplications && _filteredApplications.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_filteredApplications.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(),
      );
    }

    // FIXED: Stable itemCount prevents assertion errors
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final application = _filteredApplications[index];
          return _buildApplicationCard(application);
        },
        childCount: _filteredApplications.length, // FIXED: Stable count
      ),
    );
  }

  /// Empty state widget
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'all'
                ? 'No applications yet'
                : 'No ${_getFilterDisplayName(_selectedFilter)} applications',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'all'
                ? 'Start applying to jobs to see them here'
                : 'Try a different filter to see more applications',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedFilter == 'all')
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/candidate/jobs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Browse Jobs'),
            ),
        ],
      ),
    );
  }

  /// PHASE 1: Enhanced Application card widget - Now tappable with better visual design
  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final status = application['application_status']?.toString() ?? 'submitted';
    final appliedDate = application['applied_at']?.toString() ??
        application['application_date']?.toString() ??
        '';
    final jobTitle = application['job_title']?.toString() ?? 'Unknown Job';
    final companyName =
        application['company_name']?.toString() ?? 'Unknown Company';
    final location = application['location']?.toString() ?? '';
    final employmentType = application['employment_type']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showApplicationDetails(application),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Job Title + Status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jobTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            companyName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(status),
                  ],
                ),

                const SizedBox(height: 12),

                // Job Details Row
                if (location.isNotEmpty || employmentType.isNotEmpty)
                  Row(
                    children: [
                      if (location.isNotEmpty) ...[
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (employmentType.isNotEmpty) ...[
                          const SizedBox(width: 16),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ],
                      if (employmentType.isNotEmpty) ...[
                        Icon(Icons.work_outline,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          employmentType,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),

                const SizedBox(height: 12),

                // Bottom Row: Applied Date + Tap Indicator
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Applied: ${_formatDate(appliedDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    // Tap indicator
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Status chip widget
  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'submitted':
        color = Colors.blue;
        label = 'Applied';
        break;
      case 'under_review':
        color = Colors.orange;
        label = 'Under Review';
        break;
      case 'interview_scheduled':
        color = Colors.purple;
        label = 'Interview';
        break;
      case 'hired':
        color = Colors.green;
        label = 'Offered';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Get display name for filter
  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'submitted':
        return 'Applied';
      case 'under_review':
        return 'Under Review';
      case 'interview_scheduled':
        return 'Interview';
      case 'hired':
        return 'Offered';
      case 'rejected':
        return 'Rejected';
      default:
        return filter;
    }
  }

  /// PHASE 1: Date formatting helper
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

  /// PHASE 1: Show application details modal (basic structure)
  void _showApplicationDetails(Map<String, dynamic> application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApplicationDetailsModal(
        application: application,
        onWithdraw: () => _handleWithdrawApplication(application),
      ),
    );
  }

  /// PHASE 1: Handle withdraw application (placeholder for Phase 4)
  Future<void> _handleWithdrawApplication(
      Map<String, dynamic> application) async {
    // First close the details modal
    Navigator.pop(context);

    // Show confirmation dialog
    final shouldWithdraw = await _showWithdrawConfirmationDialog(application);

    if (shouldWithdraw == true) {
      await _performWithdrawApplication(application);
    }
  }

  // Show withdraw confirmation dialog
  Future<bool?> _showWithdrawConfirmationDialog(
      Map<String, dynamic> application) async {
    final TextEditingController reasonController = TextEditingController();

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[600],
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Withdraw Application',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to withdraw your application for:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['job_title']?.toString() ??
                            'Unknown Position',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'at ${application['company_name']?.toString() ?? 'Unknown Company'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Reason for withdrawal (optional):',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'e.g., Found another opportunity, Changed career direction, etc.',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: primaryColor),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.red[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This action cannot be undone. You will need to reapply if you change your mind.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                reasonController.dispose();
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                reasonController.dispose();
                Navigator.of(context).pop({
                  'withdraw': true,
                  'reason': reason.isNotEmpty ? reason : null,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Withdraw Application',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    ).then((result) {
      if (result is Map && result['withdraw'] == true) {
        // Store the reason for the actual withdrawal
        _withdrawalReason = result['reason'];
        return true;
      }
      return false;
    });
  }

  /// Perform the actual withdrawal
  Future<void> _performWithdrawApplication(
      Map<String, dynamic> application) async {
    // Show loading
    _safeSetState(() {
      _isPerformingAction = true;
    });

    try {
      final applicationId = application['application_id'];
      if (applicationId == null) {
        throw Exception('Application ID not found');
      }

      final result = await ApiService.withdrawApplication(
        applicationId: applicationId,
        reason: _withdrawalReason,
      );

      if (result['success'] == true) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      result['message'] ?? 'Application withdrawn successfully',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green[600],
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }

        // Refresh the applications list
        await _loadApplicationsData();
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      result['message'] ?? 'Failed to withdraw application',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red[600],
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error: ${e.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      _safeSetState(() {
        _isPerformingAction = false;
      });
    }
  }
}

/// FIXED: Proper data classes prevent widget tree issues
class _StatItem {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _FilterItem {
  final String value;
  final String label;
  final int count;

  const _FilterItem(this.value, this.label, this.count);
}
