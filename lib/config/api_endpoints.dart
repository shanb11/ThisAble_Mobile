/// App Constants - API endpoints, settings, and configuration
class AppConstants {
  // App Information
  static const String appName = 'ThisAble Mobile';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Job Portal for Inclusive Hiring';

  // API Configuration (Updated for your ThisAble project)
  static const String baseUrl =
      'http://192.168.1.3/ThisAble/api'; // UPDATED PATH!
  static const String apiVersion = 'v1';

  // API Endpoints - Landing Pages
  static const String landingJobCategories = '$baseUrl/jobs/categories.php';
  static const String landingJobListings = '$baseUrl/shared/jobs.php';
  static const String landingJobSearch = '$baseUrl/shared/jobs.php';
  static const String landingContactForm = '$baseUrl/shared/contact.php';

  // API Endpoints - Authentication (Updated paths)
  static const String candidateLogin = '$baseUrl/auth/login.php';
  static const String candidateSignup = '$baseUrl/auth/signup.php';
  static const String candidateLogout = '$baseUrl/auth/logout.php';
  static const String candidateGoogleAuth = '$baseUrl/auth/google.php';
  static const String candidatePwdVerification = '$baseUrl/auth/verify_pwd.php';

  // API Endpoints - Candidate (mirrors your backend/candidate/)
  static const String candidateGetUserData =
      '$baseUrl/candidate/get_user_data.php';
  static const String candidateSaveSetupData =
      '$baseUrl/candidate/save_setup_data.php';
  static const String candidateSaveSkills =
      '$baseUrl/candidate/save_skills.php';
  static const String candidateGetSkills = '$baseUrl/candidate/get_skills.php';
  static const String candidateGetSeekerSkills =
      '$baseUrl/candidate/get_seeker_skills.php';
  static const String candidateUploadResume =
      '$baseUrl/candidate/upload_resume_process.php';
  static const String candidateDeleteResume =
      '$baseUrl/candidate/delete_resume.php';
  static const String candidateViewResume =
      '$baseUrl/candidate/view_resume.php';
  static const String candidateUpdatePersonalInfo =
      '$baseUrl/candidate/update_personal_info.php';
  static const String candidateUpdateContactInfo =
      '$baseUrl/candidate/update_contact_info.php';
  static const String candidateUpdateEducation =
      '$baseUrl/candidate/update_education.php';
  static const String candidateUpdateExperience =
      '$baseUrl/candidate/update_experience.php';
  static const String candidateDeleteEducation =
      '$baseUrl/candidate/delete_education.php';
  static const String candidateDeleteExperience =
      '$baseUrl/candidate/delete_experience.php';
  static const String candidateUploadProfileImage =
      '$baseUrl/candidate/upload_profile_image.php';
  static const String candidateGetJobListings =
      '$baseUrl/candidate/get_job_listings.php';
  static const String candidateGetJobRecommendations =
      '$baseUrl/candidate/get_job_recommendations.php';
  static const String candidateJobActions =
      '$baseUrl/candidate/job_actions.php';
  static const String candidateGetApplications =
      '$baseUrl/candidate/get_applications.php';
  static const String candidateGetApplicationDetails =
      '$baseUrl/candidate/get_application_details.php';
  static const String candidateApplicationActions =
      '$baseUrl/candidate/application_actions.php';
  static const String candidateGetNotifications =
      '$baseUrl/candidate/get_notifications.php';
  static const String candidateMarkNotificationRead =
      '$baseUrl/candidate/mark_notification_read.php';
  static const String candidateNotificationActions =
      '$baseUrl/candidate/notification_actions.php';
  static const String candidateGetUserSettings =
      '$baseUrl/candidate/get_all_user_settings.php';
  static const String candidateSaveUserSettings =
      '$baseUrl/candidate/save_user_settings.php';
  static const String candidateUpdatePassword =
      '$baseUrl/candidate/update_password.php';
  static const String candidateSetupStatus =
      '$baseUrl/candidate/setup_status.php';
  static const String candidateGetCompatibilityScore =
      '$baseUrl/candidate/get_compatibility_score.php';

