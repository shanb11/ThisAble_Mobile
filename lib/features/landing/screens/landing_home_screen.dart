import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../config/constants.dart';
import '../../../config/routes.dart';
import '../widgets/landing_navbar.dart';
import '../widgets/landing_hero.dart';
import '../widgets/job_categories_section.dart';
import '../widgets/inclusive_workplace_section.dart';
import '../widgets/landing_footer.dart';
import '../modals/job_listings_modal.dart';
import '../modals/post_job_modal.dart';

/// Landing Home Screen - Exact mobile version of index.php
/// FIXED: Proper navigation and active states using YOUR ACTUAL theme structure
class LandingHomeScreen extends StatefulWidget {
  const LandingHomeScreen({super.key});

  @override
  State<LandingHomeScreen> createState() => _LandingHomeScreenState();
}

class _LandingHomeScreenState extends State<LandingHomeScreen> {
  // Controllers for search functionality (matches your web search)
  final TextEditingController _jobSearchController = TextEditingController();
  final TextEditingController _locationSearchController =
      TextEditingController();

  @override
  void dispose() {
    _jobSearchController.dispose();
    _locationSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Using YOUR actual color
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navigation Bar - FIXED: Now passes current page and proper callbacks
            LandingNavbar(
              currentPage: 'home', // FIXED: Identify this as home page
              onHomePressed: () {
                // FIXED: Home navigation (refresh current page)
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.landingHome,
                  (route) => false,
                );
              },
              onAboutPressed: () => AppRoutes.goToAbout(context),
              onJobsPressed: () => AppRoutes.goToJobs(context),
            ),

            // Hero Section (mirrors includes/landing/landing_hero.php)
            LandingHero(
              jobSearchController: _jobSearchController,
              locationSearchController: _locationSearchController,
              onSearchPressed: _handleSearch,
            ),

            // Job Categories Section (mirrors includes/landing/landing_job_categories_section.php)
            JobCategoriesSection(
              onCategoryPressed: _handleCategoryPressed,
              onBrowseJobsPressed: _handleBrowseJobs,
            ),

            // Inclusive Workplace Section (mirrors includes/landing/landing_inclusive_workplace.php)
            InclusiveWorkplaceSection(
              onPostJobPressed: _handlePostJob,
            ),

            // Footer (mirrors includes/landing/landing_footer.php)
            const LandingFooter(),
          ],
        ),
      ),
    );
  }

  /// Handle search functionality (matches your web search)
  void _handleSearch() {
    final keyword = _jobSearchController.text.trim();
    final location = _locationSearchController.text.trim();

    if (keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a job title or keyword'),
          backgroundColor: AppColors.errorRed, // Using YOUR actual color
        ),
      );
      return;
    }

    // Show job listings modal with search results (matches your web modal)
    _showJobListingsModal(
      searchKeyword: keyword,
      searchLocation: location,
    );
  }

  /// Handle category selection (matches your web category cards click)
  void _handleCategoryPressed(String categoryId) {
    // Find category data
    final category = AppConstants.jobCategories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => {'name': 'Jobs'},
    );

    // Show job listings modal filtered by category
    _showJobListingsModal(
      categoryFilter: categoryId,
      title: '${category['name']} Jobs',
    );
  }

  /// Handle browse all jobs (matches your web "Browse Jobs" button)
  void _handleBrowseJobs() {
    _showJobListingsModal(
      title: 'All Available Jobs',
    );
  }

  /// Handle post job (matches your web "Post a Job" button)
  void _handlePostJob() {
    _showPostJobModal();
  }

  /// Show Job Listings Modal (mirrors modals/landing/landing_job_listings_modal.php)
  void _showJobListingsModal({
    String? searchKeyword,
    String? searchLocation,
    String? categoryFilter,
    String? title,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobListingsModal(
        searchKeyword: searchKeyword,
        searchLocation: searchLocation,
        categoryFilter: categoryFilter,
        title: title ?? 'Job Search Results',
      ),
    );
  }

  /// Show Post Job Modal (mirrors modals/landing/landing_post_job_modal.php)
  void _showPostJobModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PostJobModal(),
    );
  }
}
