import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/custom_button.dart';

/// Job Categories Section - NOW USES REAL API DATA FROM YOUR DATABASE
/// Fetches actual job categories and counts from your categories.php API
class JobCategoriesSection extends StatefulWidget {
  final Function(String categoryId)? onCategoryPressed;
  final VoidCallback? onBrowseJobsPressed;

  const JobCategoriesSection({
    super.key,
    this.onCategoryPressed,
    this.onBrowseJobsPressed,
  });

  @override
  State<JobCategoriesSection> createState() => _JobCategoriesSectionState();
}

class _JobCategoriesSectionState extends State<JobCategoriesSection> {
  // Categories state
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  int totalJobs = 0;

  @override
  void initState() {
    super.initState();
    _loadCategoriesFromAPI(); // NOW CALLS REAL API
  }

  /// REAL API CALL - Load categories with actual job counts from your database
  Future<void> _loadCategoriesFromAPI() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      print('🔧 Loading job categories from API...');

      // Call your REAL API (categories.php)
      final response = await ApiService.getJobCategories();

      print('🔧 Categories API Response: ${response['success']}');
      print('🔧 Categories API Message: ${response['message']}');

      if (response['success'] == true) {
        final categoriesData = response['data']['categories'] as List<dynamic>;
        final statsData = response['data']['stats'] as Map<String, dynamic>;

        setState(() {
          categories = categoriesData.cast<Map<String, dynamic>>();
          totalJobs = statsData['total_jobs'] ?? 0;
          isLoading = false;
          hasError = false;
        });

        print(
            '✅ Successfully loaded ${categories.length} categories from your database!');
        print('✅ Total jobs available: $totalJobs');

        // Print category counts for debugging
        for (var category in categories) {
          print('📊 ${category['name']}: ${category['count']} jobs');
        }
      } else {
        // Fallback to hardcoded data if API fails (graceful degradation)
        _loadFallbackCategories();
        setState(() {
          isLoading = false;
          hasError = false; // Don't show error, just use fallback
        });
        print(
            '⚠️ API failed, using fallback categories: ${response['message']}');
      }
    } catch (e) {
      // Fallback to hardcoded data on any error
      _loadFallbackCategories();
      setState(() {
        isLoading = false;
        hasError = false; // Don't show error, just use fallback
      });
      print('⚠️ Exception loading categories, using fallback: $e');
    }
  }

  /// Fallback to hardcoded categories if API is unavailable (graceful degradation)
  void _loadFallbackCategories() {
    categories = [
      {
        'id': 'education',
        'name': 'Education & Training',
        'icon': 'graduation-cap',
        'count': '0+',
      },
      {
        'id': 'office',
        'name': 'Office Administration',
        'icon': 'briefcase',
        'count': '0+',
      },
      {
        'id': 'customer',
        'name': 'Customer Service',
        'icon': 'headset',
        'count': '0+',
      },
      {
        'id': 'business',
        'name': 'Business Administration',
        'icon': 'chart-line',
        'count': '0+',
      },
      {
        'id': 'healthcare',
        'name': 'Healthcare & Wellness',
        'icon': 'heartbeat',
        'count': '0+',
      },
      {
        'id': 'finance',
        'name': 'Finance & Accounting',
        'icon': 'dollar-sign',
        'count': '0+',
      },
    ];
    totalJobs = 0;
    print('📝 Loaded fallback categories');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Section Title
            Text(
              'Explore Job Categories',
              style: AppTextStyles.sectionTitle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Section Subtitle with REAL job count from your database
            Text(
              totalJobs > 0
                  ? 'Find your perfect job among $totalJobs+ opportunities from your database'
                  : 'Click the job types perfect for you',
              style: AppTextStyles.sectionSubtitle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Categories Grid - shows REAL data from your API or loading
            isLoading ? _buildLoadingGrid() : _buildCategoriesGrid(context),

            const SizedBox(height: 40),

            // Browse All Button with REAL job count
            _buildBrowseAllButton(),
          ],
        ),
      ),
    );
  }

  /// Loading grid while categories are being fetched from API
  Widget _buildLoadingGrid() {
    return GridView.builder(
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
        childAspectRatio: MediaQuery.of(context).size.width > 768 ? 1.2 : 1.5,
      ),
      itemCount: 6, // Show 6 loading placeholders
      itemBuilder: (context, index) {
        return _buildLoadingCategoryCard();
      },
    );
  }

  /// Loading placeholder for category card
  Widget _buildLoadingCategoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.secondaryTeal,
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Categories Grid with REAL data from your API
  Widget _buildCategoriesGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 992 ? 3 : (screenWidth > 768 ? 2 : 1),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: screenWidth > 768 ? 1.2 : 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          title: category['name'] ?? 'Category',
          count: category['count'] ?? '0+', // REAL count from your database
          icon: _getCategoryIcon(category['icon'] ?? 'briefcase'),
          onTap: () => widget.onCategoryPressed?.call(category['id'] ?? ''),
          // Show if this category has jobs from database
          hasJobs: category['job_count'] != null && category['job_count'] > 0,
        );
      },
    );
  }

  /// Browse All Button with REAL job count from database
  Widget _buildBrowseAllButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: BrowseJobsButton(
        text: totalJobs > 0
            ? 'Browse All $totalJobs+ Jobs from Database'
            : 'Browse All Jobs',
        onPressed: widget.onBrowseJobsPressed,
      ),
    );
  }

  /// Get Icon for Category - maps API icon names to Flutter icons
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
      case 'cog':
        return Icons.settings_outlined;
      case 'palette':
        return Icons.palette_outlined;
      case 'bullhorn':
        return Icons.campaign_outlined;
      default:
        return Icons.work_outline;
    }
  }
}

/// Category Card - individual job category with REAL job count from database
class CategoryCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final VoidCallback? onTap;
  final bool hasJobs;

  const CategoryCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    this.onTap,
    this.hasJobs = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasJobs ? AppColors.secondaryTeal : AppColors.borderLight,
            width: hasJobs ? 2 : 1,
          ),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      (hasJobs ? AppColors.secondaryTeal : AppColors.textLight)
                          .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color:
                      hasJobs ? AppColors.secondaryTeal : AppColors.textLight,
                  size: 30,
                ),
              ),

              const SizedBox(height: 15),

              // Category Title
              Text(
                title,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 18,
                  color:
                      hasJobs ? AppColors.secondaryTeal : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // Job Count (REAL data from your database)
              Text(
                '$count opportunities',
                style: AppTextStyles.bodySmall.copyWith(
                  color:
                      hasJobs ? AppColors.secondaryTeal : AppColors.textLight,
                  fontWeight: hasJobs ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),

              // Indicator if category has jobs
              if (hasJobs) ...[
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Available',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryTeal,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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
}

/// Browse Jobs Button - enhanced with REAL job count from database
class BrowseJobsButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;

  const BrowseJobsButton({
    super.key,
    this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondaryTeal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text ?? 'Browse All Jobs',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_forward, size: 18),
        ],
      ),
    );
  }
}
