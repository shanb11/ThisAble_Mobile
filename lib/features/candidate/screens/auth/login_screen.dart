import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../config/routes.dart';
import '../../../../core/utils/form_validators.dart';
import '../../modals/forgot_password_modal.dart';
import '../../modals/selection_modal.dart';
import '../../../../core/services/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Login Screen - Mobile version of frontend/candidate/login.php
/// Exact replica of your web login page with split-screen design
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Form state
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildLoginBody(),
    );
  }

  /// Build main login body with responsive layout
  Widget _buildLoginBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen =
            constraints.maxWidth > 768; // matches your CSS breakpoint

        if (isWideScreen) {
          // Desktop/Tablet: Split screen layout (matches your CSS: display: flex)
          return Row(
            children: [
              /*// Left side - Illustration (50% width, matches .left)
              Expanded(child: _buildLeftSide()),*/

              // Right side - Login form (50% width, matches .right)
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
                  height: 300,
                  child: _buildLeftSide(),
                ),*/

                // Right side content (form section)
                Container(
                  constraints: const BoxConstraints(minHeight: 500),
                  child: _buildRightSide(),
                ),
              ],
            ),
          );
        }
      },
    );
  }

/*
  /// Left side - Illustration section (matches includes/candidate/login_left.php)
  Widget _buildLeftSide() {
    return Container(
      // Matches your CSS: .left { background-color: #257180; }
      decoration: const BoxDecoration(
        color: AppColors.secondaryTeal,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration placeholder (matches login-image.png)
              Icon(
                Icons.people_alt_outlined,
                size: 200,
                color: Colors.white.withOpacity(0.9),
              ),

              const SizedBox(height: 30),

              // Heading (matches login_left.php h2)
              Text(
                'Empowering Inclusive Employment',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              // Description (matches login_left.php p)
              Text(
                'Find job opportunities that embrace diversity and inclusivity.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
*/
  /// Right side - Login form (matches includes/candidate/login_right.php)
  Widget _buildRightSide() {
    return Container(
      // Matches your CSS: .right { background-color: #fff; }
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo (matches .logo positioning)
              _buildLogo(),

              const SizedBox(height: 40),

              // Login form (matches .login-box)
              _buildLoginForm(),
            ],
          ),
        ),
      ),
    );
  }

  /// Logo section (matches your logo styling)
  Widget _buildLogo() {
    return GestureDetector(
      onTap: () => Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.landingHome,
        (route) => false,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo icon
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: AppColors.primaryOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.accessibility_new,
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(width: 15),

          // Logo text
          Text(
            'ThisAble',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryTeal,
            ),
          ),
        ],
      ),
    );
  }

  /// Login form section (matches .login-box)
  Widget _buildLoginForm() {
    return Container(
      width: double.infinity,
      constraints:
          const BoxConstraints(maxWidth: 400), // matches .login-box width: 60%
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title (matches .login-box h2)
            Text(
              'Welcome Back',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryTeal,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Google Sign In Button (matches .google-btn)
            _buildGoogleSignInButton(),

            const SizedBox(height: 20),

            // Divider (matches .divider)
            _buildDivider(),

            const SizedBox(height: 20),

            // Email field (matches email input-box)
            _buildEmailField(),

            const SizedBox(height: 15),

            // Password field (matches password input-box)
            _buildPasswordField(),

            const SizedBox(height: 15),

            // Forgot password link (matches .forgot)
            _buildForgotPasswordLink(),

            const SizedBox(height: 15),

            // Sign in button (matches .login-btn)
            _buildSignInButton(),

            const SizedBox(height: 20),

            // Sign up link (matches .signup)
            _buildSignUpLink(),
          ],
        ),
      ),
    );
  }

  /// Google Sign In Button (matches .google-btn styling)
  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        icon: Icon(
          Icons.g_mobiledata, // Google icon placeholder
          color: Colors.grey[600],
          size: 24,
        ),
        label: Text(
          'Sign in with Google',
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
    );
  }

  /// Divider with "OR" text (matches .divider)
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ),
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
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  /// Email input field (matches email input-box)
  Widget _buildEmailField() {
    return CustomTextField(
      controller: _emailController,
      hintText: 'Email',
      prefixIcon: const Icon(Icons.email_outlined),
      keyboardType: TextInputType.emailAddress,
      validator: FormValidators.validateEmail,
    );
  }

  /// Password input field (matches password input-box with toggle)
  Widget _buildPasswordField() {
    return CustomTextField(
      controller: _passwordController,
      hintText: 'Password',
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
      validator: (value) => FormValidators.validateRequired(value, 'password'),
    );
  }

  /// Forgot password link (matches .forgot)
  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: _showForgotPasswordModal,
        child: Text(
          'Forgot Password?',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.secondaryTeal,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  /// Sign in button (matches .login-btn)
  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: _isLoading ? 'Signing in...' : 'Sign In',
        onPressed: _isLoading ? null : _handleSignIn,
        type: CustomButtonType.primary,
      ),
    );
  }

  /// Sign up link (matches .signup)
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'New to ThisAble? ',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        GestureDetector(
          onTap: _showSelectionModal,
          child: Text(
            'Sign up',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.secondaryTeal,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================
  // EVENT HANDLERS WITH API INTEGRATION
  // ===========================================

  /// Handle regular sign in with proper navigation
  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        final data = result['data'];
        final user = data['user'];
        final setupComplete = user['setup_complete'] ?? false;

        // Show welcome message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${user['first_name']}!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate based on setup completion
        if (setupComplete) {
          _navigateToDashboard();
        } else {
          _navigateToAccountSetup();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Connection error: Please check your internet connection'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handle Google Sign-In with proper navigation
  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '83628564105-ebo9ng5modqfhkgepbm55rkv92d669l9.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      final result = await ApiService.googleSignIn(
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        final data = result['data'];

        // DEBUG: Print the entire response
        print('=== GOOGLE SIGNIN SUCCESS ===');
        print('Full response: $data');

        // CHECK IF TOKEN IS BEING SAVED
        final token = data['token'];
        print('Token from API: $token');

        // VERIFY TOKEN WAS SAVED
        await Future.delayed(Duration(milliseconds: 100)); // Wait a bit
        final savedToken = await ApiService.getToken();
        print('Token saved in storage: $savedToken');
        print('Token match: ${token == savedToken}');

        if (data['requires_profile_completion'] == true) {
          // New Google user - needs profile completion
          final googleUserInfo = data['google_user_info'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Welcome ${googleUserInfo['first_name']}! Please complete your profile.'),
              backgroundColor: Colors.green,
            ),
          );

          _navigateToAccountSetup();
        } else {
          // Existing user - check setup completion
          final user = data['user'];
          final setupComplete = user['setup_complete'] ?? false;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${user['first_name']}!'),
              backgroundColor: Colors.green,
            ),
          );

          if (setupComplete) {
            _navigateToDashboard();
          } else {
            _navigateToAccountSetup();
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Navigate to account setup
  void _navigateToAccountSetup() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.candidateAccountSetup,
      (route) => false,
    );
  }

  /// Navigate to dashboard
  void _navigateToDashboard() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.candidateDashboard,
      (route) => false,
    );
  }

  /// Show forgot password modal
  void _showForgotPasswordModal() {
    showDialog(
      context: context,
      builder: (context) => const ForgotPasswordModal(),
    );
  }

  /// Show selection modal (candidate vs employer)
  void _showSelectionModal() {
    showDialog(
      context: context,
      builder: (context) => const SelectionModal(),
    );
  }
}
