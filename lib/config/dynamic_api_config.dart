import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/network_discovery_service.dart';

const String PRODUCTION_API_URL =
    'https://thisable-production.up.railway.app/api';
const bool USE_PRODUCTION =
    true; // ← Toggle: true = Vercel, false = Local XAMPP

/// Dynamic API Configuration
/// Manages API base URL with automatic network discovery
/// ✅ ENHANCED: Now supports both local dev and production deployment
class DynamicApiConfig {
  static const String _prefKey = 'api_base_url';
  static const String _ipKey = 'discovered_ip';
  static String? currentIP;
  static const String port = '80'; // XAMPP default port
  static const String projectPath = 'ThisAble/api';

  /// Get the base URL (checks production flag first)
  static Future<String> getBaseUrl() async {
    // ✅ NEW: Check if we should use production API
    if (USE_PRODUCTION) {
      print('🌐 Using PRODUCTION API: $PRODUCTION_API_URL');
      // Production URL already includes https:// and /api path
      return PRODUCTION_API_URL;
    }

    // For local development, keep the http:// prefix
    if (currentIP != null) {
      final baseUrl = 'http://$currentIP:$port/$projectPath';
      print('📡 Using LOCAL API: $baseUrl');
      return baseUrl;
    }

    // Try to get cached IP
    final prefs = await SharedPreferences.getInstance();
    final cachedIP = prefs.getString(_ipKey);

    if (cachedIP != null) {
      currentIP = cachedIP;
      final baseUrl = 'http://$cachedIP:$port/$projectPath';
      print('💾 Using CACHED IP: $baseUrl');
      return baseUrl;
    }

    // Fallback to production if local discovery fails
    print('⚠️ Local IP not found, falling back to PRODUCTION');
    return PRODUCTION_API_URL;
  }

  /// Get the file base URL (without /api suffix for direct file access)
  static Future<String> getFileBaseUrl() async {
    // For production
    if (USE_PRODUCTION) {
      // Remove /api from production URL
      return 'https://thisable-production.up.railway.app';
    }

    // For local development
    if (currentIP != null) {
      return 'http://$currentIP:$port/ThisAble';
    }

    // Try cached IP
    final prefs = await SharedPreferences.getInstance();
    final cachedIP = prefs.getString(_ipKey);

    if (cachedIP != null) {
      return 'http://$cachedIP:$port/ThisAble';
    }

    // Fallback to production
    return 'https://thisable-production.up.railway.app';
  }

  /// Initialize configuration
  static Future<bool> initialize() async {
    print('🔧 Initializing DynamicApiConfig...');

    // If using production, skip IP discovery
    if (USE_PRODUCTION) {
      print('🌐 Production mode enabled, skipping IP discovery');
      return true;
    }

    // Try to find working IP for local development
    currentIP = await NetworkDiscoveryService.findWorkingIP();

    if (currentIP != null) {
      // Cache the IP
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_ipKey, currentIP!);
      print('✅ IP discovered and cached: $currentIP');
      return true;
    }

    print('⚠️ Local IP discovery failed, will use production');
    return true; // Still return true since we have production fallback
  }

  /// Refresh IP configuration (force rediscover)
  static Future<bool> refresh() async {
    print('🔄 Refreshing IP configuration...');

    // If using production, no need to refresh
    if (USE_PRODUCTION) {
      print('🌐 Production mode, no refresh needed');
      return true;
    }

    // Clear cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ipKey);
    currentIP = null;

    // Rediscover
    return await initialize();
  }

  /// Set manual IP (for debugging local setup)
  static Future<bool> setManualIP(String ip) async {
    print('🔧 Setting manual IP: $ip');
    currentIP = ip;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipKey, ip);

    return true;
  }

  /// Get current status
  static Future<Map<String, dynamic>> getStatus() async {
    final baseUrl = await getBaseUrl();

    return {
      'using_production': USE_PRODUCTION,
      'production_url': PRODUCTION_API_URL,
      'current_ip': currentIP,
      'current_base_url': baseUrl,
      'is_local': !USE_PRODUCTION && currentIP != null,
    };
  }

  /// Build full endpoint URL
  static Future<String> buildEndpoint(String endpoint) async {
    final baseUrl = await getBaseUrl();
    // Remove leading slash if present
    final cleanEndpoint =
        endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$baseUrl/$cleanEndpoint';
  }
}
