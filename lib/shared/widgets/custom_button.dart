import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Custom Button Widget - Matches your web CSS button styles exactly
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final double? fontSize;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = CustomButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.icon,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;

    switch (type) {
      case CustomButtonType.primary:
        button = _buildPrimaryButton();
        break;
      case CustomButtonType.secondary:
        button = _buildSecondaryButton();
        break;
      case CustomButtonType.outlined:
        button = _buildOutlinedButton();
        break;
      case CustomButtonType.text:
        button = _buildTextButton();
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  /// Primary Button - matches .btn-primary from your CSS
  Widget _buildPrimaryButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryOrange, // #FD8B51
        foregroundColor: Colors.white,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // matches border-radius: 5px
        ),
        elevation: 0,
        disabledBackgroundColor: AppColors.disabled,
      ),
      child: _buildButtonContent(
        textStyle: AppTextStyles.buttonPrimary.copyWith(
          fontSize: fontSize,
        ),
        textColor: Colors.white,
      ),
    );
  }

  /// Secondary Button - matches .btn-secondary from your CSS
  Widget _buildSecondaryButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondaryTeal, // #257180
        foregroundColor: Colors.white,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        elevation: 0,
        disabledBackgroundColor: AppColors.disabled,
      ),
      child: _buildButtonContent(
        textStyle: AppTextStyles.buttonPrimary.copyWith(
          fontSize: fontSize,
        ),
        textColor: Colors.white,
      ),
    );
  }

  /// Outlined Button - matches .apply-btn from your CSS
  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondaryTeal,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        side: const BorderSide(
          color: AppColors.secondaryTeal,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: _buildButtonContent(
        textStyle: AppTextStyles.buttonOutlined.copyWith(
          fontSize: fontSize,
        ),
        textColor: AppColors.secondaryTeal,
      ),
    );
  }

  /// Text Button - for links and subtle actions
  Widget _buildTextButton() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondaryTeal,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: _buildButtonContent(
        textStyle: AppTextStyles.buttonSecondary.copyWith(
          fontSize: fontSize,
        ),
        textColor: AppColors.secondaryTeal,
      ),
    );
  }

  /// Build button content with loading state and icon support
  Widget _buildButtonContent({
    required TextStyle textStyle,
    required Color textColor,
  }) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: textStyle,
          ),
        ],
      );
    }

    return Text(
      text,
      style: textStyle,
    );
  }
}

/// Button Types - matches your web button classes
enum CustomButtonType {
  primary, // .btn-primary (orange)
  secondary, // .btn-secondary (teal)
  outlined, // .apply-btn (outlined teal)
  text, // text button for links
}

/// Specialized Buttons for common use cases

/// Browse Jobs Button - matches your landing page
class BrowseJobsButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const BrowseJobsButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Browse Jobs',
      onPressed: onPressed,
      type: CustomButtonType.secondary,
    );
  }
}

/// Post Job Button - matches your landing page
class PostJobButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const PostJobButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Post a Job',
      onPressed: onPressed,
      type: CustomButtonType.primary,
    );
  }
}

/// Apply Now Button - matches your job cards
class ApplyNowButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ApplyNowButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Apply Now',
      onPressed: onPressed,
      type: CustomButtonType.outlined,
      fontSize: 14, // matches .apply-btn font-size: 0.9rem
    );
  }
}

/// View Details Button - matches your job cards
class ViewDetailsButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ViewDetailsButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'View Details',
      onPressed: onPressed,
      type: CustomButtonType.outlined,
      fontSize: 14,
    );
  }
}

/// Sign In Button - matches your navbar
class SignInButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SignInButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Sign In',
      onPressed: onPressed,
      type: CustomButtonType.primary,
    );
  }
}

/// Get Started Button - for hero sections
class GetStartedButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GetStartedButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Get Started',
      onPressed: onPressed,
      type: CustomButtonType.primary,
      isFullWidth: false,
    );
  }
}
