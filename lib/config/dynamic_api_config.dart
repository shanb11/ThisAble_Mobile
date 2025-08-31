import '../core/services/network_discovery_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Enhanced Dynamic API Configuration for ThisAble Mobile
/// Now supports ALL platforms with intelligent fallbacks
/// Enhanced Dynamic API Configuration - WEB PLATFORM SAFE
class DynamicApiConfig {
  static String? _currentBaseUrl;
  static String? _currentIP;
  static bool _isInitialized = false;

  // Your project structure
  static const String _projectPath = 'ThisAble';
  static const String _apiPath = 'api';

  /// ENHANCED initialization with GUARANTEED non-null return for web
  static Future<bool> initialize() async {
    if (_isInitialized &&
        _currentBaseUrl != null &&
        _currentBaseUrl!.isNotEmpty) {
      print('✅ API Config already initialized: $_currentBaseUrl');
      return true;
    }

    print('🚀 Initializing Enhanced Dynamic API Config...');
    print('🔍 Platform: ${await _getPlatformName()}');

    try {
      // Use enhanced network discovery with guaranteed non-null return
      final workingIP = await NetworkDiscoveryService.findWorkingIP();

      // CRITICAL: workingIP should never be null after our fix, but safety check
      if (workingIP != null && workingIP.trim().isNotEmpty) {
        _currentIP = workingIP.trim();
        _currentBaseUrl = 'http://$_currentIP/$_projectPath/$_apiPath';
        _isInitialized = true;

        print('✅ API Config initialized successfully!');
        print('✅ Platform: ${await _getPlatformName()}');
        print('✅ IP: $_currentIP');
        print('✅ Base URL: $_currentBaseUrl');

        // Verify the URL is accessible
        final isAccessible = await _testBaseUrl(_currentBaseUrl!);
        if (isAccessible) {
          print('✅ Base URL verified as accessible');
          return true;
        } else {
          print(
              '⚠️ Base URL not accessible, but continuing with current config');
          return true; // Still return true to prevent null errors
        }
      } else {
        print(
            '🚨 CRITICAL: Network discovery returned null/empty - using emergency fallback');
        return await _useEmergencyFallback();
      }
    } catch (e) {
      print('❌ Error during API config initialization: $e');
      return await _useEmergencyFallback();
    }
  }

  /// EMERGENCY fallback configuration - NEVER returns false for web
  static Future<bool> _useEmergencyFallback() async {
    print('🚨 Using emergency fallback configuration...');

    String fallbackIP;

    if (kIsWeb) {
      // For web platform, always use localhost as emergency fallback
      fallbackIP = 'localhost';
      print('🌐 Web emergency fallback: localhost');
    } else {
      // For mobile platforms, try common router IPs
      final emergencyIPs = [
        '192.168.1.1',
        '192.168.0.1',
        '10.0.0.1',
        'localhost'
      ];

      fallbackIP = 'localhost'; // Default fallback

      for (String ip in emergencyIPs) {
        if (await _testIP(ip)) {
          fallbackIP = ip;
          print('📱 Mobile emergency fallback found: $ip');
          break;
        }
      }

      if (fallbackIP == 'localhost') {
        print('📱 Mobile using localhost as last resort');
      }
    }

    _currentIP = fallbackIP;
    _currentBaseUrl = 'http://$fallbackIP/$_projectPath/$_apiPath';
    _isInitialized = true;

    print('✅ Emergency fallback configured:');
    print('✅ IP: $fallbackIP');
    print('✅ Base URL: $_currentBaseUrl');

    // For web platform, we ALWAYS return true to prevent null errors
    // Even if the server is not reachable, we provide a valid URL
    return true;
  }

  /// Force refresh configuration
  static Future<bool> refresh() async {
    print('🔄 Force refreshing API configuration...');

    // Clear current state
    _isInitialized = false;
    _currentBaseUrl = null;
    _currentIP = null;

    // Clear network discovery cache
    await NetworkDiscoveryService.clearCache();

    // Re-initialize
    return await initialize();
  }

