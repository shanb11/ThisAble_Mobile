import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Custom Text Field - Matches your web form styles exactly
class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool required;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final bool autofocus;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.required = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.contentPadding,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (matches your web form labels)
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: AppTextStyles.formLabel,
              ),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.errorRed,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Text Field (matches your web input styling)
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          autofocus: autofocus,
          inputFormatters: inputFormatters,
          style: AppTextStyles.formInput,

          // Decoration (matches your CSS input styles)
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.formPlaceholder,

            // Matches your CSS: padding: 12px 15px
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),

            // Icons
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,

            // Matches your CSS form styling
            filled: true,
            fillColor: enabled ? Colors.white : AppColors.backgroundColor,

            // Border styling (matches your CSS border-radius: 5px, border: 1px solid #ddd)
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
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
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(
                color: AppColors.errorRed,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
          ),

          // Validation and callbacks
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
        ),
      ],
    );
  }
}

/// Search Text Field - matches your search bars
class SearchTextField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function()? onSearchPressed;

  const SearchTextField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: hintText ?? 'Search...',
      prefixIcon: const Icon(
        Icons.search,
        color: AppColors.textLight,
      ),
      suffixIcon: onSearchPressed != null
          ? IconButton(
              icon: const Icon(
                Icons.arrow_forward,
                color: AppColors.primaryOrange,
              ),
              onPressed: onSearchPressed,
            )
          : null,
      onChanged: onChanged,
    );
  }
}

/// Job Search Field - matches your landing page search
class JobSearchField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const JobSearchField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: hintText ?? 'Job title or keyword',
      prefixIcon: const Icon(
        Icons.search,
        color: AppColors.textLight,
      ),
      onChanged: onChanged,
    );
  }
}

/// Location Search Field - matches your landing page search
class LocationSearchField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const LocationSearchField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: hintText ?? 'All Locations',
      prefixIcon: const Icon(
        Icons.location_on_outlined,
        color: AppColors.textLight,
      ),
      onChanged: onChanged,
    );
  }
}

/// Email Field - with validation
class EmailField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final bool required;
  final void Function(String)? onChanged;

  const EmailField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.required = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label ?? 'Email Address',
      hintText: hintText ?? 'Enter your email',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      required: required,
      prefixIcon: const Icon(
        Icons.email_outlined,
        color: AppColors.textLight,
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'Email is required';
        }
        if (value != null && value.isNotEmpty) {
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}

/// Password Field - with visibility toggle
class PasswordField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final bool required;
  final void Function(String)? onChanged;

  const PasswordField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.required = false,
    this.onChanged,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: widget.label ?? 'Password',
      hintText: widget.hintText ?? 'Enter your password',
      controller: widget.controller,
      obscureText: _obscureText,
      required: widget.required,
      prefixIcon: const Icon(
        Icons.lock_outlined,
        color: AppColors.textLight,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textLight,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      validator: (value) {
        if (widget.required && (value == null || value.isEmpty)) {
          return 'Password is required';
        }
        if (value != null && value.isNotEmpty && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      onChanged: widget.onChanged,
    );
  }
}

/// Text Area Field - for longer text inputs
class TextAreaField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final bool required;
  final int maxLines;
  final int? maxLength;
  final void Function(String)? onChanged;

  const TextAreaField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.required = false,
    this.maxLines = 5,
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hintText: hintText,
      controller: controller,
      required: required,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: TextInputType.multiline,
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return '${label ?? 'This field'} is required';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}
