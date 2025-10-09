import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/api_service.dart';
import 'config/dynamic_api_config.dart';
import 'core/services/tts_service.dart'; // ← ADD THIS
import 'core/services/voice_search_service.dart'; // ← ADD THIS

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting ThisAble Mobile...');

  // Initialize TTS Service
  print('🎤 Initializing TTS...');
  await ttsService.initialize();
  print('✅ TTS Ready!');

  // Initialize Voice Search Service
  print('🎙️ Initializing Voice Search...');
  await voiceSearchService.initialize();
  print('✅ Voice Search Ready!');

  // ✅ ENHANCED: Use refresh() instead of initialize() to clear any cached wrong IPs
  print('🔄 Force refreshing network configuration...');
  final apiReady = await DynamicApiConfig.refresh();

  if (apiReady) {
    print('✅ API Service ready! Auto-discovery successful.');
    print('✅ Using IP: ${DynamicApiConfig.currentIP}');
  } else {
    print('⚠️ API Service failed to initialize - will try again when needed.');
  }

  runApp(const ThisAbleApp());
}
