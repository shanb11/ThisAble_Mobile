import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/theme/app_colors.dart'; // Using existing colors
import 'profile_screen.dart';
import 'applications_screen.dart';
import 'jobs_screen.dart';
import 'settings_screen.dart';
import '../../../../../screens/test_api_screen.dart';

class CandidateDashboardScreen extends StatefulWidget {
  const CandidateDashboardScreen({super.key});

  @override
  _CandidateDashboardScreenState createState() =>
      _CandidateDashboardScreenState();
}

class _CandidateDashboardScreenState extends State<CandidateDashboardScreen> {
  int _currentIndex = 0;

  // USING YOUR EXISTING COLORS from app_colors.dart
  static const Color primaryColor = AppColors.secondaryTeal; // #257180
  static const Color accentColor = AppColors.primaryOrange; // #FD8B51

  bool _isNavigating = false;

  void updateCurrentIndex(int index) {
    if (mounted && !_isNavigating) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      CandidateApplicationsScreen(),
      CandidateJobListingsScreen(),
      CandidateSettingsScreen(),
      CandidateProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_isNavigating) return;

          _isNavigating = true;

          try {
            HapticFeedback.lightImpact();
          } catch (e) {
            print('🔧 [Dashboard] Haptic feedback not available: $e');
          }

          setState(() {
            _currentIndex = index;
          });

