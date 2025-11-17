import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../config/routes.dart';

/// Landing Navbar Widget - Enhanced to match web styling exactly
/// Active state: TEAL gradient background with white text
/// Tap state: ORANGE gradient background (mobile equivalent of hover)
class LandingNavbar extends StatelessWidget {
  final VoidCallback? onHomePressed;
  final VoidCallback? onAboutPressed;
  final VoidCallback? onJobsPressed;
  final String currentPage;

  const LandingNavbar({
    super.key,
    this.onHomePressed,
    this.onAboutPressed,
    this.onJobsPressed,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Enhanced glassmorphism effect matching web
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), // rgba(0, 0, 0, 0.08)
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryOrange.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          child: _buildNavbarContent(context),
        ),
      ),
    );
  }

  /// Build navbar content - responsive design
  Widget _buildNavbarContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 768;

    if (isLargeScreen) {
      // Desktop/Tablet Layout
      return Row(
        children: [
          _buildLogo(),
          const Spacer(),
          _buildNavLinks(),
          const SizedBox(width: 20),
          _buildSignInButton(context),
        ],
      );
    } else {
      // Mobile Layout
      return Column(
        children: [
          Row(
            children: [
              _buildLogo(),
              const Spacer(),
              _buildSignInButton(context),
            ],
          ),
          const SizedBox(height: 15),
          _buildNavLinks(),
        ],
      );
    }
  }

  /// Logo Section with gradient text effect
  /// Logo Section - Simple solid color
  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/thisablelogo.png',
          width: 50,
          height: 50,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Text(
          'ThisAble',
          style: AppTextStyles.navItemActive.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryTeal, // Solid black/dark text
          ),
        ),
      ],
    );
  }

  /// Navigation Links with enhanced styling
  Widget _buildNavLinks() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEnhancedNavLink(
          text: 'Home',
          isActive: currentPage == 'home',
          onPressed: onHomePressed,
        ),
        const SizedBox(width: 20),
        _buildEnhancedNavLink(
          text: 'Jobs',
          isActive: currentPage == 'jobs',
          onPressed: onJobsPressed,
        ),
        const SizedBox(width: 20),
        _buildEnhancedNavLink(
          text: 'About',
          isActive: currentPage == 'about',
          onPressed: onAboutPressed,
        ),
      ],
    );
  }

  /// Enhanced Navigation Link - Matches web styling exactly
  Widget _buildEnhancedNavLink({
    required String text,
    required bool isActive,
    VoidCallback? onPressed,
  }) {
    return AnimatedNavLink(
      text: text,
      isActive: isActive,
      onPressed: onPressed,
    );
  }

  /// Sign In Button with gradient
  Widget _buildSignInButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryOrange,
            AppColors.buttonGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AppRoutes.goToCandidateLogin(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 12,
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated Navigation Link Widget
/// Handles active state (TEAL gradient) and tap state (ORANGE gradient)
class AnimatedNavLink extends StatefulWidget {
  final String text;
  final bool isActive;
  final VoidCallback? onPressed;

  const AnimatedNavLink({
    super.key,
    required this.text,
    required this.isActive,
    this.onPressed,
  });

  @override
  State<AnimatedNavLink> createState() => _AnimatedNavLinkState();
}

class _AnimatedNavLinkState extends State<AnimatedNavLink>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _underlineController;
  late Animation<double> _underlineAnimation;

  @override
  void initState() {
    super.initState();
    _underlineController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _underlineAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(
      CurvedAnimation(parent: _underlineController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _underlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _underlineController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _underlineController.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _underlineController.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          // ACTIVE STATE: TEAL gradient
          // PRESSED STATE: ORANGE gradient
          // REGULAR STATE: Transparent
          gradient: widget.isActive
              ? const LinearGradient(
                  colors: [
                    AppColors.secondaryTeal, // #257180
                    Color(0xFF2B7A85), // Lighter teal
                  ],
                )
              : _isPressed
                  ? LinearGradient(
                      colors: [
                        AppColors.primaryOrange.withOpacity(0.1),
                        AppColors.buttonGradientEnd.withOpacity(0.15),
                      ],
                    )
                  : null,
          borderRadius: BorderRadius.circular(10),
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color: AppColors.secondaryTeal.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ]
              : _isPressed
                  ? [
                      BoxShadow(
                        color: AppColors.primaryOrange.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
        ),
        transform: _isPressed
            ? (Matrix4.identity()..translate(0.0, -2.0, 0.0))
            : Matrix4.identity(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Text
            Text(
              widget.text,
              style: TextStyle(
                color: widget.isActive
                    ? Colors.white
                    : _isPressed
                        ? AppColors.primaryOrange
                        : AppColors.textPrimary,
                fontSize: 16,
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),

            // Underline animation (for pressed state)
            if (!widget.isActive)
              Positioned(
                bottom: -5,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _underlineAnimation,
                  builder: (context, child) {
                    return Center(
                      child: Container(
                        width: 60 * _underlineAnimation.value,
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryOrange,
                              AppColors.buttonGradientEnd,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
