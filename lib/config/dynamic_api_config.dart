import '../core/services/network_discovery_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Enhanced Dynamic API Configuration for ThisAble Mobile
/// Complete implementation with all required methods for seamless IP discovery
/// Supports your varying IP addresses across different locations
class DynamicApiConfig {
  static String? _currentBaseUrl;
  static String? _currentIP;
  static bool _isInitialized = false;

  // Your project structure
  static const String _projectPath = 'ThisAble';
  static const String _apiPath = 'api';

  // ===========================================
  // CORE INITIALIZATION METHODS
  // ===========================================

  /// Enhanced initialization with GUARANTEED non-null return
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
      // Use your enhanced network discovery with guaranteed non-null return
      final workingIP = await NetworkDiscoveryService.findWorkingIP();

      // CRITICAL: workingIP should never be null after your fix, but safety check
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
        if (!isAccessible) {
          print('⚠️ Base URL not accessible, but keeping configuration');
        }

        return true;
      } else {
        print('❌ Network discovery failed to find working IP');
        // Set emergency fallback URL but still return true for app stability
        _setEmergencyFallback();
        return true; // Return true to prevent app from crashing
      }
    } catch (e) {
      print('❌ API Config initialization error: $e');
      _setEmergencyFallback();
      return true; // Return true to prevent app from crashing
    }
  }

  /// MISSING METHOD: Force refresh configuration (for changing locations)
  static Future<bool> refresh() async {
    print('🔄 Force refreshing API configuration...');

    // Reset initialization flag to force rediscovery
    _isInitialized = false;
    _currentIP = null;
    _currentBaseUrl = null;

    // Clear cached IP in NetworkDiscoveryService
    try {
      // Call your NetworkDiscoveryService cache clearing if available
      // This method might exist in your NetworkDiscoveryService
      await NetworkDiscoveryService.clearCache();
    } catch (e) {
      print('⚠️ Could not clear network cache: $e');
    }

    // Reinitialize with fresh discovery
    return await initialize();
  }

  // ===========================================
  // URL CONSTRUCTION METHODS
  // ===========================================

  /// MISSING METHOD: Build complete endpoint URL
  static Future<String> buildEndpoint(String endpoint) async {
    final baseUrl = await getBaseUrl();
    return '$baseUrl/$endpoint';
  }

  /// ENHANCED: Complete getBaseUrl implementation with guaranteed return
  static Future<String> getBaseUrl() async {
    // If not initialized or URL is null, initialize first
    if (!_isInitialized ||
        _currentBaseUrl == null ||
        _currentBaseUrl!.isEmpty) {
      print('🔧 API Config not ready, initializing...');
      await initialize();
    }

    // After initialization, we should have a base URL
    if (_currentBaseUrl != null && _currentBaseUrl!.isNotEmpty) {
      return _currentBaseUrl!;
    }

    // Emergency fallback - this should rarely happen
    print('🚨 Using emergency fallback URL');
    final emergencyUrl = kIsWeb
        ? 'http://localhost/$_projectPath/$_apiPath'
        : 'http://192.168.1.1/$_projectPath/$_apiPath';

    _currentBaseUrl = emergencyUrl;
    return emergencyUrl;
  }

  /// ENHANCED: Safe current IP getter with guaranteed return
  static String get currentIP {
    if (_currentIP == null || _currentIP!.isEmpty) {
      // Return platform-appropriate emergency IP
      return kIsWeb ? 'localhost' : '192.168.1.1';
    }
    return _currentIP!;
  }

  // ===========================================
  // UTILITY METHODS
  // ===========================================

  /// Set emergency fallback configuration
  static void _setEmergencyFallback() {
    final emergencyIP = kIsWeb ? 'localhost' : '192.168.1.1';
    final emergencyUrl = kIsWeb
        ? 'http://localhost/$_projectPath/$_apiPath'
        : 'http://192.168.1.1/$_projectPath/$_apiPath';

    _currentIP = emergencyIP;
    _currentBaseUrl = emergencyUrl;
    _isInitialized = true;

    print('🚨 Using emergency fallback configuration');
    print('🚨 Emergency IP: $emergencyIP');
    print('🚨 Emergency URL: $emergencyUrl');
  }

  /// Check if API is available
  static Future<bool> isApiAvailable() async {
    try {
      final baseUrl = await getBaseUrl();
      return await _testBaseUrl(baseUrl);
    } catch (e) {
      print('Error checking API availability: $e');
      return false;
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

        // Cache the working IP in NetworkDiscoveryService
        try {
          await NetworkDiscoveryService.setManualIP(cleanIP);
        } catch (e) {
          print('⚠️ Could not cache IP in NetworkDiscoveryService: $e');
        }

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
    Map<String, dynamic> discoveryStatus = {};

    try {
      discoveryStatus = await NetworkDiscoveryService.getDiscoveryStatus();
    } catch (e) {
      print('⚠️ Could not get NetworkDiscoveryService status: $e');
      discoveryStatus = {'error': 'NetworkDiscoveryService unavailable'};
    }

    final baseUrl = await getBaseUrl(); // This ensures initialization

    return {
      'initialized': _isInitialized,
      'current_ip': currentIP, // Use getter for safety
      'current_base_url': _currentBaseUrl,
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

  // ===========================================
  // BACKWARD COMPATIBILITY & CONVENIENCE
  // ===========================================

  /// Quick connection test method
  static Future<bool> testConnection() async {
    try {
      final baseUrl = await getBaseUrl();
      final testUrl = '$baseUrl/test.php';

      final response = await http.get(
        Uri.parse(testUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Reset configuration (useful for testing)
  static void reset() {
    _isInitialized = false;
    _currentIP = null;
    _currentBaseUrl = null;
    print('🔄 API Configuration reset');
  }

  /// Get current configuration summary
  static Map<String, String?> getCurrentConfig() {
    return {
      'current_ip': _currentIP,
      'current_base_url': _currentBaseUrl,
      'is_initialized': _isInitialized.toString(),
      'platform': kIsWeb ? 'Web' : 'Mobile',
    };
  }
}