  // API Endpoints - Employer (mirrors your backend/employer/)
  static const String employerLogin = '$baseUrl/employer/login_process.php';
  static const String employerSignup = '$baseUrl/employer/signup_process.php';
  static const String employerCreateJob = '$baseUrl/employer/create_job.php';
  static const String employerGetJobs =
      '$baseUrl/employer/get_employer_jobs.php';
  static const String employerUpdateJob = '$baseUrl/employer/update_job.php';
  static const String employerDeleteJob = '$baseUrl/employer/delete_job.php';
  static const String employerToggleJobStatus =
      '$baseUrl/employer/toggle_job_status.php';
  static const String employerGetApplicants =
      '$baseUrl/employer/get_applicants.php';
  static const String employerGetApplicantDetails =
      '$baseUrl/employer/get_applicant_details.php';
  static const String employerUpdateApplicationStatus =
      '$baseUrl/employer/update_application_status.php';
  static const String employerGetCompanyProfile =
      '$baseUrl/employer/get_company_profile.php';
  static const String employerUpdateCompanyIdentity =
      '$baseUrl/employer/update_company_identity.php';
  static const String employerUpdateCompanyDescription =
      '$baseUrl/employer/update_company_description.php';
  static const String employerUpdateContactInfo =
      '$baseUrl/employer/update_contact_info.php';
  static const String employerUpdateSocialLinks =
      '$baseUrl/employer/update_social_links.php';
  static const String employerUploadLogo =
      '$baseUrl/employer/upload_company_logo.php';
  static const String employerGetNotifications =
      '$baseUrl/employer/get_notifications.php';
  static const String employerScheduleInterview =
      '$baseUrl/employer/schedule_interview.php';
  static const String employerGetAnalytics =
      '$baseUrl/employer/get_analytics.php';

  // File Upload Paths (mirrors your web structure)
  static const String uploadsPath = 'http://localhost/ThisAble/uploads';
  static const String resumesPath = '$uploadsPath/resumes';
  static const String profileImagesPath = '$uploadsPath/profile_images';
  static const String companyLogosPath = '$uploadsPath/company_logos';
  static const String pwdIdsPath = '$uploadsPath/pwd_ids';

  // Job Categories (matches your web categories)
  static const List<Map<String, String>> jobCategories = [
    {
      'id': 'education',
      'name': 'Education & Training',
      'icon': 'graduation-cap',
      'count': '50+',
    },
    {
      'id': 'office',
      'name': 'Office Administration',
      'icon': 'briefcase',
      'count': '80+',
    },
    {
      'id': 'customer',
      'name': 'Customer Service',
      'icon': 'headset',
      'count': '40+',
    },
    {
      'id': 'business',
      'name': 'Business Administration',
      'icon': 'chart-line',
      'count': '60+',
    },
    {
      'id': 'healthcare',
      'name': 'Healthcare & Wellness',
      'icon': 'heartbeat',
      'count': '75+',
    },
    {
      'id': 'finance',
      'name': 'Finance & Accounting',
      'icon': 'dollar-sign',
      'count': '45+',
    },
  ];