  /// Get current base URL - GUARANTEED non-null for web platform
  static Future<String> getBaseUrl() async {
    if (!_isInitialized ||
        _currentBaseUrl == null ||
        _currentBaseUrl!.isEmpty) {
      print('⚠️ API Config not initialized, initializing now...');
      await initialize();
    }

    // SAFETY CHECK: Should never be null after initialization, but just in case
    if (_currentBaseUrl == null || _currentBaseUrl!.isEmpty) {
      print('🚨 CRITICAL: Base URL is still null after initialization');

      // Emergency web-safe fallback
      final emergencyUrl = kIsWeb
          ? 'http://localhost/$_projectPath/$_apiPath'
          : 'http://192.168.1.1/$_projectPath/$_apiPath';

      print('🚨 Using emergency URL: $emergencyUrl');

      _currentBaseUrl = emergencyUrl;
      _currentIP = kIsWeb ? 'localhost' : '192.168.1.1';
    }

    return _currentBaseUrl!;
  }

  /// Get current IP - GUARANTEED non-null
  static String get currentIP {
    if (_currentIP == null || _currentIP!.isEmpty) {
      // Return platform-appropriate emergency IP
      return kIsWeb ? 'localhost' : '192.168.1.1';
    }
    return _currentIP!;
  }

  /// Check if API is available
  static Future<bool> isApiAvailable() async {
    try {
      final baseUrl = await getBaseUrl();
      return await _testBaseUrl(baseUrl);
    } catch (e) {
      print('Error checking API availability: $e');
      return false; // API not available, but we still have a valid URL
    }
  }

  /// Test if base URL is accessible
  static Future<bool> _testBaseUrl(String baseUrl) async {
    try {
      final testUrl = '$baseUrl/test.php';
      print('🔍 Testing base URL: $testUrl');

      final response = await http.get(
        Uri.parse(testUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          bool success = data['success'] == true;
          print('🔍 Base URL test: ${success ? "✅ SUCCESS" : "❌ FAIL"}');
          return success;
        } catch (e) {
          print('🔍 Base URL test: ❌ FAIL (Invalid JSON)');
          return false;
        }
      } else {
        print('🔍 Base URL test: ❌ FAIL (${response.statusCode})');
        return false;
      }
    } catch (e) {
      print('🔍 Base URL test: ❌ FAIL ($e)');
      return false;
    }
  }

  /// Test IP helper
  static Future<bool> _testIP(String ip) async {
    try {
      final testUrl = 'http://$ip/$_projectPath/$_apiPath/test.php';
      final response = await http.get(
        Uri.parse(testUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Manual IP override with validation
  static Future<bool> setManualIP(String ip) async {
    try {
      print('🔧 Setting manual IP: $ip');

      // Validate IP format
      if (ip.trim().isEmpty) {
        print('❌ Manual IP is empty');
        return false;
      }

      final cleanIP = ip.trim();
      final testUrl = 'http://$cleanIP/$_projectPath/$_apiPath';

      // Test the IP
      if (await _testBaseUrl(testUrl)) {
        _currentIP = cleanIP;
        _currentBaseUrl = testUrl;
        _isInitialized = true;

        // Cache the working IP
        await NetworkDiscoveryService.setManualIP(cleanIP);

        print('✅ Manual IP set successfully: $cleanIP');
        return true;
      } else {
        print('❌ Manual IP is not accessible: $cleanIP');
        return false;
      }
    } catch (e) {
      print('❌ Error setting manual IP: $e');
      return false;
    }
  }

  /// Get comprehensive status for debugging
  static Future<Map<String, dynamic>> getStatus() async {
    final discoveryStatus = await NetworkDiscoveryService.getDiscoveryStatus();
    final baseUrl = await getBaseUrl(); // This ensures initialization

    return {
      'initialized': _isInitialized,
      'current_ip': currentIP, // Use getter for safety
      'base_url': baseUrl,
      'platform_info': discoveryStatus,
      'can_connect': await isApiAvailable(),
    };
  }

  /// Get platform name for debugging
  static Future<String> _getPlatformName() async {
    if (kIsWeb) return 'Web Browser';
    try {
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      if (Platform.isWindows) return 'Windows';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isLinux) return 'Linux';
    } catch (e) {
      // Platform detection might fail
    }
    return 'Unknown Platform';
  }
}