          Future.delayed(const Duration(milliseconds: 300), () {
            _isNavigating = false;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: AppColors.textLight,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8,
        backgroundColor: AppColors.cardBackground,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.description), label: "Applications"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Jobs"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // USING YOUR EXISTING COLORS
  static const Color primaryColor = AppColors.secondaryTeal;
  static const Color accentColor = AppColors.primaryOrange;

  // Keep existing loading states and data structure
  bool _isLoadingStats = true;
  bool _isLoadingApplications = true;
  bool _isLoadingInterviews = true;
  bool _isLoadingDashboardData = false;

  Map<String, dynamic> _statsData = {};
  List<dynamic> _recentApplications = [];
  List<dynamic> _upcomingInterviews = [];
  List<dynamic> _suggestedJobs = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Keep existing data loading methods
  Future<void> _loadDashboardData() async {
    if (_isLoadingDashboardData) {
      print('🔧 [Dashboard] Already loading data, skipping...');
      return;
    }

    setState(() {
      _isLoadingDashboardData = true;
    });

    try {
      print('🔧 [Dashboard] Starting coordinated data load...');
      await _loadDashboardStats();
      await _loadRecentApplications();
      await _loadUpcomingInterviews();
      print('🔧 [Dashboard] All data loaded successfully');
    } catch (e) {
      print('🔧 [Dashboard] Error during data loading: $e');
    } finally {
      setState(() {
        _isLoadingDashboardData = false;
      });
    }
  }

  Future<void> _loadDashboardStats() async {
    if (!mounted) return;

    try {
      print('🔧 [Dashboard] Loading dashboard stats...');
      final response = await ApiService.getDashboardHome();

      if (response['success'] && mounted) {
        final data = response['data'];
        final stats = data['stats'] ?? {};
        final suggestedJobs = data['suggested_jobs'] ?? [];

        setState(() {
          _statsData = stats;
          _suggestedJobs = suggestedJobs;
          _isLoadingStats = false;
        });

        print('🔧 [Dashboard] Stats loaded successfully');
      }
    } catch (e) {
      print('🔧 [Dashboard] Error loading stats: $e');
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  Future<void> _loadRecentApplications() async {
    if (!mounted) return;

    try {
      print('🔧 [Dashboard] Loading recent applications...');
      final response = await ApiService.getApplicationsList(page: 1);

      if (response['success'] && mounted) {
        final data = response['data'];
        final applications = data['applications'] ?? [];

        setState(() {
          _recentApplications = applications.take(3).toList();
          _isLoadingApplications = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _recentApplications = [];
            _isLoadingApplications = false;
          });
        }
      }
    } catch (e) {
      print('🔧 [Dashboard] Error loading applications: $e');
      if (mounted) {
        setState(() {
          _recentApplications = [];
          _isLoadingApplications = false;
        });
      }
    }
  }

  Future<void> _loadUpcomingInterviews() async {
    if (!mounted) return;

    try {
      print('🔧 [Dashboard] Loading upcoming interviews...');
      final response = await ApiService.getDashboardHome();

      if (response['success'] && mounted) {
        final data = response['data'];
        final interviews = data['upcoming_interviews'] ?? [];

        setState(() {
          _upcomingInterviews = interviews;
          _isLoadingInterviews = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _upcomingInterviews = [];
            _isLoadingInterviews = false;
          });
        }
      }
    } catch (e) {
      print('🔧 [Dashboard] Error loading interviews: $e');
      if (mounted) {
        setState(() {
          _upcomingInterviews = [];
          _isLoadingInterviews = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: primaryColor,
        child: CustomScrollView(
          slivers: [
            // Enhanced App Bar with Search (from artifact)
            _buildAppBar(),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced Welcome Section with Profile Completion
                    _buildWelcomeSection(),
                    const SizedBox(height: 25),

                    // Improved Stats Section
                    _buildQuickStats(),
                    const SizedBox(height: 25),

                    // Enhanced Recent Applications
                    _buildRecentApplications(),
                    const SizedBox(height: 25),

                    // NEW: Upcoming Interviews Section
                    if (_upcomingInterviews.isNotEmpty) ...[
                      _buildUpcomingInterviews(),
                      const SizedBox(height: 25),
                    ],

                    // NEW: Suggested Jobs Section
                    if (_suggestedJobs.isNotEmpty) ...[
                      _buildSuggestedJobs(),
                      const SizedBox(height: 25),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced App Bar with Search (from artifact)
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.cardBackground,
      foregroundColor: AppColors.textPrimary,
      elevation: 2,
      floating: true,
      snap: true,
      title: Row(
        children: [
          Text(
            'ThisAble',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined,
                    color: AppColors.textSecondary),
                onPressed: () {
                  // Navigate to notifications
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '21',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search for jobs, companies, or skills...',
                prefixIcon: Icon(Icons.search, color: AppColors.textLight),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced Welcome Section with Profile Completion (from artifact)
  Widget _buildWelcomeSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, AppColors.primary], // Using existing colors
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Greeting
            const Text(
              'Welcome Back! ✨👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Great progress! Complete a few more sections to maximize your visibility.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),

            // Profile Completion Section (NEW from artifact)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PROFILE COMPLETION',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const Text(
                        '85%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 85,
                          child: Container(
                            decoration: BoxDecoration(
                              color: accentColor, // Using existing orange
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const Expanded(flex: 15, child: SizedBox()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '💡 Complete your profile to increase visibility by up to 40%',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final dashboardState = context.findAncestorStateOfType<
                          _CandidateDashboardScreenState>();
                      dashboardState?.updateCurrentIndex(4); // Profile tab
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Complete Profile',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final dashboardState = context.findAncestorStateOfType<
                          _CandidateDashboardScreenState>();
                      dashboardState?.updateCurrentIndex(2); // Jobs tab
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Browse Jobs',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Improved Stats Section (from artifact)
  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        if (_isLoadingStats) _buildLoadingStats() else _buildStatsGrid(),
      ],
    );
  }

  Widget _buildLoadingStats() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: CircularProgressIndicator(color: primaryColor),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'title': 'Jobs Applied',
        'value': _statsData['applications_count']?.toString() ?? '0',
        'icon': Icons.send,
        'color': primaryColor,
      },
      {
        'title': 'Jobs Saved',
        'value': _statsData['saved_jobs_count']?.toString() ?? '0',
        'icon': Icons.bookmark,
        'color': accentColor,
      },
      {
        'title': 'Interviews',
        'value': _statsData['interviews_count']?.toString() ?? '0',
        'icon': Icons.calendar_today,
        'color': AppColors.infoBlue,
      },
      {
        'title': 'Profile Views',
        'value': _statsData['profile_views']?.toString() ?? '0',
        'icon': Icons.visibility,
        'color': const Color(0xFFF06292),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return GestureDetector(
          onTap: () => _showStatDetails(stat['title'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (stat['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      stat['icon'] as IconData,
                      color: stat['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    stat['value'] as String,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat['title'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Enhanced Recent Applications (from artifact)
  Widget _buildRecentApplications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Applications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                final dashboardState = context
                    .findAncestorStateOfType<_CandidateDashboardScreenState>();
                dashboardState?.updateCurrentIndex(1);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (_isLoadingApplications)
          _buildLoadingApplications()
        else if (_recentApplications.isEmpty)
          _buildEmptyApplications()
        else
          _buildApplicationsList(),
      ],
    );
  }

  Widget _buildLoadingApplications() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(child: CircularProgressIndicator(color: primaryColor)),
        ),
      ),
    );
  }

  Widget _buildEmptyApplications() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.work_outline,
            size: 48,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Applications Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start applying to jobs to see your applications here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final dashboardState = context
                  .findAncestorStateOfType<_CandidateDashboardScreenState>();
              dashboardState?.updateCurrentIndex(2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Browse Jobs'),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList() {
    return Column(
      children: _recentApplications
          .map((app) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Company Logo (NEW from artifact)
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _getCompanyInitials(
                                app['company_name'] ?? 'Unknown'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app['job_title'] ?? 'Unknown Position',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              app['company_name'] ?? 'Unknown Company',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Applied: ${_formatDate(app['applied_at'])}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const Spacer(),
                                _buildStatusBadge(
                                    app['application_status'] ?? 'unknown'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  // NEW: Upcoming Interviews Section (from artifact)
  Widget _buildUpcomingInterviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Interviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to interviews
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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
            ),
          ],
        ),
        const SizedBox(height: 15),
        ..._upcomingInterviews
            .take(2)
            .map((interview) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(color: primaryColor, width: 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatInterviewTime(interview['scheduled_at']),
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          interview['job_title'] ?? 'Interview',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          interview['company_name'] ?? 'Unknown Company',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  // NEW: Suggested Jobs Section (from artifact)
  Widget _buildSuggestedJobs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Suggested Jobs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                final dashboardState = context
                    .findAncestorStateOfType<_CandidateDashboardScreenState>();
                dashboardState?.updateCurrentIndex(2);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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
            ),
          ],
        ),
        const SizedBox(height: 15),
        ..._suggestedJobs
            .take(2)
            .map((job) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Company Logo
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  _getCompanyInitials(
                                      job['company_name'] ?? 'Unknown'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
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
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    job['company_name'] ?? 'Unknown Company',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '90% Match',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${job['location'] ?? 'Remote'} • ${job['employment_type'] ?? 'Full-time'} • Posted ${_formatDate(job['posted_at'])}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Apply to job logic
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Apply Now',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  // Helper Methods (from artifact, using existing colors)
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'submitted':
      case 'applied':
        bgColor = AppColors.infoBlue.withOpacity(0.1);
        textColor = AppColors.infoBlue;
        displayText = 'Applied';
        break;
      case 'under_review':
      case 'under review':
        bgColor = AppColors.warningYellow.withOpacity(0.1);
        textColor = AppColors.warningYellow;
        displayText = 'Under Review';
        break;
      case 'rejected':
        bgColor = AppColors.errorRed.withOpacity(0.1);
        textColor = AppColors.errorRed;
        displayText = 'Rejected';
        break;
      case 'hired':
        bgColor = AppColors.successGreen.withOpacity(0.1);
        textColor = AppColors.successGreen;
        displayText = 'Hired';
        break;
      default:
        bgColor = AppColors.textLight.withOpacity(0.1);
        textColor = AppColors.textLight;
        displayText = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _getCompanyInitials(String companyName) {
    if (companyName.isEmpty) return 'UN';

    final words = companyName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      return companyName.substring(0, 2).toUpperCase();
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';

    try {
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else {
        return date.toString();
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatInterviewTime(dynamic scheduledAt) {
    if (scheduledAt == null) return 'TBD';

    try {
      DateTime dateTime;
      if (scheduledAt is String) {
        dateTime = DateTime.parse(scheduledAt);
      } else {
        return scheduledAt.toString();
      }

      final now = DateTime.now();
      final difference = dateTime.difference(now);

      if (difference.inDays == 0) {
        return 'Today, ${_formatTime(dateTime)}';
      } else if (difference.inDays == 1) {
        return 'Tomorrow, ${_formatTime(dateTime)}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days, ${_formatTime(dateTime)}';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${_formatTime(dateTime)}';
      }
    } catch (e) {
      return 'TBD';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }

  void _showStatDetails(String statType) {
    final messages = {
      'Jobs Applied':
          'You have applied to ${_statsData['applications_count'] ?? 0} jobs. Keep applying to increase your chances!',
      'Jobs Saved':
          'You have saved ${_statsData['saved_jobs_count'] ?? 0} jobs. Save interesting positions to apply later.',
      'Interviews':
          'You have ${_statsData['interviews_count'] ?? 0} interviews. Good luck!',
      'Profile Views':
          'Your profile has been viewed ${_statsData['profile_views'] ?? 0} times. Great visibility!'
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(statType),
        content: Text(messages[statType] ?? 'Details not available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