  // Job Types
  static const List<String> jobTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
    'Freelance',
  ];

  // Work Styles (matches your workstyle options)
  static const List<Map<String, String>> workStyles = [
    {
      'id': 'full-time',
      'name': 'Full-time Work',
      'description': 'Standard 40-hour work week',
      'image': 'fulltimework.png',
    },
    {
      'id': 'part-time',
      'name': 'Part-time Work',
      'description': 'Flexible schedule, fewer hours',
      'image': 'parttimework.png',
    },
    {
      'id': 'freelance',
      'name': 'Freelance Work',
      'description': 'Project-based, independent work',
      'image': 'freelancework.png',
    },
    {
      'id': 'remote',
      'name': 'Remote Work',
      'description': 'Work from anywhere',
      'image': 'remotework.png',
    },
    {
      'id': 'onsite',
      'name': 'On-site Work',
      'description': 'Work at company location',
      'image': 'onsitework.png',
    },
    {
      'id': 'hybrid',
      'name': 'Hybrid Work',
      'description': 'Mix of remote and on-site',
      'image': 'hybridwork.png',
    },
  ];

  // Disability Types (matches your setup flow - UPDATED TO MATCH YOUR DATABASE)
  static const List<Map<String, String>> disabilityTypes = [
    {
      'id': '1', // Visual Impairment
      'name': 'Visual Impairment',
      'category': 'apparent',
      'description': 'Visible visual disabilities',
    },
    {
      'id': '2', // Physical Impairment
      'name': 'Physical Impairment',
      'category': 'apparent',
      'description': 'Visible physical disabilities',
    },
    {
      'id': '3', // Deaf/Hard of Hearing Disability
      'name': 'Deaf/Hard of Hearing Disability',
      'category': 'non-apparent',
      'description': 'Hearing impairments',
    },
    {
      'id': '4', // Intellectual Disability
      'name': 'Intellectual Disability',
      'category': 'non-apparent',
      'description': 'Cognitive disabilities',
    },
    {
      'id': '5', // Learning Disability
      'name': 'Learning Disability',
      'category': 'non-apparent',
      'description': 'Learning-related disabilities',
    },
    {
      'id': '6', // Mental Disability
      'name': 'Mental Disability',
      'category': 'non-apparent',
      'description': 'Mental health disabilities',
    },
    {
      'id': '7', // Psychosocial Disability
      'name': 'Psychosocial Disability',
      'category': 'non-apparent',
      'description': 'Psychosocial disabilities',
    },
    {
      'id': '8', // Non-apparent Visual Disability
      'name': 'Non-apparent Visual Disability',
      'category': 'non-apparent',
      'description': 'Non-visible visual disabilities',
    },
    {
      'id': '9', // Non-apparent Speech and Language Impairment
      'name': 'Speech and Language Impairment',
      'category': 'non-apparent',
      'description': 'Speech and language disabilities',
    },
    {
      'id': '10', // Non-apparent cancer
      'name': 'Cancer-related Disability',
      'category': 'non-apparent',
      'description': 'Cancer-related disabilities',
    },
    {
      'id': '11', // Non-apparent rare disease
      'name': 'Rare Disease Disability',
      'category': 'non-apparent',
      'description': 'Rare disease-related disabilities',
    },
  ];

  // App Settings
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Settings
  static const int cacheExpiryHours = 24;
  static const String cacheKeyPrefix = 'thisable_';

  // Local Storage Keys
  static const String keyUserId = 'user_id';
  static const String keyUserType = 'user_type'; // 'candidate' or 'employer'
  static const String keyAuthToken = 'auth_token';
  static const String keySetupComplete = 'setup_complete';
  static const String keyUserData = 'user_data';
  static const String keyRecentSearches = 'recent_searches';
  static const String keySavedJobs = 'saved_jobs';
  static const String keyNotificationSettings = 'notification_settings';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';

  // Error Messages
  static const String errorGeneral = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Network error. Please check your connection.';
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

  // Environment-specific URLs
  static String getEnvironmentBaseUrl() {
    // You can add logic here to switch between environments
    // For development: localhost
    // For testing on physical device: your computer's IP
    // For production: your domain

    return baseUrl; // Default to localhost for development
  }

  // Device-specific URL adjustments
  static String getDeviceAppropriateUrl() {
    // For Android emulator, use 10.0.2.2 instead of localhost
    // For iOS simulator, localhost works fine
    // For physical devices, use your computer's IP address

    return baseUrl.replaceAll('localhost', '10.0.2.2'); // For Android emulator
  }

  // Network URL for physical device testing
  static String getNetworkUrl(String yourComputerIP) {
    return baseUrl.replaceAll('localhost', yourComputerIP);
  }
}

/// Separate API Endpoints class for cleaner organization
class ApiEndpoints {
  // Base URL
  static String get baseUrl => AppConstants.baseUrl;

  // Authentication endpoints
  static String get login => AppConstants.candidateLogin;
  static String get signup => AppConstants.candidateSignup;
  static String get logout => AppConstants.candidateLogout;
  static String get googleAuth => AppConstants.candidateGoogleAuth;
  static String get verifyPwd => AppConstants.candidatePwdVerification;

  // Job endpoints
  static String get searchJobs => AppConstants.landingJobSearch;
  static String get getCategories => AppConstants.landingJobCategories;
  static String get getJobListings => AppConstants.candidateGetJobListings;

  // Test endpoint
  static String get testConnection => '$baseUrl/test.php';

  // Shared endpoints
  static String get getDisabilityTypes =>
      '$baseUrl/shared/get_disability_types.php';

  // Skills endpoints
  static String get getSkills => '$baseUrl/shared/get_skills.php';

  static String get getSkillCategories =>
      '$baseUrl/shared/get_skill_categories.php';

  // Utility methods
  static String buildUrl(String endpoint) {
    return '$baseUrl/$endpoint';
  }

  static String getDeviceUrl() {
    return AppConstants.getDeviceAppropriateUrl();
  }
}
