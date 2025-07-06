import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'text_styles.dart';

/// Complete App Theme - Matches your web design exactly
/// Compatible with Flutter 3.32.4 - Fixed theme class names
class AppTheme {
  /// Light Theme (Main theme matching your web)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Color Scheme (based on your CSS colors)
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryOrange, // #FD8B51
        secondary: AppColors.secondaryTeal, // #257180
        surface: AppColors.cardBackground, // #ffffff
        error: AppColors.errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),

      // Scaffold Background (matches body background)
      scaffoldBackgroundColor: AppColors.backgroundColor,

      // App Bar Theme (matches your header)
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 2,
        shadowColor: AppColors.shadowMedium,
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
        ),
      ),

      // Text Theme (Inter font family)
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heroTitle,
        displayMedium: AppTextStyles.sectionTitle,
        displaySmall: AppTextStyles.cardTitle,
        headlineLarge: AppTextStyles.sectionTitle,
        headlineMedium: AppTextStyles.cardTitle,
        headlineSmall: AppTextStyles.cardSubtitle,
        titleLarge: AppTextStyles.jobTitle,
        titleMedium: AppTextStyles.jobCompany,
        titleSmall: AppTextStyles.formLabel,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.buttonPrimary,
        labelMedium: AppTextStyles.navItem,
        labelSmall: AppTextStyles.jobDetail,
      ),

      // Button Themes (matches your CSS button styles)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(5), // matches border-radius: 5px
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryTeal,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          side: const BorderSide(
            color: AppColors.secondaryTeal,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondaryTeal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Card Theme (FIXED: CardTheme → CardThemeData)
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Input Decoration Theme (matches your form styles)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5), // matches border-radius: 5px
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: AppColors.primaryOrange,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
            width: 1,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.secondaryTeal,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme (for job details tags)
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.jobDetailBackground,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        elevation: 6,
      ),

      // Dialog Theme (FIXED: DialogTheme → DialogThemeData)
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
      ),

      // TabBar Theme (FIXED: TabBarTheme → TabBarThemeData)
      tabBarTheme: const TabBarThemeData(
        // ADD const HERE!
        labelColor: AppColors.primaryOrange,
        unselectedLabelColor: AppColors.textLight,
        indicator: UnderlineTabIndicator(
          // REMOVE const HERE!
          borderSide: BorderSide(
            color: AppColors.primaryOrange,
            width: 2,
          ),
        ),
      ),
    );
  }

  /// Custom Box Decorations (matches your CSS styling)
  static BoxDecoration get cardShadow => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      );

  static BoxDecoration get cardHoverShadow => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 25,
            offset: Offset(0, 10),
          ),
        ],
      );

  static BoxDecoration get heroGradient => const BoxDecoration(
        color: AppColors.secondaryTeal,
        // Can add gradient here if needed for hero section
      );

  static BoxDecoration get inclusiveBackground => BoxDecoration(
        color: AppColors.inclusiveBackground,
        borderRadius: BorderRadius.circular(10),
      );

  /// Border Styles (matches your CSS borders)
  static Border get jobCardBorder => const Border(
        left: BorderSide(
          color: AppColors.secondaryTeal,
          width: 4,
        ),
      );
}
