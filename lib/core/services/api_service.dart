import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart'; // Add this line
import '../../config/api_endpoints.dart';
import '../../config/dynamic_api_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math' as math;
// Only add this import if you're on web
import 'dart:html' as html;
import 'network_discovery_service.dart';

class ApiService {
  /// Add these methods anywhere in your ApiService class:

  static Future<Map<String, dynamic>> getNetworkStatus() async {
    return await DynamicApiConfig.getStatus();
  }

  static const String _tokenKey = 'api_token';
  static const String _userKey = 'current_user';

  // ===========================================
  // TOKEN MANAGEMENT
  // ===========================================

  /// Get stored auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Store auth token
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Clear auth token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Store current user data
  static Future<void> setCurrentUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(userData));
  }

  /// Get current user data
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return json.decode(userJson);
    }
    return null;
  }

  /// Clear all stored data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ===========================================
  // HTTP HELPERS - ENHANCED
  // ===========================================

  /// Common headers for API requests - FIXED NULL HANDLING
  static Future<Map<String, String>> _getHeaders(
      {bool includeAuth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty && token.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${token.trim()}';
        print(
            '🔧 Authorization header set: Bearer ${token.substring(0, 20)}...');
      } else {
        print('🔧 No valid token found for auth header');
      }
    }

    print('🔧 Headers: ${headers.keys.toList()}');

    // FIXED: Verify no null values in headers
    final cleanHeaders = <String, String>{};
    headers.forEach((key, value) {
      if (key != null && value != null && key.isNotEmpty && value.isNotEmpty) {
        cleanHeaders[key] = value;
      }
    });

    return cleanHeaders;
  }

  /// Handle API response (matches your PHP ApiResponse format)
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> data = json.decode(response.body);

      // Your PHP API returns 'success' field
      if (data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Success'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Unknown error occurred',
          'errors': data['errors'],
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to parse response: $e',
        'statusCode': response.statusCode
      };
    }
  }

  /// MISSING METHOD: Build API URI with proper async handling
  static Future<Uri> _buildApiUri(String endpoint) async {
    final baseUrl = await DynamicApiConfig.getBaseUrl();
    final fullUrl = '$baseUrl/$endpoint';
    return Uri.parse(fullUrl);
  }

  /// MISSING METHOD: Generic GET request method
  static Future<Map<String, dynamic>> _makeGetRequest(String endpoint) async {
    try {
      final uri = await _buildApiUri(endpoint);

      final response = await http.get(
        uri,
        headers: await _getHeaders(includeAuth: true),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Enhanced authenticated request handler - FIXED NULL HANDLING
  static Future<Map<String, dynamic>> _makeAuthenticatedRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      print('🔧 Making authenticated request to: $endpoint');

      // FIXED: Clean request body of null values
      final cleanBody = <String, dynamic>{};
      body.forEach((key, value) {
        if (value != null) {
          cleanBody[key] = value;
        }
      });

      print('🔧 Request body keys: ${cleanBody.keys.toList()}');

      final response = await http.post(
        await _buildApiUri(endpoint), // FIXED: await the async method
        headers: await _getHeaders(includeAuth: true),
        body: json.encode(cleanBody),
      );

      print('🔧 Response status: ${response.statusCode}');
      print('🔧 Response body: ${response.body}');

      final result = _handleResponse(response);

      // Enhanced token error handling
      if (!result['success'] &&
          result['message'] != null &&
          (result['message'].toString().toLowerCase().contains('token') ||
              result['message']
                  .toString()
                  .toLowerCase()
                  .contains('unauthorized') ||
              result['message']
                  .toString()
                  .toLowerCase()
                  .contains('authentication'))) {
        print('🔧 Token error detected, clearing storage');
        await clearAllData();

        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'requiresLogin': true
        };
      }

      return result;
    } catch (e) {
      print('🔧 Network error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ===========================================
  // AUTHENTICATION ENDPOINTS
  // ===========================================

  /// FIXED: Test connection - Now uses dynamic URL
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      // ✅ FIXED: Use dynamic URL construction
      final url = await ApiEndpoints.testConnection;

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Connection test failed: $e'};
    }
  }

  /// FIXED: Regular login - Now uses dynamic URL
  static Future<Map<String, dynamic>> login(
      {required String email, required String password}) async {
    try {
      // ✅ FIXED: Use dynamic URL construction
      final url = await ApiEndpoints.login;

      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// FIXED: Google Sign-In with proper async/await handling
  static Future<Map<String, dynamic>> googleSignIn({
    required String idToken,
    String? accessToken,
    String action = 'login',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      print('🔧 === ENHANCED GOOGLE SIGN-IN START ===');
      print('🔧 Platform: ${kIsWeb ? "WEB" : "MOBILE"}');

      // Build safe request body
      final requestBody = <String, dynamic>{
        'action': action.isNotEmpty ? action : 'login',
      };

      // Handle tokens safely
      final cleanIdToken = idToken.trim();
      final cleanAccessToken = accessToken?.trim() ?? '';

      bool hasValidIdToken = cleanIdToken.isNotEmpty;
      bool hasValidAccessToken = cleanAccessToken.isNotEmpty;

      if (hasValidIdToken) {
        requestBody['idToken'] = cleanIdToken;
      }

      if (hasValidAccessToken) {
        requestBody['accessToken'] = cleanAccessToken;
      }

      // Must have at least one token
      if (!hasValidIdToken && !hasValidAccessToken) {
        return {
          'success': false,
          'message': 'No valid authentication tokens available'
        };
      }

      // Add additional data safely
      if (additionalData != null) {
        final cleanAdditionalData = _deepCleanMap(additionalData);
        requestBody.addAll(cleanAdditionalData);
      }

      print('🔧 Request body keys: ${requestBody.keys.toList()}');

      // ✅ CRITICAL FIX: Properly await the ApiEndpoints method
      final googleAuthUrl = await ApiEndpoints.googleAuth;

      final response = await http.post(
        Uri.parse(googleAuthUrl),
        headers: await _getHeaders(),
        body: json.encode(requestBody),
      );

      final result = _handleResponse(response);

      // Store tokens if successful
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        if (data['token'] != null) {
          await setToken(data['token']);
        }
        if (data['user'] != null) {
          await setCurrentUser(data['user']);
        }
      }

      return result;
    } catch (e, stackTrace) {
      print('🔧 Google Sign-In error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Register new user
  static Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required int disability,
    required String pwdIdNumber,
    required String pwdIdIssuedDate,
    required String pwdIdIssuingLGU,
    String? middleName,
    String? suffix,
  }) async {
    try {
      // ✅ CORRECT:
      final url = await ApiEndpoints.signup;
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: json.encode({
          'firstName': firstName,
          'middleName': middleName,
          'lastName': lastName,
          'suffix': suffix,
          'email': email,
          'phone': phone,
          'password': password,
          'confirmPassword': confirmPassword,
          'disability': disability,
          'pwdIdNumber': pwdIdNumber,
          'pwdIdIssuedDate': pwdIdIssuedDate,
          'pwdIdIssuingLGU': pwdIdIssuingLGU,
        }),
      );

      final result = _handleResponse(response);

      // Store token and user data if signup successful
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        if (data['token'] != null) {
          await setToken(data['token']);
        }
        if (data['user'] != null) {
          await setCurrentUser(data['user']);
        }
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Verify PWD ID
  static Future<Map<String, dynamic>> verifyPwdId({
    required String pwdIdNumber,
    required String pwdIdIssuedDate,
    required String pwdIdIssuingLGU,
  }) async {
    try {
      // ✅ CORRECT:
      final url = await ApiEndpoints.verifyPwd;
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(includeAuth: true),
        body: json.encode({
          'pwdIdNumber': pwdIdNumber,
          'pwdIdIssuedDate': pwdIdIssuedDate,
          'pwdIdIssuingLGU': pwdIdIssuingLGU,
          'action': 'verify',
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Logout user
  static Future<Map<String, dynamic>> logout() async {
    try {
      // Clear local storage
      await clearAllData();

      return {'success': true, 'message': 'Logged out successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Logout failed: $e'};
    }
  }

  // ===========================================
  // SHARED ENDPOINTS (for app data)
  // ===========================================

  /// FIXED: Get disability types - Now uses dynamic URL
  static Future<Map<String, dynamic>> getDisabilityTypes() async {
    try {
      // ✅ FIXED: Use dynamic URL construction
      final url = await ApiEndpoints.getDisabilityTypes;

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get skill categories from database
  static Future<Map<String, dynamic>> getSkillCategories() async {
    try {
      final url = await ApiEndpoints.getSkillCategories;
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// FIXED: Get skills - Now uses dynamic URL
  static Future<Map<String, dynamic>> getSkills() async {
    try {
      // ✅ FIXED: Use dynamic URL construction
      final url = await ApiEndpoints.getSkills;

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ===========================================
  // CANDIDATE SETUP ENDPOINTS - ENHANCED
  // ===========================================

  /// Save selected skills - Enhanced version
  static Future<Map<String, dynamic>> saveSkills({
    required List<int> skillIds,
  }) async {
    try {
      print('🔧 === SAVE SKILLS ENHANCED ===');
      print('🔧 Skill IDs: $skillIds');

      final requestBody = {'skill_ids': skillIds};

      return await _makeAuthenticatedRequest(
        'candidate/save_skills.php',
        requestBody,
      );
    } catch (e) {
      print('🔧 ERROR in saveSkills: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Save work style (Step 3 of setup) - Enhanced version
  static Future<Map<String, dynamic>> saveWorkstyle(String workStyle) async {
    try {
      print('🔧 === SAVE WORKSTYLE ENHANCED ===');
      print('🔧 Work style: $workStyle');

      final requestBody = {'work_style': workStyle};

      return await _makeAuthenticatedRequest(
        'candidate/save_workstyle.php',
        requestBody,
      );
    } catch (e) {
      print('🔧 ERROR in saveWorkstyle: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Save job type (Step 4 of setup)
  static Future<Map<String, dynamic>> saveJobType(String jobType) async {
    try {
      print('🔧 === SAVE JOB TYPE ===');
      print('🔧 Job type: $jobType');

      final requestBody = {'job_type': jobType};

      return await _makeAuthenticatedRequest(
        'candidate/save_jobtype.php',
        requestBody,
      );
    } catch (e) {
      print('🔧 ERROR in saveJobType: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Save accommodations (Steps 6a/6b of setup) - Enhanced version
  static Future<Map<String, dynamic>> saveAccommodations({
    required String disabilityType,
    required List<String> accommodations,
    required bool noAccommodationsNeeded,
  }) async {
    try {
      print('🔧 === SAVE ACCOMMODATIONS ENHANCED ===');
      print('🔧 Disability type: $disabilityType');
      print('🔧 Accommodations: $accommodations');
      print('🔧 No accommodations needed: $noAccommodationsNeeded');

      final requestBody = {
        'disability_type': disabilityType,
        'accommodations': accommodations,
        'no_accommodations_needed': noAccommodationsNeeded,
      };

      return await _makeAuthenticatedRequest(
        'candidate/save_accommodations.php',
        requestBody,
      );
    } catch (e) {
      print('🔧 ERROR in saveAccommodations: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Complete setup process (Final step) - Enhanced version
  static Future<Map<String, dynamic>> completeSetup() async {
    try {
      print('🔧 === COMPLETE SETUP ENHANCED ===');

      return await _makeAuthenticatedRequest(
        'candidate/complete_setup.php',
        {}, // Empty body for completion endpoint
      );
    } catch (e) {
      print('🔧 ERROR in completeSetup: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// FIXED: Save setup data - Now uses dynamic URL
  static Future<Map<String, dynamic>> saveSetupData(
      Map<String, dynamic> data) async {
    try {
      // ✅ FIXED: Use dynamic URL construction
      final url = await ApiEndpoints.saveSetupData;

      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// FIXED: Get user data - Now uses dynamic URL
  static Future<Map<String, dynamic>> getUserData() async {
    try {
      // ✅ FIXED: Use dynamic URL construction
      final url = await ApiEndpoints.getUserData;

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ===========================================
  // JOB ENDPOINTS (for future use)
  // ===========================================

  /// Search jobs
  static Future<Map<String, dynamic>> searchJobs({
    String? keyword,
    String? location,
    String? category,
    int page = 1,
  }) async {
    try {
      Map<String, String> queryParams = {};
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      queryParams['page'] = page.toString();

      final baseUrl = await ApiEndpoints.searchJobs;
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ===========================================
  // UTILITY METHODS
  // ===========================================

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get device-appropriate base URL
// ✅ CORRECT - Fixed code:
  static Future<String> getDeviceUrl() async {
    // For Android emulator, use 10.0.2.2 instead of localhost
    // For iOS simulator, localhost works fine
    // For physical devices, use your computer's IP address

    final baseUrl = await ApiEndpoints.baseUrl;
    return baseUrl.replaceAll('localhost', '10.0.2.2');
  }

  /// Upload resume file - FIXED multipart request URI issue
  static Future<Map<String, dynamic>> uploadResume({
    required PlatformFile file,
  }) async {
    try {
      print('🔧 === UPLOAD RESUME DEBUG ===');
      print('🔧 File name: ${file.name}');
      print('🔧 File size: ${file.size}');

      // Check authentication
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Authentication required',
          'requiresLogin': true
        };
      }

      // FIXED: Properly await the URI building
      final uploadUri = await _buildApiUri('candidate/upload_resume.php');

      // Create multipart request with properly constructed URI
      var request = http.MultipartRequest('POST', uploadUri);

      // Add authentication header
      request.headers.addAll(await _getHeaders(includeAuth: true));

      // Handle file upload based on platform
      if (kIsWeb) {
        if (file.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'resume',
            file.bytes!,
            filename: file.name,
          ));
        } else {
          return {
            'success': false,
            'message': 'No file data available for web'
          };
        }
      } else {
        // Mobile platform
        if (file.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'resume',
            file.path!,
            filename: file.name,
          ));
        } else if (file.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'resume',
            file.bytes!,
            filename: file.name,
          ));
        } else {
          return {'success': false, 'message': 'No file available'};
        }
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      print('🔧 Resume upload error: $e');
      return {'success': false, 'message': 'Upload failed: $e'};
    }
  }

  // ==================== DASHBOARD APIs ====================

  // Dashboard Home Data
  static Future<Map<String, dynamic>> getDashboardHome() async {
    return await _makeGetRequest('candidate/get_dashboard_home.php');
  }

  /// Get job applications list - FIXED URI replace method issue
  /// Get job applications list - FIXED: Added missing searchQuery parameter
  static Future<Map<String, dynamic>> getApplicationsList({
    String? status,
    String? searchQuery, // ✅ ADDED: Missing searchQuery parameter
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      // ✅ ADDED: Handle searchQuery parameter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery; // Use 'search' to match PHP API
      }

      // ✅ FIXED: Properly await URI construction, then use replace
      final baseUri = await _buildApiUri('candidate/get_applications_list.php');
      final uri = baseUri.replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(uri, headers: await _getHeaders());
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Jobs List with Filters - FIXED: Await pattern for URI building
  static Future<Map<String, dynamic>> getJobsList({
    String? searchQuery,
    String? location,
    String? jobType,
    String? workArrangement,
    List<String>? accommodations,
    int? page,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      Map<String, String> queryParams =
          {}; // ✅ CHANGED: String keys and values for URI
      if (searchQuery != null) queryParams['search'] = searchQuery;
      if (location != null) queryParams['location'] = location;
      if (jobType != null) queryParams['job_type'] = jobType;
      if (workArrangement != null)
        queryParams['work_arrangement'] = workArrangement;
      if (accommodations != null)
        queryParams['accommodations'] = accommodations.join(',');
      if (page != null) queryParams['page'] = page.toString();

      // ✅ FIXED: Await the URI construction first, then call replace
      final baseUri = await _buildApiUri('candidate/get_jobs_list.php');
      final uri = baseUri.replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        uri,
        headers: await _getHeaders(includeAuth: true),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Profile Data
  static Future<Map<String, dynamic>> getProfileData() async {
    return await _makeGetRequest('candidate/get_profile_data.php');
  }

  // User Settings
  static Future<Map<String, dynamic>> getUserSettings() async {
    return await _makeGetRequest('candidate/get_user_settings.php');
  }

  // ==================== ACTION APIs ====================

  // Job Actions (Save/Apply)
  static Future<Map<String, dynamic>> performJobAction({
    required int jobId,
    required String action, // 'save' or 'apply'
    String? coverLetter,
  }) async {
    try {
      Map<String, dynamic> body = {
        'job_id': jobId,
        'action': action,
      };

      if (coverLetter != null) {
        body['cover_letter'] = coverLetter;
      }

      return await _makeAuthenticatedRequest('candidate/job_actions.php', body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Application Actions (Withdraw)
  static Future<Map<String, dynamic>> performApplicationAction({
    required int applicationId,
    required String action, // 'withdraw'
  }) async {
    try {
      final body = {
        'application_id': applicationId,
        'action': action,
      };

      return await _makeAuthenticatedRequest(
          'candidate/application_actions.php', body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Update Profile
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    try {
      return await _makeAuthenticatedRequest(
          'candidate/update_profile.php', profileData);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Update Settings
  static Future<Map<String, dynamic>> updateSettings(
      Map<String, dynamic> settingsData) async {
    try {
      return await _makeAuthenticatedRequest(
          'candidate/update_settings.php', settingsData);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
// ==================== LANDING PAGE APIs ====================
// ADD these methods to your existing ApiService class

  /// Landing page jobs - FIXED: Same async pattern
  static Future<Map<String, dynamic>> getLandingJobs({
    String? search,
    String? location,
    String? category,
    String? jobType,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (location != null && location.isNotEmpty)
        queryParams['location'] = location;
      if (category != null && category.isNotEmpty)
        queryParams['category'] = category;
      if (jobType != null && jobType.isNotEmpty)
        queryParams['job_type'] = jobType;

      // ✅ FIXED: Await the endpoint building, then use replace
      final endpoint = await DynamicApiConfig.buildEndpoint('shared/jobs.php');
      final uri = Uri.parse(endpoint).replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(uri, headers: await _getHeaders());
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getJobCategories() async {
    try {
      // Use dynamic API config instead of hardcoded IP
      final endpoint =
          await DynamicApiConfig.buildEndpoint('jobs/categories.php');

      print('🔧 Loading job categories from API...');
      print('🔧 Fetching categories from: $endpoint');

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔧 Categories API Response: ${response.statusCode}');
      print('🔧 Categories API Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'HTTP ${response.statusCode}: ${response.body}',
          'data': {
            'categories': [],
            'stats': {'total_jobs': 0, 'recent_jobs': 0}
          }
        };
      }
    } catch (e) {
      print('🔧 Error fetching categories: $e');

      // If network error, try to refresh IP configuration
      if (e.toString().toLowerCase().contains('no route to host') ||
          e.toString().toLowerCase().contains('connection refused')) {
        print('🔄 Network error detected, trying to refresh IP...');
        final refreshed = await DynamicApiConfig.refresh();

        if (refreshed) {
          print('✅ IP refreshed, retrying categories request...');
          // Retry once with new IP
          try {
            final endpoint =
                await DynamicApiConfig.buildEndpoint('jobs/categories.php');

            final response = await http.get(
              Uri.parse(endpoint),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            );

            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              return data;
            }
          } catch (retryError) {
            print('❌ Retry failed: $retryError');
          }
        }
      }

      return {
        'success': false,
        'message': 'Connection error: $e',
        'data': {
          'categories': [],
          'stats': {'total_jobs': 0, 'recent_jobs': 0}
        }
      };
    }
  }

// Also add this initialization method at the top of your ApiService class:

  /// Initialize API service with auto-discovery (ADD THIS METHOD)
  static Future<bool> initialize() async {
    try {
      print('🚀 Initializing API Service with auto-discovery...');
      final success = await DynamicApiConfig.initialize();

      if (success) {
        print('✅ API Service ready!');
        print('✅ Using IP: ${DynamicApiConfig.currentIP}');
        return true;
      } else {
        print('❌ API Service initialization failed');
        return false;
      }
    } catch (e) {
      print('❌ API Service initialization error: $e');
      return false;
    }
  }

// Add these helper methods for network management:

  /// Refresh IP configuration (call when changing locations)
  static Future<bool> refreshNetworkConfig() async {
    return await DynamicApiConfig.refresh();
  }

  /// Set manual IP (for debugging)
  static Future<bool> setManualIP(String ip) async {
    return await DynamicApiConfig.setManualIP(ip);
  }

  /// Get current network status
  static Future<Map<String, dynamic>> getStatus() async {
    return await DynamicApiConfig.getStatus();
  }

  /// Check if API is available
  static Future<bool> isApiAvailable() async {
    try {
      final result = await testConnection();
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Web-safe HTTP POST method - COMPLETELY NULL-PROOF
  static Future<http.Response> _webSafePost({
    required Uri uri,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
  }) async {
    try {
      // ULTRA-SAFE: Remove all null values and ensure strings
      final ultraCleanHeaders = <String, String>{};
      headers.forEach((key, value) {
        if (key != null &&
            value != null &&
            key.toString().trim().isNotEmpty &&
            value.toString().trim().isNotEmpty) {
          ultraCleanHeaders[key.toString().trim()] = value.toString().trim();
        }
      });

      // ULTRA-SAFE: Clean request body recursively
      final ultraCleanBody = _deepCleanMap(body);

      // ULTRA-SAFE: Ensure JSON can be encoded
      String jsonBody;
      try {
        jsonBody = json.encode(ultraCleanBody);
      } catch (e) {
        print('🔧 JSON Encoding Error: $e');
        throw Exception('Failed to encode request body: $e');
      }

      print('🔧 ULTRA-CLEAN Headers: $ultraCleanHeaders');
      print('🔧 ULTRA-CLEAN Body: ${ultraCleanBody.keys.toList()}');
      print('🔧 JSON Body Length: ${jsonBody.length}');

      // Make the actual request
      return await http.post(
        uri,
        headers: ultraCleanHeaders,
        body: jsonBody,
      );
    } catch (e) {
      print('🔧 _webSafePost Error: $e');
      rethrow;
    }
  }

  /// Recursively clean a map of all null values
  static Map<String, dynamic> _deepCleanMap(Map<String, dynamic> input) {
    final cleaned = <String, dynamic>{};

    input.forEach((key, value) {
      if (key != null && key.toString().trim().isNotEmpty) {
        final cleanKey = key.toString().trim();

        if (value == null) {
          // Skip null values entirely
          return;
        } else if (value is String) {
          if (value.isNotEmpty) {
            cleaned[cleanKey] = value;
          }
        } else if (value is Map) {
          final cleanedSubMap = _deepCleanMap(value.cast<String, dynamic>());
          if (cleanedSubMap.isNotEmpty) {
            cleaned[cleanKey] = cleanedSubMap;
          }
        } else if (value is List) {
          final cleanedList = value.where((item) => item != null).toList();
          if (cleanedList.isNotEmpty) {
            cleaned[cleanKey] = cleanedList;
          }
        } else {
          // For other types (int, bool, etc.), include them
          cleaned[cleanKey] = value;
        }
      }
    });

    return cleaned;
  }

  /// Add this debug method to your ApiService class
  /// Debug method for Google Auth configuration
  static Future<void> debugGoogleAuthConfiguration() async {
    print('🔍 === ROOT CAUSE ANALYSIS START ===');

    try {
      // 1. Check all URL configurations
      print('🔍 STEP 1: URL Configuration Analysis');
      final baseUrl = await DynamicApiConfig.getBaseUrl();
      final googleAuthUrl = await ApiEndpoints.googleAuth;

      print('🔍 DynamicApiConfig.getBaseUrl(): "$baseUrl"');
      print('🔍 ApiEndpoints.googleAuth: "$googleAuthUrl"');

      // 2. Check if any URLs are null or contain null
      print('🔍 Final googleAuth URL: "$googleAuthUrl"');
      print('🔍 googleAuth URL is null: ${googleAuthUrl == null}');
      print(
          '🔍 googleAuth URL contains "null": ${googleAuthUrl.contains("null")}');
      print('🔍 googleAuth URL length: ${googleAuthUrl.length}');

      // 3. Check URI parsing
      try {
        final uri = Uri.parse(googleAuthUrl);
        print('🔍 URI parsed successfully');
        print('🔍 URI scheme: "${uri.scheme}"');
        print('🔍 URI host: "${uri.host}"');
        print('🔍 URI port: ${uri.port}');
        print('🔍 URI path: "${uri.path}"');
        print('🔍 URI hasEmptyPath: ${uri.hasEmptyPath}');
      } catch (e) {
        print('🔍 ❌ URI parsing failed: $e');
      }

      // 4. Test basic connectivity
      print('🔍 STEP 2: Network Connectivity Test');
      try {
        final testUrl = googleAuthUrl.replaceAll('google.php', 'test.php');
        print('🔍 Testing connectivity to: $testUrl');

        final response = await http.get(
          Uri.parse(testUrl),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 10));

        print('🔍 Test response status: ${response.statusCode}');
        print('🔍 Test response body length: ${response.body.length}');
      } catch (e) {
        print('🔍 ❌ Network test failed: $e');
      }
    } catch (e, stackTrace) {
      print('🔍 ❌ Debug analysis failed: $e');
      print('🔍 Stack trace: $stackTrace');
    }

    print('🔍 === ROOT CAUSE ANALYSIS COMPLETE ===');
  }

  /// FIXED: Google Sign-In - Now uses dynamic URL construction
  static Future<Map<String, dynamic>> googleSignInDebug({
    required String idToken,
    String? accessToken,
    String action = 'login',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      print('🔧 === FIXED GOOGLE SIGN-IN DEBUG ===');
      print('🔧 Using dynamic URL construction...');

      // ✅ FIXED: Use dynamic URL instead of hardcoded
      final url = await ApiEndpoints.googleAuth;
      print('🔧 Dynamic URL: $url');

      // Build request body
      final requestBody = <String, dynamic>{
        'action': action,
      };

      if (idToken.trim().isNotEmpty) {
        requestBody['idToken'] = idToken.trim();
      }

      if (accessToken != null && accessToken.trim().isNotEmpty) {
        requestBody['accessToken'] = accessToken.trim();
      }

      if (additionalData != null) {
        additionalData.forEach((key, value) {
          if (value != null) {
            requestBody[key] = value;
          }
        });
      }

      print('🔧 Request body keys: ${requestBody.keys.toList()}');

      // Make request with dynamic URL
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      print('🔧 ✅ Dynamic URL request successful!');
      print('🔧 Response status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e, stackTrace) {
      print('🔧 ❌ Dynamic Google Sign-In failed: $e');
      print('🔧 Stack trace: $stackTrace');
      return {'success': false, 'message': 'Dynamic sign-in failed: $e'};
    }
  }

  // Add this debug method to test the fixes
  static Future<void> debugWebPlatformFix() async {
    print('🔍 === WEB PLATFORM FIX DEBUG TEST ===');

    try {
      // Test 1: Check platform detection
      print('🔍 Platform: ${kIsWeb ? "WEB" : "MOBILE"}');

      // Test 2: Test network discovery
      print('🔍 Testing network discovery...');
      final discoveredIP = await NetworkDiscoveryService.findWorkingIP();
      print('🔍 Discovered IP: $discoveredIP');
      print('🔍 IP is null: ${discoveredIP == null}');
      print('🔍 IP is empty: ${discoveredIP?.isEmpty ?? true}');

      // Test 3: Test dynamic API config
      print('🔍 Testing dynamic API config...');
      final initSuccess = await DynamicApiConfig.initialize();
      print('🔍 Init success: $initSuccess');

      final baseUrl = await DynamicApiConfig.getBaseUrl();
      print('🔍 Base URL: $baseUrl');
      print('🔍 Base URL is null: ${baseUrl == null}');
      print('🔍 Base URL contains "null": ${baseUrl.contains("null")}');

      // Test 4: Test API endpoints
      // Test 4: Test API endpoints
      print('🔍 Testing API endpoints...');
      final googleAuthUrl =
          await ApiEndpoints.googleAuth; // ✅ FIXED: Added await
      print('🔍 Google Auth URL: $googleAuthUrl'); // ✅ FIXED: Use variable
      print(
          '🔍 Google Auth contains "null": ${googleAuthUrl.contains("null")}'); // ✅ FIXED: Use variable
      // Test 5: Test basic connectivity
      print('🔍 Testing basic connectivity...');
      try {
        final response = await http.get(
          Uri.parse('${baseUrl}/test.php'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 10));

        print('🔍 ✅ Connection test SUCCESS: ${response.statusCode}');
        if (response.body.isNotEmpty) {
          print('🔍 Response preview: ${response.body.substring(0, 100)}...');
        }
      } catch (e) {
        print('🔍 ❌ Connection test FAILED: $e');
      }

      // Test 6: Test Google Sign-In URL construction
      print('🔍 Testing Google Sign-In URL construction...');
      final googleUrl = await ApiEndpoints.googleAuth;
      final uri = Uri.parse(googleUrl);
      print('🔍 Google URL scheme: ${uri.scheme}');
      print('🔍 Google URL host: ${uri.host}');
      print('🔍 Google URL path: ${uri.path}');
      print('🔍 Google URL is valid: ${uri.hasScheme && uri.hasAuthority}');
    } catch (e, stackTrace) {
      print('🔍 ❌ Debug test failed: $e');
      print('🔍 Stack trace: $stackTrace');
    }

    print('🔍 === DEBUG TEST COMPLETE ===');
  }

// Add this to your ApiService class for easy testing
  static Future<Map<String, dynamic>> testWebGoogleSignIn({
    required String idToken,
    String? accessToken,
  }) async {
    print('🔧 === TESTING WEB GOOGLE SIGN-IN ===');

    // First run debug test
    await debugWebPlatformFix();

    try {
      // Build safe request body
      final requestBody = <String, dynamic>{
        'action': 'login',
      };

      if (idToken.trim().isNotEmpty) {
        requestBody['idToken'] = idToken.trim();
      }

      if (accessToken != null && accessToken.trim().isNotEmpty) {
        requestBody['accessToken'] = accessToken.trim();
      }

      print('🔧 Request body: ${requestBody.keys}');

      // Get guaranteed non-null URL
      final url = await ApiEndpoints.googleAuth;
      print('🔧 Using URL: $url');

      // Make safe request
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      print('🔧 ✅ Request successful!');
      print('🔧 Status: ${response.statusCode}');
      print('🔧 Response: ${response.body}');

      return _handleResponse(response);
    } catch (e, stackTrace) {
      print('🔧 ❌ Test request failed: $e');
      print('🔧 Error type: ${e.runtimeType}');
      print('🔧 Stack trace: $stackTrace');

      return {
        'success': false,
        'message': 'Test request failed: $e',
      };
    }
  }
}
