import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text Styles - Using Inter font (same as your web)
/// Compatible with Flutter 3.32.4
class AppTextStyles {
  // Base Inter font family - Fixed for Flutter 3.32.4
  static String get fontFamily => GoogleFonts.inter().fontFamily ?? 'Inter';

  // Hero Section Styles (from your CSS)
  static TextStyle get heroTitle => GoogleFonts.inter(
        fontSize: 40, // 2.5rem equivalent on mobile
        fontWeight: FontWeight.w700, // Bold
        color: Colors.white,
        letterSpacing: 2,
        height: 1.2,
      );

  static TextStyle get heroSubtitle => GoogleFonts.inter(
        fontSize: 18, // 1.1rem equivalent
        fontWeight: FontWeight.w400, // Regular
        color: Colors.white,
        height: 1.6,
      );

  // Section Headings (h2 equivalents)
  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 32, // 2rem
        fontWeight: FontWeight.w600, // SemiBold
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get sectionSubtitle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      );

  // Card Titles (h3 equivalents)
  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 20, // 1.2rem
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get cardSubtitle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500, // Medium
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // Body Text Styles
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14, // 0.9rem
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12, // 0.8rem
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
        height: 1.5,
      );

  // Button Text Styles
  static TextStyle get buttonPrimary => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600, // SemiBold
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get buttonSecondary => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.secondaryTeal,
        height: 1.2,
      );

  static TextStyle get buttonOutlined => GoogleFonts.inter(
        fontSize: 14, // 0.9rem (apply-btn)
        fontWeight: FontWeight.w600,
        color: AppColors.secondaryTeal,
        height: 1.2,
      );

  // Navigation Styles
  static TextStyle get navItem => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500, // Medium
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get navItemActive => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600, // SemiBold when active
        color: AppColors.textPrimary,
        height: 1.2,
      );

  // Job Listing Styles
  static TextStyle get jobTitle => GoogleFonts.inter(
        fontSize: 20, // 1.2rem
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get jobCompany => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.3,
      );

  static TextStyle get jobDetail => GoogleFonts.inter(
        fontSize: 14, // 0.9rem
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get jobDescription => GoogleFonts.inter(
        fontSize: 14, // 0.9rem
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      );

  // Footer Styles
  static TextStyle get footerHeading => GoogleFonts.inter(
        fontSize: 20, // 1.2rem
        fontWeight: FontWeight.w600,
        color: AppColors.footerText,
        height: 1.3,
      );

  static TextStyle get footerLink => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.footerTextOpaque,
        height: 1.4,
      );

  static TextStyle get footerCopyright => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.footerText,
        height: 1.4,
      );

  // Form Styles
  static TextStyle get formLabel => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get formInput => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get formPlaceholder => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
        height: 1.4,
      );

  // About Page Styles
  static TextStyle get aboutHeroTitle => GoogleFonts.inter(
        fontSize: 40, // 2.5rem
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 2,
        height: 1.2,
      );

  static TextStyle get timelineTitle => GoogleFonts.inter(
        fontSize: 20, // 1.2rem
        fontWeight: FontWeight.w600,
        color: AppColors.secondaryTeal,
        height: 1.3,
      );

  static TextStyle get valueCardTitle => GoogleFonts.inter(
        fontSize: 20, // 1.2rem
        fontWeight: FontWeight.w600,
        color: AppColors.secondaryTeal,
        height: 1.3,
      );

  static TextStyle get teamMemberName => GoogleFonts.inter(
        fontSize: 20, // 1.2rem
        fontWeight: FontWeight.w600,
        color: AppColors.secondaryTeal,
        height: 1.3,
      );

  static TextStyle get teamMemberRole => GoogleFonts.inter(
        fontSize: 14, // 0.9rem
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );
}
