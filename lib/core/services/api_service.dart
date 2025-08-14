import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart'; // Add this line
import '../../config/api_endpoints.dart';

class ApiService {
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

  /// Build API URI consistently
  static Uri _buildApiUri(String endpoint) {
    return Uri.parse('${ApiEndpoints.baseUrl}/$endpoint');
  }

  //added
  static Future<Map<String, dynamic>> _makeGetRequest(String endpoint) async {
    try {
      final token = await getToken();
      print('🔧 API Call: $endpoint');
      print('🔧 Token: ${token?.substring(0, 20)}...');

      final response = await http.get(
        _buildApiUri(endpoint),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🔧 Status Code: ${response.statusCode}');
      print('🔧 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('🔧 API Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Common headers for API requests
  static Future<Map<String, String>> _getHeaders(
      {bool includeAuth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print(
            '🔧 Authorization header set: Bearer ${token.substring(0, 20)}...');
      } else {
        print('🔧 No token found for auth header');
      }
    }

    print('🔧 Headers: ${headers.keys.toList()}');
    return headers;
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

  /// Enhanced authenticated request handler
  static Future<Map<String, dynamic>> _makeAuthenticatedRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      print('🔧 Making authenticated request to: $endpoint');
      print('🔧 Request body: $body');

      final response = await http.post(
        _buildApiUri(endpoint),
        headers: await _getHeaders(includeAuth: true),
        body: json.encode(body),
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

  /// Test API connection
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        _buildApiUri('test.php'),
        headers: await _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Login user with email and password
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final result = _handleResponse(response);

      // Store token and user data if login successful
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

  /// Google Sign-In
  static Future<Map<String, dynamic>> googleSignIn({
    required String idToken,
    String? accessToken,
    String action = 'login',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      Map<String, dynamic> requestBody = {
        'idToken': idToken,
        'action': action,
      };

      if (accessToken != null) {
        requestBody['accessToken'] = accessToken;
      }

      // Add additional data for profile completion
      if (additionalData != null) {
        requestBody.addAll(additionalData);
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.googleAuth),
        headers: await _getHeaders(),
        body: json.encode(requestBody),
      );

      final result = _handleResponse(response);

      // Store token and user data if Google sign-in successful
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        if (data['token'] != null) {
          await setToken(data['token']);
          print('DEBUG: Token saved after Google Sign-In');
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
      final response = await http.post(
        Uri.parse(ApiEndpoints.signup),
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
      final response = await http.post(
        Uri.parse(ApiEndpoints.verifyPwd),
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

  /// Get disability types from database
  static Future<Map<String, dynamic>> getDisabilityTypes() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getDisabilityTypes),
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
      final response = await http.get(
        Uri.parse(ApiEndpoints.getSkillCategories),
        headers: await _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get skills from database
  static Future<Map<String, dynamic>> getSkills() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getSkills),
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

  /// Save job type (Step 4 of setup) - Enhanced version
  static Future<Map<String, dynamic>> saveJobType(String jobType) async {
    try {
      print('🔧 === SAVE JOB TYPE ENHANCED ===');
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

  /// Save setup data (general preferences) - Enhanced version
  static Future<Map<String, dynamic>> saveSetupData({
    String? workStyle,
    String? jobType,
    String? salaryRange,
    String? availability,
  }) async {
    try {
      print('🔧 === SAVE SETUP DATA ENHANCED ===');

      final requestBody = {
        'work_style': workStyle,
        'job_type': jobType,
        'salary_range': salaryRange,
        'availability': availability,
      };

      return await _makeAuthenticatedRequest(
        'candidate/save_setup_data.php',
        requestBody,
      );
    } catch (e) {
      print('🔧 ERROR in saveSetupData: $e');
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

      final uri = Uri.parse(ApiEndpoints.searchJobs)
          .replace(queryParameters: queryParams);

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
  static String getDeviceUrl() {
    // For Android emulator, use 10.0.2.2 instead of localhost
    // For iOS simulator, localhost works fine
    // For physical devices, use your computer's IP address

    return ApiEndpoints.baseUrl.replaceAll('localhost', '10.0.2.2');
  }

  /// Upload resume file - Fixed for mobile compatibility
  static Future<Map<String, dynamic>> uploadResume({
    required PlatformFile file,
  }) async {
    try {
      print('🔧 === UPLOAD RESUME DEBUG ===');
      print('🔧 File name: ${file.name}');
      print('🔧 File size: ${file.size}');
      print('🔧 File path: ${file.path}');
      print('🔧 File bytes available: ${file.bytes != null}');

      // Check authentication
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Authentication required',
          'requiresLogin': true
        };
      }

      // Validate file size (5MB max)
      if (file.size > 5 * 1024 * 1024) {
        return {'success': false, 'message': 'File size exceeds 5MB limit'};
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        _buildApiUri('candidate/upload_resume.php'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // FIXED: Use file path instead of bytes for mobile compatibility
      if (file.path != null) {
        // Use file path (works on mobile)
        request.files.add(
          await http.MultipartFile.fromPath(
            'resume_file',
            file.path!,
            filename: file.name,
          ),
        );
        print('🔧 Added file from path: ${file.path}');
      } else if (file.bytes != null) {
        // Fallback to bytes (for web)
        request.files.add(
          http.MultipartFile.fromBytes(
            'resume_file',
            file.bytes!,
            filename: file.name,
          ),
        );
        print('🔧 Added file from bytes');
      } else {
        return {
          'success': false,
          'message': 'File data not available - no path or bytes'
        };
      }

      print('🔧 Sending multipart request...');

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('🔧 Upload response status: ${response.statusCode}');
      print('🔧 Upload response body: ${response.body}');

      final result = _handleResponse(response);

      // Handle token errors
      if (!result['success'] &&
          result['message'] != null &&
          (result['message'].toString().toLowerCase().contains('token') ||
              result['message']
                  .toString()
                  .toLowerCase()
                  .contains('unauthorized'))) {
        await clearAllData();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'requiresLogin': true
        };
      }

      return result;
    } catch (e) {
      print('🔧 Upload error: $e');
      return {'success': false, 'message': 'Upload failed: $e'};
    }
  }

  // ==================== DASHBOARD APIs ====================

  // Dashboard Home Data
  static Future<Map<String, dynamic>> getDashboardHome() async {
    return await _makeGetRequest('candidate/get_dashboard_home.php');
  }

  // Applications List
  static Future<Map<String, dynamic>> getApplicationsList({
    String? status,
    String? searchQuery,
    int? page,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      Map<String, dynamic> queryParams = {};
      if (status != null) queryParams['status'] = status;
      if (searchQuery != null) queryParams['search'] = searchQuery;
      if (page != null) queryParams['page'] = page.toString();

      final uri = _buildApiUri('candidate/get_applications_list.php').replace(
          queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: await _getHeaders(includeAuth: true),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Jobs List with Filters
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

      Map<String, dynamic> queryParams = {};
      if (searchQuery != null) queryParams['search'] = searchQuery;
      if (location != null) queryParams['location'] = location;
      if (jobType != null) queryParams['job_type'] = jobType;
      if (workArrangement != null)
        queryParams['work_arrangement'] = workArrangement;
      if (accommodations != null)
        queryParams['accommodations'] = accommodations.join(',');
      if (page != null) queryParams['page'] = page.toString();

      final uri = _buildApiUri('candidate/get_jobs_list.php').replace(
          queryParameters: queryParams.isNotEmpty ? queryParams : null);

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

  /// Get jobs for landing page (calls your jobs.php)
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

      // Build URI - calls your shared/jobs.php
      final uri = Uri.parse('http://192.168.1.3/ThisAble/api/shared/jobs.php')
          .replace(
              queryParameters: queryParams.isNotEmpty ? queryParams : null);

      print('🔧 Fetching jobs from: $uri');

      // Make request (no auth required for public landing page)
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔧 Jobs API Response: ${response.statusCode}');
      print('🔧 Jobs API Body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'HTTP ${response.statusCode}: ${response.body}',
          'data': {
            'jobs': [],
            'pagination': {
              'total': 0,
              'limit': limit,
              'offset': offset,
              'has_more': false
            }
          }
        };
      }
    } catch (e) {
      print('🔧 Error fetching jobs: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'data': {
          'jobs': [],
          'pagination': {
            'total': 0,
            'limit': limit,
            'offset': offset,
            'has_more': false
          }
        }
      };
    }
  }

  /// Get job categories with real counts (calls your categories.php)
  static Future<Map<String, dynamic>> getJobCategories() async {
    try {
      // FIX: Use config instead of hardcoded IP!
      final uri = Uri.parse(AppConstants.landingJobCategories);

      print('🔧 Fetching categories from: $uri');

      final response = await http.get(
        uri,
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
}
