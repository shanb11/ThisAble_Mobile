import 'package:flutter/material.dart';

/// App Colors - Exact colors from your web CSS
class AppColors {
  // Primary Colors (from your CSS)
  static const Color primaryOrange = Color(0xFFFD8B51); // #FD8B51
  static const Color secondaryTeal = Color(0xFF257180); // #257180

  // Background Colors
  static const Color backgroundColor = Color(0xFFF9F9F9); // #f9f9f9
  static const Color cardBackground = Color(0xFFFFFFFF); // #ffffff
  static const Color accentBeige = Color(0xFFF2E5BF); // #F2E5BF

  // Inclusive Workplace Section Background
  static const Color inclusiveBackground = Color(0xFFFFF4EF); // #fff4ef

  // Job Category Colors
  static const Color categoryBackground = Color(0xFFF9F9F9); // #f9f9f9
  static const Color categoryIconBackground = Color(0xFFE6F3F0); // #e6f3f0

  // Text Colors
  static const Color textPrimary = Color(0xFF333333); // #333
  static const Color textSecondary = Color(0xFF666666); // #666
  static const Color textLight = Color(0xFF888888); // #888

  // Border and Divider Colors
  static const Color borderColor = Color(0xFFDDDDDD); // #ddd
  static const Color borderLight = Color(0xFFEEEEEE); // #eee

  // Job Detail Colors
  static const Color jobDetailBackground = Color(0xFFE6F3F0); // #e6f3f0

  // Button Hover States
  static const Color primaryHover = Color(0xFFE67A43); // Darker orange
  static const Color secondaryHover = Color(0xFF1E5D68); // Darker teal

  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFFF5722);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color infoBlue = Color(0xFF2196F3);

  // Shadow Colors
  static const Color shadowLight = Color(0x0D000000); // rgba(0, 0, 0, 0.05)
  static const Color shadowMedium = Color(0x1A000000); // rgba(0, 0, 0, 0.1)
  static const Color shadowDark = Color(0x40000000); // rgba(0, 0, 0, 0.25)

  // Footer Colors
  static const Color footerBackground = Color(0xFF257180); // Same as secondary
  static const Color footerText = Color(0xFFFFFFFF); // White
  static const Color footerTextOpaque =
      Color(0xCCFFFFFF); // rgba(255, 255, 255, 0.8)

  // Modal Colors
  static const Color modalOverlay = Color(0x80000000); // rgba(0, 0, 0, 0.5)

  // Disabled States
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color disabledText = Color(0xFF9E9E9E);

  //added
  // Primary colors from the CSS
  static const Color primary = Color(0xFF257180);
  static const Color primaryLight = Color(0xFFE1F0F2);
  static const Color accent = Color(0xFFFD8B51);
  static const Color accentHover = Color(0xFFCB6040);

  // Background colors
  static const Color background = Color(0xFFF7F9FA);

  // Other colors
  static const Color progressBackground = Color(0xFFE1E1E1);
  static const Color accentTeal = Color(0xFF26A69A);
  static const Color warningOrange = Color(0xFFFF9800);

  // PWD Accommodation Badges (Green theme from your web)
  static const Color pwdGreen = Color(0xFF4CAF50); // Main PWD green
  static const Color pwdGreenLight = Color(0xFFE8F5E8); // Light background
  static const Color pwdGreenBorder = Color(0xFF81C784); // Border color

  // PWD Feature Badges (Blue theme from your web)
  static const Color pwdBlue = Color(0xFF2196F3); // Feature blue
  static const Color pwdBlueLight = Color(0xFFE3F2FD); // Light background
  static const Color pwdBlueBorder = Color(0xFF64B5F6); // Border color

  // TTS Controls (matching your web TTS styling)
  static const Color ttsBackground = Color(0xFF257180); // Primary color
  static const Color ttsHover = Color(0xFFFD8B51); // Accent on hover
  static const Color ttsActive = Color(0xFF1E5D68); // Active state

  // Voice Search (matching your web voice search)
  static const Color voiceBackground = Color(0xFF2F8A99); // Sidebar color
  static const Color voiceActive = Color(0xFFDC3545); // Recording state
  static const Color voiceListening = Color(0xFF28A745); // Success green

  // Application Status Colors
  static const Color statusSubmitted = Color(0xFF2196F3); // Blue
  static const Color statusUnderReview = Color(0xFFFF9800); // Orange
  static const Color statusShortlisted = Color(0xFF9C27B0); // Purple
  static const Color statusInterviewing = Color(0xFF673AB7); // Deep purple
  static const Color statusHired = Color(0xFF4CAF50); // Green
  static const Color statusRejected = Color(0xFFFF5722); // Red

  // Statistics Card Colors (from your web stats cards)
  static const Color statTotalJobs = Color(0xFF257180); // Primary
  static const Color statPwdFriendly = Color(0xFF4CAF50); // Green
  static const Color statRemoteJobs = Color(0xFF2196F3); // Blue

  // Job Card Accent Colors (matching web design)
  static const Color companyLogoBg =
      Color(0xFF257180); // Company logo backgrounds
  static const Color locationPillBg =
      Color(0x80F2E5BF); // Location pill background
  static const Color salaryTextColor = Color(0xFF4CAF50); // Salary text color

  // === GRADIENT COLORS FOR ANIMATED HERO === //
  // Hero gradient animation colors
  static const Color heroGradientStart =
      Color(0xFF257180); // Same as secondaryTeal
  static const Color heroGradientEnd =
      Color(0xFF1E5D68); // Darker teal for gradient

  // Glassmorphism colors
  static const Color glassmorphismOverlay =
      Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color glassmorphismBorder =
      Color(0x4DFFFFFF); // rgba(255,255,255,0.3)

  // Button gradient colors (orange gradient)
  static const Color buttonGradientStart =
      Color(0xFFFD8B51); // Same as primaryOrange
  static const Color buttonGradientEnd = Color(0xFFFF9A65); // Lighter orange
}
