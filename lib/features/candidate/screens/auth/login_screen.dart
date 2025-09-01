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
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/services/google_signin_web_service.dart';
import '../../../../core/services/google_signin_mobile_service.dart';
import '../../../../core/services/google_signin_controller.dart';

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

/*
  @override
  void initState() {
    super.initState();

    // Test the web Google Sign-In service
    _testWebGoogleSignIn();
    _testMobileGoogleSignIn();
  }
  */

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

  /// FIXED Handle Google Sign-In - Now uses dynamic URL system
  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔧 === STARTING FIXED GOOGLE SIGN-IN ===');

      final controller = GoogleSignInController.instance;
      await controller.initialize();
      final result = await controller.signIn();

      print('🔧 Google Sign-In Result: ${result.success}');
      print('🔧 Platform: ${result.platformUsed}');

      if (result.success &&
          result.account != null &&
          result.authentication != null) {
        final idToken = result.authentication!.idToken;
        final accessToken = result.authentication!.accessToken;

        print(
            '🔧 ID Token Available: ${idToken != null && idToken.isNotEmpty}');
        print(
            '🔧 Access Token Available: ${accessToken != null && accessToken.isNotEmpty}');

        // Validate we have at least one valid token
        final hasValidIdToken = idToken != null && idToken.trim().isNotEmpty;
        final hasValidAccessToken =
            accessToken != null && accessToken.trim().isNotEmpty;

        if (!hasValidIdToken && !hasValidAccessToken) {
          throw Exception(
              'No valid authentication tokens received from Google');
        }

        // ✅ FIXED: This now uses your dynamic URL system!
        print('🔧 Calling API with dynamic URL...');
        final apiResult = await ApiService.googleSignInDebug(
          idToken: hasValidIdToken ? idToken! : '',
          accessToken: hasValidAccessToken ? accessToken! : '',
        );

        print('🔧 API Result Success: ${apiResult['success']}');

        if (apiResult['success'] == false) {
          print('🔧 API Error: ${apiResult['message']}');
        }

        setState(() {
          _isLoading = false;
        });

        if (apiResult['success'] == true) {
          final user = apiResult['user'];
          final setupComplete = apiResult['setup_complete'] ?? false;

          // Store user data
          await ApiService.setCurrentUser(user);

          // Show welcome message
          if (mounted) {
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
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(apiResult['message'] ?? 'Google Sign-In failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Sign-In was cancelled or failed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      print('🔧 Google Sign-In Error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    print('🔧 === GOOGLE SIGN-IN COMPLETE ===');
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
// test codes
/*
  // ADD THESE TEST METHODS TO YOUR _LoginScreenState CLASS
  // (Add them at the end of the class, before the final closing brace)

  /// Test method for web Google Sign-In service initialization
  void _testWebGoogleSignIn() async {
    // Only test on web platform
    if (!PlatformUtils.isWeb) {
      print('⚠️ Skipping web Google Sign-In test - not on web platform');
      return;
    }

    try {
      print('\n🔧 TESTING WEB GOOGLE SIGN-IN SERVICE 🔧');

      // Get the web service instance
      final webService = GoogleSignInWebService.instance;

      // Initialize the service
      print('🔄 Initializing web service...');
      await webService.initialize();
      print('✅ Web service initialized');

      // Check current state
      print('📊 Current state:');
      print('  - Is signed in: ${webService.isSignedIn}');
      print('  - Current user: ${webService.currentUser?.email ?? 'None'}');

      print('🔧 WEB GOOGLE SIGN-IN SERVICE TEST COMPLETE 🔧\n');
    } catch (e) {
      print('❌ Web service test failed: $e');
    }
  }

  /// Test method for full sign-in flow (optional - for later testing)
  void _testWebSignInFlow() async {
    if (!PlatformUtils.isWeb) {
      print('⚠️ Web sign-in test only available on web platform');
      return;
    }

    try {
      print('\n🚀 TESTING WEB SIGN-IN FLOW 🚀');

      final webService = GoogleSignInWebService.instance;

      // Attempt sign-in
      final result = await webService.signIn();

      print('📊 Sign-in result:');
      print('  - Success: ${result.success}');
      print('  - Type: ${result.type}');
      print('  - Account: ${result.account?.email ?? 'None'}');
      print('  - Has idToken: ${result.authentication?.idToken != null}');
      print(
          '  - Has accessToken: ${result.authentication?.accessToken != null}');

      if (result.success && result.authentication?.idToken != null) {
        print('✅ SUCCESS: Web Google Sign-In completed with idToken!');
        print(
            '🔑 idToken preview: ${result.authentication!.idToken!.substring(0, 50)}...');
      } else {
        print('❌ FAILED: ${result.error ?? 'Unknown error'}');
      }

      print('🚀 WEB SIGN-IN FLOW TEST COMPLETE 🚀\n');
    } catch (e) {
      print('❌ Web sign-in flow test failed: $e');
    }
  }

  // Add this method to your LoginScreen class for testing
  void _testMobileGoogleSignIn() async {
    try {
      print('\n📱 TESTING MOBILE GOOGLE SIGN-IN SERVICE 📱');

      // Get the mobile service instance
      final mobileService = GoogleSignInMobileService.instance;

      // Initialize the service
      print('🔄 Initializing mobile service...');
      await mobileService.initialize();
      print('✅ Mobile service initialized');

      // Check current state
      print('📊 Current state:');
      print('  - Platform: ${PlatformUtils.platformName}');
      print('  - Is mobile platform: ${PlatformUtils.isMobile}');
      print('  - Is signed in: ${mobileService.isSignedIn}');
      print('  - Current user: ${mobileService.currentUser?.email ?? 'None'}');

      print('📱 MOBILE GOOGLE SIGN-IN SERVICE TEST COMPLETE 📱\n');
    } catch (e) {
      print('❌ Mobile service test failed: $e');
    }
  }

// Add this to test actual mobile sign-in (call this from a button press)
  void _testMobileSignInFlow() async {
    try {
      print('\n🚀 TESTING MOBILE SIGN-IN FLOW 🚀');

      final mobileService = GoogleSignInMobileService.instance;

      // Attempt sign-in
      final result = await mobileService.signIn();

      print('📊 Mobile sign-in result:');
      print('  - Success: ${result.success}');
      print('  - Type: ${result.type}');
      print('  - Account: ${result.account?.email ?? 'None'}');
      print('  - Has idToken: ${result.authentication?.idToken != null}');
      print(
          '  - Has accessToken: ${result.authentication?.accessToken != null}');

      if (result.success && result.authentication?.idToken != null) {
        print('✅ SUCCESS: Mobile Google Sign-In completed with idToken!');
        print(
            '🔑 idToken preview: ${result.authentication!.idToken!.substring(0, 50)}...');
      } else {
        print('❌ FAILED: ${result.error ?? 'Unknown error'}');
      }

      print('🚀 MOBILE SIGN-IN FLOW TEST COMPLETE 🚀\n');
    } catch (e) {
      print('❌ Mobile sign-in flow test failed: $e');
    }
  }
  */
}
