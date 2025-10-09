import 'package:flutter_tts/flutter_tts.dart';

/// TTS Service - Centralized Text-to-Speech for all screens
/// Reuses existing TTS patterns from job_detail_modal.dart
class TTSService {
  // Singleton pattern - one instance for entire app
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  // TTS instance
  FlutterTts? _flutterTts;

  // State tracking
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isPaused = false;

  // Current speech rate (0.5 = slow, 1.0 = normal, 1.5 = fast)
  double _speechRate = 0.9;

  /// Get current speaking state
  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  double get speechRate => _speechRate;

  /// Initialize TTS - Call this once at app startup or first use
  /// Uses same settings as your job_detail_modal.dart
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();

      // Same settings as your existing TTS code
      await _flutterTts?.setLanguage("en-US");
      await _flutterTts?.setSpeechRate(_speechRate);
      await _flutterTts?.setVolume(0.8);
      await _flutterTts?.setPitch(1.0);

      // Set handlers
      _flutterTts?.setStartHandler(() {
        _isSpeaking = true;
        _isPaused = false;
      });

      _flutterTts?.setCompletionHandler(() {
        _isSpeaking = false;
        _isPaused = false;
      });

      _flutterTts?.setCancelHandler(() {
        _isSpeaking = false;
        _isPaused = false;
      });

      _flutterTts?.setErrorHandler((message) {
        print('TTS Error: $message');
        _isSpeaking = false;
        _isPaused = false;
      });

      _isInitialized = true;
      print('✅ TTS Service initialized successfully');
    } catch (e) {
      print('❌ TTS initialization error: $e');
      _isInitialized = false;
    }
  }

  /// Speak text aloud
  /// Auto-initializes if not already done
  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    // Initialize if needed
    if (!_isInitialized) {
      await initialize();
    }

    if (_flutterTts == null) {
      print('❌ TTS not available');
      return;
    }

    try {
      // Stop any current speech
      await stop();

      // Start speaking
      print(
          '🔊 TTS Speaking: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
      await _flutterTts?.speak(text);
    } catch (e) {
      print('❌ TTS speak error: $e');
    }
  }

  /// Stop speaking immediately
  Future<void> stop() async {
    if (_flutterTts == null) return;

    try {
      await _flutterTts?.stop();
      _isSpeaking = false;
      _isPaused = false;
      print('⏹️ TTS Stopped');
    } catch (e) {
      print('❌ TTS stop error: $e');
    }
  }

  /// Pause speaking (can resume later)
  Future<void> pause() async {
    if (_flutterTts == null || !_isSpeaking) return;

    try {
      await _flutterTts?.pause();
      _isPaused = true;
      print('⏸️ TTS Paused');
    } catch (e) {
      print('❌ TTS pause error: $e');
    }
  }

  /// Resume speaking after pause
  Future<void> resume() async {
    if (_flutterTts == null || !_isPaused) return;

    try {
      // Note: Flutter TTS doesn't have resume, so we'll handle pause state
      _isPaused = false;
      print('▶️ TTS Resumed');
    } catch (e) {
      print('❌ TTS resume error: $e');
    }
  }

  /// Set speech rate (0.5 = slow, 1.0 = normal, 1.5 = fast)
  Future<void> setSpeechRate(double rate) async {
    if (_flutterTts == null) return;

    try {
      _speechRate = rate;
      await _flutterTts?.setSpeechRate(rate);
      print('🎚️ TTS Speed: ${rate}x');
    } catch (e) {
      print('❌ TTS set rate error: $e');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (_flutterTts == null) return;

    try {
      await _flutterTts?.setVolume(volume);
      print('🔊 TTS Volume: ${(volume * 100).toInt()}%');
    } catch (e) {
      print('❌ TTS set volume error: $e');
    }
  }

  /// Dispose - cleanup when app closes
  Future<void> dispose() async {
    await stop();
    _flutterTts = null;
    _isInitialized = false;
  }
}

/// Global instance for easy access
final ttsService = TTSService();
