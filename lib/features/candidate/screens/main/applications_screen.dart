import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/services/api_service.dart';
import '../../widgets/application_details_modal.dart';
import '../../../../../core/theme/app_colors.dart';

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
  static const Color sidebarColor =
      Color(0xFF2F8A99); // Not in AppColors, keep local

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

  String? _withdrawalReason;

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

  Future<void> _loadApplicationStats() async {
    if (_isDisposed) return;

    try {
      final response = await ApiService.getDashboardHome();
      if (response['success'] == true && !_isDisposed) {
        _safeSetState(() {
          // Use safe type conversion here too
          _statsData = _convertStatsData(response['data']['stats'] ?? {});
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

  // Add this helper method to applications screen
  Map<String, dynamic> _convertStatsData(Map<String, dynamic> rawStats) {
    Map<String, dynamic> convertedStats = {};

    rawStats.forEach((key, value) {
      if (value is String) {
        // Try to convert string to int
        convertedStats[key] = int.tryParse(value) ?? 0;
      } else if (value is int) {
        convertedStats[key] = value;
      } else {
        convertedStats[key] = 0;
      }
    });

    return convertedStats;
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
        color: AppColors.secondaryTeal, // Added
        backgroundColor: Colors.white, // Added
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(),
            const SliverToBoxAdapter(
                child: SizedBox(height: 16)), // Added spacing
            SliverToBoxAdapter(child: _buildStatsSection()),
            const SliverToBoxAdapter(
                child: SizedBox(height: 12)), // Added spacing
            SliverToBoxAdapter(child: _buildSearchSection()),
            const SliverToBoxAdapter(
                child: SizedBox(height: 12)), // Added spacing
            SliverToBoxAdapter(child: _buildFiltersSection()),
            const SliverToBoxAdapter(
                child: SizedBox(height: 8)), // Added spacing
            _buildApplicationsList(),
            const SliverToBoxAdapter(
                child: SizedBox(height: 16)), // Bottom padding
          ],
        ),
      ),
    );
  }

  /// App bar with gradient background
  /// Enhanced app bar with gradient and decorative elements
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130, // Increased from 120
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.secondaryTeal,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 72, bottom: 16),
        title: const Text(
          'My Applications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22, // Increased from 20
            fontWeight: FontWeight.w800, // Increased from bold
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        background: Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondaryTeal,
                    sidebarColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Decorative circles
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              right: 30,
              top: 60,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryOrange.withOpacity(0.1),
                ),
              ),
            ),

            // Bottom accent line
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryOrange,
                      AppColors.primaryOrange.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FIXED: Simple statistics section without animations
  /// Enhanced statistics section with professional styling
  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Enhanced shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        // Gradient accent border on top
        border: Border(
          top: BorderSide(
            width: 3,
            color: AppColors.secondaryTeal,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient background
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondaryTeal.withOpacity(0.05),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Application Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700, // Increased weight
                    color: Colors.black87,
                    letterSpacing: 0.5, // Increased from 0.3
                    height: 1.2, // Line height
                  ),
                ),
                Icon(
                  Icons.analytics_outlined,
                  color: AppColors.secondaryTeal,
                  size: 20,
                ),
              ],
            ),
          ),

          // Stats grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoadingStats ? _buildLoadingStats() : _buildStatsGrid(),
          ),
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
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey[100]!,
                Colors.grey[50]!,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: Colors.grey[300]!,
                width: 4,
              ),
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.secondaryTeal,
              ),
            ),
          ),
        );
      },
    );
  }

  /// FIXED: Single implementation of statistics grid
  Widget _buildStatsGrid() {
    final stats = [
      _StatItem(
        title: 'Total Applications',
        value: _statsData['applications_count'] ?? 0,
        icon: Icons.assignment,
        color: AppColors.secondaryTeal,
        trend: '+100%', // You can make this dynamic from API
        showTrend: true,
      ),
      _StatItem(
        title: 'Applications Reviewed',
        value: _statsData['under_review_count'] ?? 0,
        icon: Icons.rate_review,
        color: AppColors.statusUnderReview,
        percentage: '0% response rate', // You can make this dynamic from API
        showPercentage: true,
      ),
      _StatItem(
        title: 'Interviews Scheduled',
        value: _statsData['interview_scheduled_count'] ?? 0,
        icon: Icons.event,
        color: AppColors.statusInterviewing,
      ),
      _StatItem(
        title: 'Job Offers',
        value: _statsData['hired_count'] ?? 0,
        icon: Icons.check_circle,
        color: AppColors.statusHired,
        percentage: '0% response rate', // You can make this dynamic from API
        showPercentage: true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(stat);
      },
    );
  }

  Widget _buildStatCard(_StatItem stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            stat.color.withOpacity(0.08),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: stat.color,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: stat.color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon and trend badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: stat.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  stat.icon,
                  color: stat.color,
                  size: 24,
                ),
              ),
              // Trend badge (if applicable)
              if (stat.showTrend && stat.trend != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        size: 10,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        stat.trend!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Value with gradient text
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [stat.color, stat.color.withOpacity(0.7)],
            ).createShader(bounds),
            child: Text(
              stat.value.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Label
          Text(
            stat.title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Percentage (if applicable)
          if (stat.showPercentage && stat.percentage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                stat.percentage!,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Search section
  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search applications...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 15,
            letterSpacing: 0.2,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.secondaryTeal,
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _safeSetState(() => _searchQuery = '');
                    _performSearch();
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Remove border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.secondaryTeal,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
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
    // Define filters with labels
    final filters = [
      {'value': 'all', 'label': 'All Applications'},
      {'value': 'submitted', 'label': 'Applied'},
      {'value': 'under_review', 'label': 'Reviewed'},
      {'value': 'interview_scheduled', 'label': 'Interview'},
      {'value': 'hired', 'label': 'Offered'},
      {'value': 'rejected', 'label': 'Rejected'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: filters.map((filter) {
            final value = filter['value'] as String;
            final label = filter['label'] as String;
            final isSelected = _selectedFilter == value;
            final count = _getFilterCount(value);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(label, value, isSelected, count),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Build enhanced filter chip with count badge
  /// Build enhanced filter chip with count badge
  Widget _buildFilterChip(
      String label, String value, bool isSelected, int count) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _safeSetState(() {
            _selectedFilter = value;
            // Apply filter by updating the filtered list
            if (value == 'all') {
              _filteredApplications = List.from(_allApplications);
            } else {
              _filteredApplications = _allApplications.where((app) {
                final status = app['application_status']?.toString() ?? '';
                return status == value;
              }).toList();
            }
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.secondaryTeal,
                      AppColors.secondaryTeal.withOpacity(0.8),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.secondaryTeal : Colors.grey[300]!,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.secondaryTeal.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.25)
                        : AppColors.secondaryTeal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: Colors.white.withOpacity(0.3))
                        : null,
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : AppColors.secondaryTeal,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
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
              color: Colors.grey[700], // Slightly darker
              fontWeight: FontWeight.w600, // Increased from w500
              letterSpacing: 0.2, // Added
              height: 1.3, // Line height
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'all'
                ? 'Start applying to jobs to see them here'
                : 'Try a different filter to see more applications',
            style: TextStyle(
              fontSize: 15, // Increased from 14
              color: Colors.grey[600], // Slightly darker
              height: 1.4, // Line height
              letterSpacing: 0.1, // Added
            ),
            textAlign: TextAlign.center, // Added center alignment
          ),
          const SizedBox(height: 24),
          if (_selectedFilter == 'all')
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/candidate/jobs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryTeal,
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

  /// Extract company initials for logo
  String _getCompanyInitials(String companyName) {
    return companyName
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();
  }

  /// Build company logo circle with gradient
  Widget _buildCompanyLogo(String companyName) {
    final initials = _getCompanyInitials(companyName);

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryTeal.withOpacity(0.9),
            AppColors.primaryOrange.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryTeal.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// Get status configuration (color, label, icon)
  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return {
          'color': AppColors.statusSubmitted,
          'label': 'Applied',
          'icon': Icons.send,
        };
      case 'under_review':
        return {
          'color': AppColors.statusUnderReview,
          'label': 'Under Review',
          'icon': Icons.rate_review,
        };
      case 'interview_scheduled':
      case 'interviewed':
        return {
          'color': AppColors.statusInterviewing,
          'label': 'Interview',
          'icon': Icons.calendar_today,
        };
      case 'hired':
        return {
          'color': AppColors.statusHired,
          'label': 'Hired',
          'icon': Icons.check_circle,
        };
      case 'rejected':
        return {
          'color': AppColors.statusRejected,
          'label': 'Rejected',
          'icon': Icons.cancel,
        };
      case 'withdrawn':
        return {
          'color': Colors.grey[600]!,
          'label': 'Withdrawn',
          'icon': Icons.remove_circle_outline,
        };
      default:
        return {
          'color': AppColors.statusSubmitted,
          'label': 'Applied',
          'icon': Icons.send,
        };
    }
  }

  /// Build enhanced status badge with gradient and icon
  Widget _buildStatusBadge(String status) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config['color'].withOpacity(0.9),
            config['color'],
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: config['color'].withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'],
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            config['label'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Build progress timeline visualization
  Widget _buildProgressTimeline(String status) {
    // Only show timeline for active application statuses
    final activeStatuses = [
      'submitted',
      'under_review',
      'interview_scheduled',
      'hired'
    ];
    if (!activeStatuses.contains(status.toLowerCase())) {
      return const SizedBox.shrink();
    }

    // Define stages
    final stages = [
      {'key': 'submitted', 'label': 'Applied', 'icon': Icons.send},
      {'key': 'under_review', 'label': 'Review', 'icon': Icons.rate_review},
      {'key': 'interview_scheduled', 'label': 'Interview', 'icon': Icons.event},
      {'key': 'hired', 'label': 'Offer', 'icon': Icons.check_circle},
    ];

    // Determine current stage index
    int currentStageIndex =
        stages.indexWhere((s) => s['key'] == status.toLowerCase());
    if (currentStageIndex == -1) currentStageIndex = 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: List.generate(stages.length * 2 - 1, (index) {
          if (index.isOdd) {
            // This is a connector line
            final lineIndex = index ~/ 2;
            final isActive = lineIndex < currentStageIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: isActive ? AppColors.secondaryTeal : Colors.grey[300],
              ),
            );
          } else {
            // This is a stage indicator
            final stageIndex = index ~/ 2;
            final stage = stages[stageIndex];
            final isActive = stageIndex <= currentStageIndex;
            final isCurrent = stageIndex == currentStageIndex;

            return Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        isActive ? AppColors.secondaryTeal : Colors.grey[300],
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(
                            color: AppColors.primaryOrange,
                            width: 2.5,
                          )
                        : null,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.secondaryTeal.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    stage['icon'] as IconData,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 50,
                  child: Text(
                    stage['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          isActive ? AppColors.secondaryTeal : Colors.grey[500],
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  /// Build interview info box (if interview is scheduled)
  Widget _buildInterviewInfo(Map<String, dynamic> application) {
    final status = application['application_status']?.toString() ?? '';

    // Only show for interview_scheduled status
    if (status.toLowerCase() != 'interview_scheduled') {
      return const SizedBox.shrink();
    }

    // For now, show placeholder. You can add actual interview date/time from API
    final interviewDate = application['interview_date']?.toString();
    final interviewTime = application['interview_time']?.toString();

    if (interviewDate == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.statusInterviewing.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.statusInterviewing.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.statusInterviewing,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.event,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Interview Scheduled',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  interviewTime != null
                      ? '$interviewDate at $interviewTime'
                      : interviewDate,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// PHASE 1: Enhanced Application card widget - Now tappable with better visual design
  /// Enhanced application card with company logo, timeline, and professional styling
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
    final statusConfig = _getStatusConfig(status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: statusConfig['color'],
                width: 4,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showApplicationDetails(application),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Company Logo + Job Info + Status Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company Logo
                      _buildCompanyLogo(companyName),
                      const SizedBox(width: 12),

                      // Job Title and Company
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              jobTitle,
                              style: const TextStyle(
                                fontSize: 18, // Increased from 17
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                height: 1.3, // Better line height
                                letterSpacing: 0.2, // Slightly increased
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              companyName,
                              style: TextStyle(
                                fontSize: 15, // Increased from 14
                                fontWeight:
                                    FontWeight.w600, // Increased from w500
                                color: Colors.grey[700],
                                letterSpacing: 0.1, // Added letter spacing
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Status Badge
                      _buildStatusBadge(status),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Divider
                  Divider(
                    color: Colors.grey[200],
                    height: 1,
                  ),

                  const SizedBox(height: 12),

                  // Job Details Row
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      if (location.isNotEmpty)
                        _buildDetailChip(
                          Icons.location_on_outlined,
                          location,
                          AppColors.secondaryTeal,
                        ),
                      if (employmentType.isNotEmpty)
                        _buildDetailChip(
                          Icons.work_outline,
                          employmentType,
                          AppColors.primaryOrange,
                        ),
                      _buildDetailChip(
                        Icons.calendar_today_outlined,
                        _formatDate(appliedDate),
                        Colors.grey[600]!,
                      ),
                    ],
                  ),

                  // Progress Timeline
                  _buildProgressTimeline(status),

                  // Interview Info (if applicable)
                  _buildInterviewInfo(application),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build detail chip (location, employment type, date)
  Widget _buildDetailChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13, // Increased from 12
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1, // Added
          ),
        ),
      ],
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
  /// Format date for display
  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Recently';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      } else {
        final months = (difference.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      }
    } catch (e) {
      return dateString;
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

// STEP 1: Change the method signature to allow dynamic returns
  Future<dynamic> _showWithdrawConfirmationDialog(
      Map<String, dynamic> application) async {
    final TextEditingController reasonController = TextEditingController();

    return showDialog<dynamic>(
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
                    color: AppColors.secondaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.secondaryTeal.withOpacity(0.3)),
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
                          color: AppColors.secondaryTeal,
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
                      borderSide:
                          const BorderSide(color: AppColors.secondaryTeal),
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
      // Handle the case where user cancels (returns false)
      if (result == false || result == null) {
        return false;
      }

      // Handle the case where user confirms withdrawal (returns Map)
      if (result is Map && result['withdraw'] == true) {
        // Store the reason for the actual withdrawal
        _withdrawalReason = result['reason'] as String?;
        return true;
      }

      // Fallback for any other case
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
/// Stat item model with enhanced properties
class _StatItem {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool showTrend;
  final String? percentage;
  final bool showPercentage;

  _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.showTrend = false,
    this.percentage,
    this.showPercentage = false,
  });
}

class _FilterItem {
  final String value;
  final String label;
  final int count;

  const _FilterItem(this.value, this.label, this.count);
}
