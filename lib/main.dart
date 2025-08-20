import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize auto-discovery API service
  print('🚀 Starting ThisAble Mobile...');
  final apiReady = await ApiService.initialize();

  if (apiReady) {
    print('✅ API Service ready! Auto-discovery successful.');
  } else {
    print('⚠️ API Service failed to initialize - will try again when needed.');
  }

  runApp(const ThisAbleApp());
}
