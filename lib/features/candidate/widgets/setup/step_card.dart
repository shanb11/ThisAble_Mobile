import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;

  const StepCard({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Check if screen is small (mobile)
          bool isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return Column(
              children: [
                _buildStepIcon(),
                const SizedBox(height: 16),
                _buildStepContent(),
              ],
            );
          } else {
            return Row(
              children: [
                _buildStepIcon(),
                const SizedBox(width: 20),
                Expanded(child: _buildStepContent()),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildStepIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          stepNumber.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
