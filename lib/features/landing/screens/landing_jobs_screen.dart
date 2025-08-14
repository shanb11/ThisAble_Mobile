import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../config/constants.dart';
import '../../../config/routes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../widgets/landing_navbar.dart';
import '../widgets/landing_footer.dart';
import '../modals/job_listings_modal.dart';
import '../../../core/services/api_service.dart'; // ← ADDED THIS LINE

/// Landing Jobs Screen - Complete mobile version of landing_jobs.php
/// Mirrors your web jobs page structure exactly: hero + search + filters + grid + alerts
class LandingJobsScreen extends StatefulWidget {
  const LandingJobsScreen({super.key});

  @override
  State<LandingJobsScreen> createState() => _LandingJobsScreenState();
}

class _LandingJobsScreenState extends State<LandingJobsScreen> {
  // Search and filter controllers (matches your web job search)
  final _jobSearchController = TextEditingController();
  final _locationController = TextEditingController();
  final _alertEmailController = TextEditingController();

  // Filter state (matches your web filter options)
  String? selectedCategory;
  String? selectedJobType;
  String? selectedSalaryRange;
  String? selectedExperience;

  // Page state
  bool isLoadingJobs = true;
  List<Map<String, dynamic>> jobs = [];
  List<Map<String, dynamic>> filteredJobs = [];
  int currentPage = 1;
  final int jobsPerPage = 12;

