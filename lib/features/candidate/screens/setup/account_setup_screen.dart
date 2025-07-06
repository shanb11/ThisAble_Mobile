import 'package:flutter/material.dart';
//import '../../../theme/app_colors.dart';
import '../../../../core/theme/app_colors.dart';
//import '../widgets/step_card.dart';
import '../../../candidate/widgets/setup/step_card.dart';
//import '../widgets/progress_bar_widget.dart';
import '../../../candidate/widgets/setup/progress_bar_widget.dart';

import 'skill_selection_screen.dart';

class AccountSetupScreen extends StatelessWidget {
  const AccountSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Logo positioned at top right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/thisablelogo.png',
                    width: 70,
                    height: 70,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Header section
              Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    // Setup image
                    Image.asset(
                      'assets/images/setupimg.png',
                      width: 200,
                      height: 200,
                    ),

                    const SizedBox(height: 30),

                    // Welcome title
                    const Text(
                      'Welcome to ThisAble!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryTeal,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tagline
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Ready to unlock your career potential? We\'re here to help you connect with inclusive employers who value your unique talents.',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Progress bar
                    const ProgressBarWidget(progress: 0.25),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Steps infographic
              Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: const Column(
                  children: [
                    StepCard(
                      stepNumber: 1,
                      title: 'Create Your Profile',
                      description:
                          'Build a professional profile that highlights your experience, education, and unique skills that make you stand out.',
                    ),
                    SizedBox(height: 30),
                    StepCard(
                      stepNumber: 2,
                      title: 'Showcase Your Skills',
                      description:
                          'Select from our comprehensive skill library or add custom skills that represent your professional capabilities.',
                    ),
                    SizedBox(height: 30),
                    StepCard(
                      stepNumber: 3,
                      title: 'Connect With Employers',
                      description:
                          'Get matched with inclusive companies looking for talented professionals with your specific skill set.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Get Started button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _goToSkillSelection(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started Now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _goToSkillSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SkillSelectionScreen(),
      ),
    );
  }
}
