import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/services/api_service.dart';
import 'profile_screen.dart';
import 'applications_screen.dart';
import 'jobs_screen.dart';
import 'settings_screen.dart';

class CandidateDashboardScreen extends StatefulWidget {
  const CandidateDashboardScreen({super.key});

  @override
  _CandidateDashboardScreenState createState() =>
      _CandidateDashboardScreenState();
}

class _CandidateDashboardScreenState extends State<CandidateDashboardScreen> {
  int _currentIndex = 0;

  // ThisAble Colors
  static const Color primaryColor = Color(0xFF257180);
  static const Color secondaryColor = Color(0xFFF2E5BF);
  static const Color accentColor = Color(0xFFFD8B51);
  static const Color sidebarColor = Color(0xFF2F8A99);

  // ADDED: Safe navigation tracking
  bool _isNavigating = false;

  // Add this method to allow HomePage to trigger navigation
  void updateCurrentIndex(int index) {
    if (mounted && !_isNavigating) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIXED: Create pages without GlobalKeys to prevent conflicts
    final List<Widget> pages = [
      HomePage(), // Home content
      CandidateApplicationsScreen(),
      CandidateJobListingsScreen(),
      CandidateSettingsScreen(),
      CandidateProfileScreen(), // Profile
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // FIXED: Safe navigation with error handling
          if (_isNavigating) return; // Prevent rapid taps

          _isNavigating = true;

          try {
            HapticFeedback.lightImpact();
          } catch (e) {
            // Haptic feedback failed, continue without it
            print('🔧 [Dashboard] Haptic feedback not available: $e');
          }

          setState(() {
            _currentIndex = index;
          });

          // Reset navigation flag after short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            _isNavigating = false;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: "Applications",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: "Jobs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
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
  // ThisAble Colors
  static const Color primaryColor = Color(0xFF257180);
  static const Color secondaryColor = Color(0xFFF2E5BF);
  static const Color accentColor = Color(0xFFFD8B51);
  static const Color sidebarColor = Color(0xFF2F8A99);

  // Loading states
  bool _isLoadingStats = true;
  bool _isLoadingApplications = true;
  bool _isLoadingInterviews = true;

  // ADDED: API call tracking to prevent loops
  bool _isLoadingDashboardData = false;

  // Data from API
  Map<String, dynamic> _statsData = {};
  List<dynamic> _recentApplications = [];
  List<dynamic> _upcomingInterviews = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // FIXED: Single coordinated data loading method
  Future<void> _loadDashboardData() async {
    // Prevent multiple simultaneous calls
    if (_isLoadingDashboardData) {
      print('🔧 [Dashboard] Already loading data, skipping...');
      return;
    }

    setState(() {
      _isLoadingDashboardData = true;
    });

    try {
      print('🔧 [Dashboard] Starting coordinated data load...');

      // Make all API calls in sequence to avoid conflicts
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

      print('🔧 [Dashboard] API Response success: ${response['success']}');

      if (response['success'] && mounted) {
        final data = response['data'];
        final stats = data['stats'] ?? {};

        print('🔧 [Dashboard] Stats data: $stats');

        setState(() {
          _statsData = stats;
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

      print('🔧 [Dashboard] Applications API success: ${response['success']}');

      if (response['success'] && mounted) {
        final data = response['data'];
        final applications = data['applications'] ?? [];

        print('🔧 [Dashboard] Applications count: ${applications.length}');

        setState(() {
          _recentApplications = applications.take(3).toList();
          _isLoadingApplications = false; // FIXED: Always set to false
        });

        print(
            '🔧 [Dashboard] Recent applications loaded: ${_recentApplications.length}');
      } else {
        // FIXED: Handle API failure properly
        print('🔧 [Dashboard] API failed or no data');
        if (mounted) {
          setState(() {
            _recentApplications =
                []; // FIXED: Set empty array instead of keeping loading
            _isLoadingApplications = false;
          });
        }
      }
    } catch (e) {
      print('🔧 [Dashboard] Error loading applications: $e');
      if (mounted) {
        setState(() {
          _recentApplications = []; // FIXED: Set empty array on error
          _isLoadingApplications = false;
        });
      }
    }
  }

  Future<void> _loadUpcomingInterviews() async {
    if (!mounted) return;

    try {
      print('🔧 [Dashboard] Loading upcoming interviews...');
      // Use the already loaded dashboard data to avoid duplicate API calls
      final response = await ApiService.getDashboardHome();

      if (response['success'] && mounted) {
        final data = response['data'];
        final interviews = data['upcoming_interviews'] ?? [];

        print('🔧 [Dashboard] Interviews count: ${interviews.length}');

        setState(() {
          _upcomingInterviews = interviews;
          _isLoadingInterviews = false;
        });

        print(
            '🔧 [Dashboard] Upcoming interviews loaded: ${_upcomingInterviews.length}');
      }
    } catch (e) {
      print('🔧 [Dashboard] Error loading interviews: $e');
      if (mounted) {
        setState(() => _isLoadingInterviews = false);
      }
    }
  }

  // FIXED: Single refresh method to prevent multiple API calls
  Future<void> _refreshData() async {
    // Prevent multiple refresh calls
    if (_isLoadingDashboardData) return;

    setState(() {
      _isLoadingStats = true;
      _isLoadingApplications = true;
      _isLoadingInterviews = true;
    });

    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildQuickStats(),
            const SizedBox(height: 32),
            _buildRecentApplications(),
            const SizedBox(height: 32),
            if (_upcomingInterviews.isNotEmpty) ...[
              _buildUpcomingInterviews(),
              const SizedBox(height: 32),
            ],
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF257180), Color(0xFF2F8A99)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF257180).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ready to find your next opportunity?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // FIXED: Safe navigation to jobs tab
                    try {
                      final dashboardState = context.findAncestorStateOfType<
                          _CandidateDashboardScreenState>();
                      if (dashboardState != null) {
                        dashboardState.updateCurrentIndex(2); // Jobs tab index
                      }
                    } catch (e) {
                      print('🔧 [Dashboard] Navigation error: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF257180),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
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
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF257180)),
            ),
          ),
        );
      },
    );
  }

  // In _buildStatsGrid() method, around line 200
  Widget _buildStatsGrid() {
    final stats = [
      {
        'title': 'Jobs Applied',
        // FIXED: Changed from 'jobs_applied' to 'applications_count' to match API
        'value': _statsData['applications_count']?.toString() ?? '0',
        'icon': Icons.send,
        'color': const Color(0xFF257180)
      },
      {
        'title': 'Jobs Saved',
        // FIXED: Changed from 'jobs_saved' to 'saved_jobs_count' to match API
        'value': _statsData['saved_jobs_count']?.toString() ?? '0',
        'icon': Icons.bookmark,
        'color': const Color(0xFFFFB74D)
      },
      {
        'title': 'Interviews',
        // FIXED: Changed from 'interviews' to 'interviews_count' to match API
        'value': _statsData['interviews_count']?.toString() ?? '0',
        'icon': Icons.calendar_today,
        'color': const Color(0xFF7986CB)
      },
      {
        'title': 'Profile Views',
        // FIXED: This one was already correct
        'value': _statsData['profile_views']?.toString() ?? '0',
        'icon': Icons.visibility,
        'color': const Color(0xFFF06292)
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return GestureDetector(
          onTap: () {
            _showStatDetails(stat['title'] as String);
          },
          child: Container(
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat['title'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                try {
                  final dashboardState = context.findAncestorStateOfType<
                      _CandidateDashboardScreenState>();
                  if (dashboardState != null) {
                    dashboardState
                        .updateCurrentIndex(1); // Applications tab index
                  }
                } catch (e) {
                  print('🔧 [Dashboard] Navigation error: $e');
                }
              },
              child: const Text(
                'View All',
                style: TextStyle(color: Color(0xFF257180)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // FIXED: Better state management
        _buildApplicationsContent(),
      ],
    );
  }

  Widget _buildApplicationsContent() {
    if (_isLoadingApplications) {
      return _buildLoadingApplications();
    }

    if (_recentApplications.isEmpty) {
      return _buildEmptyApplications();
    }

    return _buildApplicationsList();
  }

  Widget _buildLoadingApplications() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 100, // FIXED: Increased height to match real cards
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF257180).withOpacity(0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyApplications() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // ENHANCED: Better icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF257180).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline,
              size: 48,
              color: const Color(0xFF257180).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Applications Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your job search journey!\nApply to jobs that match your skills.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // ENHANCED: Call-to-action button
          ElevatedButton.icon(
            onPressed: () {
              try {
                final dashboardState = context
                    .findAncestorStateOfType<_CandidateDashboardScreenState>();
                if (dashboardState != null) {
                  dashboardState.updateCurrentIndex(2); // Jobs tab index
                }
              } catch (e) {
                print('🔧 [Dashboard] Navigation error: $e');
              }
            },
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Browse Jobs'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF257180),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
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
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    app['job_title'] ?? 'Unknown Position',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        app['company_name'] ?? 'Unknown Company',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatusChip(app['status'] ?? 'applied'),
                          const Spacer(),
                          Text(
                            _formatDate(app['applied_at']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    _viewApplicationDetails(app);
                  },
                ),
              ))
          .toList(),
    );
  }

  Widget _buildUpcomingInterviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Interviews',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingInterviews)
          _buildLoadingInterviews()
        else
          _buildInterviewsList(),
      ],
    );
  }

  Widget _buildLoadingInterviews() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildInterviewsList() {
    return Column(
      children: _upcomingInterviews
          .map((interview) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Interview with ${interview['company_name'] ?? 'Company'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF257180),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            interview['interview_type'] ?? 'Interview',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(interview['scheduled_date']),
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 20),
                        Icon(Icons.access_time,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          interview['scheduled_time'] ?? 'TBA',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          interview['interview_type'] == 'online'
                              ? Icons.videocam
                              : Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            interview['meeting_link'] ??
                                interview['location_address'] ??
                                'Details to be shared',
                            style: TextStyle(color: Colors.grey[700]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Update Profile',
                Icons.person,
                const Color(0xFF257180),
                () {
                  // FIXED: Safe navigation to profile tab
                  try {
                    final dashboardState = context.findAncestorStateOfType<
                        _CandidateDashboardScreenState>();
                    if (dashboardState != null) {
                      dashboardState.updateCurrentIndex(4); // Profile tab index
                    }
                  } catch (e) {
                    print('🔧 [Dashboard] Navigation error: $e');
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'Browse Jobs',
                Icons.search,
                const Color(0xFFFFB74D),
                () {
                  // FIXED: Safe navigation to jobs tab
                  try {
                    final dashboardState = context.findAncestorStateOfType<
                        _CandidateDashboardScreenState>();
                    if (dashboardState != null) {
                      dashboardState.updateCurrentIndex(2); // Jobs tab index
                    }
                  } catch (e) {
                    print('🔧 [Dashboard] Navigation error: $e');
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'under_review':
      case 'under review':
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF9800);
        break;
      case 'shortlisted':
        backgroundColor = const Color(0xFFE0F7FA);
        textColor = const Color(0xFF00BCD4);
        break;
      case 'rejected':
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFF44336);
        break;
      case 'interviewed':
        backgroundColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF4CAF50);
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[600]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'under_review':
        return 'Under Review';
      case 'shortlisted':
        return 'Shortlisted';
      case 'rejected':
        return 'Rejected';
      case 'interviewed':
        return 'Interviewed';
      case 'applied':
        return 'Applied';
      default:
        return status;
    }
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString.toString());
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '${difference} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString.toString();
    }
  }

  void _showStatDetails(String statType) {
    // Show more details about the stat
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(statType),
        content:
            Text('Detailed information about $statType will be shown here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewApplicationDetails(Map<String, dynamic> application) {
    // Navigate to detailed application view
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(application['job_title'] ?? 'Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company: ${application['company_name'] ?? 'N/A'}'),
            Text(
                'Status: ${_formatStatus(application['status'] ?? 'applied')}'),
            Text('Applied: ${_formatDate(application['applied_at'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
