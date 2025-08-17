import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/services/api_service.dart';

/// Job Categories Section - FIXED: Real database data, NO Browse All button
/// Shows actual categories from database with accurate job counts
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

  @override
  void initState() {
    super.initState();
    _loadCategoriesFromAPI();
  }

  /// Load categories with real job counts from database
  Future<void> _loadCategoriesFromAPI() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      print('🔧 Loading job categories from API...');

      // Call your REAL API (categories.php)
      final response = await ApiService.getJobCategories();

      if (response['success'] == true) {
        final categoriesData = response['data']['categories'] as List<dynamic>;

        setState(() {
          categories = categoriesData.cast<Map<String, dynamic>>();
          isLoading = false;
          hasError = false;
        });

        print(
            '✅ Successfully loaded ${categories.length} categories from database!');

        // Log actual data for debugging
        for (var category in categories) {
          print('📊 ${category['name']}: ${category['count']} jobs');
        }
      } else {
        setState(() {
          hasError = true;
          errorMessage = response['message'] ?? 'Failed to load categories';
          isLoading = false;
        });
        print('❌ API Error: ${response['message']}');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Connection error: $e';
        isLoading = false;
      });
      print('❌ Exception loading categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Column(
        children: [
          // Section Header
          _buildSectionHeader(),

          const SizedBox(height: 40),

          // Categories Content (NO Browse All button)
          _buildCategoriesContent(),
        ],
      ),
    );
  }

  /// Section Header - matches your web section header
  Widget _buildSectionHeader() {
    return Column(
      children: [
        Text(
          'Explore Job Categories',
          style: AppTextStyles.sectionTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Click the job types perfect for you',
          style: AppTextStyles.sectionSubtitle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Categories Content - FIXED: Only shows categories grid, no Browse All button
  Widget _buildCategoriesContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(
            color: AppColors.primaryOrange,
          ),
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load job categories',
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.errorRed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCategoriesFromAPI,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (categories.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 48,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No job categories available',
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      );
    }

    // FIXED: Only categories grid - completely removed Browse All button
    return _buildCategoriesGrid();
  }

  /// Categories Grid - displays all categories in grid layout
  Widget _buildCategoriesGrid() {
    final screenWidth = MediaQuery.of(context).size.width;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 1200
            ? 3
            : (screenWidth > 768 ? 2 : 1), // Responsive grid
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: screenWidth > 768 ? 1.2 : 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          title: category['name'] ?? 'Category',
          count: category['count'] ?? '0', // Real count from database
          icon: _getCategoryIcon(category['icon'] ?? 'briefcase'),
          onTap: () => widget.onCategoryPressed?.call(category['id'] ?? ''),
          hasJobs: category['job_count'] != null && category['job_count'] > 0,
        );
      },
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

/// Category Card - individual job category card with real job count
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
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: hasJobs
                      ? AppColors.categoryIconBackground
                      : AppColors.borderLight.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color:
                      hasJobs ? AppColors.secondaryTeal : AppColors.textLight,
                ),
              ),

              const SizedBox(height: 20),

              // Category Title
              Text(
                title,
                style: AppTextStyles.cardTitle.copyWith(
                  color: hasJobs ? AppColors.textPrimary : AppColors.textLight,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Job Count
              Text(
                count == '0' ? 'Coming soon!' : '$count opportunities',
                style: AppTextStyles.cardSubtitle.copyWith(
                  color:
                      hasJobs ? AppColors.secondaryTeal : AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),

              // Status Indicator (if has jobs)
              if (hasJobs) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.categoryIconBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Available',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryTeal,
                      fontWeight: FontWeight.w500,
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
