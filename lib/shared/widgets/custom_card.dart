import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/text_styles.dart';
import 'custom_button.dart';

/// Job Card - matches your web job card styling exactly
class JobCard extends StatelessWidget {
  final String jobTitle;
  final String company;
  final String location;
  final String jobType;
  final String salary;
  final String description;
  final String? postedTime;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final VoidCallback? onSave;
  final bool isSaved;

  const JobCard({
    super.key,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.jobType,
    required this.salary,
    required this.description,
    this.postedTime,
    this.onTap,
    this.onApply,
    this.onSave,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.cardShadow.copyWith(
          border: AppTheme.jobCardBorder, // Left border like your CSS
        ),
        child: Padding(
          padding: const EdgeInsets.all(10), // matches your CSS padding: 25px
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title and Save Button Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      jobTitle,
                      style: AppTextStyles.jobTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onSave != null) ...[
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved
                            ? AppColors.primaryOrange
                            : AppColors.textLight,
                      ),
                      onPressed: onSave,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 10),

              // Company Name
              Text(
                company,
                style: AppTextStyles.jobCompany,
              ),

              const SizedBox(height: 15),

              // Job Details (location, type, salary) - matches your CSS job-details
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _buildJobDetailChip(
                    icon: Icons.location_on_outlined,
                    text: location,
                  ),
                  _buildJobDetailChip(
                    icon: Icons.access_time,
                    text: jobType,
                  ),
                  _buildJobDetailChip(
                    icon: Icons.attach_money,
                    text: salary,
                  ),
                  if (postedTime != null)
                    _buildJobDetailChip(
                      icon: Icons.calendar_today_outlined,
                      text: postedTime!,
                    ),
                ],
              ),

              const SizedBox(height: 15),

              // Job Description
              Text(
                description,
                style: AppTextStyles.jobDescription,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ViewDetailsButton(
                      onPressed: onTap,
                    ),
                  ),
                  if (onApply != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ApplyNowButton(
                        onPressed: onApply,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Job Detail Chip - matches your CSS .job-detail styling
  Widget _buildJobDetailChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.jobDetailBackground, // #e6f3f0
        borderRadius: BorderRadius.circular(15), // matches border-radius: 15px
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTextStyles.jobDetail,
          ),
        ],
      ),
    );
  }
}

/// Category Card - matches your web category card styling
class CategoryCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.cardShadow,
        child: Padding(
          padding:
              const EdgeInsets.all(20), // matches your CSS padding: 30px 20px
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container - matches your CSS .icon styling
              Container(
                width: 70,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.categoryIconBackground, // #e6f3f0
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: AppColors.secondaryTeal,
                ),
              ),

              const SizedBox(height: 20),

              // Category Title
              Text(
                title,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // Job Count
              Text(
                count,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Info Card - for general content sections
class InfoCard extends StatelessWidget {
  final String? title;
  final Widget content;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    this.title,
    required this.content,
    this.padding,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.cardShadow.copyWith(
          color: backgroundColor ?? AppColors.cardBackground,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 15),
              ],
              content,
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature Card - matches your inclusive workplace features
class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Icon
          Icon(
            icon,
            size: 24,
            color: AppColors.primaryOrange,
          ),

          const SizedBox(height: 15),

          // Title
          Text(
            title,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 5),

          // Description
          Text(
            description,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Team Member Card - for about page
class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String? imageUrl;
  final List<Widget>? socialLinks;

  const TeamMemberCard({
    super.key,
    required this.name,
    required this.role,
    this.imageUrl,
    this.socialLinks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardShadow,
      child: Column(
        children: [
          // Member Image Placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.categoryIconBackground,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 80,
                    color: AppColors.secondaryTeal,
                  ),
          ),

          // Member Info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  name,
                  style: AppTextStyles.teamMemberName,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  role,
                  style: AppTextStyles.teamMemberRole,
                  textAlign: TextAlign.center,
                ),
                if (socialLinks != null) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: socialLinks!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Value Card - for about page values section
class ValueCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const ValueCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardShadow.copyWith(
        border: const Border(
          top: BorderSide(
            color: AppColors.primaryOrange,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Icon
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: AppColors.categoryIconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: AppColors.secondaryTeal,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: AppTextStyles.valueCardTitle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              description,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
