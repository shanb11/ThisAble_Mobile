import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_button.dart';

/// Inclusive Workplace Section - Mobile version of includes/landing/landing_inclusive_workplace.php
/// Matches your web inclusive workplace section styling exactly
class InclusiveWorkplaceSection extends StatelessWidget {
  final VoidCallback? onPostJobPressed;

  const InclusiveWorkplaceSection({
    super.key,
    this.onPostJobPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Matches your CSS: background-color: #fff4ef, padding: 60px 0, margin: 0 20px 60px, border-radius: 10px
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 60),
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: AppColors.inclusiveBackground, // #fff4ef
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _buildContent(context),
      ),
    );
  }

  /// Build content based on screen size (matches your web responsive behavior)
  Widget _buildContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 768;

    if (isLargeScreen) {
      // Desktop/Tablet Layout (matches your web .inclusive-workplace .container flex)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Content Section (matches .inclusive-content)
          Expanded(
            flex: 1,
            child: _buildContentSection(),
          ),

          const SizedBox(width: 40), // matches padding-right: 40px

          // Features Section (matches .inclusive-features)
          Expanded(
            flex: 1,
            child: _buildFeaturesGrid(),
          ),
        ],
      );
    } else {
      // Mobile Layout (responsive design)
      return Column(
        children: [
          // Content Section
          _buildContentSection(),

          const SizedBox(height: 40),

          // Features Section
          _buildFeaturesGrid(),
        ],
      );
    }
  }

  /// Content Section - matches your web .inclusive-content
  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title (matches your CSS .inclusive-content h2)
        Text(
          'Create an Inclusive Workplace',
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: 28, // matches font-size: 1.8rem (adjusted for mobile)
          ),
        ),

        const SizedBox(height: 20), // matches margin-bottom: 20px

        // Description (matches your CSS .inclusive-content p)
        Text(
          'With leading organizations committed to building diverse and inclusive teams. Post your job opportunities and connect with qualified candidates from all backgrounds.',
          style: AppTextStyles.sectionSubtitle,
        ),

        const SizedBox(height: 30), // matches margin-bottom: 30px

        // Post Job Button (matches your web #post-job-btn .btn-primary)
        PostJobButton(
          onPressed: onPostJobPressed,
        ),
      ],
    );
  }

  /// Features Grid - matches your web .inclusive-features
  Widget _buildFeaturesGrid() {
    // Features data (matches your web structure exactly)
    final features = [
      {
        'icon': Icons.people_outline,
        'title': 'Diverse Workforce',
        'description': 'Access talent from all backgrounds',
      },
      {
        'icon': Icons.handshake_outlined,
        'title': 'Inclusive Culture',
        'description': 'Promote a welcoming environment',
      },
      {
        'icon': Icons.accessibility_new_outlined,
        'title': 'Accessibility',
        'description': 'Equal opportunities for everyone',
      },
      {
        'icon': Icons.public_outlined,
        'title': 'Global Reach',
        'description': 'Connect with talent worldwide',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // matches grid-template-columns: repeat(2, 1fr)
        crossAxisSpacing: 20, // matches gap: 20px
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(
          icon: feature['icon'] as IconData,
          title: feature['title'] as String,
          description: feature['description'] as String,
        );
      },
    );
  }

  /// Individual Feature Card - matches your web .feature styling
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      // Matches your CSS .feature styling
      padding: const EdgeInsets.all(0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Feature Icon (matches your CSS .feature i)
          Icon(
            icon,
            size: 24, // matches font-size: 24px
            color: AppColors.primaryOrange, // matches color: #FD8B51
          ),

          const SizedBox(height: 5), // matches margin-bottom: 15px

          // Feature Title (matches your CSS .feature h4)
          Text(
            title,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 14, // Adjusted for mobile
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 5), // matches margin-bottom: 5px

          // Feature Description (matches your CSS .feature p)
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Alternative Compact Inclusive Workplace (for very small screens)
class CompactInclusiveWorkplaceSection extends StatelessWidget {
  final VoidCallback? onPostJobPressed;

  const CompactInclusiveWorkplaceSection({
    super.key,
    this.onPostJobPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.inclusiveBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Compact Title
          Text(
            'Create an Inclusive Workplace',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 15),

          // Compact Description
          Text(
            'Post your job opportunities and connect with qualified candidates from all backgrounds.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Feature Icons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCompactFeature(Icons.people_outline, 'Diverse'),
              _buildCompactFeature(Icons.handshake_outlined, 'Inclusive'),
              _buildCompactFeature(
                  Icons.accessibility_new_outlined, 'Accessible'),
              _buildCompactFeature(Icons.public_outlined, 'Global'),
            ],
          ),

          const SizedBox(height: 20),

          // Post Job Button
          PostJobButton(onPressed: onPostJobPressed),
        ],
      ),
    );
  }

  Widget _buildCompactFeature(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.primaryOrange,
          size: 20,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
