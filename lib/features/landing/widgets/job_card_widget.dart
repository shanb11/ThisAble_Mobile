import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';

/// Job Card Widget - Displays individual job listing
/// Matches the style from your web version
class JobCardWidget extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;
  final VoidCallback onApply;

  const JobCardWidget({
    super.key,
    required this.job,
    required this.onTap,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Company Logo + Name
              Row(
                children: [
                  // Company Logo
                  _buildCompanyLogo(),
                  const SizedBox(width: 12),

                  // Company Name & Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['company'] ?? 'Company',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                job['location'] ?? 'Remote',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Job Title
              Text(
                job['title'] ?? 'Job Title',
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Job Details Badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Job Type Badge
                  _buildBadge(
                    icon: Icons.work_outline,
                    label: job['type'] ?? 'Full-time',
                    color: AppColors.primaryOrange,
                  ),

                  // Salary Badge (if available)
                  if (job['salary'] != null &&
                      job['salary'].toString().isNotEmpty)
                    _buildBadge(
                      icon: Icons.payments,
                      label: job['salary'],
                      color: Colors.green,
                    ),

                  // Remote Badge (if available)
                  if (job['remote_available'] == true ||
                      job['remote_available'] == 1)
                    _buildBadge(
                      icon: Icons.home,
                      label: 'Remote',
                      color: Colors.blue,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Job Description Preview
              Text(
                job['description'] ?? 'No description available',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              // Footer: Posted Time + Apply Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Posted Time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job['posted'] ?? 'Recently',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  // Apply Button
                  ElevatedButton.icon(
                    onPressed: () {
                      onApply();
                    },
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('Apply'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyLogo() {
    final logoPath = job['company_logo'];

    if (logoPath != null && logoPath.toString().isNotEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            logoPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildLogoFallback();
            },
          ),
        ),
      );
    }

    return _buildLogoFallback();
  }

  Widget _buildLogoFallback() {
    final companyName = job['company'] ?? 'Company';
    final initials = companyName
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange.withOpacity(0.8),
            AppColors.secondaryTeal.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
