import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../config/routes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../widgets/landing_navbar.dart';
import '../widgets/landing_footer.dart';
import '../widgets/job_card_widget.dart';
import '../modals/job_details_modal.dart';
import '../../../core/services/api_service.dart';

/// Landing Jobs Screen - COMPLETE IMPLEMENTATION
/// Displays all jobs from your database on the landing page
class LandingJobsScreen extends StatefulWidget {
  const LandingJobsScreen({super.key});

  @override
  State<LandingJobsScreen> createState() => _LandingJobsScreenState();
}

class _LandingJobsScreenState extends State<LandingJobsScreen> {
  // Controllers
  final _jobSearchController = TextEditingController();
  final _locationController = TextEditingController();
  final _scrollController = ScrollController();

  // State
  bool isLoadingJobs = true;
  bool isLoadingMore = false;
  List<Map<String, dynamic>> jobs = [];
  List<Map<String, dynamic>> filteredJobs = [];

  // Pagination
  int currentPage = 1;
  final int jobsPerPage = 12;
  int totalJobs = 0;
  bool hasMoreJobs = true;

  // Filters
  String? selectedCategory;
  String? selectedJobType;

  // Categories for filtering
  final List<Map<String, String>> jobCategories = [
    {'id': 'education', 'name': 'Education & Training', 'icon': '🎓'},
    {'id': 'office', 'name': 'Office Administration', 'icon': '💼'},
    {'id': 'customer', 'name': 'Customer Service', 'icon': '🎧'},
    {'id': 'business', 'name': 'Business Administration', 'icon': '📊'},
    {'id': 'healthcare', 'name': 'Healthcare & Wellness', 'icon': '❤️'},
    {'id': 'finance', 'name': 'Finance & Accounting', 'icon': '💰'},
  ];

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _jobSearchController.dispose();
    _locationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Load jobs from API - COMPLETE IMPLEMENTATION
  Future<void> _loadJobs({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        isLoadingJobs = true;
        currentPage = 1;
        jobs.clear();
        filteredJobs.clear();
        hasMoreJobs = true;
      });
    } else if (!hasMoreJobs || isLoadingMore) {
      return;
    }

    setState(() {
      if (refresh) {
        isLoadingJobs = true;
      } else {
        isLoadingMore = true;
      }
    });

    try {
      print('🔍 Loading jobs from database...');
      print('   Search: ${_jobSearchController.text}');
      print('   Location: ${_locationController.text}');
      print('   Category: $selectedCategory');
      print('   Type: $selectedJobType');
      print('   Page: $currentPage');

      final response = await ApiService.getLandingJobs(
        search: _jobSearchController.text.isEmpty
            ? null
            : _jobSearchController.text,
        location:
            _locationController.text.isEmpty ? null : _locationController.text,
        category: selectedCategory,
        jobType: selectedJobType,
        limit: jobsPerPage,
        offset: (currentPage - 1) * jobsPerPage,
      );

      print('📦 API Response: ${response['success']}');

      if (response['success'] == true) {
        final jobsData = response['data']['jobs'] as List<dynamic>;
        final pagination =
            response['data']['pagination'] as Map<String, dynamic>;

        setState(() {
          if (refresh) {
            jobs = jobsData.cast<Map<String, dynamic>>();
          } else {
            jobs.addAll(jobsData.cast<Map<String, dynamic>>());
          }

          filteredJobs = List.from(jobs);
          totalJobs = pagination['total'] ?? 0;
          hasMoreJobs = jobs.length < totalJobs;
          isLoadingJobs = false;
          isLoadingMore = false;
        });

        print('✅ Loaded ${jobsData.length} jobs. Total: $totalJobs');
      } else {
        setState(() {
          isLoadingJobs = false;
          isLoadingMore = false;
        });
        _showError(response['message'] ?? 'Failed to load jobs');
      }
    } catch (e) {
      print('❌ Error loading jobs: $e');
      setState(() {
        isLoadingJobs = false;
        isLoadingMore = false;
      });
      _showError('Failed to load jobs. Please check your connection.');
    }
  }

  /// Handle scroll for infinite loading
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (hasMoreJobs && !isLoadingMore) {
        setState(() => currentPage++);
        _loadJobs();
      }
    }
  }

  /// Handle search
  void _handleSearch() {
    currentPage = 1;
    _loadJobs(refresh: true);
  }

  /// Handle category filter
  void _handleCategoryFilter(String? categoryId) {
    setState(() {
      selectedCategory = categoryId == selectedCategory ? null : categoryId;
      currentPage = 1;
    });
    _loadJobs(refresh: true);
  }

  /// Handle job type filter
  void _handleJobTypeFilter(String? jobType) {
    setState(() {
      selectedJobType = jobType == selectedJobType ? null : jobType;
      currentPage = 1;
    });
    _loadJobs(refresh: true);
  }

  /// Show job details modal
  void _showJobDetails(Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobDetailsModal(
        job: job,
        onApply: () => _handleApply(job),
      ),
    );
  }

  /// Handle apply - redirect to login/signup
  void _handleApply(Map<String, dynamic> job) {
    Navigator.pop(context); // Close modal

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Required'),
        content: const Text(
          'Please sign in or create an account to apply for this job.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.candidateSignup);
            },
            child: const Text('Sign Up'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.candidateLogin);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  /// Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () => _loadJobs(refresh: true),
        color: AppColors.primaryOrange,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Navigation Bar
            SliverToBoxAdapter(
              child: LandingNavbar(
                currentPage: 'jobs',
                onHomePressed: () => AppRoutes.goToHome(context),
                onAboutPressed: () => AppRoutes.goToAbout(context),
                onJobsPressed: () {},
              ),
            ),

            // Hero Section
            SliverToBoxAdapter(child: _buildHeroSection()),

            // Search Section
            SliverToBoxAdapter(child: _buildSearchSection()),

            // Category Filters
            SliverToBoxAdapter(child: _buildCategoryFilters()),

            // Job Type Filters
            SliverToBoxAdapter(child: _buildJobTypeFilters()),

            // Jobs Count Header
            SliverToBoxAdapter(child: _buildJobsHeader()),

            // Jobs Grid
            _buildJobsGrid(),

            // Loading More Indicator
            if (isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            // Footer
            const SliverToBoxAdapter(child: LandingFooter()),
          ],
        ),
      ),
    );
  }

  // ============ BUILD METHODS ============

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryOrange,
            AppColors.secondaryTeal,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find Your Perfect Job',
              style: AppTextStyles.sectionTitle.copyWith(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Browse thousands of job opportunities across various industries and locations',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Keywords Input
          TextField(
            controller: _jobSearchController,
            decoration: InputDecoration(
              hintText: 'Job title, skills, or company',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onSubmitted: (_) => _handleSearch(),
          ),
          const SizedBox(height: 12),

          // Location Input
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'City, state, or "Remote"',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onSubmitted: (_) => _handleSearch(),
          ),
          const SizedBox(height: 16),

          // Search Button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Search Jobs',
              onPressed: _handleSearch,
              type: CustomButtonType.primary,
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse by Category',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: jobCategories.map((category) {
              final isSelected = selectedCategory == category['id'];
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category['icon']!),
                    const SizedBox(width: 8),
                    Text(category['name']!),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => _handleCategoryFilter(category['id']),
                selectedColor: AppColors.primaryOrange.withOpacity(0.2),
                checkmarkColor: AppColors.primaryOrange,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildJobTypeFilters() {
    final jobTypes = ['Full-time', 'Part-time', 'Contract', 'Freelance'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Type',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: jobTypes.map((type) {
              final isSelected = selectedJobType == type;
              return FilterChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (_) => _handleJobTypeFilter(type),
                selectedColor: AppColors.secondaryTeal.withOpacity(0.2),
                checkmarkColor: AppColors.secondaryTeal,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isLoadingJobs
                ? 'Loading jobs...'
                : '$totalJobs ${totalJobs == 1 ? 'Job' : 'Jobs'} Found',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
          ),
          if (!isLoadingJobs && jobs.isNotEmpty)
            Text(
              'Showing ${jobs.length} of $totalJobs',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJobsGrid() {
    if (isLoadingJobs) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (filteredJobs.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No jobs found',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search filters',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Clear Filters',
                onPressed: () {
                  setState(() {
                    _jobSearchController.clear();
                    _locationController.clear();
                    selectedCategory = null;
                    selectedJobType = null;
                  });
                  _loadJobs(refresh: true);
                },
                type: CustomButtonType.secondary,
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(24.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final job = filteredJobs[index];
            return JobCardWidget(
              job: job,
              onTap: () => _showJobDetails(job),
              onApply: () => _handleApply(job),
            );
          },
          childCount: filteredJobs.length,
        ),
      ),
    );
  }
}
