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
import '../../../core/services/api_service.dart';

/// Landing Jobs Screen - Complete mobile version of landing_jobs.php
/// FIXED: Proper navigation and active states using YOUR ACTUAL theme structure
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

  // Categories state for real API data
  List<Map<String, dynamic>> categories = [];
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _loadCategories();
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
      backgroundColor: AppColors.backgroundColor, // Using YOUR actual color
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navigation Bar - FIXED: Now passes current page and proper callbacks
            LandingNavbar(
              currentPage: 'jobs', // FIXED: Identify this as jobs page
              onHomePressed: () => AppRoutes.goToHome(context),
              onAboutPressed: () => AppRoutes.goToAbout(context),
              onJobsPressed: () {
                // FIXED: Jobs navigation (refresh current page)
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.landingJobs,
                  (route) => false,
                );
              },
            ),

            // Jobs Hero Section (matches landing_jobs.php hero)
            _buildJobsHero(),

            // Job Search & Filters Section (matches your web search section)
            _buildSearchFiltersSection(),

            // Footer (matches your web footer)
            const LandingFooter(),
          ],
        ),
      ),
    );
  }

  // Keep your existing _loadJobs and other methods...
  Future<void> _loadJobs() async {
    // Your existing implementation
  }

  Future<void> _loadCategories() async {
    // Your existing implementation
  }

  Widget _buildJobsHero() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryOrange, // Using YOUR actual colors
            AppColors.secondaryTeal,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Find Your Dream Job',
                style: AppTextStyles.sectionTitle.copyWith(
                  // Using YOUR actual text style
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Discover inclusive opportunities that match your skills and passion',
                style: AppTextStyles.bodyLarge.copyWith(
                  // Using YOUR actual text style
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFiltersSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Search Inputs
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _jobSearchController,
                  decoration: const InputDecoration(
                    hintText: 'Job title or keyword',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 16),

          // Search Button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Search Jobs',
              onPressed: _loadJobs,
              type: CustomButtonType.primary, // Using YOUR actual button type
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
