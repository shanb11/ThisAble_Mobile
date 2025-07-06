import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/api_service.dart';
import 'workstyle_screen.dart';
import '../../../../config/routes.dart';

class SkillSelectionScreen extends StatefulWidget {
  const SkillSelectionScreen({super.key});

  @override
  State<SkillSelectionScreen> createState() => _SkillSelectionScreenState();
}

class _SkillSelectionScreenState extends State<SkillSelectionScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  Set<int> _selectedSkills = {}; // Changed to int for skill IDs

  List<Map<String, dynamic>> _allSkills = []; // Will be loaded from API
  List<Map<String, dynamic>> _categories = []; // Will be loaded from API
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSkillsData();
  }

  Future<void> _loadSkillsData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load skills from API
      final skillsResponse = await ApiService.getSkills();
      final categoriesResponse = await ApiService.getSkillCategories();

      if (skillsResponse['success'] && categoriesResponse['success']) {
        setState(() {
          _allSkills =
              List<Map<String, dynamic>>.from(skillsResponse['data']['skills']);

          // Add "All Skills" category first
          _categories = [
            {'id': 'all', 'name': 'All Skills', 'icon': '📋'}
          ];

          // Add categories from API
          final apiCategories = List<Map<String, dynamic>>.from(
              categoriesResponse['data']['skill_categories']);
          for (var category in apiCategories) {
            _categories.add({
              'id': category['id'].toString(),
              'name': category['name'],
              'icon': _getCategoryIcon(category['name'])
            });
          }

          _isLoading = false;
        });
      } else {
        setState(() {
          _error = skillsResponse['message'] ?? 'Failed to load skills';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'digital and technical skills':
        return '💻';
      case 'customer service skills':
        return '🎧';
      case 'administrative and clerical skills':
        return '📋';
      case 'accounting and financial skills':
        return '🧮';
      case 'bpo-specific skills':
        return '🏢';
      case 'manufacturing skills':
        return '🏭';
      case 'disability-specific strengths':
        return '⭐';
      case 'soft skills and work attributes':
        return '👥';
      default:
        return '📋';
    }
  }

  List<Map<String, dynamic>> get _filteredSkills {
    return _allSkills.where((skill) {
      bool matchesCategory = _selectedCategory == 'all' ||
          skill['category_id'].toString() == _selectedCategory;
      bool matchesSearch = _searchQuery.isEmpty ||
          skill['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  String _getSkillIcon(String iconClass) {
    // Convert FontAwesome class to emoji
    switch (iconClass) {
      case 'fa-desktop':
      case 'fa-laptop-code':
        return '💻';
      case 'fa-keyboard':
        return '⌨️';
      case 'fa-file-word':
        return '📊';
      case 'fa-chart-bar':
        return '📈';
      case 'fa-code':
        return '👨‍💻';
      case 'fa-phone-alt':
        return '📞';
      case 'fa-comments':
        return '💬';
      case 'fa-headphones':
        return '🎧';
      default:
        return '📋';
    }
  }

  Future<void> _goToWorkstyle() async {
    if (_selectedSkills.isEmpty) return;

    try {
      // DEBUG TOKEN
      final token = await ApiService.getToken();
      print('=== TOKEN DEBUG ===');
      print('Token exists: ${token != null}');
      print('Token length: ${token?.length ?? 0}');
      print('Token preview: ${token?.substring(0, 20) ?? "null"}...');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication required. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );

        // Navigate back to login
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.candidateLogin,
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

      // Save skills to database
      final response = await ApiService.saveSkills(
        skillIds: _selectedSkills.toList(),
      );

      print('=== API RESPONSE ===');
      print(response);

      // Hide loading
      Navigator.pop(context);

      if (response['success']) {
        // Navigate to next screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WorkstyleScreen(),
          ),
        );
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to save skills'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Hide loading if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text('Loading skills...'),
                        ],
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 48),
                              SizedBox(height: 16),
                              Text(_error!, textAlign: TextAlign.center),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadSkillsData,
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              // Header text
                              const Text(
                                'Showcase Your Skills',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Select skills that highlight your expertise. These skills will help us connect you with inclusive employers looking for your unique talents.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 20),

                              // Progress bar
                              Container(
                                width: double.infinity,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1E1E1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 0.5,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Search box
                              Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 500),
                                child: TextField(
                                  onChanged: (value) =>
                                      setState(() => _searchQuery = value),
                                  decoration: InputDecoration(
                                    hintText: 'Search for skills...',
                                    prefixIcon: const Icon(Icons.search,
                                        color: AppColors.primary),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: AppColors.primary, width: 2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: AppColors.primary, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 25),

                              // Category tabs
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: _categories
                                    .map(
                                      (category) => GestureDetector(
                                        onTap: () => setState(() =>
                                            _selectedCategory = category['id']),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: _selectedCategory ==
                                                    category['id']
                                                ? AppColors.primary
                                                : AppColors.primaryLight,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(category['icon'],
                                                  style: const TextStyle(
                                                      fontSize: 16)),
                                              const SizedBox(width: 8),
                                              Text(
                                                category['name'],
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: _selectedCategory ==
                                                          category['id']
                                                      ? Colors.white
                                                      : AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),

                              const SizedBox(height: 25),

                              // Skills grid
                              _filteredSkills.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(40.0),
                                      child: Text(
                                        'No skills found matching your search.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 15,
                                      runSpacing: 15,
                                      alignment: WrapAlignment.center,
                                      children: _filteredSkills
                                          .map(
                                            (skill) => GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (_selectedSkills
                                                      .contains(skill['id'])) {
                                                    _selectedSkills
                                                        .remove(skill['id']);
                                                  } else {
                                                    _selectedSkills
                                                        .add(skill['id']);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: 160,
                                                height: 110,
                                                padding:
                                                    const EdgeInsets.all(15),
                                                decoration: BoxDecoration(
                                                  color: _selectedSkills
                                                          .contains(skill['id'])
                                                      ? const Color(0xFFFFF9F2)
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: _selectedSkills
                                                            .contains(
                                                                skill['id'])
                                                        ? AppColors.accent
                                                        : Colors.transparent,
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      _getSkillIcon(
                                                          skill['icon']),
                                                      style: TextStyle(
                                                        fontSize: 24,
                                                        color: _selectedSkills
                                                                .contains(
                                                                    skill['id'])
                                                            ? AppColors.accent
                                                            : AppColors.primary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      skill['name'],
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),

                              const SizedBox(height: 30),

                              // Selected skills section
                              Container(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Selected Skills (${_selectedSkills.length})',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Container(
                                      width: double.infinity,
                                      constraints:
                                          const BoxConstraints(minHeight: 50),
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: _selectedSkills.isEmpty
                                          ? const Text(
                                              'No skills selected yet. Choose skills from above.',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 14,
                                              ),
                                            )
                                          : Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: _selectedSkills
                                                  .map((skillId) {
                                                final skill =
                                                    _allSkills.firstWhere((s) =>
                                                        s['id'] == skillId);
                                                return Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        skill['name'],
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      GestureDetector(
                                                        onTap: () => setState(
                                                            () => _selectedSkills
                                                                .remove(
                                                                    skillId)),
                                                        child: Container(
                                                          width: 20,
                                                          height: 20,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.2),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: const Icon(
                                                            Icons.close,
                                                            size: 12,
                                                            color: Colors.white,
                                                          ),
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
                              ),

                              const SizedBox(height: 100),
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
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE1E1E1),
                foregroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            Row(
              children: [
                if (_selectedSkills.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _selectedSkills.clear()),
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2D9D5),
                      foregroundColor: AppColors.accentHover,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                if (_selectedSkills.isNotEmpty) const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _selectedSkills.isNotEmpty ? _goToWorkstyle : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
