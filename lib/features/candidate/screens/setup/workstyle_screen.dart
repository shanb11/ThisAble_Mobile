import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'jobtype_screen.dart';
import '../../../../core/services/api_service.dart';

class WorkstyleScreen extends StatefulWidget {
  const WorkstyleScreen({super.key});

  @override
  State<WorkstyleScreen> createState() => _WorkstyleScreenState();
}

class _WorkstyleScreenState extends State<WorkstyleScreen> {
  String? _selectedWorkstyle;

  final List<Map<String, dynamic>> _workstyles = [
    {
      'id': 'remote',
      'title': 'Remote Work',
      'icon': Icons.home,
      'badge': 'Flexibility',
      'description':
          'Work from anywhere with flexible scheduling and complete autonomy over your workspace.',
      'features': [
        'No commute time or costs',
        'Personalized work environment',
        'Flexible scheduling options',
      ],
    },
    {
      'id': 'hybrid',
      'title': 'Hybrid Work',
      'icon': Icons.sync_alt,
      'badge': 'Balance',
      'description':
          'Enjoy the best of both worlds with a mix of remote work and in-office collaboration.',
      'features': [
        'Balanced social interaction',
        'Partial commute reduction',
        'Structured yet flexible schedule',
      ],
    },
    {
      'id': 'onsite',
      'title': 'Onsite Work',
      'icon': Icons.business,
      'badge': 'Collaboration',
      'description':
          'Traditional office environment with face-to-face collaboration and team dynamics.',
      'features': [
        'In-person team collaboration',
        'Clear work/home separation',
        'Access to office resources',
      ],
    },
  ];

  void _selectWorkstyle(String workstyleId) {
    setState(() {
      _selectedWorkstyle = workstyleId;
    });
  }

  void _goBack() {
    Navigator.pop(context);
  }

  Future<void> _continue() async {
    if (_selectedWorkstyle == null) return;

    print('🔧 WORKSTYLE: Starting _continue process...');

    try {
      // ENHANCED DEBUG: Check everything before making API call
      print('🔧 WORKSTYLE: Step 1 - Checking authentication status...');
      final isAuth = await ApiService.isAuthenticated();
      print('🔧 WORKSTYLE: Is authenticated: $isAuth');

      print('🔧 WORKSTYLE: Step 2 - Getting current token...');
      final currentToken = await ApiService.getToken();
      print('🔧 WORKSTYLE: Current token exists: ${currentToken != null}');
      print('🔧 WORKSTYLE: Token length: ${currentToken?.length ?? 0}');
      print(
          '🔧 WORKSTYLE: Token preview: ${currentToken?.substring(0, 20) ?? "null"}...');

      print('🔧 WORKSTYLE: Step 3 - Getting current user...');
      final currentUser = await ApiService.getCurrentUser();
      print(
          '🔧 WORKSTYLE: Current user: ${currentUser != null ? currentUser['first_name'] : 'null'}');

      // If no token, navigate back to login
      if (currentToken == null || currentToken.isEmpty) {
        print('🔧 WORKSTYLE: ERROR - No token found, redirecting to login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        // Navigate to login
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/candidate/login',
          (route) => false,
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      print('🔧 WORKSTYLE: Step 4 - Making API call to saveWorkstyle...');
      print('🔧 WORKSTYLE: Selected workstyle: $_selectedWorkstyle');

      // ✅ NEW: Use specific saveWorkstyle API instead of general saveSetupData
      final response = await ApiService.saveWorkstyle(_selectedWorkstyle!);

      print('🔧 WORKSTYLE: Step 5 - API response received');
      print('🔧 WORKSTYLE: Response success: ${response['success']}');
      print('🔧 WORKSTYLE: Response message: ${response['message']}');
      print('🔧 WORKSTYLE: Full response: $response');

      // Hide loading
      Navigator.pop(context);

      if (response['success']) {
        print('🔧 WORKSTYLE: SUCCESS - Navigating to next screen');
        // Navigate to next screen (Job Type Selection)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const JobtypeScreen(),
          ),
        );
      } else {
        print('🔧 WORKSTYLE: FAILURE - Showing error message');
        // Check if it's an authentication error
        if (response['message'] != null &&
            (response['message'].contains('token') ||
                response['message'].contains('unauthorized') ||
                response['message'].contains('authentication'))) {
          // Clear stored data and redirect to login
          await ApiService.clearAllData();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/candidate/login',
            (route) => false,
          );
        } else {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to save work style'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('🔧 WORKSTYLE: EXCEPTION CAUGHT: $e');
      print('🔧 WORKSTYLE: Exception type: ${e.runtimeType}');

      // Hide loading if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildWorkstyleCard(Map<String, dynamic> workstyle) {
    bool isSelected = _selectedWorkstyle == workstyle['id'];

    return GestureDetector(
      onTap: () => _selectWorkstyle(workstyle['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 280,
        margin: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header with image and badge
            Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  // Background gradient
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryLight,
                          AppColors.primary.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Icon(
                      workstyle['icon'],
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),

                  // Badge
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        workstyle['badge'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Selection indicator
                  if (isSelected)
                    Positioned(
                      top: -10,
                      right: -10,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with icon
                  Row(
                    children: [
                      Icon(
                        workstyle['icon'],
                        size: 24,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          workstyle['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Description
                  Text(
                    workstyle['description'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Features list
                  ...(workstyle['features'] as List<String>)
                      .map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/thisablelogo.png',
                    width: 70,
                    height: 70,
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Header text
                    Container(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: const Column(
                        children: [
                          Text(
                            'How Would You Like to Work?',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Choose the work arrangement that best matches your lifestyle and preferences.',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Progress bar (75%)
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 600),
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1E1E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.75,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Guidance box
                    Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Different work styles offer unique benefits. Consider your productivity habits, commute preferences, and social needs when making your selection.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Workstyle cards
                    Container(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Check if we should show cards horizontally or vertically
                          bool isWideScreen = constraints.maxWidth > 950;

                          if (isWideScreen) {
                            return Row(
                              children: _workstyles
                                  .map(
                                    (workstyle) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: _buildWorkstyleCard(workstyle),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          } else {
                            return Column(
                              children: _workstyles
                                  .map(
                                    (workstyle) =>
                                        _buildWorkstyleCard(workstyle),
                                  )
                                  .toList(),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            ElevatedButton.icon(
              onPressed: _goBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE1E1E1),
                foregroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Continue button
            ElevatedButton.icon(
              onPressed: _selectedWorkstyle != null ? _continue : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
