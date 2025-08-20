import '../core/services/network_discovery_service.dart';

/// Dynamic API Configuration for ThisAble Mobile
/// Automatically finds and uses the correct computer IP address
class DynamicApiConfig {
  static String? _currentBaseUrl;
  static String? _currentIP;
  static bool _isInitialized = false;

  // Your project structure
  static const String _projectPath = 'ThisAble';
  static const String _apiPath = 'api';

  /// Initialize the API configuration
  static Future<bool> initialize() async {
    if (_isInitialized && _currentBaseUrl != null) {
      return true; // Already working
    }

    print('🚀 Initializing Dynamic API Config...');

    try {
      // Auto-discover working IP
      final workingIP = await NetworkDiscoveryService.findWorkingIP();

      if (workingIP != null) {
        _currentIP = workingIP;
        _currentBaseUrl = 'http://$workingIP/$_projectPath/$_apiPath';
        _isInitialized = true;

        print('✅ API Config initialized with IP: $workingIP');
        print('✅ Base URL: $_currentBaseUrl');
        return true;
      } else {
        print('❌ Failed to find working IP');
        _isInitialized = false;
        return false;
      }
    } catch (e) {
      print('❌ Error initializing API config: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Get current base URL (auto-initializes if needed)
  static Future<String> getBaseUrl() async {
    if (!_isInitialized || _currentBaseUrl == null) {
      final success = await initialize();
      if (!success) {
        throw Exception(
            'Unable to determine API URL. Please check your network connection and XAMPP server.');
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

  /// Force refresh (useful when changing locations)
  static Future<bool> refresh() async {
    print('🔄 Refreshing API configuration...');

    // Clear cache and re-initialize
    await NetworkDiscoveryService.clearCache();
    _isInitialized = false;
    _currentBaseUrl = null;
    _currentIP = null;

    return await initialize();
  }

  /// Set manual IP (for debugging)
  static Future<bool> setManualIP(String ip) async {
    try {
      await NetworkDiscoveryService.setManualIP(ip);
      _currentIP = ip;
      _currentBaseUrl = 'http://$ip/$_projectPath/$_apiPath';
      _isInitialized = true;

      print('✅ Manual IP set: $ip');
      return true;
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

  /// Get all endpoints
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

      // Jobs & Landing (the failing one!)
      'job_categories': '$baseUrl/jobs/categories.php',
      'job_listings': '$baseUrl/shared/jobs.php',
      'job_search': '$baseUrl/shared/jobs.php',
      'contact_form': '$baseUrl/shared/contact.php',

      // Candidate
      'candidate_dashboard': '$baseUrl/candidate/get_dashboard_home.php',
      'candidate_user_data': '$baseUrl/candidate/get_user_data.php',
      'candidate_save_setup': '$baseUrl/candidate/save_setup_data.php',
      'candidate_save_skills': '$baseUrl/candidate/save_skills.php',
      'candidate_get_skills': '$baseUrl/candidate/get_skills.php',
      'candidate_applications': '$baseUrl/candidate/get_applications_list.php',
      'candidate_jobs_list': '$baseUrl/candidate/get_jobs_list.php',

      // Shared data
      'disability_types': '$baseUrl/shared/get_disability_types.php',
      'skills': '$baseUrl/shared/get_skills.php',
      'skill_categories': '$baseUrl/shared/get_skill_categories.php',
    };
  }

  /// Get network status for debugging
  static Future<Map<String, dynamic>> getNetworkStatus() async {
    return {
      'current_base_url': _currentBaseUrl,
      'current_ip': _currentIP,
      'is_initialized': _isInitialized,
      'project_path': _projectPath,
      'api_path': _apiPath,
    };
  }
}
