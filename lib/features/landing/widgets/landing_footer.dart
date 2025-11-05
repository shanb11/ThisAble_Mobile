import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';

/// Landing Footer Widget - Mobile version of includes/landing/landing_footer.php
/// Matches your web footer styling exactly
class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Matches your CSS: background-color: #257180, color: white, padding: 60px 0 20px
      color: AppColors.secondaryTeal,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        children: [
          // Footer Content (matches .footer-content)
          _buildFooterContent(context),

          const SizedBox(height: 40), // matches margin-bottom: 40px

          // Footer Bottom (matches .footer-bottom)
          _buildFooterBottom(),
        ],
      ),
    );
  }

  /// Footer Content - matches your web .footer-content layout
  Widget _buildFooterContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 768;

    if (isLargeScreen) {
      // Desktop/Tablet Layout (matches your web flex layout)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Section
          Expanded(child: _buildCompanySection()),
          const SizedBox(width: 30),

          // Candidates Section
          Expanded(child: _buildCandidatesSection()),
          const SizedBox(width: 30),

          // Employers Section
          Expanded(child: _buildEmployersSection()),
          const SizedBox(width: 30),

          // Contact Section
          Expanded(child: _buildContactSection()),
        ],
      );
    } else {
      // Mobile Layout (responsive design)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompanySection(),
          const SizedBox(height: 30),
          _buildCandidatesSection(),
          const SizedBox(height: 30),
          _buildEmployersSection(),
          const SizedBox(height: 30),
          _buildContactSection(),
        ],
      );
    }
  }

  /// Company Section - matches your web company footer section
  Widget _buildCompanySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company Title (matches footer section h3)
        _buildSectionTitle('ThisAble'),

        const SizedBox(height: 20),

        // Company Description
        Text(
          'Creating opportunities for everyone',
          style: AppTextStyles.footerLink,
        ),
      ],
    );
  }

  /// Candidates Section - matches your web "For Candidates" section
  Widget _buildCandidatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        _buildSectionTitle('For Candidates'),

        const SizedBox(height: 20),

        // Candidate Links (matches your web footer links)
        _buildFooterLink('Browse Jobs', () {
          // Will implement navigation
        }),
        // _buildFooterLink('Career Resources', () {}),
        // _buildFooterLink('Job Alerts', () {}),
      ],
    );
  }

  /// Employers Section - matches your web "For Employers" section
  Widget _buildEmployersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        _buildSectionTitle('For Employers'),

        const SizedBox(height: 20),

        // Employer Links (matches your web footer links)
        _buildFooterLink('Post a Job', () {
          // Will implement post job modal
        }),
        // _buildFooterLink('Talent Search', () {}),
        // _buildFooterLink('Employer Resources', () {}),
      ],
    );
  }

  /// Contact Section - matches your web "Contact" section
  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        _buildSectionTitle('Contact'),

        const SizedBox(height: 20),

        // Contact Links (matches your web footer links)
        // _buildFooterLink('Help Center', () {}),
        _buildFooterLink('About Us', () {
          // Will implement about navigation
        }),
        // _buildFooterLink('Privacy Policy', () {}),
      ],
    );
  }

  /// Section Title - matches your web footer section h3 styling
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.footerHeading,
        ),

        const SizedBox(height: 10),

        // Underline (matches your CSS h3:after)
        Container(
          width: 40, // matches width: 40px
          height: 2, // matches height: 2px
          color: AppColors.primaryOrange, // matches background-color: #FD8B51
        ),
      ],
    );
  }

  /// Footer Link - matches your web footer ul li a styling
  Widget _buildFooterLink(String text, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10), // matches margin-bottom: 10px
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: AppTextStyles.footerLink,
        ),
      ),
    );
  }

  /// Footer Bottom - matches your web .footer-bottom
  Widget _buildFooterBottom() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20), // matches padding-top: 20px
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(
                0x1AFFFFFF), // matches border-top: 1px solid rgba(255, 255, 255, 0.1)
            width: 1,
          ),
        ),
      ),
      child: Text(
        '© 2025 ThisAble. All rights reserved.',
        style: AppTextStyles.footerCopyright,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Alternative Compact Footer (for very small screens)
class CompactLandingFooter extends StatelessWidget {
  const CompactLandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondaryTeal,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Compact Company Info
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.accessibility_new,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ThisAble',
                    style: AppTextStyles.footerHeading.copyWith(fontSize: 18),
                  ),
                  Text(
                    'Creating opportunities for everyone',
                    style: AppTextStyles.footerLink.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick Links Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCompactLink('Jobs'),
              _buildCompactLink('About'),
              _buildCompactLink('Post Job'),
              _buildCompactLink('Help'),
            ],
          ),

          const SizedBox(height: 20),

          // Copyright
          Container(
            padding: const EdgeInsets.only(top: 15),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0x1AFFFFFF),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              '© 2025 ThisAble. All rights reserved.',
              style: AppTextStyles.footerCopyright.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLink(String text) {
    return GestureDetector(
      onTap: () {
        // Will implement navigation
      },
      child: Text(
        text,
        style: AppTextStyles.footerLink.copyWith(fontSize: 12),
      ),
    );
  }
}
