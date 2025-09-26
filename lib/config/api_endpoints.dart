import 'dynamic_api_config.dart';

/// FIXED API Endpoints - Now uses your NetworkDiscoveryService via DynamicApiConfig
/// No more hardcoded IPs! Works on web emulator AND physical devices
class ApiEndpoints {
  // DYNAMIC BASE URL - Uses your NetworkDiscoveryService
  static Future<String> get baseUrl => DynamicApiConfig.getBaseUrl();

  // DYNAMIC Authentication endpoints - No more hardcoded IPs!
  static Future<String> get login async => '${await baseUrl}/auth/login.php';
  static Future<String> get signup async => '${await baseUrl}/auth/signup.php';
  static Future<String> get logout async => '${await baseUrl}/auth/logout.php';
  static Future<String> get googleAuth async =>
      '${await baseUrl}/auth/google.php';
  static Future<String> get verifyPwd async =>
      '${await baseUrl}/auth/verify_pwd.php';

  // DYNAMIC Job endpoints
  static Future<String> get searchJobs async =>
      '${await baseUrl}/shared/jobs.php';
  static Future<String> get getCategories async =>
      '${await baseUrl}/jobs/categories.php';
  static Future<String> get getJobListings async =>
      '${await baseUrl}/candidate/get_job_listings.php';

  // DYNAMIC Test endpoint
  static Future<String> get testConnection async => '${await baseUrl}/test.php';

  // DYNAMIC Shared endpoints
  static Future<String> get getDisabilityTypes async =>
      '${await baseUrl}/shared/get_disability_types.php';
  static Future<String> get getSkills async =>
      '${await baseUrl}/shared/get_skills.php';
  static Future<String> get getSkillCategories async =>
      '${await baseUrl}/shared/get_skill_categories.php';

  // DYNAMIC Candidate endpoints
  static Future<String> get getUserData async =>
      '${await baseUrl}/candidate/get_user_data.php';
  static Future<String> get saveSetupData async =>
      '${await baseUrl}/candidate/save_setup_data.php';
  static Future<String> get saveSkills async =>
      '${await baseUrl}/candidate/save_skills.php';
  static Future<String> get getCandidateSkills async =>
      '${await baseUrl}/candidate/get_skills.php';
  static Future<String> get getSeekerSkills async =>
      '${await baseUrl}/candidate/get_seeker_skills.php';
  static Future<String> get uploadResume async =>
      '${await baseUrl}/candidate/upload_resume_process.php';
  static Future<String> get deleteResume async =>
      '${await baseUrl}/candidate/delete_resume.php';
  static Future<String> get viewResume async =>
      '${await baseUrl}/candidate/view_resume.php';
  static Future<String> get updatePersonalInfo async =>
      '${await baseUrl}/candidate/update_personal_info.php';
  static Future<String> get updateContactInfo async =>
      '${await baseUrl}/candidate/update_contact_info.php';
  static Future<String> get updateEducation async =>
      '${await baseUrl}/candidate/update_education.php';
  static Future<String> get updateExperience async =>
      '${await baseUrl}/candidate/update_experience.php';
  static Future<String> get deleteEducation async =>
      '${await baseUrl}/candidate/delete_education.php';
  static Future<String> get deleteExperience async =>
      '${await baseUrl}/candidate/delete_experience.php';
  static Future<String> get uploadProfileImage async =>
      '${await baseUrl}/candidate/upload_profile_image.php';
  static Future<String> get getDashboardHome async =>
      '${await baseUrl}/candidate/get_dashboard_home.php';
  static Future<String> get getApplicationsList async =>
      '${await baseUrl}/candidate/get_applications_list.php';
  static Future<String> get getEnhancedJobListings async =>
      '${await baseUrl}/candidate/get_enhanced_job_listings.php';

  // UTILITY: Build any endpoint dynamically
  static Future<String> buildUrl(String endpoint) async {
    final base = await baseUrl;
    return '$base/$endpoint';
  }

  // UTILITY: Get current network status for debugging
  static Future<Map<String, dynamic>> getNetworkStatus() async {
    return await DynamicApiConfig.getStatus();
  }
}

/// CLEANED AppConstants - NO MORE HARDCODED URLs
/// All URL constants moved to dynamic ApiEndpoints class above
class AppConstants {
  // App Information (non-URL constants)
  static const String appName = 'ThisAble Mobile';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Job Portal for Inclusive Hiring';
  static const String apiVersion = 'v1';

  // Error Messages
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorAuth = 'Authentication failed. Please login again.';
  static const String errorValidation =
      'Please check your input and try again.';
  static const String errorFileUpload = 'File upload failed. Please try again.';
  static const String errorNotFound = 'Requested resource not found.';

  // Success Messages
  static const String successSaved = 'Successfully saved!';
  static const String successUploaded = 'File uploaded successfully!';
  static const String successDeleted = 'Successfully deleted!';
  static const String successUpdated = 'Successfully updated!';
  static const String successApplied = 'Application submitted successfully!';

  // REMOVED all hardcoded URL constants:
  // - baseUrl (now dynamic)
  // - candidateLogin (now in ApiEndpoints)
  // - candidateSignup (now in ApiEndpoints)
  // - candidateGoogleAuth (now in ApiEndpoints)
  // - etc. All URLs are now dynamic!
}
