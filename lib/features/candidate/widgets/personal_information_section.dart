import 'package:flutter/material.dart';
import 'profile_info_item.dart'; // Import the widget we just created

/// Updated Personal Information Section - Matches Web Grid Layout
///
/// This replaces the current _buildPersonalInfoSection() and _buildReadOnlyPersonalInfo()
/// in lib/features/candidate/screens/main/profile_screen.dart

class PersonalInformationSection {
  // ThisAble Colors (match web)
  static const Color primaryColor = Color(0xFF257180);
  static const Color accentColor = Color(0xFFFD8B51);

  /// Build Personal Info Section with Grid Layout (Read-Only Mode)
  static Widget buildReadOnlySection(Map<String, dynamic> profileData) {
    // Format full name with middle name and suffix
    String fullName = _formatFullName(
      profileData['first_name'] ?? '',
      profileData['middle_name'] ?? '',
      profileData['last_name'] ?? '',
      profileData['suffix'] ?? '',
    );

    // Format location
    String location = _formatLocation(
      profileData['city'] ?? '',
      profileData['province'] ?? '',
    );

    // Check if PWD ID is verified
    bool isPwdVerified = (profileData['pwd_id'] ?? '').isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header (matches web)
          _buildSectionHeader(),

          // Info Grid (2 columns)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Row 1: Full Name | Email
                Row(
                  children: [
                    Expanded(
                      child: ProfileInfoItem(
                        label: 'Full Name',
                        value: fullName,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ProfileInfoItem(
                        label: 'Email',
                        value: profileData['email'] ?? '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 2: Phone | Location
                Row(
                  children: [
                    Expanded(
                      child: ProfileInfoItem(
                        label: 'Phone',
                        value: profileData['contact_number'] ?? '',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ProfileInfoItem(
                        label: 'Location',
                        value: location,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 3: PWD ID | Type of Disability
                Row(
                  children: [
                    Expanded(
                      child: ProfileInfoItem(
                        label: 'PWD ID',
                        value: profileData['pwd_id'] ?? '',
                        trailing: isPwdVerified ? const VerifiedBadge() : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ProfileInfoItem(
                        label: 'Type of Disability',
                        value: profileData['disability_type'] ?? '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build Section Header (matches web styling)
  static Widget _buildSectionHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: accentColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          // Edit button will be added separately in the main widget
        ],
      ),
    );
  }

  /// Format full name with middle name and suffix
  static String _formatFullName(
      String first, String middle, String last, String suffix) {
    List<String> parts = [];

    if (first.isNotEmpty) parts.add(first);
    if (middle.isNotEmpty) parts.add(middle);
    if (last.isNotEmpty) parts.add(last);
    if (suffix.isNotEmpty) parts.add(suffix);

    return parts.join(' ');
  }

  /// Format location as "City, Province, Philippines"
  static String _formatLocation(String city, String province) {
    List<String> parts = [];

    if (city.isNotEmpty) parts.add(city);
    if (province.isNotEmpty) parts.add(province);

    if (parts.isEmpty) {
      return 'Not specified';
    }

    parts.add('Philippines');
    return parts.join(', ');
  }
}
