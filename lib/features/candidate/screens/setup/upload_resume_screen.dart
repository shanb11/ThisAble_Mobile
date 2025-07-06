import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Add this line
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../config/routes.dart';

class UploadResumeScreen extends StatefulWidget {
  const UploadResumeScreen({super.key});

  @override
  State<UploadResumeScreen> createState() => _UploadResumeScreenState();
}

class _UploadResumeScreenState extends State<UploadResumeScreen> {
  bool _fileSelected = false;
  bool _isUploading = false;
  String _fileName = '';
  String _fileSize = '';
  PlatformFile? _selectedFile; // Add this line

  final List<Map<String, dynamic>> _resumeTips = [
    {
      'icon': Icons.check_circle,
      'title': 'Clear Formatting',
      'description':
          'Use clean, consistent formatting with readable fonts and proper spacing for better readability.',
    },
    {
      'icon': Icons.star,
      'title': 'Highlight Skills',
      'description':
          'Emphasize your relevant skills and competencies that match potential job requirements.',
    },
    {
      'icon': Icons.description,
      'title': 'Updated Content',
      'description':
          'Ensure your resume reflects your most recent experience, education, and accomplishments.',
    },
  ];

  Future<void> _handleFileSelect() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        // Validate file size (5MB limit)
        if (file.size > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File size must be less than 5MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _fileSelected = true;
          _fileName = file.name;
          _fileSize = _formatFileSize(file.size);
          _selectedFile = file; // Store the actual file
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeFile() {
    setState(() {
      _fileSelected = false;
      _fileName = '';
      _fileSize = '';
      _selectedFile = null; // Add this line
    });
  }

  void _goBack() {
    Navigator.pop(context);
  }

  Future<void> _continue() async {
    if (!_fileSelected || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a resume file first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      print('🔧 Starting file upload...');

      // Upload the file
      final uploadResult = await ApiService.uploadResume(file: _selectedFile!);

      if (uploadResult['success']) {
        print('🔧 File uploaded successfully, completing setup...');

        // Complete the setup process
        final setupResult = await ApiService.completeSetup();

        setState(() {
          _isUploading = false;
        });

        if (setupResult['success']) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Setup Complete!'),
              content: const Text(
                  'Your profile setup is now complete. You can start exploring job opportunities.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.candidateDashboard,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: const Text('Go to Dashboard'),
                ),
              ],
            ),
          );
        } else {
          // Setup completion failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(setupResult['message'] ?? 'Failed to complete setup'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (uploadResult['requiresLogin'] == true) {
        // Handle session expiry
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.candidateDashboard,
          (route) => false,
        );
      } else {
        // Upload failed
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(uploadResult['message'] ?? 'Upload failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes} B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F8FA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tip['icon'],
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tip['title'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            tip['description'],
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _handleFileSelect,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: AppColors.primary,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_upload,
              size: 40,
              color: AppColors.primary,
            ),
            const SizedBox(height: 10),
            const Text(
              'Drag & Drop your resume here',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'or',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _handleFileSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text('Choose File'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Accepted file type: PDF',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfo() {
    if (!_fileSelected) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F8FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('📄', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _fileName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _fileSize,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 4),
              Text(
                'Ready to upload',
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _removeFile,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete, color: Colors.red, size: 16),
                SizedBox(width: 4),
                Text(
                  'Remove file',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
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

            // Main content - Fixed with proper spacing
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
                            'Upload Your Resume',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Share your professional experience to help employers understand your qualifications and find the perfect match for your skills.',
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

                    // Progress bar (100%)
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 600),
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1E1E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

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
                              'Your resume helps employers understand your background and skills. Having an up-to-date resume increases your chances of finding suitable employment opportunities.',
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

                    const SizedBox(height: 25),

                    // Resume tips - Fixed responsive layout
                    Container(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 600) {
                            return Row(
                              children: _resumeTips
                                  .map(
                                    (tip) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: _buildTipCard(tip),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          } else {
                            return Column(
                              children: _resumeTips
                                  .map(
                                    (tip) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: _buildTipCard(tip),
                                    ),
                                  )
                                  .toList(),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Upload section
                    _buildUploadArea(),

                    // File info
                    _buildFileInfo(),

                    const SizedBox(
                        height: 120), // Extra space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation - Fixed positioning
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: SafeArea(
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
                onPressed: _isUploading ? null : _continue,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.arrow_forward),
                label: Text(_isUploading ? 'Uploading...' : 'Continue'),
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
      ),
    );
  }
}
