import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../config/constants.dart';

/// PWD Details Modal - Mobile version of modals/candidate/pwd_details_modal.php
/// For Google users to complete their profile with PWD information
class PWDDetailsModal extends StatefulWidget {
  final Map<String, dynamic>? googleUserData;

  const PWDDetailsModal({
    super.key,
    this.googleUserData,
  });

  @override
  State<PWDDetailsModal> createState() => _PWDDetailsModalState();
}

class _PWDDetailsModalState extends State<PWDDetailsModal>
    with SingleTickerProviderStateMixin {
  // Form controllers
  final _phoneController = TextEditingController();
  final _pwdIdController = TextEditingController();
  final _pwdIssuedDateController = TextEditingController();

  // Form state
  String? _selectedDisabilityType;
  String? _selectedIssuingLGU;
  bool _isLoading = false;
  bool _isVerifying = false;
  //String? _selectedFileName;
  //PlatformFile? _selectedFile;

  // Verification state
  bool _verificationComplete = false;
  String? _verificationMessage;
  String? _verificationStatus;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Animation
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
    _phoneController.dispose();
    _pwdIdController.dispose();
    _pwdIssuedDateController.dispose();
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

  /// Build modal content
  Widget _buildModalContent() {
    return Container(
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
        maxWidth: 500,
        maxHeight: 700,
      ),
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildModalHeader(),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: _buildModalBody(),
            ),
          ),
        ],
      ),
    );
  }

  /// Modal header with close button
  Widget _buildModalHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primaryOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.accessibility_new,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 15),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Your Registration',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryTeal,
                  ),
                ),
                if (widget.googleUserData != null)
                  Text(
                    'Welcome ${widget.googleUserData!['first_name'] ?? 'User'}!',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),

          // Close button
          GestureDetector(
            onTap: _closeModal,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: AppColors.primaryOrange,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Modal body content
  Widget _buildModalBody() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            'We need some additional information to complete your account setup.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 25),

          // Pre-filled user data (read-only)
          if (widget.googleUserData != null) ...[
            _buildReadOnlyField(
              label: 'Email Address',
              value: widget.googleUserData!['email'] ?? '',
              icon: Icons.email_outlined,
              subtitle: 'Email address from your Google account',
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _buildReadOnlyField(
                    label: 'First Name',
                    value: widget.googleUserData!['first_name'] ?? '',
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildReadOnlyField(
                    label: 'Last Name',
                    value: widget.googleUserData!['last_name'] ?? '',
                    icon: Icons.person_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Divider
            Row(
              children: [
                Expanded(child: Container(height: 1, color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Additional Information Required',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(child: Container(height: 1, color: Colors.grey[300])),
              ],
            ),

            const SizedBox(height: 25),
          ],

          // Phone number field
          CustomTextField(
            controller: _phoneController,
            hintText: 'Phone Number (e.g., 09171234567)',
            prefixIcon: Icon(Icons.phone_outlined),
            keyboardType: TextInputType.phone,
            validator: _validatePhoneNumber,
          ),

          const SizedBox(height: 15),

          // Disability type dropdown
          _buildDisabilityDropdown(),

          const SizedBox(height: 15),

          // PWD ID Number
          CustomTextField(
            controller: _pwdIdController,
            hintText: 'PWD ID Number',
            prefixIcon: Icon(Icons.badge_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your PWD ID number';
              }
              return null;
            },
          ),

          const SizedBox(height: 15),

          // PWD ID Issued Date
          CustomTextField(
            controller: _pwdIssuedDateController,
            hintText: 'Date Issued',
            prefixIcon: Icon(Icons.calendar_today_outlined),
            //readOnly: true,
            onTap: _selectIssuedDate,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select the date your PWD ID was issued';
              }
              return null;
            },
          ),

          const SizedBox(height: 15),

          // Issuing LGU dropdown
          _buildLGUDropdown(),

          const SizedBox(height: 20),

          // Verify PWD ID button
          _buildVerifyButton(),

          // Verification status
          if (_verificationMessage != null) ...[
            const SizedBox(height: 15),
            _buildVerificationStatus(),
          ],

          // File upload section (shown if verification fails)
          if (_verificationStatus == 'error' ||
              _verificationStatus == 'warning') ...[
            const SizedBox(height: 20),
            _buildFileUploadSection(),
          ],

          const SizedBox(height: 25),

          // Complete registration button
          _buildCompleteButton(),
        ],
      ),
    );
  }

  /// Read-only field for Google user data
  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  color: Colors.grey[500],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    value.isNotEmpty ? value : label,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: value.isNotEmpty
                          ? Colors.grey[700]
                          : Colors.grey[500],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  /// Disability type dropdown
  Widget _buildDisabilityDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryOrange),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.accessibility_outlined,
              color: AppColors.primaryOrange,
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDisabilityType,
                hint: Text(
                  'Select Type of Disability',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                isExpanded: true,
                items: AppConstants.disabilityTypes.map((disability) {
                  return DropdownMenuItem<String>(
                    value: disability['id'],
                    child: Text(
                      disability['name']!,
                      style: GoogleFonts.inter(fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDisabilityType = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// LGU dropdown
  Widget _buildLGUDropdown() {
    final lgus = [
      'Bacoor City',
      'Cavite City',
      'Dasmariñas City',
      'General Trias City',
      'Imus City',
      'Tagaytay City',
      'Trece Martires City',
      'Alfonso',
      'Amadeo',
      'Carmona',
      'General Mariano Alvarez (GMA)',
      'Indang',
      'Kawit',
      'Magallanes',
      'Maragondon',
      'Mendez',
      'Naic',
      'Noveleta',
      'Rosario',
      'Silang',
      'Tanza',
      'Ternate',
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryOrange),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.location_on_outlined,
              color: AppColors.primaryOrange,
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedIssuingLGU,
                hint: Text(
                  'Select Issuing LGU/Municipality in Cavite',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                isExpanded: true,
                items: lgus.map((lgu) {
                  return DropdownMenuItem<String>(
                    value: lgu,
                    child: Text(
                      lgu,
                      style: GoogleFonts.inter(fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIssuingLGU = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Verify PWD ID button
  Widget _buildVerifyButton() {
    return Container(
      width: double.infinity,
      child: CustomButton(
        text: _isVerifying ? 'Verifying...' : 'Verify PWD ID',
        onPressed: _isVerifying ? null : _handleVerifyPwdId,
        type: CustomButtonType.secondary,
        //loading: _isVerifying,
      ),
    );
  }

  /// Verification status display
  Widget _buildVerificationStatus() {
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    IconData icon;

    switch (_verificationStatus) {
      case 'success':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        borderColor = Colors.green[200]!;
        icon = Icons.check_circle;
        break;
      case 'error':
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        borderColor = Colors.red[200]!;
        icon = Icons.error;
        break;
      case 'warning':
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        borderColor = Colors.orange[200]!;
        icon = Icons.warning;
        break;
      default:
        backgroundColor = Colors.grey[50]!;
        textColor = Colors.grey[700]!;
        borderColor = Colors.grey[200]!;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _verificationMessage!,
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// File upload section
  /// File upload section (temporarily disabled for Phase 1)
  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section divider
        Row(
          children: [
            Expanded(child: Container(height: 1, color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                'Manual Verification',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Expanded(child: Container(height: 1, color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 15),

        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(5),
            color: Colors.grey[50],
          ),
          child: Column(
            children: [
              Icon(
                Icons.upload_file,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 10),
              Text(
                'PWD ID Upload Coming Soon',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'File upload will be available in Phase 2.\nFor now, you can complete registration without file upload.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Complete registration button
  Widget _buildCompleteButton() {
    return Container(
      width: double.infinity,
      child: CustomButton(
        text: _isLoading ? 'Processing...' : 'Complete Registration',
        onPressed: (_isLoading || !_canCompleteRegistration())
            ? null
            : _handleCompleteRegistration,
        type: CustomButtonType.primary,
        //loading: _isLoading,
      ),
    );
  }

  /// Handle PWD ID verification
  void _handleVerifyPwdId() async {
    if (_pwdIdController.text.isEmpty ||
        _pwdIssuedDateController.text.isEmpty ||
        _selectedIssuingLGU == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all PWD ID details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _verificationMessage =
          'Connecting to DOH database for verification. This may take a moment...';
      _verificationStatus = null;
    });

    // Simulate DOH verification
    await Future.delayed(const Duration(seconds: 3));

    final random = DateTime.now().millisecond % 3;

    setState(() {
      _isVerifying = false;

      if (random == 0) {
        _verificationStatus = 'success';
        _verificationMessage =
            'PWD ID successfully verified through DOH database!';
        _verificationComplete = true;
      } else if (random == 1) {
        _verificationStatus = 'warning';
        _verificationMessage =
            'Automatic verification unavailable. Please upload your PWD ID for manual verification.';
        _verificationComplete = false;
      } else {
        _verificationStatus = 'error';
        _verificationMessage =
            'PWD ID verification failed. Please upload your PWD ID for manual verification.';
        _verificationComplete = false;
      }
    });
  }

  /// Handle complete registration
  void _handleCompleteRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDisabilityType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your disability type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });

    // Show success and navigate
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Profile completed successfully! Redirecting to account setup...'),
        backgroundColor: Colors.green,
      ),
    );

    _closeModal();

    // Navigate to account setup (will be implemented later)
    // AppRoutes.goToCandidateSetup(context);
  }

/*
  /// Pick file for PWD ID upload
  void _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          _selectedFileName = result.files.first.name;

          if (_verificationStatus == 'error' ||
              _verificationStatus == 'warning') {
            _verificationComplete = true;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
*/
  /// Select issued date
  void _selectIssuedDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _pwdIssuedDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  /// Validate Philippine phone number
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    final philippinePhoneRegex = RegExp(r'^(\+63|0)9\d{9}$');

    if (!philippinePhoneRegex.hasMatch(value)) {
      return 'Please enter a valid Philippine phone number (e.g., 09171234567)';
    }

    return null;
  }

  /// Check if registration can be completed
  /// Check if registration can be completed (Phase 1: no file required)
  bool _canCompleteRegistration() {
    // For Phase 1, allow completion after verification attempt
    return _verificationComplete ||
        _verificationStatus == 'success' ||
        _verificationStatus == 'warning' ||
        _verificationStatus == 'error';
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
