import 'package:flutter/material.dart';
import '../../core/services/tts_service.dart';
import '../../core/theme/app_colors.dart';

/// TTS Button Widget - Reusable text-to-speech button
/// Drop this anywhere to add TTS functionality
///
/// Usage:
/// TTSButton(
///   text: "Content to read aloud",
///   tooltip: "Read aloud",
/// )
class TTSButton extends StatefulWidget {
  final String text; // Text to speak
  final String? tooltip; // Tooltip text
  final IconData? icon; // Custom icon (defaults to volume_up)
  final Color? color; // Custom color (defaults to AppColors.ttsBackground)
  final double size; // Button size (defaults to 40)
  final bool
      isIconOnly; // Show only icon or with background (defaults to icon only)

  const TTSButton({
    super.key,
    required this.text,
    this.tooltip,
    this.icon,
    this.color,
    this.size = 40,
    this.isIconOnly = true,
  });

  @override
  State<TTSButton> createState() => _TTSButtonState();
}

class _TTSButtonState extends State<TTSButton>
    with SingleTickerProviderStateMixin {
  bool _isSpeaking = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Create pulse animation for when speaking
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Listen to TTS state changes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        if (_isSpeaking) {
          _animationController.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.text.isEmpty) {
      // Show message if no text
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No content to read'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (_isSpeaking) {
      // Stop speaking
      await ttsService.stop();
      setState(() {
        _isSpeaking = false;
      });
      _animationController.stop();
      _animationController.reset();
    } else {
      // Start speaking
      setState(() {
        _isSpeaking = true;
      });
      _animationController.forward();

      await ttsService.speak(widget.text);

      // Update state after speaking completes
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? AppColors.ttsBackground;
    final iconData = widget.icon ?? Icons.volume_up;

    if (widget.isIconOnly) {
      // Icon-only button (for app bars, floating buttons)
      return Tooltip(
        message: widget.tooltip ?? 'Read aloud',
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: IconButton(
            icon: Icon(iconData),
            color: _isSpeaking ? AppColors.ttsActive : buttonColor,
            iconSize: widget.size * 0.6,
            onPressed: _handleTap,
          ),
        ),
      );
    } else {
      // Button with background (for cards, prominent placement)
      return Tooltip(
        message: widget.tooltip ?? 'Read aloud',
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            color: _isSpeaking ? AppColors.ttsActive : buttonColor,
            borderRadius: BorderRadius.circular(widget.size / 2),
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(widget.size / 2),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.size / 2),
                  boxShadow: _isSpeaking
                      ? [
                          BoxShadow(
                            color: AppColors.ttsActive.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: widget.size * 0.5,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

/// Floating TTS Button - For placing at screen corners
/// Mimics your web's floating TTS control
class TTSFloatingButton extends StatelessWidget {
  final String text;
  final Alignment alignment; // Where to position (e.g., Alignment.topRight)

  const TTSFloatingButton({
    super.key,
    required this.text,
    this.alignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TTSButton(
            text: text,
            isIconOnly: false,
            size: 56,
            tooltip: 'Read page aloud',
          ),
        ),
      ),
    );
  }
}
