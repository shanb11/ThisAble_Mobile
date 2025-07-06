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
  final int jobsPerPage = 12; // matches your web pagination

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _jobSearchController.dispose();
    _locationController.dispose();
    _alertEmailController.dispose();
    super.dispose();
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

            // Featured Categories (matches your web categories)
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

  /// Jobs Hero Section - matches your CSS .jobs-hero
  Widget _buildJobsHero() {
    return Container(
      width: double.infinity,
      color: AppColors.secondaryTeal, // matches background-color: #257180
      padding: const EdgeInsets.symmetric(
          vertical: 50, horizontal: 20), // matches padding: 50px 0
      child: Column(
        children: [
          // Hero Title (matches .jobs-hero h1)
          Text(
            'Find Your Perfect Job',
            style: AppTextStyles.heroTitle
                .copyWith(fontSize: 32), // Adjusted for jobs page
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 15), // matches margin-bottom: 15px

          // Hero Description (matches .jobs-hero p)
          Container(
            constraints:
                const BoxConstraints(maxWidth: 600), // matches max-width: 600px
            child: Text(
              'Explore thousands of job opportunities from inclusive employers. Find the perfect role that matches your skills and career goals.',
              style: AppTextStyles.heroSubtitle
                  .copyWith(fontSize: 16), // Adjusted for jobs page
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 25), // matches margin-bottom: 25px

          // Quick Search (matches .quick-search)
          _buildQuickSearch(),
        ],
      ),
    );
  }

  /// Quick Search - matches your web .quick-search structure
  Widget _buildQuickSearch() {
    return Container(
      constraints:
          const BoxConstraints(maxWidth: 600), // matches max-width: 600px
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: MediaQuery.of(context).size.width > 768
            ? _buildDesktopQuickSearch()
            : _buildMobileQuickSearch(),
      ),
    );
  }

  /// Desktop Quick Search Layout
  Widget _buildDesktopQuickSearch() {
    return Row(
      children: [
        // Job Search Input
        Expanded(
          child: _buildQuickSearchInput(
            controller: _jobSearchController,
            hintText: 'Job title or keyword',
            icon: Icons.search,
          ),
        ),

        // Divider
        Container(width: 1, height: 50, color: AppColors.borderLight),

        // Location Input
        Expanded(
          child: _buildQuickSearchInput(
            controller: _locationController,
            hintText: 'Location',
            icon: Icons.location_on_outlined,
          ),
        ),

        // Search Button
        CustomButton(
          text: 'Search',
          onPressed: _handleQuickSearch,
          type: CustomButtonType.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        ),
      ],
    );
  }

  /// Mobile Quick Search Layout
  Widget _buildMobileQuickSearch() {
    return Column(
      children: [
        _buildQuickSearchInput(
          controller: _jobSearchController,
          hintText: 'Job title or keyword',
          icon: Icons.search,
        ),
        Container(height: 1, color: AppColors.borderLight),
        _buildQuickSearchInput(
          controller: _locationController,
          hintText: 'Location',
          icon: Icons.location_on_outlined,
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Search Jobs',
              onPressed: _handleQuickSearch,
              type: CustomButtonType.secondary,
            ),
          ),
        ),
      ],
    );
  }

  /// Quick Search Input Helper
  Widget _buildQuickSearchInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textLight, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.formInput,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: AppTextStyles.formPlaceholder,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Search & Filters Section - matches your web .search-filters
  Widget _buildSearchFiltersSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
          vertical: 40, horizontal: 20), // matches padding: 40px 0
      child: Column(
        children: [
          // Section Title
          Text(
            'Refine Your Search',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          // Filters Grid (matches .filters-grid)
          _buildFiltersGrid(),

          const SizedBox(height: 20),

          // Apply Filters Button
          Center(
            child: CustomButton(
              text: 'Apply Filters',
              onPressed: _applyFilters,
              type: CustomButtonType.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Filters Grid - matches your web filter options
  Widget _buildFiltersGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 768 ? 2 : 1,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: MediaQuery.of(context).size.width > 768 ? 3 : 4,
      children: [
        // Category Filter
        _buildFilterDropdown(
          label: 'Category',
          value: selectedCategory,
          items: [
            const DropdownMenuItem(value: null, child: Text('All Categories')),
            ...AppConstants.jobCategories.map((cat) =>
                DropdownMenuItem(value: cat['id'], child: Text(cat['name']!))),
          ],
          onChanged: (value) => setState(() => selectedCategory = value),
        ),

        // Job Type Filter
        _buildFilterDropdown(
          label: 'Job Type',
          value: selectedJobType,
          items: [
            const DropdownMenuItem(value: null, child: Text('All Types')),
            ...AppConstants.jobTypes.map(
                (type) => DropdownMenuItem(value: type, child: Text(type))),
          ],
          onChanged: (value) => setState(() => selectedJobType = value),
        ),

        // Salary Range Filter
        _buildFilterDropdown(
          label: 'Salary Range',
          value: selectedSalaryRange,
          items: const [
            DropdownMenuItem(value: null, child: Text('Any Salary')),
            DropdownMenuItem(
                value: '30k-50k', child: Text('\$30,000 - \$50,000')),
            DropdownMenuItem(
                value: '50k-70k', child: Text('\$50,000 - \$70,000')),
            DropdownMenuItem(
                value: '70k-100k', child: Text('\$70,000 - \$100,000')),
            DropdownMenuItem(value: '100k+', child: Text('\$100,000+')),
          ],
          onChanged: (value) => setState(() => selectedSalaryRange = value),
        ),

        // Experience Level Filter
        _buildFilterDropdown(
          label: 'Experience Level',
          value: selectedExperience,
          items: const [
            DropdownMenuItem(value: null, child: Text('Any Experience')),
            DropdownMenuItem(value: 'entry', child: Text('Entry Level')),
            DropdownMenuItem(value: 'mid', child: Text('Mid Level')),
            DropdownMenuItem(value: 'senior', child: Text('Senior Level')),
            DropdownMenuItem(value: 'executive', child: Text('Executive')),
          ],
          onChanged: (value) => setState(() => selectedExperience = value),
        ),
      ],
    );
  }

  /// Filter Dropdown Helper
  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.formLabel),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Featured Categories - matches your web featured categories
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

          // Categories Grid (first 6 categories)
          GridView.builder(
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
            itemCount: 6, // Show first 6 categories
            itemBuilder: (context, index) {
              final category = AppConstants.jobCategories[index];
              return CategoryCard(
                title: category['name']!,
                count: category['count']!,
                icon: _getCategoryIcon(category['icon']!),
                onTap: () => _handleCategorySearch(category['id']!),
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

        // Page Numbers
        ...List.generate(totalPages, (index) {
          final page = index + 1;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              onPressed: () => _goToPage(page),
              style: TextButton.styleFrom(
                backgroundColor:
                    page == currentPage ? AppColors.primaryOrange : null,
                foregroundColor:
                    page == currentPage ? Colors.white : AppColors.textPrimary,
              ),
              child: Text('$page'),
            ),
          );
        }),

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

  /// Job Alerts Section - matches your web job alerts
  Widget _buildJobAlertsSection() {
    return Container(
      color: AppColors.inclusiveBackground,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            Text(
              'Get Job Alerts',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            Text(
              'Never miss a job opportunity! Subscribe to receive email alerts when new jobs matching your criteria are posted.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Alert Signup Form
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: MediaQuery.of(context).size.width > 768
                  ? _buildDesktopAlertSignup()
                  : _buildMobileAlertSignup(),
            ),
          ],
        ),
      ),
    );
  }

  /// Desktop Alert Signup
  Widget _buildDesktopAlertSignup() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _alertEmailController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter your email address',
              contentPadding: EdgeInsets.all(15),
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
        ),
        CustomButton(
          text: 'Subscribe',
          onPressed: _handleJobAlertSignup,
          type: CustomButtonType.primary,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        ),
      ],
    );
  }

  /// Mobile Alert Signup
  Widget _buildMobileAlertSignup() {
    return Column(
      children: [
        TextField(
          controller: _alertEmailController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter your email address',
            contentPadding: EdgeInsets.all(15),
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Subscribe to Job Alerts',
              onPressed: _handleJobAlertSignup,
              type: CustomButtonType.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================
  // EVENT HANDLERS & BUSINESS LOGIC
  // ===========================================

  /// Load Jobs Data (simulates API call)
  Future<void> _loadJobs() async {
    setState(() => isLoadingJobs = true);

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Sample job data (matches your web structure)
    final jobsData = [
      {
        'id': 1,
        'title': 'Elementary School Teacher',
        'company': 'Bright Future Academy',
        'location': 'New York',
        'type': 'Full-time',
        'category': 'education',
        'salary': '\$45,000 - \$60,000',
        'description':
            'Looking for a passionate elementary school teacher to educate and inspire young minds.',
        'posted': '3 days ago',
      },
      {
        'id': 2,
        'title': 'Administrative Assistant',
        'company': 'Global Solutions Inc.',
        'location': 'Chicago',
        'type': 'Full-time',
        'category': 'office',
        'salary': '\$35,000 - \$45,000',
        'description':
            'Seeking an organized administrative assistant to support our executive team.',
        'posted': '1 week ago',
      },
      {
        'id': 3,
        'title': 'Customer Service Representative',
        'company': 'Tech Support Central',
        'location': 'Remote',
        'type': 'Part-time',
        'category': 'customer',
        'salary': '\$18 - \$22 per hour',
        'description':
            'Join our remote customer service team providing technical support to customers.',
        'posted': '2 days ago',
      },
      {
        'id': 4,
        'title': 'Business Analyst',
        'company': 'Finance Corp',
        'location': 'San Francisco',
        'type': 'Full-time',
        'category': 'business',
        'salary': '\$70,000 - \$90,000',
        'description':
            'Seeking a business analyst to help improve our operational processes.',
        'posted': '1 month ago',
      },
      {
        'id': 5,
        'title': 'Registered Nurse',
        'company': 'Community Health Center',
        'location': 'Miami',
        'type': 'Full-time',
        'category': 'healthcare',
        'salary': '\$65,000 - \$85,000',
        'description': 'Join our healthcare team as a registered nurse.',
        'posted': '2 weeks ago',
      },
      {
        'id': 6,
        'title': 'Bookkeeper',
        'company': 'Small Business Solutions',
        'location': 'Atlanta',
        'type': 'Part-time',
        'category': 'finance',
        'salary': '\$25 - \$30 per hour',
        'description': 'Part-time bookkeeper needed for local accounting firm.',
        'posted': '5 days ago',
      },
      // Add more jobs for pagination testing
      {
        'id': 7,
        'title': 'Software Developer',
        'company': 'Tech Innovations',
        'location': 'Remote',
        'type': 'Full-time',
        'category': 'technology',
        'salary': '\$80,000 - \$120,000',
        'description': 'Experienced developer needed for innovative projects.',
        'posted': '1 day ago',
      },
      {
        'id': 8,
        'title': 'Marketing Coordinator',
        'company': 'Creative Agency',
        'location': 'Los Angeles',
        'type': 'Full-time',
        'category': 'business',
        'salary': '\$50,000 - \$65,000',
        'description': 'Creative marketing coordinator for growing agency.',
        'posted': '4 days ago',
      },
    ];

    setState(() {
      jobs = jobsData;
      filteredJobs = jobsData;
      isLoadingJobs = false;
    });
  }

  /// Handle Quick Search
  void _handleQuickSearch() {
    final keyword = _jobSearchController.text.trim().toLowerCase();
    final location = _locationController.text.trim().toLowerCase();

    List<Map<String, dynamic>> results = jobs;

    // Filter by keyword
    if (keyword.isNotEmpty) {
      results = results
          .where((job) =>
              job['title'].toString().toLowerCase().contains(keyword) ||
              job['company'].toString().toLowerCase().contains(keyword) ||
              job['description'].toString().toLowerCase().contains(keyword))
          .toList();
    }

    // Filter by location
    if (location.isNotEmpty) {
      results = results
          .where((job) =>
              job['location'].toString().toLowerCase().contains(location))
          .toList();
    }

    setState(() {
      filteredJobs = results;
      currentPage = 1;
    });
  }

  /// Apply Advanced Filters
  void _applyFilters() {
    List<Map<String, dynamic>> results = jobs;

    // Apply category filter
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      results =
          results.where((job) => job['category'] == selectedCategory).toList();
    }

    // Apply job type filter
    if (selectedJobType != null && selectedJobType!.isNotEmpty) {
      results = results.where((job) => job['type'] == selectedJobType).toList();
    }

    // Apply salary range filter (simplified logic)
    if (selectedSalaryRange != null && selectedSalaryRange!.isNotEmpty) {
      // Add salary filtering logic based on your requirements
    }

    setState(() {
      filteredJobs = results;
      currentPage = 1;
    });
  }

  /// Clear All Filters
  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      selectedJobType = null;
      selectedSalaryRange = null;
      selectedExperience = null;
      filteredJobs = jobs;
      currentPage = 1;
    });

    _jobSearchController.clear();
    _locationController.clear();
  }

  /// Handle Category Search
  void _handleCategorySearch(String categoryId) {
    setState(() {
      selectedCategory = categoryId;
    });
    _applyFilters();
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
