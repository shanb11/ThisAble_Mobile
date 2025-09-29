import 'package:flutter/material.dart';

/// Job Statistics Section - Mirrors your web version exactly
/// Shows views, applications, and posted time with proper icons
class JobStatisticsSection extends StatelessWidget {
  final int viewsCount;
  final int applicationsCount;
  final String postedTime;

  const JobStatisticsSection({
    super.key,
    required this.viewsCount,
    required this.applicationsCount,
    required this.postedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.bar_chart_outlined,
              color: Color(0xFF257180), // secondaryTeal
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Job Statistics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF257180), // secondaryTeal
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Statistics row with icons matching web version
        Row(
          children: [
            _buildStatistic(
              icon: Icons.visibility_outlined,
              value: viewsCount.toString(),
              label: 'views',
            ),
            const SizedBox(width: 24),
            _buildStatistic(
              icon: Icons.people_outlined,
              value: applicationsCount.toString(),
              label: 'applications',
            ),
            const SizedBox(width: 24),
            _buildStatistic(
              icon: Icons.schedule_outlined,
              value: '',
              label: 'Posted $postedTime',
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual statistic item with icon and text
  Widget _buildStatistic({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.grey[600],
          size: 16,
        ),
        const SizedBox(width: 4),
        if (value.isNotEmpty) ...[
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(width: 2),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
