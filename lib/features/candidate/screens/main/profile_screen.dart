import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/services/api_service.dart';

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

  // Text Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProfileData();
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
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      final response = await ApiService.getProfileData();
      if (response['success'] && mounted) {
        final data = response['data'];
        setState(() {
          _profileData = data['profile'] ?? {};
          _educationList = data['education'] ?? [];
          _experienceList = data['experience'] ?? [];
          _skillsList = data['skills'] ?? [];
          _accommodationsList = data['accommodations'] ?? [];
          _resumeUrl = data['resume_url'] ?? '';
          _profileCompletion = data['completion_percentage'] ?? 0;
          _isLoadingProfile = false;
        });

        // Populate text controllers
        _populateControllers();

        // FIXED: Safe animation trigger with proper cleanup
        if (mounted) {
          // Stop any existing animation
          _profileCompletionController.reset();

          // Create new animation with actual completion percentage
          _profileCompletionAnimation = Tween<double>(
            begin: 0.0,
            end: (_profileCompletion / 100.0)
                .clamp(0.0, 1.0), // Ensure within bounds
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
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
        _showErrorSnackBar('Failed to load profile data');
      }
    }
  }

  void _populateControllers() {
    _firstNameController.text = _profileData['first_name'] ?? '';
    _lastNameController.text = _profileData['last_name'] ?? '';
    _emailController.text = _profileData['email'] ?? '';
    _phoneController.text = _profileData['phone'] ?? '';
    _locationController.text = _profileData['location'] ?? '';
    _bioController.text = _profileData['bio'] ?? '';
  }

  Future<void> _updatePersonalInfo() async {
    setState(() => _isUpdatingProfile = true);

    try {
      print('🔧 [Profile] Updating personal info...');

      // FIXED: Prepare data for API
      final profileData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
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
          _profileData['last_name'] = _lastNameController.text.trim();
          _profileData['email'] = _emailController.text.trim();
          _profileData['phone'] = _phoneController.text.trim();
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // REPLACE the _buildProfileHeader() method in profile_screen.dart (around line 290)
  Widget _buildProfileHeader() {
    return SliverAppBar(
      expandedHeight: 320, // INCREASED from 300 to 350 to fix overflow
      floating: false,
      pinned: true,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, sidebarColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  // Profile Photo
                  Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white,
                          backgroundImage: _profileData['profile_photo'] != null
                              ? NetworkImage(_profileData['profile_photo'])
                              : null,
                          child: _profileData['profile_photo'] == null
                              ? Text(
                                  _getInitials(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _editProfilePhoto,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // User Info
                  Text(
                    '${_profileData['first_name'] ?? ''} ${_profileData['last_name'] ?? ''}'
                        .trim(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _profileData['email'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // FIXED: Profile Completion Section
                  Container(
                    width: double.infinity, // FIXED: Ensure full width
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      // FIXED: Changed from Row to Column for better space
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Profile Completion',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // FIXED: Show percentage prominently
                            AnimatedBuilder(
                              animation: _profileCompletionAnimation,
                              builder: (context, child) {
                                return Text(
                                  '${(_profileCompletionAnimation.value * _profileCompletion).round()}%',
                                  style: const TextStyle(
                                    color: secondaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // FIXED: Progress bar with proper constraints
                        AnimatedBuilder(
                          animation: _profileCompletionAnimation,
                          builder: (context, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: _profileCompletionAnimation.value,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    secondaryColor),
                                minHeight: 6,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        // FIXED: Add helpful text
                        Text(
                          _getCompletionText(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
          // Section Header
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
                  icon: _isUpdatingProfile
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _isEditingPersonal ? Icons.check : Icons.edit,
                          color: primaryColor,
                        ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: _isEditingPersonal
                ? _buildPersonalInfoForm()
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: _skillsList.isEmpty
                ? const Text('No skills added yet.')
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skillsList.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: primaryColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          skill['skill_name'] ?? '',
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
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
                                accommodation['accommodation_name'] ?? '',
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
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _resumeUrl.isEmpty
                ? const Text('No resume uploaded yet.')
                : Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red[600]),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Resume.pdf'),
                      ),
                      TextButton(
                        onPressed: _viewResume,
                        child: const Text('View'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
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
                      education['degree'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      education['institution'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${education['start_year'] ?? ''} - ${education['end_year'] ?? ''}',
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
                    onPressed: () => _editEducation(education),
                    icon: const Icon(Icons.edit, size: 18, color: primaryColor),
                  ),
                  IconButton(
                    onPressed: () => _deleteEducation(education['id']),
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  ),
                ],
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
    final firstName = _profileData['first_name'] ?? '';
    final lastName = _profileData['last_name'] ?? '';

    if (firstName.isEmpty && lastName.isEmpty) return 'U';

    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
        .toUpperCase();
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

  void _uploadResume() {
    // TODO: Implement resume upload
    _showSuccessSnackBar('Resume upload will be implemented');
  }

  void _viewResume() {
    // TODO: Implement resume viewing
    _showSuccessSnackBar('Resume viewing will be implemented');
  }
}
