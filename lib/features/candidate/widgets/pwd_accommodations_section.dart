import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// PWD Accommodations & Support Section - Mirrors your web version exactly
/// Displays green accommodation badges matching your web design
class PWDAccommodationsSection extends StatelessWidget {
  final List<String> accommodations;

  const PWDAccommodationsSection({
    super.key,
    required this.accommodations,
  });

  @override
  Widget build(BuildContext context) {
    // If no accommodations, show "None specified" message
    if (accommodations.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.accessible_forward,
                color: AppColors.successGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'PWD Accommodations & Support',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF257180), // secondaryTeal
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text(
              'No specific accommodations mentioned for this position.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.accessible_forward,
              color: AppColors.successGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'PWD Accommodations & Support',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF257180), // secondaryTeal
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Accommodation badges - Green styling to match web
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: accommodations.map((accommodation) {
            return _buildAccommodationBadge(accommodation);
          }).toList(),
        ),
      ],
    );
  }

  /// Build individual accommodation badge with green styling (matches web)
  Widget _buildAccommodationBadge(String accommodation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.successGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getAccommodationIcon(accommodation),
            color: AppColors.successGreen,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            accommodation,
            style: TextStyle(
              color: AppColors.successGreen,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Get appropriate icon for each accommodation type
  IconData _getAccommodationIcon(String accommodation) {
    switch (accommodation.toLowerCase()) {
      case 'wheelchair accessible':
        return Icons.accessible;
      case 'flexible schedule':
        return Icons.schedule_outlined;
      case 'assistive technology':
        return Icons.computer;
      case 'remote work option':
        return Icons.home_work_outlined;
      case 'screen reader compatible':
        return Icons.visibility_outlined;
      case 'sign language interpreter':
        return Icons.sign_language;
      case 'modified workspace':
        return Icons.business_outlined;
      case 'transportation support':
        return Icons.directions_bus_outlined;
      case 'additional accommodations available':
        return Icons.more_horiz;
      default:
        return Icons.check_circle_outline;
    }
  }
}
