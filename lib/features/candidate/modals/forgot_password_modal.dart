import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../core/utils/form_validators.dart';

/// Forgot Password Modal - Mobile version of modals/candidate/login_forgotpass_modal.php
/// Matches your web modal styling and behavior exactly
class ForgotPasswordModal extends StatefulWidget {
  const ForgotPasswordModal({super.key});

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _showSuccess = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: _buildModalContent(),
      ),
    );
  }

  /// Build modal content (matches .modal-content styling)
  Widget _buildModalContent() {
    return Container(
      // Matches your CSS: .modal-content styling
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      constraints: const BoxConstraints(
        maxWidth: 400, // matches your modal width
        maxHeight: 500,
      ),
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            _buildModalHeader(),

            const SizedBox(height: 20),

            // Title (matches modal h3)
            _buildModalTitle(),

            const SizedBox(height: 15),

            // Description (matches modal p)
            _buildModalDescription(),

            const SizedBox(height: 25),

            // Email input or success message
            if (!_showSuccess) ...[
              _buildEmailField(),
              const SizedBox(height: 25),
              _buildSubmitButton(),
            ] else ...[
              _buildSuccessMessage(),
              const SizedBox(height: 25),
              _buildCloseButton(),
            ],
          ],
        ),
      ),
    );
  }

  /// Modal header with close button (matches .close-modal)
  Widget _buildModalHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: _closeModal,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.close,
              color: AppColors.primaryOrange,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  /// Modal title (matches modal h3)
  Widget _buildModalTitle() {
    return Text(
      'Reset Your Password',
      style: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.secondaryTeal,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Modal description (matches modal p)
  Widget _buildModalDescription() {
    return Text(
      'Enter your email address below and we\'ll send you a link to reset your password.',
      style: GoogleFonts.inter(
        fontSize: 14,
        color: Colors.grey[600],
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Email input field (matches .input-box)
  Widget _buildEmailField() {
    return CustomTextField(
      controller: _emailController,
      hintText: 'Email',
      prefixIcon: const Icon(Icons.email_outlined),
      keyboardType: TextInputType.emailAddress,
      validator: FormValidators.validateEmail,
    );
  }

  /// Submit button (matches .submit-btn)
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: _isLoading ? 'Sending...' : 'Send Reset Link',
        onPressed: _isLoading ? null : _handleSendResetLink,
        type: CustomButtonType.primary,
      ),
    );
  }

  /// Success message (matches .success-message)
  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green[600],
            size: 48,
          ),
          const SizedBox(height: 15),
          Text(
            'Password reset link has been sent to your email!',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Close button for success state
  Widget _buildCloseButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Close',
        onPressed: _closeModal,
        type: CustomButtonType.secondary,
      ),
    );
  }

  /// Handle send reset link (matches your JS functionality)
  void _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call (replace with actual API integration later)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _showSuccess = true;
    });

    // Auto-close after 3 seconds (matches your web behavior)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _closeModal();
      }
    });
  }

  /// Close modal with animation
  void _closeModal() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
