import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/api_service.dart';
import 'config/dynamic_api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting ThisAble Mobile...');

  // FORCE REFRESH instead of initialize para ma-clear yung cached wrong IP
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
