import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_button.dart';

/// Landing Hero Widget - Enhanced with animated gradient and glassmorphism
/// Professional animated gradient with 4-second smooth cycle
class LandingHero extends StatelessWidget {
  final TextEditingController? jobSearchController;
  final TextEditingController? locationSearchController;
  final VoidCallback? onSearchPressed;

  const LandingHero({
    super.key,
    this.jobSearchController,
    this.locationSearchController,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientHeroContainer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 80),
        child: Column(
          children: [
            // Hero Title (matches your CSS .hero h1)
            Text(
              'ThisAble',
              style: AppTextStyles.heroTitle.copyWith(
                shadows: [
                  const Shadow(
                    color: Color(0x33000000), // rgba(0,0,0,0.2)
                    offset: Offset(0, 4),
                    blurRadius: 20,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20), // matches margin-bottom: 20px

            // Hero Subtitle (matches your CSS .hero p)
            Container(
              constraints: const BoxConstraints(
                  maxWidth: 700), // matches max-width: 700px
              child: Text(
                'Connect with thousands of employers and job opportunities. We\'re dedicated to making the job search process easier for everyone.',
                style: AppTextStyles.heroSubtitle.copyWith(
                  color: Colors.white.withOpacity(0.95),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30), // matches margin: 0 auto 30px

            // Search Bar (matches your CSS .search-bar)
            _buildSearchBar(context),
          ],
        ),
      ),
    );
  }

  /// Search Bar - Enhanced with glassmorphism effect
  Widget _buildSearchBar(BuildContext context) {
    // Check screen width for responsive behavior
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 768;

    return Container(
      constraints:
          const BoxConstraints(maxWidth: 800), // matches max-width: 800px
      child: Container(
        // Enhanced glassmorphism styling
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.98),
          borderRadius: BorderRadius.circular(15), // Increased from 5 to 15
          border: Border.all(
            color: AppColors.glassmorphismBorder,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26257180), // rgba(37,113,128,0.15)
              blurRadius: 40,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: isLargeScreen
            ? _buildDesktopSearchBar(context)
            : _buildMobileSearchBar(context),
      ),
    );
  }

  /// Desktop Search Bar Layout (matches your web .search-bar flex)
  Widget _buildDesktopSearchBar(BuildContext context) {
    return Row(
      children: [
        // Job Search Input (matches .search-input)
        Expanded(
          child: _buildSearchInput(),
        ),

        // Divider (matches border-right: 1px solid #eee)
        Container(
          width: 1,
          height: 50,
          color: AppColors.borderLight,
        ),

        // Location Input (matches .location-input)
        Expanded(
          child: _buildLocationInput(),
        ),

        // Search Button (matches .search-bar button)
        _buildSearchButton(context),
      ],
    );
  }

  /// Mobile Search Bar Layout - Enhanced spacing
  Widget _buildMobileSearchBar(BuildContext context) {
    return Column(
      children: [
        // Job Search Input - Enhanced padding
        Container(
          padding:
              const EdgeInsets.fromLTRB(20, 20, 20, 15), // Increased padding
          child: _buildSearchInput(),
        ),

        // Divider
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          color: AppColors.borderLight,
        ),

        // Location Input - Enhanced padding
        Container(
          padding:
              const EdgeInsets.fromLTRB(20, 15, 20, 20), // Increased padding
          child: _buildLocationInput(),
        ),

        // Search Button - Enhanced spacing and full width
        Padding(
          padding:
              const EdgeInsets.fromLTRB(20, 0, 20, 20), // Better bottom padding
          child: SizedBox(
            width: double.infinity,
            child: _buildSearchButton(context),
          ),
        ),
      ],
    );
  }

  /// Job Search Input - Borderless styling to match web
  Widget _buildSearchInput() {
    return Row(
      children: [
        // Search Icon (matches .search-input i)
        const Icon(
          Icons.search,
          color: AppColors.textLight, // matches color: #888
          size: 20,
        ),

        const SizedBox(width: 10), // matches margin-right: 10px

        // Search Input Field - Borderless and better padding
        Expanded(
          child: TextField(
            controller: jobSearchController,
            style: AppTextStyles.formInput,
            decoration: InputDecoration(
              border: InputBorder.none, // Completely borderless
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              hintText: 'Job title or keyword', // matches placeholder
              hintStyle: AppTextStyles.formPlaceholder,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18, // Increased padding to match web
              ),
              filled: false, // No background fill
            ),
          ),
        ),
      ],
    );
  }

  /// Location Input - Borderless styling to match web
  Widget _buildLocationInput() {
    return Row(
      children: [
        // Location Icon (matches .location-input i)
        const Icon(
          Icons.location_on_outlined,
          color: AppColors.textLight,
          size: 20,
        ),

        const SizedBox(width: 10),

        // Location Input Field - Borderless and better padding
        Expanded(
          child: TextField(
            controller: locationSearchController,
            style: AppTextStyles.formInput,
            decoration: InputDecoration(
              border: InputBorder.none, // Completely borderless
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              hintText: 'All Locations', // matches placeholder
              hintStyle: AppTextStyles.formPlaceholder,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18, // Increased padding to match web
              ),
              filled: false, // No background fill
            ),
          ),
        ),
      ],
    );
  }

  /// Search Button - Enhanced with gradient (orange gradient)
  Widget _buildSearchButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.buttonGradientStart,
            AppColors.buttonGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSearchPressed,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 25, // matches padding: 15px 25px
              vertical: 18, // Increased to match text field height
            ),
            child: const Text(
              'Search',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/// Static Gradient Container for Hero Section - Teal to Orange
class AnimatedGradientHeroContainer extends StatelessWidget {
  final Widget child;

  const AnimatedGradientHeroContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            AppColors.secondaryTeal, // Teal #257180
            AppColors.primaryOrange, // Orange #FD8B51
          ],
        ),
      ),
      child: Stack(
        children: [
          // Radial gradient overlays
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.6, -0.5),
                  radius: 1.0,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.8, 0.8),
                  radius: 1.0,
                  colors: [
                    AppColors.primaryOrange.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Alternative Compact Hero (for very small screens)
class CompactLandingHero extends StatelessWidget {
  final TextEditingController? jobSearchController;
  final VoidCallback? onSearchPressed;

  const CompactLandingHero({
    super.key,
    this.jobSearchController,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.secondaryTeal,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Compact Title
          Text(
            'ThisAble',
            style: AppTextStyles.heroTitle.copyWith(fontSize: 32),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 15),

          // Compact Subtitle
          Text(
            'Find your perfect job opportunity',
            style: AppTextStyles.heroSubtitle.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Simple Search - Borderless with orange gradient button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowMedium,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: jobSearchController,
                    decoration: const InputDecoration(
                      hintText: 'Search jobs...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(15),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textLight,
                      ),
                      filled: false,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButton(
                    text: 'Go',
                    onPressed: onSearchPressed,
                    type: CustomButtonType.primary, // Orange button
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