  // ← ADDED: Categories state for real API data
  List<Map<String, dynamic>> categories = [];
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _loadCategories(); // ← ADDED: Load real categories
  }

  @override
  void dispose() {
    _jobSearchController.dispose();
    _locationController.dispose();
    _alertEmailController.dispose();
    super.dispose();
  }

  // ← ADDED: Load real categories from API (same as home page)
  Future<void> _loadCategories() async {
    setState(() => isLoadingCategories = true);

    try {
      print('🔧 Loading job categories for jobs page...');

      final response = await ApiService.getJobCategories();

      if (response['success'] == true) {
        final categoriesData = response['data']['categories'] as List<dynamic>;

        setState(() {
          categories = categoriesData.cast<Map<String, dynamic>>();
          isLoadingCategories = false;
        });

        print('✅ Loaded ${categories.length} categories for jobs page');
      } else {
        // Fallback to hardcoded if API fails
        _loadFallbackCategories();
      }
    } catch (e) {
      print('⚠️ Error loading categories: $e');
      _loadFallbackCategories();
    }
  }

  // ← ADDED: Fallback categories (same as home page)
  void _loadFallbackCategories() {
    categories = [
      {
        'id': 'education',
        'name': 'Education & Training',
        'icon': 'graduation-cap',
        'count': '0+'
      },
      {
        'id': 'office',
        'name': 'Office Administration',
        'icon': 'briefcase',
        'count': '0+'
      },
      {
        'id': 'customer',
        'name': 'Customer Service',
        'icon': 'headset',
        'count': '0+'
      },
      {
        'id': 'business',
        'name': 'Business Administration',
        'icon': 'chart-line',
        'count': '0+'
      },
      {
        'id': 'healthcare',
        'name': 'Healthcare & Wellness',
        'icon': 'heartbeat',
        'count': '0+'
      },
      {
        'id': 'finance',
        'name': 'Finance & Accounting',
        'icon': 'dollar-sign',
        'count': '0+'
      },
    ];
    setState(() => isLoadingCategories = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navigation Bar (matches your web jobs page navbar)
            LandingNavbar(
              onAboutPressed: () => AppRoutes.goToAbout(context),
              onJobsPressed: () {}, // Current page
            ),

            // Jobs Hero Section (matches landing_jobs.php hero)
            _buildJobsHero(),

            // Job Search & Filters Section (matches your web search section)
            _buildSearchFiltersSection(),

            // Featured Categories (matches your web categories) - ← NOW USES REAL API DATA
            _buildFeaturedCategories(),

            // Jobs Grid Section (matches your web jobs grid)
            _buildJobsGridSection(),

            // Job Alerts Section (matches your web job alerts)
            _buildJobAlertsSection(),

            // Footer (matches your web footer)
            const LandingFooter(),
          ],
        ),
      ),
    );
  }

  /// Load Jobs Data from Real API
  Future<void> _loadJobs() async {
    setState(() => isLoadingJobs = true);

    try {
      print('🔧 Loading jobs from database...');

      // Call your real API
      final response = await ApiService.getLandingJobs(
        search: _jobSearchController.text.isNotEmpty
            ? _jobSearchController.text
            : null,
        location: _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
        category: selectedCategory,
        limit: 50,
      );

      print('🔧 API Response: ${response['success']}');

      if (response['success'] == true) {
        final jobsData = response['data']['jobs'] as List<dynamic>;

        // Map API response to expected format
        final mappedJobs = jobsData.map<Map<String, dynamic>>((job) {
          return {
            'id': job['job_id'],
            'title': job['job_title'] ?? job['title'],
            'company': job['company_name'] ?? job['company'],
            'location': job['location'],
            'type': job['employment_type'] ?? job['type'] ?? 'Full-time',
            'category': _mapJobCategory(job['department'] ?? ''),
            'salary': job['salary_range'] ?? 'Competitive',
            'description': job['job_description'] ?? job['description'] ?? '',
            'posted': _formatPostedDate(job['posted_at'] ?? job['created_at']),
            'job_id': job['job_id'],
            'employer_id': job['employer_id'],
            'requirements': job['job_requirements'],
            'deadline': job['application_deadline'],
            'remote_available': job['remote_work_available'] ?? false,
            'flexible_schedule': job['flexible_schedule'] ?? false,
          };
        }).toList();

        setState(() {
          jobs = mappedJobs;
          filteredJobs = List.from(jobs);
          isLoadingJobs = false;
        });

        print('✅ Successfully loaded ${jobs.length} real jobs from database!');

        if (jobs.isNotEmpty) {
          print(
              '📋 First job: ${jobs.first['title']} at ${jobs.first['company']}');
        }
      } else {
        setState(() {
          jobs = [];
          filteredJobs = [];
          isLoadingJobs = false;
        });

        print('❌ API Error: ${response['message']}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to load jobs: ${response['message'] ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Network Error: $e');

      setState(() {
        jobs = [];
        filteredJobs = [];
        isLoadingJobs = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error: Please check your connection'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    _applyFilters();
  }

  /// Map job department to category for filtering
  String _mapJobCategory(String department) {
    final categoryMap = {
      'IT': 'technology',
      'Technology': 'technology',
      'Healthcare': 'healthcare',
      'Education': 'education',
      'Finance': 'finance',
      'Customer Service': 'customer',
      'Administrative': 'office',
      'Marketing': 'business',
      'Sales': 'business',
      'Human Resources': 'business',
    };

    return categoryMap[department] ?? 'other';
  }

  /// Format posted date to user-friendly string
  String _formatPostedDate(dynamic postedAt) {
    if (postedAt == null) return 'Recently';

    try {
      final postedDate = DateTime.parse(postedAt.toString());
      final now = DateTime.now();
      final difference = now.difference(postedDate).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '$difference days ago';
      } else if (difference < 30) {
        return '${(difference / 7).floor()} weeks ago';
      } else {
        return '${(difference / 30).floor()} months ago';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  /// Jobs Hero Section - matches your CSS .jobs-hero
  Widget _buildJobsHero() {
    return Container(
      width: double.infinity,
      color: AppColors.secondaryTeal,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Column(
        children: [
          Text(
            'Find Your Perfect Job',
            style: AppTextStyles.heroTitle.copyWith(fontSize: 32),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Explore thousands of job opportunities from inclusive employers. Find the perfect role that matches your skills and career goals.',
              style: AppTextStyles.heroSubtitle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Search and Filters Section
  Widget _buildSearchFiltersSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          Text(
            'Search Jobs',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Search bars
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _jobSearchController,
                  decoration: const InputDecoration(
                    hintText: 'Job title or keyword',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    hintText: 'Location',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          CustomButton(
            text: 'Search Jobs',
            onPressed: _handleJobSearch,
            type: CustomButtonType.primary,
          ),
        ],
      ),
    );
  }

  /// ← UPDATED: Featured Categories - now uses REAL API data instead of hardcoded
  Widget _buildFeaturedCategories() {
    return Container(
      color: AppColors.backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Column(
        children: [
          Text(
            'Popular Categories',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // ← CHANGED: Show loading or real categories instead of hardcoded
          isLoadingCategories
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 992
                        ? 3
                        : MediaQuery.of(context).size.width > 768
                            ? 2
                            : 1,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio:
                        MediaQuery.of(context).size.width > 768 ? 1.2 : 1.5,
                  ),
                  itemCount: categories.length > 6
                      ? 6
                      : categories.length, // Show first 6
                  itemBuilder: (context, index) {
                    final category =
                        categories[index]; // ← CHANGED: Use real categories
                    return CategoryCard(
                      title: category['name'] ?? 'Unknown',
                      count: category['count']?.toString() ?? '0',
                      icon: _getCategoryIcon(category['icon'] ?? 'briefcase'),
                      onTap: () => _handleCategorySearch(category['id'] ?? ''),
                    );
                  },
                ),
        ],
      ),
    );
  }

  /// Jobs Grid Section - matches your web jobs grid
  Widget _buildJobsGridSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Column(
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Jobs (${filteredJobs.length})',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
              ),
              DropdownButton<String>(
                value: 'latest',
                items: const [
                  DropdownMenuItem(value: 'latest', child: Text('Latest')),
                  DropdownMenuItem(
                      value: 'salary', child: Text('Highest Salary')),
                  DropdownMenuItem(
                      value: 'relevant', child: Text('Most Relevant')),
                ],
                onChanged: (value) => _handleSortChange(value),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Jobs Grid or Loading
          isLoadingJobs ? _buildJobsLoading() : _buildJobsGrid(),

          // Pagination
          if (!isLoadingJobs && filteredJobs.isNotEmpty) ...[
            const SizedBox(height: 40),
            _buildPagination(),
          ],
        ],
      ),
    );
  }

  /// Jobs Grid
  Widget _buildJobsGrid() {
    if (filteredJobs.isEmpty) {
      return _buildNoJobsFound();
    }

    final startIndex = (currentPage - 1) * jobsPerPage;
    final endIndex = startIndex + jobsPerPage;
    final pageJobs = filteredJobs.sublist(startIndex,
        endIndex > filteredJobs.length ? filteredJobs.length : endIndex);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 768 ? 2 : 1,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: MediaQuery.of(context).size.width > 768 ? 1.1 : 0.8,
      ),
      itemCount: pageJobs.length,
      itemBuilder: (context, index) {
        final job = pageJobs[index];
        return JobCard(
          jobTitle: job['title'],
          company: job['company'],
          location: job['location'],
          jobType: job['type'],
          salary: job['salary'],
          description: job['description'],
          postedTime: job['posted'],
          onTap: () => _showJobDetails(job),
          onApply: () => _handleApply(job),
          onSave: () => _handleSave(job),
        );
      },
    );
  }

  /// Jobs Loading State
  Widget _buildJobsLoading() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 768 ? 2 : 1,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: MediaQuery.of(context).size.width > 768 ? 1.1 : 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const JobCardShimmer(),
    );
  }

  /// No Jobs Found State
  Widget _buildNoJobsFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(
              Icons.work_off_outlined,
              size: 80,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 20),
            Text(
              'No Jobs Found',
              style: AppTextStyles.cardTitle,
            ),
            const SizedBox(height: 10),
            Text(
              'Try adjusting your search criteria or filters to find more opportunities.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Clear Filters',
              onPressed: _clearFilters,
              type: CustomButtonType.outlined,
            ),
          ],
        ),
      ),
    );
  }

  /// Pagination
  Widget _buildPagination() {
    final totalPages = (filteredJobs.length / jobsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous Button
        IconButton(
          onPressed: currentPage > 1 ? () => _goToPage(currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),

        // Page Info
        Text(
          'Page $currentPage of $totalPages',
          style: AppTextStyles.bodyMedium,
        ),

        // Next Button
        IconButton(
          onPressed: currentPage < totalPages
              ? () => _goToPage(currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  /// Job Alerts Section
  Widget _buildJobAlertsSection() {
    return Container(
      color: AppColors.backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Column(
        children: [
          Text(
            'Get Job Alerts',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Stay updated with the latest job opportunities that match your preferences.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _alertEmailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CustomButton(
                  text: 'Subscribe',
                  onPressed: _handleJobAlertSignup,
                  type: CustomButtonType.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================
  // EVENT HANDLERS & BUSINESS LOGIC
  // ===========================================

  /// Handle search button press
  Future<void> _handleJobSearch() async {
    await _loadJobs(); // This will now use the search parameters
  }

  /// Handle category filter
  Future<void> _handleCategorySearch(String categoryId) async {
    setState(() {
      selectedCategory = categoryId;
    });
    await _loadJobs(); // Reload with new category filter
  }

  /// Clear all filters
  Future<void> _clearFilters() async {
    setState(() {
      selectedCategory = null;
      selectedJobType = null;
      selectedSalaryRange = null;
      selectedExperience = null;
    });

    _jobSearchController.clear();
    _locationController.clear();

    await _loadJobs(); // Reload without filters
  }

  /// Apply Filters (local filtering)
  void _applyFilters() {
    setState(() {
      filteredJobs = List.from(jobs);
      // Add additional local filtering logic here if needed
    });
  }

  /// Handle Sort Change
  void _handleSortChange(String? sortBy) {
    if (sortBy == null) return;

    List<Map<String, dynamic>> sorted = List.from(filteredJobs);

    switch (sortBy) {
      case 'latest':
        // Sort by posted date (most recent first)
        break;
      case 'salary':
        // Sort by salary (highest first)
        break;
      case 'relevant':
        // Sort by relevance
        break;
    }

    setState(() {
      filteredJobs = sorted;
    });
  }

  /// Go to Page
  void _goToPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  /// Show Job Details
  void _showJobDetails(Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobListingsModal(
        title: job['title'],
        searchKeyword: job['title'],
      ),
    );
  }

  /// Handle Job Application
  void _handleApply(Map<String, dynamic> job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied to ${job['title']} at ${job['company']}! 🎉'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  /// Handle Save Job
  void _handleSave(Map<String, dynamic> job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved ${job['title']} to your favorites! 📌'),
        backgroundColor: AppColors.primaryOrange,
      ),
    );
  }

  /// Handle Job Alert Signup
  void _handleJobAlertSignup() {
    final email = _alertEmailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully subscribed to job alerts! 🔔'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    _alertEmailController.clear();
  }

  /// Get Category Icon
  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'graduation-cap':
        return Icons.school_outlined;
      case 'briefcase':
        return Icons.work_outline;
      case 'headset':
        return Icons.headset_mic_outlined;
      case 'chart-line':
        return Icons.trending_up_outlined;
      case 'heartbeat':
        return Icons.favorite_outline;
      case 'dollar-sign':
        return Icons.attach_money_outlined;
      default:
        return Icons.work_outline;
    }
  }
}
