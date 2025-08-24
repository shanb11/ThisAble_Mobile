import '../core/services/network_discovery_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Enhanced Dynamic API Configuration for ThisAble Mobile
/// Now supports ALL platforms with intelligent fallbacks
class DynamicApiConfig {
  static String? _currentBaseUrl;
  static String? _currentIP;
  static bool _isInitialized = false;

  // Your project structure
  static const String _projectPath = 'ThisAble';
  static const String _apiPath = 'api';

  /// Enhanced initialization with multi-platform support
  static Future<bool> initialize() async {
    if (_isInitialized && _currentBaseUrl != null) {
      print('✅ API Config already initialized: $_currentBaseUrl');
      return true; // Already working
    }

    print('🚀 Initializing Enhanced Dynamic API Config...');

    try {
      // Use enhanced network discovery
      final workingIP = await NetworkDiscoveryService.findWorkingIP();

      if (workingIP != null) {
        _currentIP = workingIP;
        _currentBaseUrl = 'http://$workingIP/$_projectPath/$_apiPath';
        _isInitialized = true;

        print('✅ API Config initialized successfully!');
        print('✅ Platform: ${await _getPlatformName()}');
        print('✅ IP: $workingIP');
        print('✅ Base URL: $_currentBaseUrl');
        return true;
      } else {
        print('❌ Network discovery failed - no working IP found');

        // Enhanced fallback handling
        return await _handleDiscoveryFailure();
      }
    } catch (e) {
      print('❌ Error during API config initialization: $e');
      return await _handleDiscoveryFailure();
    }
  }

  /// Handle discovery failure with intelligent fallbacks
  static Future<bool> _handleDiscoveryFailure() async {
    print('🔧 Attempting fallback configuration...');

    // Try platform-specific fallbacks
    String? fallbackIP;

    if (kIsWeb) {
      // Web browser fallback
      fallbackIP = 'localhost';
      print('🌐 Web platform fallback: $fallbackIP');
    } else {
      try {
        // Try to detect platform for better fallback
        if (Platform.isAndroid) {
          // Android emulator fallback
          fallbackIP = '10.0.2.2';
          print('🤖 Android emulator fallback: $fallbackIP');
        } else if (Platform.isIOS) {
          // iOS simulator fallback
          fallbackIP = 'localhost';
          print('📱 iOS simulator fallback: $fallbackIP');
        }
      } catch (e) {
        print('❓ Platform detection failed: $e');
      }
    }

    // Test fallback IP if we have one
    if (fallbackIP != null) {
      print('🔧 Testing fallback IP: $fallbackIP');

      try {
        final response = await http.get(
          Uri.parse('http://$fallbackIP/$_projectPath/$_apiPath/test.php'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            _currentIP = fallbackIP;
            _currentBaseUrl = 'http://$fallbackIP/$_projectPath/$_apiPath';
            _isInitialized = true;

            print('✅ Fallback configuration successful!');
            print('✅ Using fallback IP: $fallbackIP');

            // Cache this working IP
            try {
              await NetworkDiscoveryService.setManualIP(fallbackIP);
            } catch (e) {
              print('⚠️ Could not cache fallback IP: $e');
            }

            return true;
          }
        }
      } catch (e) {
        print('❌ Fallback test failed: $e');
      }
    }

    // Ultimate fallback - set a default but mark as failed
    print('❌ All discovery and fallback methods failed');
    _isInitialized = false;
    return false;
  }

  /// Get current base URL with enhanced error handling
  static Future<String> getBaseUrl() async {
    if (!_isInitialized || _currentBaseUrl == null) {
      final success = await initialize();
      if (!success) {
        throw Exception('Unable to determine API URL. Please check:\n'
            '1. XAMPP is running (Apache started)\n'
            '2. ThisAble project is at C:\\xampp\\htdocs\\ThisAble\n'
            '3. Your computer and device are on the same network\n'
            '4. Windows Firewall is not blocking connections');
      }
    }

    return _currentBaseUrl!;
  }

  /// Get current IP address
  static String? get currentIP => _currentIP;

  /// Check if API is available
  static Future<bool> isApiAvailable() async {
    try {
      await initialize();
      return _isInitialized;
    } catch (e) {
      return false;
    }
  }

  /// Enhanced refresh with better error handling
  static Future<bool> refresh() async {
    print('🔄 Force refreshing network configuration...');

    // Clear cache and re-initialize
    try {
      await NetworkDiscoveryService.clearCache();
    } catch (e) {
      print('⚠️ Could not clear cache: $e');
    }

    _isInitialized = false;
    _currentBaseUrl = null;
    _currentIP = null;

    return await initialize();
  }

  /// Set manual IP with validation
  static Future<bool> setManualIP(String ip) async {
    try {
      print('🔧 Setting manual IP: $ip');

      // Validate IP works before setting
      final response = await http.get(
        Uri.parse('http://$ip/$_projectPath/$_apiPath/test.php'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _currentIP = ip;
          _currentBaseUrl = 'http://$ip/$_projectPath/$_apiPath';
          _isInitialized = true;

          // Cache this IP
          await NetworkDiscoveryService.setManualIP(ip);

          print('✅ Manual IP set and validated: $ip');
          return true;
        }
      }

      throw Exception('Manual IP validation failed');
    } catch (e) {
      print('❌ Failed to set manual IP: $e');
      return false;
    }
  }

  /// Build specific endpoint URL
  static Future<String> buildEndpoint(String endpoint) async {
    final baseUrl = await getBaseUrl();
    return '$baseUrl/$endpoint';
  }

  /// Get comprehensive status for debugging
  static Future<Map<String, dynamic>> getStatus() async {
    final discoveryStatus = await NetworkDiscoveryService.getDiscoveryStatus();

    return {
      'initialized': _isInitialized,
      'current_ip': _currentIP,
      'base_url': _currentBaseUrl,
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

  /// Get all endpoints with current base URL
  static Future<Map<String, String>> getEndpoints() async {
    final baseUrl = await getBaseUrl();

    return {
      // Test endpoint
      'test': '$baseUrl/test.php',

      // Authentication
      'login': '$baseUrl/auth/login.php',
      'signup': '$baseUrl/auth/signup.php',
      'logout': '$baseUrl/auth/logout.php',
      'google_auth': '$baseUrl/auth/google.php',
      'verify_pwd': '$baseUrl/auth/verify_pwd.php',

      // Jobs & Categories (your current endpoints)
      'job_categories': '$baseUrl/jobs/categories.php',
      'job_listings': '$baseUrl/shared/jobs.php',
      'job_search': '$baseUrl/shared/jobs.php',

      // Candidate
      'get_user_data': '$baseUrl/candidate/get_user_data.php',
      'save_setup_data': '$baseUrl/candidate/save_setup_data.php',
      'upload_resume': '$baseUrl/candidate/upload_resume_process.php',

      // Shared
      'get_skills': '$baseUrl/shared/get_skills.php',
      'get_disability_types': '$baseUrl/shared/get_disability_types.php',
    };
  }

  /// Test connection to API
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final baseUrl = await getBaseUrl();
      final testUrl = '$baseUrl/test.php';

      print('🔧 Testing connection to: $testUrl');

      final response = await http.get(
        Uri.parse(testUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'status_code': response.statusCode,
          'response': data,
          'url': testUrl,
        };
      } else {
        return {
          'success': false,
          'status_code': response.statusCode,
          'error': 'HTTP ${response.statusCode}',
          'url': testUrl,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'url': 'Connection failed',
      };
    }
  }
}
