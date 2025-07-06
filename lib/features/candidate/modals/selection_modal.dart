import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../config/routes.dart';

/// Selection Modal - Mobile version of modals/candidate/selection_modal.php
/// Shows choice between candidate and employer signup
class SelectionModal extends StatefulWidget {
  const SelectionModal({super.key});

  @override
  State<SelectionModal> createState() => _SelectionModalState();
}

class _SelectionModalState extends State<SelectionModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Add navigation flag to prevent double navigation
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.all(10), // Minimal padding for maximum space
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: _buildModalContent(),
      ),
    );
  }

  /// Build modal content - MAXIMUM VISIBILITY VERSION
  Widget _buildModalContent() {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // More aggressive sizing for full visibility
    final isSmallScreen = screenHeight < 700;
    final modalPadding = 15.0; // Reduced padding for more space
    final maxModalHeight = screenHeight * 0.95; // Use 95% of screen height
    final modalWidth = screenWidth - 20; // Use almost full width

    return Center(
      child: Container(
        width: modalWidth,
        constraints: BoxConstraints(
          maxHeight: maxModalHeight,
          maxWidth: 700, // Increased max width
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button - MINIMAL SPACE
              Container(
                padding: EdgeInsets.only(
                  top: modalPadding,
                  left: modalPadding,
                  right: modalPadding,
                  bottom: 5,
                ),
                child: _buildModalHeader(),
              ),

              // Scrollable content area
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: modalPadding,
                    right: modalPadding,
                    bottom: modalPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      _buildModalTitle(isSmallScreen),

                      // Minimal spacing before cards
                      const SizedBox(height: 15),

                      // Selection cards
                      _buildSelectionCards(isSmallScreen),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Modal header with close button
  Widget _buildModalHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: _closeModal,
          child: Container(
            padding: const EdgeInsets.all(5),
            child: const Icon(
              Icons.close,
              color: AppColors.primaryOrange,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  /// Modal title - COMPACT VERSION
  Widget _buildModalTitle(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        'Join as a candidate or company',
        style: GoogleFonts.inter(
          fontSize: isSmallScreen ? 18 : 22, // Slightly smaller for more space
          fontWeight: FontWeight.bold,
          color: AppColors.secondaryTeal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Selection cards - OPTIMIZED FOR FULL VISIBILITY
  Widget _buildSelectionCards(bool isSmallScreen) {
    // Always use stacked layout for better text visibility
    return Column(
      children: [
        _buildCandidateCard(isSmallScreen),
        const SizedBox(height: 12), // Reduced spacing between cards
        _buildCompanyCard(isSmallScreen),
        const SizedBox(height: 10), // Bottom padding
      ],
    );
  }

  /// Candidate selection card - COMPACT BUT COMPLETE
  Widget _buildCandidateCard(bool isSmallScreen) {
    return GestureDetector(
      onTap: () => _selectCandidate(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20), // Consistent padding
        decoration: BoxDecoration(
          color: AppColors.accentBeige,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              Icons.person,
              size: isSmallScreen ? 36 : 42, // Slightly smaller icon
              color: AppColors.primaryOrange,
            ),

            const SizedBox(height: 8),

            // Title
            Text(
              'I am a candidate',
              style: GoogleFonts.inter(
                fontSize: isSmallScreen ? 15 : 17,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            // Description - GUARANTEED FULL VISIBILITY
            Text(
              'Looking for employment opportunities',
              style: GoogleFonts.inter(
                fontSize: isSmallScreen ? 12 : 13,
                color: Colors.grey[700],
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Company selection card - COMPACT BUT COMPLETE
  Widget _buildCompanyCard(bool isSmallScreen) {
    return GestureDetector(
      onTap: () => _selectCompany(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20), // Consistent padding
        decoration: BoxDecoration(
          color: AppColors.accentBeige,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              Icons.business,
              size: isSmallScreen ? 36 : 42, // Slightly smaller icon
              color: AppColors.primaryOrange,
            ),

            const SizedBox(height: 8),

            // Title
            Text(
              'I am a company',
              style: GoogleFonts.inter(
                fontSize: isSmallScreen ? 15 : 17,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            // Description - GUARANTEED FULL VISIBILITY
            Text(
              'Seeking candidates for job openings',
              style: GoogleFonts.inter(
                fontSize: isSmallScreen ? 12 : 13,
                color: Colors.grey[700],
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Handle candidate selection
  void _selectCandidate() {
    if (_isNavigating) return;
    _isNavigating = true;

    final navigatorContext = Navigator.of(context);
    navigatorContext.pop();
    navigatorContext.pushReplacementNamed(AppRoutes.candidateSignup);
  }

  /// Handle company selection
  void _selectCompany() {
    if (_isNavigating) return;
    _isNavigating = true;

    final navigatorContext = Navigator.of(context);
    navigatorContext.pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Employer signup will be implemented in the next phase'),
        backgroundColor: AppColors.secondaryTeal,
      ),
    );
  }

  /// Close modal with animation
  void _closeModal() {
    if (_isNavigating) return;

    _animationController.reverse().then((_) {
      if (mounted && !_isNavigating) {
        Navigator.of(context).pop();
      }
    });
  }
}
