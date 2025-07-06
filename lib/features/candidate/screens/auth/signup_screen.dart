import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../config/routes.dart';
import '../../../../config/constants.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/services/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Signup Screen - Mobile version of frontend/candidate/signup.php
/// Complete 3-step signup process matching your web implementation
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Current step (1, 2, or 3)
  int _currentStep = 1;

  // Form controllers for Step 2
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _suffixController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Form controllers for Step 3
  final _pwdIdController = TextEditingController();
  final _pwdIssuedDateController = TextEditingController();

  // Form state
  String? _selectedDisabilityType;
  String? _selectedIssuingLGU;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isVerifying = false;

  // Google Sign-In state
  bool _isGoogleUser = false;
  Map<String, dynamic>? _googleUserData;
  bool _isGoogleSignInLoading = false;
  String? _googleIdToken; // ← ADD THIS LINE

  // Verification state
  bool _verificationComplete = false;
  String? _verificationMessage;
  String? _verificationStatus; // 'success', 'error', 'warning'

  // Disability types from API
  List<Map<String, dynamic>> _disabilityTypes = [];
  bool _isLoadingDisabilityTypes = false;
  String? _disabilityTypesError;

  // Form keys
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Fetch disability types when screen loads
    _fetchDisabilityTypes();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _suffixController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pwdIdController.dispose();
    _pwdIssuedDateController.dispose();
    super.dispose();
  }

  /// Fetch disability types from API
  Future<void> _fetchDisabilityTypes() async {
    setState(() {
      _isLoadingDisabilityTypes = true;
      _disabilityTypesError = null;
    });

    try {
      final result = await ApiService.getDisabilityTypes();

      if (result['success']) {
        setState(() {
          _disabilityTypes = List<Map<String, dynamic>>.from(
              result['data']['disability_types']);
          _isLoadingDisabilityTypes = false;
        });
      } else {
        setState(() {
          _disabilityTypesError = result['message'];
          _isLoadingDisabilityTypes = false;
        });
      }
    } catch (e) {
      setState(() {
        _disabilityTypesError = 'Failed to load disability types: $e';
        _isLoadingDisabilityTypes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSignupBody(),
    );
  }

  /// Build main signup body with responsive layout
  Widget _buildSignupBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 768;

        if (isWideScreen) {
          // Desktop/Tablet: Split screen layout
          return Row(
            children: [
              /*// Left side - Illustration (50% width)
              Expanded(child: _buildLeftSide()),*/

              // Right side - Signup form (50% width)
              Expanded(child: _buildRightSide()),
            ],
          );
        } else {
          // Mobile: Stacked layout
          return SingleChildScrollView(
            child: Column(
              children: [
                /*// Left side content (illustration section)
                SizedBox(
                  height: 250,
                  child: _buildLeftSide(),
                ),*/

                // Right side content (form section)
                Container(
                  constraints: const BoxConstraints(minHeight: 600),
                  child: _buildRightSide(),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  /*/// Left side - Illustration section (matches login_left.php)
  Widget _buildLeftSide() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondaryTeal,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration placeholder
              Icon(
                Icons.people_alt_outlined,
                size: 150,
                color: Colors.white.withOpacity(0.9),
              ),

              const SizedBox(height: 20),

              // Heading
              Text(
                'Empowering Inclusive Employment',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Description
              Text(
                'Find job opportunities that embrace diversity and inclusivity.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  /// Right side - Signup form (matches signup_right.php)
  Widget _buildRightSide() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              _buildLogo(),

              const SizedBox(height: 30),

              // Signup form container
              _buildSignupForm(),
            ],
          ),
        ),
      ),
    );
  }

  /// Logo section
  Widget _buildLogo() {
    return GestureDetector(
      onTap: () => AppRoutes.goToHome(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.primaryOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.accessibility_new,
              color: Colors.white,
              size: 35,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            'ThisAble',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryTeal,
            ),
          ),
        ],
      ),
    );
  }

  /// Signup form container (matches .signup-box)
  Widget _buildSignupForm() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        children: [
          // Title
          Text(
            'Create Account',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryTeal,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          // Progress bar (matches .progress-bar)
          _buildProgressBar(),

          const SizedBox(height: 30),

          // Step content
          _buildStepContent(),
        ],
      ),
    );
  }

  /// Progress bar (matches your web progress-bar)
  Widget _buildProgressBar() {
    return Row(
      children: [
        // Step 1
        _buildProgressStep(1, 'Sign Up'),

        // Line 1
        Expanded(child: _buildProgressLine(1)),

        // Step 2
        _buildProgressStep(2, 'Profile Details'),

        // Line 2
        Expanded(child: _buildProgressLine(2)),

        // Step 3
        _buildProgressStep(3, 'PWD Verification'),
      ],
    );
  }

  /// Individual progress step
  Widget _buildProgressStep(int stepNumber, String label) {
    final isActive = stepNumber == _currentStep;
    final isCompleted = stepNumber < _currentStep;

    Color backgroundColor;
    if (isCompleted) {
      backgroundColor = AppColors.secondaryTeal; // matches .completed
    } else if (isActive) {
      backgroundColor = AppColors.primaryOrange; // matches .active
    } else {
      backgroundColor = Colors.grey[300]!; // matches default
    }

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Progress line between steps
  Widget _buildProgressLine(int lineNumber) {
    final isCompleted = lineNumber < _currentStep;

    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20), // Account for label space
      color: isCompleted ? AppColors.secondaryTeal : Colors.grey[300],
    );
  }

  /// Build content for current step
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Content();
      case 2:
        return _buildStep2Content();
      case 3:
        return _buildStep3Content();
      default:
        return _buildStep1Content();
    }
  }

  /// Step 1: Initial sign up with Google or email
  Widget _buildStep1Content() {
    return Column(
      children: [
        // Google Sign Up Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isGoogleSignInLoading ? null : _handleGoogleSignUp,
            icon: _isGoogleSignInLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                    ),
                  )
                : Icon(
                    Icons.g_mobiledata,
                    color: Colors.grey[600],
                    size: 24,
                  ),
            label: Text(
              _isGoogleSignInLoading
                  ? 'Signing up with Google...'
                  : 'Sign up with Google',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              backgroundColor: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Divider
        _buildDivider(),

        const SizedBox(height: 20),

        // Continue with Email button
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Continue with Email',
            onPressed: () => _goToStep(2),
            type: CustomButtonType.primary,
          ),
        ),

        const SizedBox(height: 20),

        // Login link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            GestureDetector(
              onTap: () => AppRoutes.goToCandidateLogin(context),
              child: Text(
                'Log in',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.secondaryTeal,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Step 2: Complete profile form (enhanced for Google users) - VERTICAL LAYOUT
  Widget _buildStep2Content() {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced title and description for Google users
          _buildStep2Header(),

          const SizedBox(height: 25),

          // First Name field
          _buildGoogleAwareTextField(
            controller: _firstNameController,
            hintText: 'First Name',
            prefixIcon: const Icon(Icons.person_outline),
            validator: (value) =>
                FormValidators.validateName(value, 'first name'),
            isReadOnly: _isGoogleUser,
          ),

          const SizedBox(height: 15),

          // Middle Name field
          CustomTextField(
            controller: _middleNameController,
            hintText: 'Middle Name (Optional)',
            prefixIcon: const Icon(Icons.person_outline),
          ),

          const SizedBox(height: 15),

          // Last Name field
          _buildGoogleAwareTextField(
            controller: _lastNameController,
            hintText: 'Last Name',
            prefixIcon: const Icon(Icons.person_outline),
            validator: (value) =>
                FormValidators.validateName(value, 'last name'),
            isReadOnly: _isGoogleUser,
          ),

          const SizedBox(height: 15),

          // Suffix field
          CustomTextField(
            controller: _suffixController,
            hintText: 'Suffix (Jr., Sr., III, etc.)',
            prefixIcon: const Icon(Icons.person_add_outlined),
          ),

          const SizedBox(height: 15),

          // Email field (read-only for Google users)
          _buildEmailField(),

          const SizedBox(height: 15),

          // Phone field
          CustomTextField(
            controller: _phoneController,
            hintText: 'Phone Number (e.g., 09171234567)',
            prefixIcon: const Icon(Icons.phone_outlined),
            keyboardType: TextInputType.phone,
            validator: FormValidators.validatePhilippinePhoneNumber,
          ),

          const SizedBox(height: 15),

          // Disability type dropdown
          _buildDisabilityDropdown(),

          // Password fields (hidden for Google users)
          if (!_isGoogleUser) ...[
            const SizedBox(height: 15),
            _buildPasswordFields(),
          ],

          const SizedBox(height: 25),

          // Form buttons
          _buildStep2Buttons(),
        ],
      ),
    );
  }

  /// Build Step 2 header with Google user indication
  Widget _buildStep2Header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          _isGoogleUser
              ? 'Complete Your Google Profile'
              : 'Complete Your Profile',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryTeal,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 10),

        // Description with Google user indicator
        if (_isGoogleUser) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Google account connected! Your name and email are pre-filled.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Standard description
        Text(
          _isGoogleUser
              ? 'Please complete the remaining information to continue.'
              : 'Please provide the following information to continue.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build email field (read-only for Google users)
  Widget _buildEmailField() {
    return _buildGoogleAwareTextField(
      controller: _emailController,
      hintText: 'Email Address',
      prefixIcon: const Icon(Icons.email_outlined),
      keyboardType: TextInputType.emailAddress,
      validator: FormValidators.validateEmail,
      isReadOnly: _isGoogleUser,
    );
  }

  /// Build password fields (only for non-Google users) - VERTICAL LAYOUT
  Widget _buildPasswordFields() {
    return Column(
      children: [
        // Password field
        CustomTextField(
          controller: _passwordController,
          hintText: 'Create Password',
          prefixIcon: const Icon(Icons.lock_outline),
          obscureText: !_isPasswordVisible,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: AppColors.primaryOrange,
            ),
          ),
          validator: FormValidators.validatePassword,
        ),

        const SizedBox(height: 15),

        // Confirm password field
        CustomTextField(
          controller: _confirmPasswordController,
          hintText: 'Confirm Password',
          prefixIcon: const Icon(Icons.lock_outline),
          obscureText: !_isConfirmPasswordVisible,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
            icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: AppColors.primaryOrange,
            ),
          ),
          validator: (value) => FormValidators.validatePasswordConfirmation(
              value, _passwordController.text),
        ),
      ],
    );
  }

  /// Build text field that's read-only for Google users - ENHANCED STYLING
  Widget _buildGoogleAwareTextField({
    required TextEditingController controller,
    required String hintText,
    required Widget prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isReadOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isReadOnly ? Colors.grey[300]! : AppColors.primaryOrange,
          width: 1.5, // Slightly thicker border
        ),
        borderRadius: BorderRadius.circular(8), // More rounded corners
        color: isReadOnly ? Colors.grey[50] : Colors.white,
        boxShadow: [
          if (!isReadOnly)
            BoxShadow(
              color: AppColors.primaryOrange.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: IconTheme(
              data: IconThemeData(
                color: isReadOnly ? Colors.grey[400] : AppColors.primaryOrange,
                size: 20,
              ),
              child: prefixIcon,
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: isReadOnly,
              keyboardType: keyboardType,
              validator: validator,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isReadOnly ? Colors.grey[600] : Colors.black87,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                suffixIcon: isReadOnly
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.lock_outlined,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 3: PWD verification
  Widget _buildStep3Content() {
    return Form(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          Text(
            'PWD Verification',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryTeal,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          Text(
            'Final step: Please provide your PWD ID details for verification through the DOH database.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 25),

          // PWD ID Number
          CustomTextField(
            controller: _pwdIdController,
            hintText: 'PWD ID Number',
            prefixIcon: const Icon(Icons.badge_outlined),
            validator: FormValidators.validatePwdId,
          ),

          const SizedBox(height: 15),

          // PWD ID Issued Date with picker button
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _pwdIssuedDateController,
                  hintText: 'Date Issued (YYYY-MM-DD)',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  validator: (value) => FormValidators.validateDate(
                      value, 'date your PWD ID was issued'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: _selectIssuedDate,
                icon: const Icon(
                  Icons.calendar_month,
                  color: AppColors.primaryOrange,
                  size: 28,
                ),
                tooltip: 'Select Date',
              ),
            ],
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

          // Form buttons
          _buildStep3Buttons(),
        ],
      ),
    );
  }

  /// Disability type dropdown - ENHANCED STYLING
  Widget _buildDisabilityDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primaryOrange,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: const Icon(
              Icons.accessibility_outlined,
              color: AppColors.primaryOrange,
              size: 20,
            ),
          ),
          Expanded(
            child: _isLoadingDisabilityTypes
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryOrange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Loading...',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : _disabilityTypesError != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Error loading options',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: Colors.red[600],
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextButton(
                              onPressed: _fetchDisabilityTypes,
                              child: Text(
                                'Retry',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDisabilityType,
                          hint: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 8),
                            child: Text(
                              'Select Type of Disability',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          isExpanded: true,
                          items: _disabilityTypes.map((disability) {
                            return DropdownMenuItem<String>(
                              value: disability['id'].toString(),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  disability['name']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDisabilityType = value;
                            });
                          },
                          icon: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  /// LGU dropdown
  Widget _buildLGUDropdown() {
    // Philippine LGUs in Cavite (matches your web PHP list)
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
            child: const Icon(
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
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: _isVerifying ? 'Verifying...' : 'Verify PWD ID',
        onPressed: _isVerifying ? null : _handleVerifyPwdId,
        type: CustomButtonType.secondary,
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

  /// Step 2 form buttons
  Widget _buildStep2Buttons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Back',
            onPressed: () => _goToStep(1),
            type: CustomButtonType.secondary,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: CustomButton(
            text: 'Continue',
            onPressed: _handleStep2Continue,
            type: CustomButtonType.primary,
          ),
        ),
      ],
    );
  }

  /// Step 3 form buttons
  Widget _buildStep3Buttons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Back',
            onPressed: () => _goToStep(2),
            type: CustomButtonType.secondary,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: CustomButton(
            text: _isLoading ? 'Processing...' : 'Complete Sign Up',
            onPressed: (_isLoading || !_canCompleteSignup())
                ? null
                : _handleCompleteSignUp,
            type: CustomButtonType.primary,
          ),
        ),
      ],
    );
  }

  /// Divider with "OR" text
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'OR',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: Colors.grey[300])),
      ],
    );
  }

  // ===========================================
  // EVENT HANDLERS WITH API INTEGRATION
  // ===========================================

  /// Navigate to specific step
  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  /// Handle Google sign up with actual OAuth implementation
  void _handleGoogleSignUp() async {
    setState(() {
      _isGoogleSignInLoading = true;
    });

    try {
      // Configure Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '83628564105-ebo9ng5modqfhkgepbm55rkv92d669l9.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled sign-in
        setState(() {
          _isGoogleSignInLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google sign-up was cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      // First, check if user already exists
      final checkResult = await ApiService.googleSignIn(
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
        action: 'login', // Check if existing user
      );

      setState(() {
        _isGoogleSignInLoading = false;
      });

      if (checkResult['success']) {
        final data = checkResult['data'];

        if (data['requires_profile_completion'] == true) {
          // New Google user - proceed to complete profile in Step 2
          final googleUserInfo = data['google_user_info'];

          setState(() {
            _isGoogleUser = true;
            _googleUserData = googleUserInfo;
            _googleIdToken = googleAuth.idToken; // ← ADD THIS LINE

            // Pre-fill form fields
            _firstNameController.text = googleUserInfo['first_name'] ?? '';
            _lastNameController.text = googleUserInfo['last_name'] ?? '';
            _emailController.text = googleUserInfo['email'] ?? '';
          });

          // Show success message and proceed to Step 2
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Welcome ${googleUserInfo['first_name']}! Please complete your profile.'),
              backgroundColor: Colors.green,
            ),
          );

          // Go to Step 2 to complete profile
          _goToStep(2);
        } else {
          // Existing Google user - redirect to login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Account already exists. Please use the login page.'),
              backgroundColor: Colors.blue,
            ),
          );

          // Sign out and redirect to login
          await googleSignIn.signOut();
          AppRoutes.goToCandidateLogin(context);
        }
      } else {
        // Error in Google authentication
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-up failed: ${checkResult['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGoogleSignInLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-up error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handle step 2 continue with Google user support
  void _handleStep2Continue() {
    if (_step2FormKey.currentState!.validate()) {
      if (_selectedDisabilityType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your disability type'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // For Google users, skip password validation
      if (!_isGoogleUser) {
        // Validate password fields for non-Google users
        if (_passwordController.text.isEmpty ||
            _confirmPasswordController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter and confirm your password'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (_passwordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Passwords do not match'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // All validation passed, proceed to Step 3
      _goToStep(3);
    }
  }

  /// Handle PWD ID verification with API integration
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
      _verificationMessage = 'Connecting to DOH database for verification...';
      _verificationStatus = null;
    });

    try {
      // Call PWD verification API
      final result = await ApiService.verifyPwdId(
        pwdIdNumber: _pwdIdController.text.trim(),
        pwdIdIssuedDate: _pwdIssuedDateController.text.trim(),
        pwdIdIssuingLGU: _selectedIssuingLGU!,
      );

      setState(() {
        _isVerifying = false;
      });

      if (result['success']) {
        final data = result['data'];

        if (data['verified'] == true) {
          // Successful verification
          setState(() {
            _verificationStatus = 'success';
            _verificationMessage = result['message'];
            _verificationComplete = true;
          });
        } else if (data['status'] == 'service_unavailable') {
          // Service unavailable - allow manual verification
          setState(() {
            _verificationStatus = 'warning';
            _verificationMessage = result['message'];
            _verificationComplete =
                false; // Can proceed but need manual verification
          });
        } else {
          // Verification failed
          setState(() {
            _verificationStatus = 'error';
            _verificationMessage = result['message'];
            _verificationComplete = false;
          });
        }
      } else {
        // API call failed
        setState(() {
          _verificationStatus = 'error';
          _verificationMessage = result['message'];
          _verificationComplete = false;
        });
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _verificationStatus = 'error';
        _verificationMessage =
            'Connection error: Please check your internet connection';
        _verificationComplete = false;
      });
    }
  }

  /// Handle complete sign up with API integration
  void _handleCompleteSignUp() async {
    if (!_step3FormKey.currentState!.validate()) {
      return;
    }

    // Validate required fields
    if (_selectedDisabilityType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your disability type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedIssuingLGU == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the issuing LGU'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate Google token if Google user
      if (_isGoogleUser &&
          (_googleIdToken == null || _googleIdToken!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Google authentication expired. Please sign up again.'),
            backgroundColor: Colors.red,
          ),
        );
        _goToStep(1); // Go back to Step 1
        return;
      }

      // Call appropriate signup API
      Map<String, dynamic> result;

      if (_isGoogleUser) {
        // Google user - complete profile
        result = await ApiService.googleSignIn(
          idToken: _googleIdToken!,
          action: 'complete_profile',
          additionalData: {
            'phone': _phoneController.text.trim(),
            'disability': int.parse(_selectedDisabilityType!),
            'pwdIdNumber': _pwdIdController.text.trim(),
            'pwdIdIssuedDate': _pwdIssuedDateController.text.trim(),
            'pwdIdIssuingLGU': _selectedIssuingLGU!,
          },
        );
      } else {
        // Regular user - normal signup
        result = await ApiService.signup(
          firstName: _firstNameController.text.trim(),
          middleName: _middleNameController.text.trim().isEmpty
              ? null
              : _middleNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          suffix: _suffixController.text.trim().isEmpty
              ? null
              : _suffixController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
          confirmPassword: _confirmPasswordController.text.trim(),
          disability: int.parse(_selectedDisabilityType!),
          pwdIdNumber: _pwdIdController.text.trim(),
          pwdIdIssuedDate: _pwdIssuedDateController.text.trim(),
          pwdIdIssuingLGU: _selectedIssuingLGU!,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );

        // Show success dialog with next steps
        _showSignupSuccessDialog(result['data']);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );

        // If validation errors, show them
        if (result['errors'] != null) {
          _showValidationErrors(result['errors']);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed: Please check your connection'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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

  /// Check if sign up can be completed (Phase 1: no file required)
  bool _canCompleteSignup() {
    // For Phase 1, allow completion after verification attempt
    return _verificationComplete ||
        _verificationStatus == 'success' ||
        _verificationStatus == 'warning' ||
        _verificationStatus == 'error';
  }

  // ===========================================
  // HELPER METHODS FOR API RESPONSES
  // ===========================================

  void _showSignupSuccessDialog(Map<String, dynamic> data) {
    final user = data['user'];
    final nextStep = data['next_step'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('Welcome to ThisAble!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello ${user['first_name']}!'),
            const SizedBox(height: 10),
            const Text('Your account has been created successfully.'),
            const SizedBox(height: 10),
            if (nextStep == 'pwd_verification')
              const Text('Next: Verify your PWD ID to access all features.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (nextStep == 'pwd_verification') {
                _showPwdVerificationDialog();
              } else {
                // Navigate to login or appropriate screen
                AppRoutes.goToCandidateLogin(context);
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showPwdVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PWD Verification'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_user, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('Your PWD ID verification is pending.'),
            SizedBox(height: 8),
            Text('You can login and complete the verification process later.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppRoutes.goToCandidateLogin(context);
            },
            child: const Text('Login Now'),
          ),
        ],
      ),
    );
  }

  void _showValidationErrors(Map<String, dynamic> errors) {
    final errorMessages = <String>[];
    errors.forEach((field, message) {
      errorMessages.add('$field: $message');
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Errors'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errorMessages.map((error) => Text('• $error')).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
