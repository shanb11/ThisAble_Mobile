import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../config/routes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../widgets/landing_navbar.dart';
import '../widgets/landing_footer.dart';

/// Landing About Screen - Complete mobile version of landing_about.php
/// FIXED: Proper navigation and active states using YOUR ACTUAL theme structure
class LandingAboutScreen extends StatefulWidget {
  const LandingAboutScreen({super.key});

  @override
  State<LandingAboutScreen> createState() => _LandingAboutScreenState();
}

class _LandingAboutScreenState extends State<LandingAboutScreen> {
  // Contact form controllers (matches your web contact form)
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _contactFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Using YOUR actual color
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navigation Bar - FIXED: Now passes current page and proper callbacks
            LandingNavbar(
              currentPage: 'about', // FIXED: Identify this as about page
              onHomePressed: () => AppRoutes.goToHome(context),
              onAboutPressed: () {
                // FIXED: About navigation (refresh current page)
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.landingAbout,
                  (route) => false,
                );
              },
              onJobsPressed: () => AppRoutes.goToJobs(context),
            ),

            // About Hero Section (matches landing_about_team.php hero)
            _buildAboutHero(),

            // Footer (matches your web footer)
            const LandingFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutHero() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.secondaryTeal, // Using YOUR actual colors
            AppColors.secondaryTeal.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Hero Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'About ThisAble',
                style: AppTextStyles.sectionTitle.copyWith(
                  // Using YOUR actual text style
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                'Connecting talented individuals with disabilities to inclusive employers who value diversity and accessibility.',
                style: AppTextStyles.bodyLarge.copyWith(
                  // Using YOUR actual text style
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
