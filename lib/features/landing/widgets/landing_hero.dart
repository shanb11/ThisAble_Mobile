import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_button.dart';

/// Landing Hero Widget - Mobile version of includes/landing/landing_hero.php
/// FIXED: Matches your web hero section styling exactly
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
    return Container(
      width: double.infinity,
      // Matches your CSS: background-color: #257180, padding: 60px 0 80px
      color: AppColors.secondaryTeal,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 80),
      child: Column(
        children: [
          // Hero Title (matches your CSS .hero h1)
          Text(
            'ThisAble',
            style: AppTextStyles.heroTitle,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20), // matches margin-bottom: 20px

          // Hero Subtitle (matches your CSS .hero p)
          Container(
            constraints:
                const BoxConstraints(maxWidth: 700), // matches max-width: 700px
            child: Text(
              'Connect with thousands of employers and job opportunities. We\'re dedicated to making the job search process easier for everyone.',
              style: AppTextStyles.heroSubtitle,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 30), // matches margin: 0 auto 30px

          // Search Bar (matches your CSS .search-bar)
          _buildSearchBar(context),
        ],
      ),
    );
  }

  /// Search Bar - matches your web search bar structure exactly
  Widget _buildSearchBar(BuildContext context) {
    // Check screen width for responsive behavior
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 768;

    return Container(
      constraints:
          const BoxConstraints(maxWidth: 800), // matches max-width: 800px
      child: Container(
        // Matches your CSS: background-color: white, border-radius: 5px, box-shadow
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowMedium, // rgba(0, 0, 0, 0.1)
              blurRadius: 15,
              offset: Offset(0, 5),
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

  /// Mobile Search Bar Layout - FIXED: Better spacing and proportions
  Widget _buildMobileSearchBar(BuildContext context) {
    return Column(
      children: [
        // Job Search Input - FIXED: Better padding and spacing
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

        // Location Input - FIXED: Better padding and spacing
        Container(
          padding:
              const EdgeInsets.fromLTRB(20, 15, 20, 20), // Increased padding
          child: _buildLocationInput(),
        ),

        // Search Button - FIXED: Better spacing and full width
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

  /// Job Search Input - FIXED: Borderless styling to match web
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

        // Search Input Field - FIXED: Borderless and better padding
        Expanded(
          child: TextField(
            controller: jobSearchController,
            style: AppTextStyles.formInput,
            decoration: InputDecoration(
              border: InputBorder.none, // FIXED: Completely borderless
              enabledBorder: InputBorder.none, // FIXED: No enabled border
              focusedBorder: InputBorder.none, // FIXED: No focus border
              disabledBorder: InputBorder.none, // FIXED: No disabled border
              errorBorder: InputBorder.none, // FIXED: No error border
              focusedErrorBorder:
                  InputBorder.none, // FIXED: No error focus border
              hintText: 'Job title or keyword', // matches placeholder
              hintStyle: AppTextStyles.formPlaceholder,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18, // FIXED: Increased padding to match web
              ),
              filled: false, // FIXED: No background fill
            ),
          ),
        ),
      ],
    );
  }

  /// Location Input - FIXED: Borderless styling to match web
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

        // Location Input Field - FIXED: Borderless and better padding
        Expanded(
          child: TextField(
            controller: locationSearchController,
            style: AppTextStyles.formInput,
            decoration: InputDecoration(
              border: InputBorder.none, // FIXED: Completely borderless
              enabledBorder: InputBorder.none, // FIXED: No enabled border
              focusedBorder: InputBorder.none, // FIXED: No focus border
              disabledBorder: InputBorder.none, // FIXED: No disabled border
              errorBorder: InputBorder.none, // FIXED: No error border
              focusedErrorBorder:
                  InputBorder.none, // FIXED: No error focus border
              hintText: 'All Locations', // matches placeholder
              hintStyle: AppTextStyles.formPlaceholder,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18, // FIXED: Increased padding to match web
              ),
              filled: false, // FIXED: No background fill
            ),
          ),
        ),
      ],
    );
  }

  /// Search Button - FIXED: Use orange color (primary) instead of teal (secondary)
  Widget _buildSearchButton(BuildContext context) {
    return CustomButton(
      text: 'Search',
      onPressed: onSearchPressed,
      type: CustomButtonType
          .primary, // FIXED: Changed from secondary to primary (orange)
      padding: const EdgeInsets.symmetric(
        horizontal: 25, // matches padding: 15px 25px
        vertical: 18, // FIXED: Increased to match text field height
      ),
    );
  }
}

/// Alternative Compact Hero (for very small screens) - FIXED: Also use orange button
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

          // Simple Search - FIXED: Borderless and orange button
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
                      border: InputBorder.none, // FIXED: Borderless
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(15),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textLight,
                      ),
                      filled: false, // FIXED: No background fill
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButton(
                    text: 'Go',
                    onPressed: onSearchPressed,
                    type: CustomButtonType.primary, // FIXED: Orange button
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
