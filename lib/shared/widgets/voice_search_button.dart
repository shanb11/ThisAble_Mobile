import 'package:flutter/material.dart';
import '../../core/services/voice_search_service.dart';
import '../../core/theme/app_colors.dart';

/// Voice Search Button Widget - Animated microphone button for speech input
///
/// Usage:
/// VoiceSearchButton(
///   onResult: (text) {
///     _searchController.text = text;
///     _performSearch();
///   },
/// )
class VoiceSearchButton extends StatefulWidget {
  final Function(String) onResult; // Callback with recognized text
  final String? tooltip;
  final Color? idleColor; // Color when not listening
  final Color? listeningColor; // Color when listening
  final double size; // Button size
  final bool showLabel; // Show "Tap to speak" label

  const VoiceSearchButton({
    super.key,
    required this.onResult,
    this.tooltip,
    this.idleColor,
    this.listeningColor,
    this.size = 48,
    this.showLabel = false,
  });

  @override
  State<VoiceSearchButton> createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  bool _isInitializing = false;
  String _partialText = '';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Create pulse animation for listening state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Loop the animation
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        if (_isListening) {
          _pulseController.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isListening) {
      // Stop listening
      await _stopListening();
    } else {
      // Start listening
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      final success = await voiceSearchService.startListening(
        onResult: (text) {
          print('🎤 Final result: $text');

          if (mounted) {
            setState(() {
              _isListening = false;
              _partialText = '';
            });
            _pulseController.stop();
            _pulseController.reset();

            // Return result to parent
            widget.onResult(text);

            // Show success feedback
            _showFeedback('Voice search: "$text"', isSuccess: true);
          }
        },
        onPartialResult: (text) {
          print('🎤 Partial result: $text');
          if (mounted) {
            setState(() {
              _partialText = text;
            });
          }
        },
        onComplete: () {
          if (mounted) {
            setState(() {
              _isListening = false;
              _partialText = '';
            });
            _pulseController.stop();
            _pulseController.reset();
          }
        },
      );

      if (success) {
        setState(() {
          _isListening = true;
          _isInitializing = false;
        });
        _pulseController.forward();
      } else {
        setState(() {
          _isInitializing = false;
        });
        _showFeedback('Microphone permission required', isSuccess: false);
      }
    } catch (e) {
      print('❌ Voice search error: $e');
      setState(() {
        _isListening = false;
        _isInitializing = false;
      });
      _showFeedback('Voice search failed', isSuccess: false);
    }
  }

  Future<void> _stopListening() async {
    await voiceSearchService.stopListening();
    setState(() {
      _isListening = false;
      _partialText = '';
    });
    _pulseController.stop();
    _pulseController.reset();
  }

  void _showFeedback(String message, {required bool isSuccess}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final idleColor = widget.idleColor ?? AppColors.voiceBackground;
    final listeningColor = widget.listeningColor ?? AppColors.voiceActive;

    if (widget.showLabel) {
      return _buildButtonWithLabel(idleColor, listeningColor);
    } else {
      return _buildIconButton(idleColor, listeningColor);
    }
  }

  /// Icon-only button (for search bars)
  Widget _buildIconButton(Color idleColor, Color listeningColor) {
    if (_isInitializing) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: SizedBox(
            width: widget.size * 0.5,
            height: widget.size * 0.5,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(idleColor),
            ),
          ),
        ),
      );
    }

    return Tooltip(
      message:
          widget.tooltip ?? (_isListening ? 'Listening...' : 'Voice search'),
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: IconButton(
          icon: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            color: _isListening ? listeningColor : idleColor,
          ),
          iconSize: widget.size * 0.6,
          onPressed: _handleTap,
        ),
      ),
    );
  }

  /// Button with label and partial text display
  Widget _buildButtonWithLabel(Color idleColor, Color listeningColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Microphone button
        Tooltip(
          message: widget.tooltip ??
              (_isListening ? 'Listening...' : 'Voice search'),
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: Material(
              color: _isListening ? listeningColor : idleColor,
              borderRadius: BorderRadius.circular(widget.size / 2),
              child: InkWell(
                onTap: _isInitializing ? null : _handleTap,
                borderRadius: BorderRadius.circular(widget.size / 2),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.size / 2),
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: listeningColor.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ]
                        : [],
                  ),
                  child: _isInitializing
                      ? Center(
                          child: SizedBox(
                            width: widget.size * 0.5,
                            height: widget.size * 0.5,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: widget.size * 0.5,
                        ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Status text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isListening
              ? Text(
                  _partialText.isEmpty ? 'Listening...' : _partialText,
                  key: ValueKey(_partialText),
                  style: TextStyle(
                    fontSize: 14,
                    color: listeningColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : Text(
                  'Tap to speak',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
        ),
      ],
    );
  }
}

/// Floating Voice Search Button - For prominent placement
class VoiceSearchFloatingButton extends StatelessWidget {
  final Function(String) onResult;
  final Alignment alignment;

  const VoiceSearchFloatingButton({
    super.key,
    required this.onResult,
    this.alignment = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: VoiceSearchButton(
            onResult: onResult,
            showLabel: true,
            size: 64,
            tooltip: 'Voice search',
          ),
        ),
      ),
    );
  }
}
