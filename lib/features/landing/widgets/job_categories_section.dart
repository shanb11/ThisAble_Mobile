import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/custom_button.dart';

/// Job Categories Section - Mobile version of includes/landing/landing_job_categories_section.php
/// Matches your web categories section styling exactly
class JobCategoriesSection extends StatelessWidget {
  final Function(String categoryId)? onCategoryPressed;
  final VoidCallback? onBrowseJobsPressed;

  const JobCategoriesSection({
    super.key,
    this.onCategoryPressed,
    this.onBrowseJobsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Matches your CSS: padding: 60px 0, background-color: #fff
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 20), // matches container padding
        child: Column(
          children: [
            // Section Title (matches your CSS .categories h2)
            Text(
              'Explore Job Categories',
              style: AppTextStyles.sectionTitle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20), // matches margin-bottom: 10px

            // Section Subtitle (matches your CSS .categories > p)
            Text(
              'Click the job types perfect for you',
              style: AppTextStyles.sectionSubtitle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40), // matches margin-bottom: 40px

            // Categories Grid (matches your CSS .category-grid)
            _buildCategoriesGrid(context),

            const SizedBox(height: 40), // matches margin-bottom: 40px from grid

            // Browse All Button (matches your CSS .browse-all)
            _buildBrowseAllButton(),
          ],
        ),
      ),
    );
  }

  /// Categories Grid - matches your web .category-grid layout
  Widget _buildCategoriesGrid(BuildContext context) {
    // Get screen width for responsive grid
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;

    // Responsive grid layout (matches your CSS @media queries)
    if (screenWidth > 992) {
      crossAxisCount = 3; // Desktop: 3 columns
      childAspectRatio = 1.2;
    } else if (screenWidth > 768) {
      crossAxisCount = 2; // Tablet: 2 columns
      childAspectRatio = 1.1;
    } else {
      crossAxisCount = 1; // Mobile: 1 column
      childAspectRatio = 2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 30, // matches gap: 30px
        mainAxisSpacing: 30,
        childAspectRatio: childAspectRatio,
      ),
      itemCount:
          AppConstants.jobCategories.length, // 6 categories from your web
      itemBuilder: (context, index) {
        final category = AppConstants.jobCategories[index];
        return _buildCategoryCard(
          categoryId: category['id']!,
          title: category['name']!,
          count: category['count']!,
          iconName: category['icon']!,
        );
      },
    );
  }

  /// Individual Category Card - matches your web .category-card styling
  Widget _buildCategoryCard({
    required String categoryId,
    required String title,
    required String count,
    required String iconName,
  }) {
    return GestureDetector(
      onTap: () => onCategoryPressed?.call(categoryId),
      child: Container(
        // Matches your CSS .category-card styling exactly
        decoration: BoxDecoration(
          color: AppColors.categoryBackground, // #f9f9f9
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight, // rgba(0, 0, 0, 0.05)
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onCategoryPressed?.call(categoryId),
            // Hover effect matches your CSS .category-card:hover
            child: Container(
              padding: const EdgeInsets.all(
                  20), // matches padding: 30px 20px (adjusted for mobile)
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Container (matches your CSS .category-card .icon)
                  Container(
                    width: 40, // matches width: 70px
                    height: 40, // matches height: 70px
                    decoration: const BoxDecoration(
                      color: AppColors.categoryIconBackground, // #e6f3f0
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(iconName),
                      size: 30, // matches font-size: 30px
                      color: AppColors.secondaryTeal, // matches color: #257180
                    ),
                  ),

                  const SizedBox(height: 20), // matches margin-bottom: 20px

                  // Category Title (matches your CSS .category-card h3)
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 18, // Slightly smaller for mobile
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10), // matches margin-bottom: 10px

                  // Opportunity Count (matches your CSS .category-card p)
                  Text(
                    '$count opportunities',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Browse All Button - matches your web .browse-all button
  Widget _buildBrowseAllButton() {
    return Container(
      margin: const EdgeInsets.only(
          top: 20), // matches .browse-all margin-top: 20px
      child: BrowseJobsButton(
        onPressed: onBrowseJobsPressed,
      ),
    );
  }

  /// Get Icon for Category - maps your web icon names to Flutter icons
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

/// Alternative Compact Categories (for very small screens)
class CompactJobCategoriesSection extends StatelessWidget {
  final Function(String categoryId)? onCategoryPressed;
  final VoidCallback? onBrowseJobsPressed;

  const CompactJobCategoriesSection({
    super.key,
    this.onCategoryPressed,
    this.onBrowseJobsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Job Categories',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Horizontal scrollable categories
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.jobCategories.length,
              itemBuilder: (context, index) {
                final category = AppConstants.jobCategories[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 15),
                  child: GestureDetector(
                    onTap: () => onCategoryPressed?.call(category['id']!),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: AppColors.categoryIconBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getCategoryIcon(category['icon']!),
                            color: AppColors.secondaryTeal,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          category['name']!,
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          BrowseJobsButton(onPressed: onBrowseJobsPressed),
        ],
      ),
    );
  }

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
