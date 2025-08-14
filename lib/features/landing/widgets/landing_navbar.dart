import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../config/routes.dart';

/// Landing Navbar Widget - Mobile version of includes/landing/landing_navbar.php
/// Matches your web header styling exactly
class LandingNavbar extends StatelessWidget {
  final VoidCallback? onAboutPressed;
  final VoidCallback? onJobsPressed;

  const LandingNavbar({super.key, this.onAboutPressed, this.onJobsPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Matches your CSS: background-color: #ffffff, box-shadow, position: sticky
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium, // rgba(0, 0, 0, 0.1)
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
        // Logo Icon (matches your thisablelogo.png)
        Container(
          width: 50, // matches .logo img height: 50px
          height: 50,
          decoration: const BoxDecoration(
            color: AppColors.primaryOrange,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.accessibility_new,
            color: Colors.white,
            size: 30,
          ),
        ),

        const SizedBox(width: 10), // matches .logo img margin-right: 10px
        // Logo Text (matches .logo span)
        Text(
          'ThisAble',
          style: AppTextStyles.navItemActive.copyWith(
            fontSize: 24, // matches .logo span font-size: 1.5rem
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Navigation Links - matches your nav ul structure
  Widget _buildNavLinks() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Home Link (matches nav ul li a)
        _buildNavLink(
          text: 'Home',
          isActive: true, // Current page
          onPressed: () {}, // Already on home
        ),

        const SizedBox(width: 20), // matches nav ul li margin-left: 20px
        // Jobs Link
        _buildNavLink(text: 'Jobs', isActive: false, onPressed: onJobsPressed),

        const SizedBox(width: 20),

        // About Link
        _buildNavLink(
          text: 'About',
          isActive: false,
          onPressed: onAboutPressed,
        ),
      ],
    );
  }

  /// Individual Navigation Link - matches your nav ul li a styling
  /// Individual Navigation Link - IMPROVED with better responsiveness
  Widget _buildNavLink({
    required String text,
    required bool isActive,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      // CHANGED: Use InkWell instead of GestureDetector for better feedback
      onTap: onPressed,
      borderRadius: BorderRadius.circular(5), // Matches container border radius
      splashColor: AppColors.primaryOrange.withOpacity(0.1), // Visual feedback
      highlightColor: AppColors.primaryOrange.withOpacity(0.05),
      child: Container(
        // EXPANDED: Bigger tap area for easier tapping
        padding: const EdgeInsets.symmetric(
            horizontal: 15, vertical: 10), // INCREASED padding
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentBeige : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          text,
          style: isActive ? AppTextStyles.navItemActive : AppTextStyles.navItem,
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return Material(
      // Wrap in Material for better ink effects
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AppRoutes.goToCandidateLogin(context),
        borderRadius: BorderRadius.circular(5),
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryOrange.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Sign In',
            style: AppTextStyles.buttonPrimary, // FIXED: Use correct style
          ),
        ),
      ),
    );
  }
}

/// Mobile App Bar Version (Alternative for very small screens)
class LandingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onAboutPressed;
  final VoidCallback? onJobsPressed;

  const LandingAppBar({super.key, this.onAboutPressed, this.onJobsPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 2,
      shadowColor: AppColors.shadowMedium,

      // Logo in title
      title: Row(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(width: 10),
          Text(
            'ThisAble',
            style: AppTextStyles.navItemActive.copyWith(fontSize: 20),
          ),
        ],
      ),

      // Actions: Navigation + Sign In
      actions: [
        TextButton(
          onPressed: onJobsPressed,
          child: Text('Jobs', style: AppTextStyles.navItem),
        ),
        TextButton(
          onPressed: onAboutPressed,
          child: Text('About', style: AppTextStyles.navItem),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: CustomButton(
            text: 'Sign In',
            onPressed: () => AppRoutes.goToCandidateLogin(context),
            type: CustomButtonType.primary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
