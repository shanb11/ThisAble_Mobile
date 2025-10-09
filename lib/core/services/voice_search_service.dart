import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// Voice Search Service - Speech-to-Text for search functionality
/// Handles microphone permissions and speech recognition
class VoiceSearchService {
  // Singleton pattern
  static final VoiceSearchService _instance = VoiceSearchService._internal();
  factory VoiceSearchService() => _instance;
  VoiceSearchService._internal();

  // Speech recognition instance
  stt.SpeechToText? _speech;

  // State tracking
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isAvailable = false;

  /// Get current listening state
  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;

  /// Initialize speech recognition
  /// Call this once at app startup or first use
  Future<bool> initialize() async {
    if (_isInitialized) return _isAvailable;

    try {
      _speech = stt.SpeechToText();
      _isAvailable = await _speech!.initialize(
        onError: (error) => print('❌ Speech recognition error: $error'),
        onStatus: (status) => print('🎤 Speech status: $status'),
      );

      _isInitialized = true;

      if (_isAvailable) {
        print('✅ Voice Search Service initialized successfully');
      } else {
        print('⚠️ Speech recognition not available on this device');
      }

      return _isAvailable;
    } catch (e) {
      print('❌ Voice search initialization error: $e');
      _isInitialized = false;
      _isAvailable = false;
      return false;
    }
  }

  /// Check if microphone permission is granted
  Future<bool> checkPermission() async {
    final status = await Permission.microphone.status;
    print('🎤 Microphone permission status: $status');
    return status.isGranted;
  }

  /// Request microphone permission
  Future<bool> requestPermission() async {
    print('🎤 Requesting microphone permission...');
    final status = await Permission.microphone.request();

    if (status.isGranted) {
      print('✅ Microphone permission granted');
      return true;
    } else if (status.isDenied) {
      print('❌ Microphone permission denied');
      return false;
    } else if (status.isPermanentlyDenied) {
      print('❌ Microphone permission permanently denied - open settings');
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Start listening for speech
  /// Returns recognized text via onResult callback
  Future<bool> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
    Function()? onComplete,
  }) async {
    if (!_isInitialized || !_isAvailable) {
      print('⚠️ Voice search not initialized or available');
      final initialized = await initialize();
      if (!initialized) {
        return false;
      }
    }

    // Check permission
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      final granted = await requestPermission();
      if (!granted) {
        return false;
      }
    }

    if (_speech == null || !_speech!.isAvailable) {
      print('❌ Speech recognition not available');
      return false;
    }

    try {
      _isListening = true;

      await _speech!.listen(
        onResult: (result) {
          print('🎤 Speech result: ${result.recognizedWords}');

          if (result.hasConfidenceRating && result.confidence > 0) {
            print('🎤 Confidence: ${result.confidence}');
          }

          // Send partial results while speaking
          if (onPartialResult != null && !result.finalResult) {
            onPartialResult(result.recognizedWords);
          }

          // Send final result when done
          if (result.finalResult) {
            onResult(result.recognizedWords);
            _isListening = false;
            onComplete?.call();
          }
        },
        listenFor: const Duration(seconds: 30), // Max listening time
        pauseFor: const Duration(seconds: 3), // Pause detection
        partialResults: true, // Get results while speaking
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );

      print('🎤 Started listening...');
      return true;
    } catch (e) {
      print('❌ Error starting voice search: $e');
      _isListening = false;
      return false;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_speech == null) return;

    try {
      await _speech!.stop();
      _isListening = false;
      print('⏹️ Stopped listening');
    } catch (e) {
      print('❌ Error stopping voice search: $e');
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (_speech == null) return;

    try {
      await _speech!.cancel();
      _isListening = false;
      print('🚫 Cancelled listening');
    } catch (e) {
      print('❌ Error cancelling voice search: $e');
    }
  }

  /// Get list of available locales for speech recognition
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (_speech == null) return [];

    try {
      return await _speech!.locales();
    } catch (e) {
      print('❌ Error getting locales: $e');
      return [];
    }
  }

  /// Dispose - cleanup when app closes
  Future<void> dispose() async {
    await stopListening();
    _speech = null;
    _isInitialized = false;
  }
}

/// Global instance for easy access
final voiceSearchService = VoiceSearchService();
