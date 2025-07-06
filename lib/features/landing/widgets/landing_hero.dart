import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_button.dart';

/// Landing Hero Widget - Mobile version of includes/landing/landing_hero.php
/// Matches your web hero section styling exactly
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

  /// Mobile Search Bar Layout (responsive for small screens)
  Widget _buildMobileSearchBar(BuildContext context) {
    return Column(
      children: [
        // Job Search Input
        _buildSearchInput(),

        // Divider
        Container(
          height: 1,
          color: AppColors.borderLight,
        ),

        // Location Input
        _buildLocationInput(),

        const SizedBox(height: 15),

        // Full-width Search Button
        Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            width: double.infinity,
            child: _buildSearchButton(context),
          ),
        ),
      ],
    );
  }

  /// Job Search Input - matches your web .search-input structure
  Widget _buildSearchInput() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 15), // matches padding: 0 15px
      child: Row(
        children: [
          // Search Icon (matches .search-input i)
          const Icon(
            Icons.search,
            color: AppColors.textLight, // matches color: #888
            size: 20,
          ),

          const SizedBox(width: 10), // matches margin-right: 10px

          // Search Input Field (matches .search-input input)
          Expanded(
            child: TextField(
              controller: jobSearchController,
              style: AppTextStyles.formInput,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Job title or keyword', // matches placeholder
                hintStyle: AppTextStyles.formPlaceholder,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 15), // matches padding: 15px 0
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Location Input - matches your web .location-input structure
  Widget _buildLocationInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          // Location Icon (matches .location-input i)
          const Icon(
            Icons.location_on_outlined,
            color: AppColors.textLight,
            size: 20,
          ),

          const SizedBox(width: 10),

          // Location Input Field (matches .location-input input)
          Expanded(
            child: TextField(
              controller: locationSearchController,
              style: AppTextStyles.formInput,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'All Locations', // matches placeholder
                hintStyle: AppTextStyles.formPlaceholder,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Search Button - matches your web .search-bar button styling
  Widget _buildSearchButton(BuildContext context) {
    return CustomButton(
      text: 'Search',
      onPressed: onSearchPressed,
      type: CustomButtonType.secondary, // matches .btn-secondary
      padding: const EdgeInsets.symmetric(
        horizontal: 25, // matches padding: 15px 25px
        vertical: 15,
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

          // Simple Search
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: jobSearchController,
                    decoration: const InputDecoration(
                      hintText: 'Search jobs...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(15),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                CustomButton(
                  text: 'Go',
                  onPressed: onSearchPressed,
                  type: CustomButtonType.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
