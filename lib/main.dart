import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/api_service.dart';
import 'config/dynamic_api_config.dart';
import 'core/services/tts_service.dart';
import 'core/services/voice_search_service.dart';

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

  // ✅ UPDATED: Initialize API configuration
  print('🌐 Initializing API configuration...');
  await DynamicApiConfig.initialize();

  final baseUrl = await DynamicApiConfig.getBaseUrl();
  print('✅ API ready at: $baseUrl');

  runApp(const ThisAbleApp());
}
