import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/services/api_service.dart';
import '../../widgets/work_preferences_bottom_sheet.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../../widgets/resume_viewer_screen.dart';
import '../../widgets/profile_info_item.dart';
import '../../widgets/personal_information_section.dart';
import '../../widgets/personal_info_edit_form.dart';
import '../../widgets/bio_section.dart';

class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({super.key});

  @override
  _CandidateProfileScreenState createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _profileCompletionController;
  late Animation<double> _profileCompletionAnimation;

  // ThisAble Colors
  static const Color primaryColor = Color(0xFF257180);
  static const Color secondaryColor = Color(0xFFF2E5BF);
  static const Color accentColor = Color(0xFFFD8B51);
  static const Color sidebarColor = Color(0xFF2F8A99);

  // Edit States
  bool _isEditingPersonal = false;
  bool _isEditingBio = false;

  // Loading States
  bool _isLoadingProfile = true;
  bool _isUpdatingProfile = false;

  // Data from API
  Map<String, dynamic> _profileData = {};
  List<dynamic> _educationList = [];
  List<dynamic> _experienceList = [];
  List<dynamic> _skillsList = [];
  List<dynamic> _accommodationsList = [];
  String _resumeUrl = '';
  int _profileCompletion = 0;

  String? _resumeName;
  int? _resumeId;
  int? _resumeSize;
  String? _resumeUploadDate;

  // Text Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _suffixController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();

  Map<String, dynamic> _workPreferences = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProfileDataWithTimeout();
  }

  void _initializeAnimations() {
    _profileCompletionController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // FIXED: Simple animation without problematic intervals
    _profileCompletionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _profileCompletionController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _profileCompletionController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();

    _middleNameController.dispose();
    _suffixController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      print('🔧 [Profile] ===== LOADING PROFILE DATA =====');
      print('🔧 [Profile] Calling ApiService.getProfileData()...');

      final response = await ApiService.getProfileData();

      print('🔧 [Profile] Response received');
      print('🔧 [Profile] Success: ${response['success']}');
      print('🔧 [Profile] Message: ${response['message']}');

      if (response['success'] == true && mounted) {
        final data = response['data'];

        print('🔧 [Profile] ✅ SUCCESS - Processing data...');

        setState(() {
          // FIXED: Map API response structure to mobile app structure
          final personalInfo = data['personal_info'] ?? {};
          _profileData = {
            'first_name': personalInfo['first_name'] ?? '',
            'middle_name': personalInfo['middle_name'] ?? '', // ADD
            'last_name': personalInfo['last_name'] ?? '',
            'suffix': personalInfo['suffix'] ?? '', // ADD
            'email': personalInfo['email'] ?? '',
            'phone': personalInfo['contact_number'] ?? '',
            'city': personalInfo['city'] ?? '', // ADD
            'province': personalInfo['province'] ?? '', // ADD
            'location': personalInfo['preferred_location'] ?? '',
            'bio': personalInfo['bio'] ?? '',
            'profile_photo': personalInfo['profile_photo_path'],
            'pwd_id': personalInfo['pwd_id_number'] ?? '',
            'disability_type': personalInfo['disability_name'] ?? '',
          };

          _educationList = data['education'] ?? [];
          _experienceList = data['experience'] ?? [];

          // FIXED: Handle categorized skills from API
          var skillsData = data['skills'] ?? [];
          if (skillsData is List) {
            _skillsList = [];
            for (var category in skillsData) {
              if (category['skills'] != null) {
                _skillsList.addAll(category['skills']);
              }
            }
          } else {
            _skillsList = [];
          }

          _accommodationsList = data['accessibility_needs'] ?? [];
          _profileCompletion = data['profile_completion'] ?? 0;

          print('🔧 [Profile] Profile completion: $_profileCompletion%');

          // Handle resume data
          final resumes = data['resumes'] ?? [];
          if (resumes.isNotEmpty) {
            final resume = resumes[0];
            _resumeUrl = resume['file_path'] ?? '';
            _resumeName = resume['file_name'] ?? 'Resume';
            _resumeId = resume['resume_id'];
            _resumeSize = resume['file_size'];
            _resumeUploadDate = resume['upload_date'];

            print('🔧 [Profile] Resume loaded: $_resumeName');
          }

          _workPreferences = data['work_preferences'] ??
              {
                'work_style': null,
                'job_type': null,
                'salary_range': null,
                'availability': null,
              };
          print('🔧 [Profile] Work preferences loaded: $_workPreferences');

          // Populate text controllers
          _populateControllers();

          // FIXED: Safe animation trigger with proper cleanup
          if (mounted) {
            // Stop any existing animation
            _profileCompletionController.reset();

            // Create new animation with actual completion percentage
            _profileCompletionAnimation = Tween<double>(
              begin: 0.0,
              end: (_profileCompletion / 100.0).clamp(0.0, 1.0),
            ).animate(CurvedAnimation(
              parent: _profileCompletionController,
              curve: Curves.easeInOut,
            ));

            // Start animation with delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && !_profileCompletionController.isAnimating) {
                _profileCompletionController.forward();
              }
            });
          }

          // ✅ CRITICAL FIX: Set loading to false on SUCCESS
          _isLoadingProfile = false;
        });

        print('🔧 [Profile] ✅ Profile loaded successfully!');
      } else {
        // ✅ CRITICAL FIX: Handle API failure (not an exception)
        print('🔧 [Profile] ❌ API FAILED');
        print('🔧 [Profile] Error message: ${response['message']}');

        if (mounted) {
          setState(() => _isLoadingProfile = false);

          final errorMsg = response['message'] ?? 'Failed to load profile data';

          // Check if it's an authentication error
          if (response['requiresLogin'] == true ||
              errorMsg.toLowerCase().contains('token') ||
              errorMsg.toLowerCase().contains('unauthorized') ||
              errorMsg.toLowerCase().contains('authentication')) {
            print(
                '🔧 [Profile] Authentication error detected - redirecting to login');

            _showErrorSnackBar('Session expired. Please login again.');

            // Navigate to login after short delay
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/candidate/login');
              }
            });
          } else {
            _showErrorSnackBar(errorMsg);
          }
        }
      }
    } catch (e, stackTrace) {
      print('🔧 [Profile] ❌ EXCEPTION CAUGHT');
      print('🔧 [Profile] Exception: $e');
      print('🔧 [Profile] Stack trace: $stackTrace');

      if (mounted) {
        setState(() => _isLoadingProfile = false);
        _showErrorSnackBar(
            'Network error. Please check your connection and try again.');
      }
    }
  }

  Future<void> _loadProfileDataWithTimeout() async {
    print('🔧 [Profile] Starting load with 20-second safety timeout');

    // Set a safety timeout (fallback if API hangs)
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted && _isLoadingProfile) {
        print(
            '🔧 [Profile] ⚠️ SAFETY TIMEOUT REACHED - Stopping loading indicator');
        setState(() => _isLoadingProfile = false);
        _showErrorSnackBar('Loading is taking too long. Please try again.');
      }
    });

    // Call actual load method
    await _loadProfileData();
  }

  void _populateControllers() {
    _firstNameController.text = (_profileData['first_name'] ?? '').toString();
    _middleNameController.text =
        (_profileData['middle_name'] ?? '').toString(); // ADD
    _lastNameController.text = (_profileData['last_name'] ?? '').toString();
    _suffixController.text = (_profileData['suffix'] ?? '').toString(); // ADD
    _emailController.text = (_profileData['email'] ?? '').toString();
    _phoneController.text = (_profileData['phone'] ?? '').toString();
    _cityController.text = (_profileData['city'] ?? '').toString(); // ADD
    _provinceController.text =
        (_profileData['province'] ?? '').toString(); // ADD
    _locationController.text = (_profileData['location'] ?? '').toString();
    _bioController.text = (_profileData['bio'] ?? '').toString();
  }

  Future<void> _updatePersonalInfo() async {
    setState(() => _isUpdatingProfile = true);

    try {
      print('🔧 [Profile] Updating personal info...');

      // FIXED: Prepare data for API
      final profileData = {
        'first_name': _firstNameController.text.trim(),
        'middle_name': _middleNameController.text.trim(), // ADD
        'last_name': _lastNameController.text.trim(),
        'suffix': _suffixController.text.trim(), // ADD
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(), // ADD
        'province': _provinceController.text.trim(), // ADD
        'location': _locationController.text.trim(),
        'bio': _bioController.text.trim(),
        'section': 'personal_info',
      };

      print('🔧 [Profile] Sending data: ${profileData.toString()}');

      final response = await ApiService.updateProfile(profileData);

      print('🔧 [Profile] API Response: ${response.toString()}');

      if (response['success']) {
        // FIXED: Update local data immediately
        setState(() {
          _profileData['first_name'] = _firstNameController.text.trim();
          _profileData['middle_name'] =
              _middleNameController.text.trim(); // ADD
          _profileData['last_name'] = _lastNameController.text.trim();
          _profileData['suffix'] = _suffixController.text.trim(); // ADD
          _profileData['email'] = _emailController.text.trim();
          _profileData['phone'] = _phoneController.text.trim();
          _profileData['city'] = _cityController.text.trim(); // ADD
          _profileData['province'] = _provinceController.text.trim(); // ADD
          _profileData['location'] = _locationController.text.trim();
          _profileData['bio'] = _bioController.text.trim();

          _isEditingPersonal = false;
          _isEditingBio = false;
        });

        _showSuccessSnackBar('Profile updated successfully! 🎉');

        // FIXED: Reload profile data to get updated completion percentage
        await _loadProfileData();
      } else {
        // FIXED: Better error handling
        final errorMessage = response['message'] ?? 'Failed to update profile';
        print('🔧 [Profile] Error: $errorMessage');
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      print('🔧 [Profile] Exception: $e');
      _showErrorSnackBar('Network error: Failed to update profile');
    } finally {
      if (mounted) {
        setState(() => _isUpdatingProfile = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(
        backgroundColor: Colors.grey,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _loadProfileData,
        child: CustomScrollView(
          slivers: [
            _buildProfileHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 16),
                    _buildBioSection(),
                    const SizedBox(height: 16),
                    _buildSkillsSection(),
                    const SizedBox(height: 16),
                    _buildEducationSection(),
                    const SizedBox(height: 16),
                    _buildExperienceSection(),
                    const SizedBox(height: 16),
                    _buildAccessibilitySection(),
                    const SizedBox(height: 16),
                    _buildResumeSection(),
                    const SizedBox(height: 16),
                    _buildWorkPreferencesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1️⃣ COVER PHOTO SECTION (matches web .profile-cover)
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover photo with gradient
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    gradient: LinearGradient(
                      colors: [primaryColor, sidebarColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // Edit cover button (top-right)
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Implement cover photo edit
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cover photo editing coming soon'),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // 2️⃣ PROFILE PICTURE (overlapping cover - matches web .profile-picture)
                Positioned(
                  bottom: -75, // Overlaps cover by 75px
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 73,
                            backgroundColor: Colors.white,
                            backgroundImage: _profileData['profile_photo'] !=
                                    null
                                ? NetworkImage(_profileData['profile_photo'])
                                : null,
                            child: _profileData['profile_photo'] == null
                                ? Text(
                                    _getInitials(),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  )
                                : null,
                          ),
                        ),

                        // Camera icon overlay (bottom-right of profile photo)
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: _editProfilePhoto,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 3️⃣ WHITE SECTION BELOW (matches web .profile-info)
            const SizedBox(height: 85), // Space for overlapping profile picture

            // Profile Details (Name, Bio, Button)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Name
                  Text(
                    '${(_profileData['first_name'] ?? '').toString()} ${(_profileData['last_name'] ?? '').toString()}'
                            .trim()
                            .isEmpty
                        ? 'Name not specified'
                        : '${(_profileData['first_name'] ?? '').toString()} ${(_profileData['last_name'] ?? '').toString()}'
                            .trim(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Headline/Bio (if exists)
                  if (_profileData['bio'] != null &&
                      _profileData['bio'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _profileData['bio'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // "Edit Profile" Button (matches web button)
                  ElevatedButton.icon(
                    onPressed: () {
                      // Scroll to first editable section
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Scroll down to edit sections'),
                          backgroundColor: primaryColor,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCompletionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile Completion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              AnimatedBuilder(
                animation: _profileCompletionAnimation,
                builder: (context, child) {
                  return Text(
                    '${(_profileCompletionAnimation.value * _profileCompletion).round()}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Progress bar
          AnimatedBuilder(
            animation: _profileCompletionAnimation,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _profileCompletionAnimation.value,
                  backgroundColor:
                      const Color(0x33257180), // primaryColor with 20% opacity
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                  minHeight: 8,
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          // Completion tips section
          if (_profileCompletion < 100)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getCompletionText(),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Checklist of incomplete sections
                  _buildCompletionChecklist(),
                ],
              ),
            )
          else
            // Celebration message when 100% complete
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0x1AFD8B51), // accentColor with 10% opacity
                    const Color(0x1A257180), // primaryColor with 10% opacity
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '🎉 Congratulations! Your profile is 100% complete!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Build checklist of incomplete sections
  Widget _buildCompletionChecklist() {
    final List<Map<String, dynamic>> checklistItems = [
      {
        'section': 'Personal Information',
        'completed': _profileData['first_name'] != null &&
            _profileData['first_name'].toString().isNotEmpty,
        'weight': '20%',
      },
      {
        'section': 'Skills',
        'completed': _skillsList.isNotEmpty && _skillsList.length >= 3,
        'weight': '15%',
      },
      {
        'section': 'Work Preferences',
        'completed': _profileData['work_arrangement'] != null,
        'weight': '15%',
      },
      {
        'section': 'Accessibility Needs',
        'completed': _accommodationsList.isNotEmpty,
        'weight': '10%',
      },
      {
        'section': 'Education History',
        'completed': _educationList.isNotEmpty,
        'weight': '15%',
      },
      {
        'section': 'Work Experience',
        'completed': _experienceList.isNotEmpty,
        'weight': '15%',
      },
      {
        'section': 'Resume Upload',
        'completed': _resumeUrl.isNotEmpty,
        'weight': '10%',
      },
    ];

    return Column(
      children: checklistItems
          .where((item) => !item['completed'])
          .take(3) // Show only first 3 incomplete items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      item['completed']
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: item['completed']
                          ? Colors.green[700]
                          : Colors.grey[400],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item['section']} (${item['weight']})',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // ADD this helper method to profile_screen.dart
  String _getCompletionText() {
    if (_profileCompletion >= 80) {
      return 'Your profile looks great! 🎉';
    } else if (_profileCompletion >= 50) {
      return 'You\'re halfway there! Keep going 💪';
    } else if (_profileCompletion >= 20) {
      return 'Good start! Add more details to stand out ✨';
    } else {
      return 'Complete your profile to attract employers 🚀';
    }
  }

  Widget _buildEditablePersonalInfo() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Location',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person, color: accentColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _isUpdatingProfile
                      ? null
                      : () {
                          if (_isEditingPersonal) {
                            _updatePersonalInfo();
                          } else {
                            setState(() {
                              _isEditingPersonal = true;
                            });
                          }
                        },
                  icon: Icon(
                    _isEditingPersonal ? Icons.check : Icons.edit,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _isEditingPersonal
                ? _buildEditablePersonalInfo()
                : _buildPersonalInfoDisplay(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                // FIXED: Changed to TextFormField for validation
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name *',
                  border: const OutlineInputBorder(),
                  errorText: _firstNameController.text.trim().isEmpty
                      ? 'Required'
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name *',
                  border: const OutlineInputBorder(),
                  errorText: _lastNameController.text.trim().isEmpty
                      ? 'Required'
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
            helperText: 'Leave empty to keep current email',
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty && !value.contains('@')) {
              return 'Invalid email format';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
            helperText: 'Format: 09XXXXXXXXX',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null &&
                value.isNotEmpty &&
                !RegExp(r'^09\d{9}$').hasMatch(value)) {
              return 'Invalid Philippine phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Location',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
            helperText: 'City, Province',
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoDisplay() {
    return Column(
      children: [
        _buildInfoRow(
            Icons.person,
            'Name',
            '${_profileData['first_name'] ?? ''} ${_profileData['last_name'] ?? ''}'
                .trim()),
        _buildInfoRow(Icons.email, 'Email', _profileData['email'] ?? ''),
        _buildInfoRow(Icons.phone, 'Phone', _profileData['phone'] ?? ''),
        _buildInfoRow(
            Icons.location_on, 'Location', _profileData['location'] ?? ''),
        if (_profileData['pwd_id'] != null)
          _buildInfoRow(Icons.badge, 'PWD ID', _profileData['pwd_id']),
        if (_profileData['disability_type'] != null)
          _buildInfoRow(Icons.accessible, 'Disability Type',
              _profileData['disability_type']),
      ],
    );
  }

  Widget _buildBioSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.description, color: accentColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'About Me',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _isUpdatingProfile
                      ? null
                      : () {
                          if (_isEditingBio) {
                            _updatePersonalInfo();
                          } else {
                            setState(() {
                              _isEditingBio = true;
                            });
                          }
                        },
                  icon: Icon(
                    _isEditingBio ? Icons.check : Icons.edit,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _isEditingBio
                ? TextField(
                    controller: _bioController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Tell us about yourself...',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    _profileData['bio'] ?? 'No bio added yet.',
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkPreferencesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.work_outline, color: accentColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Work Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _editWorkPreferences,
                  icon: const Icon(Icons.edit, color: primaryColor),
                ),
              ],
            ),
          ),

          // Work Preferences Grid (matches web layout)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Row 1: Work Style & Job Type
                Row(
                  children: [
                    Expanded(
                      child: _buildPreferenceItem(
                        icon: Icons.laptop_chromebook,
                        title: 'Work Style',
                        value: _workPreferences['work_style'] != null
                            ? _capitalizeFirst(_workPreferences['work_style'])
                            : 'Not specified',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPreferenceItem(
                        icon: Icons.business_center,
                        title: 'Job Type',
                        value: _workPreferences['job_type'] != null
                            ? _formatJobType(_workPreferences['job_type'])
                            : 'Not specified',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row 2: Salary & Availability
                Row(
                  children: [
                    Expanded(
                      child: _buildPreferenceItem(
                        icon: Icons.payments,
                        title: 'Expected Salary',
                        value:
                            _workPreferences['salary_range'] ?? 'Not specified',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPreferenceItem(
                        icon: Icons.event_available,
                        title: 'Availability',
                        value:
                            _workPreferences['availability'] ?? 'Not specified',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatJobType(String jobType) {
    switch (jobType.toLowerCase()) {
      case 'fulltime':
        return 'Full-Time';
      case 'parttime':
        return 'Part-Time';
      case 'freelance':
        return 'Freelance';
      default:
        return _capitalizeFirst(jobType);
    }
  }

  void _editWorkPreferences() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: WorkPreferencesBottomSheet(
          currentPreferences: _workPreferences,
          onSaved: () {
            // Reload profile data after saving
            _loadProfileData();
          },
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.star, color: accentColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Skills',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _editSkills,
                  icon: const Icon(Icons.add, color: primaryColor),
                ),
              ],
            ),
          ),

          // Skills Content - FIXED: Now categorized!
          Padding(
            padding: const EdgeInsets.all(20),
            child: _skillsList.isEmpty
                ? const Text('No skills added yet.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildCategorizedSkills(),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategorizedSkills() {
    // Group skills by category (if not already grouped from API)
    Map<String, List<dynamic>> skillsByCategory = {};

    // Check if skills are already grouped (from new API structure)
    if (_skillsList.isNotEmpty &&
        _skillsList[0] is Map &&
        _skillsList[0].containsKey('category_name')) {
      // Skills are already grouped by API
      for (var category in _skillsList) {
        String categoryName = category['category_name'] ?? 'Uncategorized';
        List<dynamic> skills = category['skills'] ?? [];
        if (skills.isNotEmpty) {
          skillsByCategory[categoryName] = skills;
        }
      }
    } else {
      // Fallback: Group skills manually if API doesn't group them
      for (var skill in _skillsList) {
        String categoryName = skill['category_name'] ?? 'Uncategorized';
        if (!skillsByCategory.containsKey(categoryName)) {
          skillsByCategory[categoryName] = [];
        }
        skillsByCategory[categoryName]!.add(skill);
      }
    }

    // Build UI for each category
    List<Widget> categoryWidgets = [];

    for (var entry in skillsByCategory.entries) {
      String categoryName = entry.key;
      List<dynamic> skills = entry.value;

      if (skills.isNotEmpty) {
        categoryWidgets.add(_buildSkillCategory(categoryName, skills));

        // Add spacing between categories (except last one)
        if (entry != skillsByCategory.entries.last) {
          categoryWidgets.add(const SizedBox(height: 20));
        }
      }
    }

    return categoryWidgets;
  }

  Widget _buildSkillCategory(String categoryName, List<dynamic> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Title - matches web design
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            categoryName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryColor,
              height: 1.2,
            ),
          ),
        ),

        // Skills in this category - wrapped like web version
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            return _buildSkillChip(skill);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillChip(dynamic skill) {
    String skillName = '';

    // Handle both possible skill data structures
    if (skill is Map) {
      skillName = skill['skill_name'] ?? skill['name'] ?? skill.toString();
    } else {
      skillName = skill.toString();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // FIXED: Matches web styling more closely
        color: const Color(0xFFF8F9FA), // Light gray background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        skillName,
        style: const TextStyle(
          color: primaryColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.school, color: accentColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Education',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _addEducation,
                  icon: const Icon(Icons.add, color: primaryColor),
                ),
              ],
            ),
          ),

          // Education Content - FIXED: No more boxes!
          _educationList.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No education added yet.'),
                )
              : Column(
                  children: _educationList.map((education) {
                    return _buildEducationItem(education);
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.work, color: accentColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Experience',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _addExperience,
                  icon: const Icon(Icons.add, color: primaryColor),
                ),
              ],
            ),
          ),
          _experienceList.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No experience added yet.'),
                )
              : Column(
                  children: _experienceList.map((experience) {
                    return _buildExperienceItem(experience);
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.accessible, color: accentColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Accessibility Needs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _editAccessibility,
                  icon: const Icon(Icons.edit, color: primaryColor),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _accommodationsList.isEmpty
                ? const Text('No accessibility needs specified.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _accommodationsList.map((accommodation) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green[600], size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                accommodation.toString(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.description, color: accentColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Resume',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _uploadResume,
                  icon: const Icon(Icons.upload_file, color: primaryColor),
                  tooltip:
                      _resumeUrl.isEmpty ? 'Upload Resume' : 'Replace Resume',
                ),
              ],
            ),
          ),

          // Resume Content
          Padding(
            padding: const EdgeInsets.all(20),
            child:
                _resumeUrl.isEmpty ? _buildNoResumeState() : _buildResumeCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResumeState() {
    return Column(
      children: [
        Icon(
          Icons.upload_file,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 12),
        Text(
          'No resume uploaded yet',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _uploadResume,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Upload Resume',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResumeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Resume Info Row
          Row(
            children: [
              // PDF Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),

              // Resume Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _resumeName ?? 'Resume.pdf',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (_resumeSize != null) ...[
                      Text(
                        _formatFileSize(_resumeSize!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (_resumeUploadDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Uploaded: $_resumeUploadDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _viewResume,
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _downloadResume,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _deleteResume,
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete Resume',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not specified' : value,
              style: TextStyle(
                fontSize: 14,
                color: value.isEmpty ? Colors.grey[500] : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationItem(Map<String, dynamic> education) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        // REMOVED: No more border, no more background color
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[100]!, // Very subtle divider
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Education Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Degree/Program - Main title
                Text(
                  education['degree'] ?? 'Degree not specified',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 4),

                // Institution name
                Text(
                  education['institution'] ?? 'Institution not specified',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 2),

                // Duration
                Text(
                  '${education['start_year'] ?? ''} - ${education['end_year'] ?? 'Present'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons - Subtle and minimal
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _editEducation(education),
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Colors.grey[600],
                ),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
              IconButton(
                onPressed: () => _deleteEducation(education['id']),
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.grey[600],
                ),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(Map<String, dynamic> experience) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience['job_title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      experience['company'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${experience['start_date'] ?? ''} - ${experience['end_date'] ?? 'Present'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editExperience(experience),
                    icon: const Icon(Icons.edit, size: 18, color: primaryColor),
                  ),
                  IconButton(
                    onPressed: () => _deleteExperience(experience['id']),
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
          if (experience['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              experience['description'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getInitials() {
    try {
      final firstName = (_profileData['first_name'] ?? '').toString();
      final lastName = (_profileData['last_name'] ?? '').toString();

      if (firstName.isEmpty && lastName.isEmpty) return 'U';

      return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();
    } catch (e) {
      print('🔧 Initials error: $e');
      return 'U';
    }
  }

  // Action Methods
  void _editProfilePhoto() {
    // TODO: Implement profile photo editing
    _showSuccessSnackBar('Profile photo editing will be implemented');
  }

  void _editSkills() {
    // TODO: Navigate to skills editing screen
    _showSuccessSnackBar('Skills editing will be implemented');
  }

  void _addEducation() {
    // TODO: Navigate to add education screen
    _showSuccessSnackBar('Add education will be implemented');
  }

  void _editEducation(Map<String, dynamic> education) {
    // TODO: Navigate to edit education screen
    _showSuccessSnackBar('Edit education will be implemented');
  }

  void _deleteEducation(int? id) {
    // TODO: Implement education deletion
    _showSuccessSnackBar('Delete education will be implemented');
  }

  void _addExperience() {
    // TODO: Navigate to add experience screen
    _showSuccessSnackBar('Add experience will be implemented');
  }

  void _editExperience(Map<String, dynamic> experience) {
    // TODO: Navigate to edit experience screen
    _showSuccessSnackBar('Edit experience will be implemented');
  }

  void _deleteExperience(int? id) {
    // TODO: Implement experience deletion
    _showSuccessSnackBar('Delete experience will be implemented');
  }

  void _editAccessibility() {
    // TODO: Navigate to accessibility editing screen
    _showSuccessSnackBar('Accessibility editing will be implemented');
  }

  Future<void> _uploadResume() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: !kIsWeb, // Get bytes for web, path for mobile
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Show loading dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Upload file
        final response = await ApiService.uploadResumeProfile(file: file);

        // Close loading dialog
        if (mounted) {
          Navigator.pop(context);
        }

        // Show result
        if (response['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(response['message'] ?? 'Resume uploaded successfully'),
                backgroundColor: Colors.green[600],
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Reload profile data
            _loadProfileData();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Failed to upload resume'),
                backgroundColor: Colors.red[600],
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('🔧 Resume upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _viewResume() {
    if (_resumeUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No resume to view'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Navigate to resume viewer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResumeViewerScreen(
          resumePath: _resumeUrl,
          resumeName: _resumeName ?? 'Resume',
        ),
      ),
    );
  }

  Future<void> _downloadResume() async {
    if (_resumeUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No resume to download'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // Get download URL
      final downloadUrl = await ApiService.getResumeDownloadUrl(_resumeUrl);

      // Show info message (actual download will open in browser on mobile)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening: $_resumeName'),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OPEN',
              textColor: Colors.white,
              onPressed: () {
                // You can use url_launcher here if needed
                print('🔧 Download URL: $downloadUrl');
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('🔧 Download error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteResume() async {
    if (_resumeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No resume to delete'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resume'),
        content: Text('Are you sure you want to delete "$_resumeName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Delete resume
      final response = await ApiService.deleteResume(resumeId: _resumeId!);

      // Close loading
      if (mounted) {
        Navigator.pop(context);
      }

      // Show result
      if (response['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(response['message'] ?? 'Resume deleted successfully'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Reload profile data
          _loadProfileData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to delete resume'),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('🔧 Delete error: $e');
      if (mounted) {
        // Close loading if still open
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
