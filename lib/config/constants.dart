/// App Constants - API endpoints, settings, and configuration
class AppConstants {
  // App Information
  static const String appName = 'ThisAble Mobile';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Job Portal for Inclusive Hiring';

  // API Configuration (Update with your actual domain)
  static const String baseUrl = 'https://yoursite.com/thisable'; // UPDATE THIS!
  static const String apiVersion = 'v1';

  // API Endpoints - Landing Pages
  static const String landingJobCategories = '$baseUrl/api/job-categories';
  static const String landingJobListings = '$baseUrl/api/job-listings';
  static const String landingJobSearch = '$baseUrl/api/job-search';
  static const String landingContactForm = '$baseUrl/api/contact-form';

  // API Endpoints - Candidate (mirrors your backend/candidate/)
  static const String candidateLogin =
      '$baseUrl/backend/candidate/login_process.php';
  static const String candidateSignup =
      '$baseUrl/backend/candidate/signup_process.php';
  static const String candidateLogout = '$baseUrl/backend/candidate/logout.php';
  static const String candidateGetUserData =
      '$baseUrl/backend/candidate/get_user_data.php';
  static const String candidateSaveSetupData =
      '$baseUrl/backend/candidate/save_setup_data.php';
  static const String candidateSaveSkills =
      '$baseUrl/backend/candidate/save_skills.php';
  static const String candidateGetSkills =
      '$baseUrl/backend/candidate/get_skills.php';
  static const String candidateGetSeekerSkills =
      '$baseUrl/backend/candidate/get_seeker_skills.php';
  static const String candidateUploadResume =
      '$baseUrl/backend/candidate/upload_resume_process.php';
  static const String candidateDeleteResume =
      '$baseUrl/backend/candidate/delete_resume.php';
  static const String candidateViewResume =
      '$baseUrl/backend/candidate/view_resume.php';
  static const String candidateUpdatePersonalInfo =
      '$baseUrl/backend/candidate/update_personal_info.php';
  static const String candidateUpdateContactInfo =
      '$baseUrl/backend/candidate/update_contact_info.php';
  static const String candidateUpdateEducation =
      '$baseUrl/backend/candidate/update_education.php';
  static const String candidateUpdateExperience =
      '$baseUrl/backend/candidate/update_experience.php';
  static const String candidateDeleteEducation =
      '$baseUrl/backend/candidate/delete_education.php';
  static const String candidateDeleteExperience =
      '$baseUrl/backend/candidate/delete_experience.php';
  static const String candidateUploadProfileImage =
      '$baseUrl/backend/candidate/upload_profile_image.php';
  static const String candidateGetJobListings =
      '$baseUrl/backend/candidate/get_job_listings.php';
  static const String candidateGetJobRecommendations =
      '$baseUrl/backend/candidate/get_job_recommendations.php';
  static const String candidateJobActions =
      '$baseUrl/backend/candidate/job_actions.php';
  static const String candidateGetApplications =
      '$baseUrl/backend/candidate/get_applications.php';
  static const String candidateGetApplicationDetails =
      '$baseUrl/backend/candidate/get_application_details.php';
  static const String candidateApplicationActions =
      '$baseUrl/backend/candidate/application_actions.php';
  static const String candidateGetNotifications =
      '$baseUrl/backend/candidate/get_notifications.php';
  static const String candidateMarkNotificationRead =
      '$baseUrl/backend/candidate/mark_notification_read.php';
  static const String candidateNotificationActions =
      '$baseUrl/backend/candidate/notification_actions.php';
  static const String candidateGetUserSettings =
      '$baseUrl/backend/candidate/get_all_user_settings.php';
  static const String candidateSaveUserSettings =
      '$baseUrl/backend/candidate/save_user_settings.php';
  static const String candidateUpdatePassword =
      '$baseUrl/backend/candidate/update_password.php';
  static const String candidatePwdVerification =
      '$baseUrl/backend/candidate/pwd_verification.php';
  static const String candidateSetupStatus =
      '$baseUrl/backend/candidate/setup_status.php';
  static const String candidateGetCompatibilityScore =
      '$baseUrl/backend/candidate/get_compatibility_score.php';

  // API Endpoints - Employer (mirrors your backend/employer/)
  static const String employerLogin =
      '$baseUrl/backend/employer/login_process.php';
  static const String employerSignup =
      '$baseUrl/backend/employer/signup_process.php';
  static const String employerCreateJob =
      '$baseUrl/backend/employer/create_job.php';
  static const String employerGetJobs =
      '$baseUrl/backend/employer/get_employer_jobs.php';
  static const String employerUpdateJob =
      '$baseUrl/backend/employer/update_job.php';
  static const String employerDeleteJob =
      '$baseUrl/backend/employer/delete_job.php';
  static const String employerToggleJobStatus =
      '$baseUrl/backend/employer/toggle_job_status.php';
  static const String employerGetApplicants =
      '$baseUrl/backend/employer/get_applicants.php';
  static const String employerGetApplicantDetails =
      '$baseUrl/backend/employer/get_applicant_details.php';
  static const String employerUpdateApplicationStatus =
      '$baseUrl/backend/employer/update_application_status.php';
  static const String employerGetCompanyProfile =
      '$baseUrl/backend/employer/get_company_profile.php';
  static const String employerUpdateCompanyIdentity =
      '$baseUrl/backend/employer/update_company_identity.php';
  static const String employerUpdateCompanyDescription =
      '$baseUrl/backend/employer/update_company_description.php';
  static const String employerUpdateContactInfo =
      '$baseUrl/backend/employer/update_contact_info.php';
  static const String employerUpdateSocialLinks =
      '$baseUrl/backend/employer/update_social_links.php';
  static const String employerUploadLogo =
      '$baseUrl/backend/employer/upload_company_logo.php';
  static const String employerGetNotifications =
      '$baseUrl/backend/employer/get_notifications.php';
  static const String employerScheduleInterview =
      '$baseUrl/backend/employer/schedule_interview.php';
  static const String employerGetAnalytics =
      '$baseUrl/backend/employer/get_analytics.php';

  // File Upload Paths (mirrors your web structure)
  static const String uploadsPath = '$baseUrl/uploads';
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

  // Disability Types (matches your setup flow)
  static const List<Map<String, String>> disabilityTypes = [
    {
      'id': 'apparent',
      'name': 'Apparent Disability',
      'description': 'Visible physical disabilities',
      'image': 'apparent.png',
    },
    {
      'id': 'non-apparent',
      'name': 'Non-Apparent Disability',
      'description': 'Hidden or invisible disabilities',
      'image': 'nonapparent.png',
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
}
