import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/services/api_service.dart';

class CandidateApplicationsScreen extends StatefulWidget {
  const CandidateApplicationsScreen({super.key});

  @override
  _CandidateApplicationsScreenState createState() =>
      _CandidateApplicationsScreenState();
}

class _CandidateApplicationsScreenState
    extends State<CandidateApplicationsScreen> with TickerProviderStateMixin {
  // ThisAble Colors
  static const Color primaryColor = Color(0xFF257180);
  static const Color secondaryColor = Color(0xFFF2E5BF);
  static const Color accentColor = Color(0xFFFD8B51);
  static const Color sidebarColor = Color(0xFF2F8A99);

  // Filter and Search State
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Animation Controllers
  late AnimationController _statsAnimationController;
  late List<Animation<double>> _statsAnimations;

  // Loading States
  bool _isLoadingApplications = true;
  bool _isLoadingStats = true;
  bool _isPerformingAction = false;

  // ADDED: Disposal tracking to prevent errors
  bool _isDisposed = false;

  // Data from API
  List<dynamic> _allApplications = [];
  Map<String, dynamic> _statsData = {};
  int _currentPage = 1;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadApplicationsData();
  }

  // Fix the _initializeAnimations method in applications_screen.dart around line 45
  void _initializeAnimations() {
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // FIXED: Ensure all intervals stay within 0.0 to 1.0 range
    _statsAnimations = List.generate(4, (index) {
      // Calculate safe intervals that never exceed 1.0
      final startTime = (index * 0.15).clamp(0.0, 0.6); // Max start: 0.6
      final endTime =
          (startTime + 0.4).clamp(startTime + 0.1, 1.0); // Max end: 1.0

      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _statsAnimationController,
        curve: Interval(
          startTime, // Safe start times: 0.0, 0.15, 0.3, 0.45
          endTime, // Safe end times: 0.4, 0.55, 0.7, 0.85
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    // Delay animation start to avoid conflicts with initial loading
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && !_statsAnimationController.isAnimating) {
        _statsAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    print('🔧 [Applications] Disposing widget...');

    _isDisposed = true;

    // Stop animations before disposing
    if (_statsAnimationController.isAnimating) {
      _statsAnimationController.stop();
    }

    // Dispose animation controller
    _statsAnimationController.dispose();

    // Dispose text controllers
    _searchController.dispose();

    print('🔧 [Applications] Widget disposed successfully');
    super.dispose();
  }

  // ADDED: Safe state update method
  void _safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      setState(fn);
    }
  }

  Future<void> _loadApplicationsData() async {
    await Future.wait([
      _loadApplications(),
      _loadApplicationStats(),
    ]);
  }

  // Fix the _loadApplications method in applications_screen.dart
  Future<void> _loadApplications({bool refresh = false}) async {
    if (_isDisposed) return;

    if (refresh) {
      _safeSetState(() {
        _isLoadingApplications = true;
        _currentPage = 1;
        _allApplications.clear();
        _hasMoreData = true;
      });
    }

    try {
      print('🔧 [Applications] Loading applications...');
      print('🔧 [Applications] Status filter: $_selectedFilter');
      print('🔧 [Applications] Search query: $_searchQuery');
      print('🔧 [Applications] Page: $_currentPage');

      final response = await ApiService.getApplicationsList(
        status: _selectedFilter == 'all' ? null : _selectedFilter,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: _currentPage,
      );

      print('🔧 [Applications] API Response: ${response.toString()}');
      print('🔧 [Applications] API Response success: ${response['success']}');

      if (response['success'] == true && mounted && !_isDisposed) {
        final data = response['data'];
        if (data != null) {
          final newApplications = data['applications'] ?? [];
          final pagination = data['pagination'] ?? {};

          print(
              '🔧 [Applications] New applications count: ${newApplications.length}');
          print('🔧 [Applications] Pagination: $pagination');

          _safeSetState(() {
            if (refresh || _currentPage == 1) {
              _allApplications = newApplications;
            } else {
              _allApplications.addAll(newApplications);
            }

            final totalPages = pagination['total_pages'] ?? 1;
            _hasMoreData = _currentPage < totalPages;
            _isLoadingApplications = false;
          });

          print(
              '🔧 [Applications] Total applications: ${_allApplications.length}');
          print('🔧 [Applications] Has more data: $_hasMoreData');
        } else {
          print('🔧 [Applications] API returned null data');
          _safeSetState(() {
            _allApplications = [];
            _hasMoreData = false;
            _isLoadingApplications = false;
          });
        }
      } else {
        print(
            '🔧 [Applications] API failed: ${response['message'] ?? 'Unknown error'}');

        _safeSetState(() {
          if (refresh || _currentPage == 1) {
            _allApplications = [];
          }
          _hasMoreData = false;
          _isLoadingApplications = false;
        });

        if (_currentPage == 1) {
          _showErrorSnackBar(
              response['message'] ?? 'Failed to load applications');
        }
      }
    } catch (e) {
      print('🔧 [Applications] Error loading applications: $e');
      if (mounted && !_isDisposed) {
        _safeSetState(() {
          _isLoadingApplications = false;
          if (refresh || _currentPage == 1) {
            _allApplications = [];
          }
          _hasMoreData = false;
        });
        _showErrorSnackBar('Network error: Failed to load applications');
      }
    }
  }

  // Fix the _loadApplicationStats method around line 80
  Future<void> _loadApplicationStats() async {
    if (_isDisposed) return;

    try {
      final response = await ApiService.getDashboardHome();
      if (response['success'] && mounted && !_isDisposed) {
        _safeSetState(() {
          _statsData = response['data']['stats'] ?? {};
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        _safeSetState(() => _isLoadingStats = false);
        _showErrorSnackBar('Failed to load application statistics');
      }
    }
  }

  Future<void> _performSearch() async {
    if (_isDisposed) return;
    _currentPage = 1;
    await _loadApplications(refresh: true);
  }

  Future<void> _changeFilter(String filter) async {
    if (_isDisposed) return;
    if (_selectedFilter != filter) {
      _safeSetState(() {
        _selectedFilter = filter;
      });
      _currentPage = 1;
      await _loadApplications(refresh: true);
    }
  }

  Future<void> _withdrawApplication(Map<String, dynamic> application) async {
    if (_isDisposed) return;

    _safeSetState(() => _isPerformingAction = true);

    try {
      final response = await ApiService.performApplicationAction(
        applicationId: application['application_id'],
        action: 'withdraw_application',
      );

      if (response['success']) {
        _showSuccessSnackBar('Application withdrawn successfully');
        await _loadApplications(refresh: true);
        await _loadApplicationStats();
      } else {
        _showErrorSnackBar(
            response['message'] ?? 'Failed to withdraw application');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to withdraw application');
    } finally {
      if (mounted && !_isDisposed) {
        _safeSetState(() => _isPerformingAction = false);
      }
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

  List<dynamic> get _filteredApplications {
    return _allApplications.where((app) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return (app['job_title']?.toString().toLowerCase().contains(query) ??
                false) ||
            (app['company_name']?.toString().toLowerCase().contains(query) ??
                false);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () => _loadApplicationsData(),
        child: CustomScrollView(
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

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          if (_isLoadingStats) _buildLoadingStats() else _buildStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildLoadingStats() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  // Fix the _buildStatsGrid method around line 140
  Widget _buildStatsGrid() {
    final stats = [
      StatItem(
        'All Applications',
        // FIXED: Changed from 'total' to 'applications_count' to match API
        _statsData['applications_count'] ?? 0,
        Icons.assignment,
        primaryColor,
      ),
      StatItem(
        'Under Review',
        // FIXED: This field doesn't exist in current API, using 0 for now
        0, // _statsData['under_review'] ?? 0,
        Icons.hourglass_empty,
        Colors.orange,
      ),
      StatItem(
        'Interviews',
        // FIXED: Changed from 'interview' to 'interviews_count' to match API
        _statsData['interviews_count'] ?? 0,
        Icons.calendar_today,
        Colors.blue,
      ),
      StatItem(
        'Offers',
        // FIXED: This field doesn't exist in current API, using 0 for now
        // TODO: Update get_dashboard_home.php to include offer status
        0, // _statsData['offered'] ?? 0,
        Icons.check_circle,
        Colors.green,
      ),
    ];

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return AnimatedBuilder(
            animation: _statsAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _statsAnimations[index].value,
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: stat.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(stat.icon, color: stat.color, size: 20),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stat.value.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stat.title,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

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
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _performSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        onSubmitted: (value) => _performSearch(),
      ),
    );
  }

  // Fix the _buildFiltersSection method around line 180
  Widget _buildFiltersSection() {
    final filters = [
      // FIXED: Use applications_count from dashboard stats for 'all' count
      FilterOption('all', 'All', _statsData['applications_count'] ?? 0),
      // FIXED: These detailed breakdown stats aren't in current API, using 0 for now
      // TODO: Update get_applications_list.php to return status-based counts in filter_stats
      FilterOption(
          'applied', 'Applied', 0), // Will be populated when API is updated
      FilterOption('under_review', 'Under Review', 0),
      FilterOption(
          'interview', 'Interview', _statsData['interviews_count'] ?? 0),
      FilterOption('offered', 'Offered', 0),
      FilterOption('rejected', 'Rejected', 0),
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter.key;

          return GestureDetector(
            onTap: () => _changeFilter(filter.key),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
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
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (filter.count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        filter.count.toString(),
                        style: TextStyle(
                          color: isSelected ? primaryColor : Colors.white,
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

  Widget _buildApplicationsList() {
    if (_isLoadingApplications && _allApplications.isEmpty) {
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

    if (_filteredApplications.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == _filteredApplications.length) {
            if (_hasMoreData) {
              return _buildLoadMoreButton();
            }
            return const SizedBox.shrink();
          }

          final application = _filteredApplications[index];
          return _buildApplicationCard(application);
        },
        childCount: _filteredApplications.length + (_hasMoreData ? 1 : 0),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
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
            _searchQuery.isNotEmpty
                ? 'No applications found for "$_searchQuery"'
                : 'No applications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search criteria'
                : 'Start applying to jobs to see them here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to jobs tab - will be handled by bottom navigation
                Navigator.of(context).pop(); // Close current screen if in modal
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Browse Jobs',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
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
            await _loadApplications();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primaryColor,
            elevation: 2,
          ),
          child: const Text('Load More'),
        ),
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
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
        onTap: () => _showApplicationDetails(application),
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
                        _getCompanyInitials(application['company_name'] ?? ''),
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
                          application['job_title'] ?? 'Unknown Position',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application['company_name'] ?? 'Unknown Company',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(application['status'] ?? 'applied'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.location_on,
                    application['location'] ?? 'Remote',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.work,
                    application['employment_type'] ?? 'Full-time',
                  ),
                ],
              ),
              if (application['salary_range'] != null) ...[
                const SizedBox(height: 8),
                _buildInfoChip(
                  Icons.attach_money,
                  application['salary_range'],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Applied ${_formatDate(application['applied_at'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (_canWithdraw(application))
                    TextButton(
                      onPressed: _isPerformingAction
                          ? null
                          : () => _confirmWithdrawal(application),
                      child: Text(
                        'Withdraw',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                        ),
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

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'applied':
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        displayText = 'Applied';
        break;
      case 'under_review':
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF9800);
        displayText = 'Under Review';
        break;
      case 'interview':
        backgroundColor = const Color(0xFFE0F7FA);
        textColor = const Color(0xFF00BCD4);
        displayText = 'Interview';
        break;
      case 'offered':
        backgroundColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF4CAF50);
        displayText = 'Offered';
        break;
      case 'rejected':
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFF44336);
        displayText = 'Rejected';
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[600]!;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
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
    if (dateString == null) return 'N/A';
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
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString.toString();
    }
  }

  bool _canWithdraw(Map<String, dynamic> application) {
    final status = application['status']?.toString().toLowerCase() ?? '';
    return status == 'applied' || status == 'under_review';
  }

  void _confirmWithdrawal(Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Application'),
        content: Text(
          'Are you sure you want to withdraw your application for ${application['job_title']} at ${application['company_name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _withdrawApplication(application);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Withdraw',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showApplicationDetails(Map<String, dynamic> application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildApplicationDetailsModal(application),
    );
  }

  Widget _buildApplicationDetailsModal(Map<String, dynamic> application) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
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
                        application['job_title'] ?? 'Unknown Position',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application['company_name'] ?? 'Unknown Company',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(application['status'] ?? 'applied'),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Details
                  _buildDetailSection('Job Information', [
                    DetailItem(
                      'Location',
                      application['location'] ?? 'Remote',
                      Icons.location_on,
                    ),
                    DetailItem(
                      'Type',
                      application['employment_type'] ?? 'Full-time',
                      Icons.work,
                    ),
                    if (application['salary_range'] != null)
                      DetailItem(
                        'Salary',
                        application['salary_range'],
                        Icons.attach_money,
                      ),
                    DetailItem(
                      'Applied',
                      _formatDate(application['applied_at']),
                      Icons.calendar_today,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Application Progress
                  _buildDetailSection('Application Progress', []),
                  _buildProgressIndicator(application),

                  const SizedBox(height: 24),

                  // Description
                  if (application['job_description'] != null) ...[
                    _buildDetailSection('Job Description', []),
                    Text(
                      application['job_description'],
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Requirements
                  if (application['job_requirements'] != null) ...[
                    _buildDetailSection('Requirements', []),
                    Text(
                      application['job_requirements'],
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Actions
                  if (_canWithdraw(application))
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _confirmWithdrawal(application);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Withdraw Application'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<DetailItem> items) {
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
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(item.icon, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text('${item.label}: ',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  Expanded(child: Text(item.value)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildProgressIndicator(Map<String, dynamic> application) {
    final status = application['status']?.toString().toLowerCase() ?? 'applied';
    final steps = ['Applied', 'Under Review', 'Interview', 'Decision'];
    int currentStep = 0;

    switch (status) {
      case 'applied':
        currentStep = 0;
        break;
      case 'under_review':
        currentStep = 1;
        break;
      case 'interview':
        currentStep = 2;
        break;
      case 'offered':
      case 'rejected':
        currentStep = 3;
        break;
    }

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = index <= currentStep;
        final isActive = index == currentStep;

        return Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? primaryColor : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? primaryColor : Colors.grey[600],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// Data Models
class StatItem {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  StatItem(this.title, this.value, this.icon, this.color);
}

class FilterOption {
  final String key;
  final String label;
  final int count;

  FilterOption(this.key, this.label, this.count);
}

class DetailItem {
  final String label;
  final String value;
  final IconData icon;

  DetailItem(this.label, this.value, this.icon);
}
