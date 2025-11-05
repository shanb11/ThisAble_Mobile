import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../config/routes.dart';

/// Landing Navbar Widget - Mobile version of includes/landing/landing_navbar.php
/// FIXED: Proper navigation and active states using YOUR ACTUAL theme structure
class LandingNavbar extends StatelessWidget {
  final VoidCallback? onHomePressed; // ADDED: Missing Home callback
  final VoidCallback? onAboutPressed;
  final VoidCallback? onJobsPressed;
  final String currentPage; // ADDED: Track current page for active states

  const LandingNavbar({
    super.key,
    this.onHomePressed, // ADDED: Now accepts Home callback
    this.onAboutPressed,
    this.onJobsPressed,
    required this.currentPage, // REQUIRED: Must specify current page
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Matches your CSS: background-color: #ffffff, box-shadow, position: sticky
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium, // Using YOUR actual color
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20, // matches container padding: 0 20px
            vertical: 15, // matches header padding: 15px 0
          ),
          child: _buildNavbarContent(context),
        ),
      ),
    );
  }

  /// Build navbar content - responsive design
  Widget _buildNavbarContent(BuildContext context) {
    // Check screen width for responsive behavior
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen =
        screenWidth > 768; // matches your @media (max-width: 768px)

    if (isLargeScreen) {
      // Desktop/Tablet Layout (matches your web header flex)
      return Row(
        children: [
          // Logo Section (matches .logo styling)
          _buildLogo(),

          const Spacer(),

          // Navigation Links (matches nav ul)
          _buildNavLinks(),

          const SizedBox(width: 20),

          // Sign In Button (matches .sign-in)
          _buildSignInButton(context),
        ],
      );
    } else {
      // Mobile Layout (responsive design)
      return Column(
        children: [
          // Top row: Logo and Sign In
          Row(
            children: [
              _buildLogo(),
              const Spacer(),
              _buildSignInButton(context),
            ],
          ),

          const SizedBox(height: 15),

          // Bottom row: Navigation Links
          _buildNavLinks(),
        ],
      );
    }
  }

  /// Logo Section - matches your .logo CSS
  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Your actual logo PNG
        Image.asset(
          'assets/images/thisablelogo.png',
          width: 50,
          height: 50,
          fit: BoxFit.contain,
        ),

        const SizedBox(width: 10),

        // Logo Text
        Text(
          'ThisAble',
          style: AppTextStyles.navItemActive.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Navigation Links - FIXED: Dynamic active states based on current page
  Widget _buildNavLinks() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Home Link - FIXED: Now has proper callback and dynamic active state
        _buildNavLink(
          text: 'Home',
          isActive: currentPage == 'home', // DYNAMIC: Based on current page
          onPressed: onHomePressed, // FIXED: Now has proper callback
        ),

        const SizedBox(width: 20), // matches nav ul li margin-left: 20px

        // Jobs Link - FIXED: Now has dynamic active state
        _buildNavLink(
          text: 'Jobs',
          isActive: currentPage == 'jobs', // DYNAMIC: Based on current page
          onPressed: onJobsPressed,
        ),

        const SizedBox(width: 20),

        // About Link - FIXED: Now has dynamic active state
        _buildNavLink(
          text: 'About',
          isActive: currentPage == 'about', // DYNAMIC: Based on current page
          onPressed: onAboutPressed,
        ),
      ],
    );
  }

  /// Individual Navigation Link - matches your nav ul li a styling
  Widget _buildNavLink({
    required String text,
    required bool isActive,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          // Active state styling (matches your CSS)
          color: isActive
              ? AppColors.primaryOrange.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? AppColors.primaryOrange
                : Colors.transparent, // Using YOUR actual colors
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: isActive
              ? AppTextStyles.navItemActive.copyWith(
                  // Using YOUR actual text styles
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                )
              : AppTextStyles.navItem.copyWith(
                  // Using YOUR actual text styles
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
        ),
      ),
    );
  }

  /// Sign In Button - matches your .sign-in CSS
  Widget _buildSignInButton(BuildContext context) {
    return SignInButton(
      // Using YOUR actual SignInButton component
      onPressed: () => AppRoutes.goToCandidateLogin(context),
    );
  }

  /// Show Sign-In Options Modal (matches your web dropdown)
  void _showSignInOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Header
            Text(
              'Choose Your Account Type',
              style: AppTextStyles.cardTitle.copyWith(
                // Using YOUR actual text style
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select how you want to sign in to ThisAble',
              style: AppTextStyles.bodyMedium.copyWith(
                // Using YOUR actual text style
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Candidate Sign In
            CustomButton(
              text: 'Sign In as Job Seeker',
              onPressed: () {
                Navigator.pop(context);
                AppRoutes.goToCandidateLogin(context);
              },
              type: CustomButtonType.primary, // Using YOUR actual button type
              icon: const Icon(Icons.person, color: Colors.white),
              isFullWidth: true,
            ),
            const SizedBox(height: 12),

            // Employer Sign In
            CustomButton(
              text: 'Sign In as Employer',
              onPressed: () {
                Navigator.pop(context);
                AppRoutes.goToEmployerLogin(context);
              },
              type: CustomButtonType.outlined, // Using YOUR actual button type
              icon: Icon(Icons.business, color: AppColors.secondaryTeal),
              isFullWidth: true,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
