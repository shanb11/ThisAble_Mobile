import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../config/dynamic_api_config.dart';

/// Resume Viewer Screen - Simple External Viewer
/// Opens PDF in system's default PDF viewer
class ResumeViewerScreen extends StatefulWidget {
  final String resumePath; // Relative path like "uploads/resumes/4_abc123.pdf"
  final String resumeName; // Display name

  const ResumeViewerScreen({
    Key? key,
    required this.resumePath,
    required this.resumeName,
  }) : super(key: key);

  @override
  State<ResumeViewerScreen> createState() => _ResumeViewerScreenState();
}

class _ResumeViewerScreenState extends State<ResumeViewerScreen> {
  bool _isLoading = true;
  String? _fullUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _openResume();
  }

  Future<void> _openResume() async {
    try {
      // Get base URL from config
      final baseUrl = await DynamicApiConfig.getFileBaseUrl();

      // Build full URL
      _fullUrl = '$baseUrl/${widget.resumePath}';

      print('🔧 Opening Resume URL: $_fullUrl');

      // Open in external viewer
      final uri = Uri.parse(_fullUrl!);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in system PDF viewer
        );

        // Close this screen since PDF opened externally
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = 'Could not open PDF viewer';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔧 Error opening resume: $e');
      setState(() {
        _errorMessage = 'Failed to open resume: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.resumeName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.secondaryTeal,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.secondaryTeal),
            ),
            const SizedBox(height: 16),
            const Text('Opening PDF...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryTeal,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // This shouldn't be reached since we navigate back after opening
    return const Center(child: Text('PDF opened in external viewer'));
  }
}
