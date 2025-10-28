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
import 'package:flutter/foundation.dart'; // ✅ ADDED: For kIsWeb

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config/api_endpoints.dart';
import '../../../../config/dynamic_api_config.dart';

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
          // Your actual PNG logo
          Image.asset(
            'assets/images/thisablelogo.png',
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
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

  /// ✅ ENHANCED: Handle Google Sign-In with comprehensive debugging
  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔧 ═══════════════════════════════════════════════════');
      print('🔧 STARTING GOOGLE SIGN-IN WITH ENHANCED DEBUGGING');
      print('🔧 ═══════════════════════════════════════════════════');

      // ✅ STEP 1: Verify Platform Detection
      print('🔧 STEP 1: Platform Detection');
      print('  📱 kIsWeb (Flutter constant): ${kIsWeb}');
      print('  📱 PlatformUtils.isWeb: ${PlatformUtils.isWeb}');
      print('  📱 PlatformUtils.isMobile: ${PlatformUtils.isMobile}');
      print('  📱 PlatformUtils.platformName: ${PlatformUtils.platformName}');
      print(
          '  📱 Expected Service: ${kIsWeb ? "WEB SERVICE" : "MOBILE SERVICE"}');

      // ✅ STEP 2: Initialize Controller
      print('🔧 STEP 2: Controller Initialization');
      final controller = GoogleSignInController.instance;

      // Get controller info BEFORE initialization
      print('  📊 Controller Info (BEFORE init): ${controller.platformInfo}');

      await controller.initialize();

      // Get controller info AFTER initialization
      print('  📊 Controller Info (AFTER init): ${controller.platformInfo}');

      // ✅ STEP 3: Perform Sign-In
      print('🔧 STEP 3: Performing Sign-In');
      final result = await controller.signIn();

      print('  ✅ Sign-In Result:');
      print('    - Success: ${result.success}');
      print('    - Platform Used: ${result.platformUsed}');
      print('    - Account Email: ${result.account?.email ?? 'N/A'}');
      print('    - Has idToken: ${result.authentication?.idToken != null}');
      print(
          '    - Has accessToken: ${result.authentication?.accessToken != null}');

      if (result.success &&
          result.account != null &&
          result.authentication != null) {
        final idToken = result.authentication!.idToken;
        final accessToken = result.authentication!.accessToken;

        // ✅ STEP 4: Validate Tokens
        print('🔧 STEP 4: Token Validation');
        final hasValidIdToken = idToken != null && idToken.trim().isNotEmpty;
        final hasValidAccessToken =
            accessToken != null && accessToken.trim().isNotEmpty;

        print('  🔑 Token Status:');
        print('    - Valid idToken: $hasValidIdToken');
        print('    - Valid accessToken: $hasValidAccessToken');

        if (!hasValidIdToken && !hasValidAccessToken) {
          throw Exception(
              'No valid authentication tokens received from Google');
        }

        // ✅ STEP 5: Call Backend API
        print('🔧 STEP 5: Calling Backend API');
        final apiResult = await ApiService.googleSignIn(
          idToken: hasValidIdToken ? idToken! : '',
          accessToken: hasValidAccessToken ? accessToken! : '',
        );

        print('  📡 API Response:');
        print('    - Success: ${apiResult['success']}');
        print('    - Message: ${apiResult['message'] ?? 'N/A'}');

        setState(() {
          _isLoading = false;
        });

        if (apiResult['success'] == true) {
          final data = apiResult['data'];

          // ✅ STEP 6: Check if New User
          print('🔧 STEP 6: User Type Detection');
          if (data['is_new_user'] == true) {
            // NEW USER - Redirect to signup with Google data
            print('  🆕 NEW USER DETECTED - Redirecting to signup');

            final googleData = data['google_data'];

            if (mounted) {
              // Show message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Welcome! Please complete your registration with PWD ID details.',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 3),
                ),
              );

              // Navigate to signup with Google data
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.candidateSignup,
                arguments: {
                  'google_data': googleData,
                  'from_google': true,
                },
              );
            }
            return;
          }

          // ✅ EXISTING USER - Continue to dashboard
          print('  👤 EXISTING USER - Proceeding to dashboard');
          final user = data['user'];
          final setupComplete = user['setup_complete'] == true ||
              user['setup_complete'] == 1 ||
              user['setup_complete'] == '1';

          print('  📋 Setup Complete: $setupComplete');

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
              print('  🏠 Navigating to Dashboard');
              _navigateToDashboard();
            } else {
              print('  ⚙️ Navigating to Account Setup');
              _navigateToAccountSetup();
            }
          }
        } else {
          // API returned error
          print('  ❌ API Error: ${apiResult['message']}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(apiResult['message'] ?? 'Login failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Sign-in was not successful
        setState(() {
          _isLoading = false;
        });

        print('  ❌ Sign-In Failed:');
        print('    - Error: ${result.error}');
        print('    - Type: ${result.type}');

        if (result.type != GoogleSignInControllerResultType.cancelled &&
            mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Google Sign-In failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      print('🔧 ═══════════════════════════════════════════════════');
      print('🔧 GOOGLE SIGN-IN PROCESS COMPLETE');
      print('🔧 ═══════════════════════════════════════════════════');
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });

      print('🔧 ═══════════════════════════════════════════════════');
      print('🔧 CRITICAL ERROR IN GOOGLE SIGN-IN');
      print('🔧 ═══════════════════════════════════════════════════');
      print('❌ Error: $e');
      print('❌ Error Type: ${e.runtimeType}');
      print('❌ Stack Trace:');
      print(stackTrace);
      print('🔧 ═══════════════════════════════════════════════════');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-In Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
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
// SIMPLE HTTP TEST - Add this to your login_screen.dart
// This version uses your existing imports and methods

  void _testBasicHttpCall() async {
    print('🔍 === BASIC HTTP TEST START ===');

    setState(() {
      _isLoading = true;
    });

    try {
      // Use your existing API service method to get the URL
      print('🔍 Step 1: Getting base URL...');

      // Test your basic API connectivity first
      final testUrl = 'http://localhost/ThisAble/api/test.php';
      print('🔍 Testing basic URL: $testUrl');

      try {
        final response = await http.get(
          Uri.parse(testUrl),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 10));

        print('✅ Basic test successful: ${response.statusCode}');
        print('✅ Response: ${response.body.substring(0, 100)}...');
      } catch (e) {
        print('❌ Basic test failed: $e');
        setState(() => _isLoading = false);
        return;
      }

      // Test POST to your google endpoint
      print('🔍 Step 2: Testing POST to google endpoint...');

      final googleUrl = 'http://localhost/ThisAble/api/auth/google.php';
      print('🔍 POST URL: $googleUrl');

      final testBody = {'action': 'test', 'debug': 'flutter_test'};

      print('🔍 Request body: $testBody');
      print('🔍 Making POST request...');

      try {
        final postResponse = await http
            .post(
              Uri.parse(googleUrl),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: json.encode(testBody),
            )
            .timeout(const Duration(seconds: 15));

        print('✅ POST request completed!');
        print('✅ Status: ${postResponse.statusCode}');
        print('✅ Response: ${postResponse.body}');

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ HTTP test successful!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('❌ POST request failed: $e');
        print('❌ Error type: ${e.runtimeType}');

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ HTTP test failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Test failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    print('🔍 === BASIC HTTP TEST COMPLETE ===');
  }
}
