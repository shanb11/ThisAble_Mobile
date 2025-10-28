import 'package:flutter/material.dart';

// Import screens - will be created step by step
import '../features/landing/screens/landing_home_screen.dart';
import '../features/landing/screens/landing_about_screen.dart';
import '../features/landing/screens/landing_jobs_screen.dart';

// Candidate screens
import '../features/candidate/screens/auth/login_screen.dart';
import '../features/candidate/screens/auth/signup_screen.dart';
import '../features/candidate/screens/main/dashboard_screen.dart';
import '../features/candidate/screens/main/profile_screen.dart';
import '../features/candidate/screens/main/applications_screen.dart';
import '../features/candidate/screens/main/jobs_screen.dart';
// import '../features/candidate/screens/main/notifications_screen.dart';
import '../features/candidate/screens/main/settings_screen.dart';

// Candidate setup screens - to be created
import '../features/candidate/screens/setup/account_setup_screen.dart';
import '../features/candidate/screens/setup/skill_selection_screen.dart';
import '../features/candidate/screens/setup/upload_resume_screen.dart';
import '../features/candidate/screens/setup/workstyle_screen.dart';
import '../features/candidate/screens/setup/jobtype_screen.dart';
import '../features/candidate/screens/setup/disability_type_screen.dart';
import '../features/candidate/screens/setup/apparent_needs_screen.dart';
import '../features/candidate/screens/setup/non_apparent_needs_screen.dart';

// Employer screens - to be created
// import '../features/employer/screens/auth/emp_login_screen.dart';
// import '../features/employer/screens/auth/emp_signup_screen.dart';
// import '../features/employer/screens/main/emp_dashboard_screen.dart';
// import '../features/employer/screens/main/emp_profile_screen.dart';
// import '../features/employer/screens/main/emp_joblist_screen.dart';
// import '../features/employer/screens/main/emp_applicants_screen.dart';
// import '../features/employer/screens/main/emp_notifications_screen.dart';
// import '../features/employer/screens/main/emp_settings_screen.dart';

// Employer setup screens - to be created
// import '../features/employer/screens/setup/emp_account_setup_screen.dart';
// import '../features/employer/screens/setup/emp_description_screen.dart';
// import '../features/employer/screens/setup/emp_preferences_screen.dart';
// import '../features/employer/screens/setup/emp_social_links_screen.dart';
// import '../features/employer/screens/setup/emp_upload_logo_screen.dart';

/// Routes Configuration - Mirrors your web URL structure exactly
class AppRoutes {
  // LANDING PAGES (mirrors frontend/landing/)
  static const String landingHome = '/'; // index.php
  static const String landingAbout = '/about'; // landing_about.php
  static const String landingJobs = '/jobs'; // landing_jobs.php

  // CANDIDATE AUTHENTICATION (mirrors frontend/candidate/)
  static const String candidateLogin = '/candidate/login'; // login.php
  static const String candidateSignup = '/candidate/signup'; // signup.php

  // CANDIDATE MAIN PAGES (mirrors frontend/candidate/)
  static const String candidateDashboard =
      '/candidate/dashboard'; // dashboard.php
  static const String candidateProfile = '/candidate/profile'; // profile.php
  static const String candidateApplications =
      '/candidate/applications'; // applications.php
  static const String candidateJobListings =
      '/candidate/jobs'; // joblistings.php
  static const String candidateNotifications =
      '/candidate/notifications'; // notifications.php
  static const String candidateSettings = '/candidate/settings'; // settings.php

  // CANDIDATE SETUP FLOW (mirrors frontend/candidate/ setup files)
  static const String candidateAccountSetup =
      '/candidate/setup'; // accountsetup.php
  static const String candidateSkillSelection =
      '/candidate/setup/skills'; // skillselection.php
  static const String candidateUploadResumeSetup =
      '/candidate/setup/resume'; // uploadresume.php
  static const String candidateWorkstyle =
      '/candidate/setup/workstyle'; // workstyle.php
  static const String candidateJobType =
      '/candidate/setup/jobtype'; // jobtype.php
  static const String candidateDisabilityTypeSetup =
      '/candidate/setup/disability-type'; // disabilitytype.php
  static const String candidateApparentWorkplaceSetup =
      '/candidate/setup/workplace-apparent'; // apparent-workplaceneeds.php
  static const String candidateNonApparentWorkplaceSetup =
      '/candidate/setup/workplace-nonapparent'; // non-apparent-workplaceneeds.php

  // EMPLOYER AUTHENTICATION (mirrors frontend/employer/)
  static const String employerLogin = '/employer/login'; // emplogin.php
  static const String employerSignup = '/employer/signup'; // empsignup.php

  // EMPLOYER MAIN PAGES (mirrors frontend/employer/)
  static const String employerDashboard =
      '/employer/dashboard'; // empdashboard.php
  static const String employerProfile = '/employer/profile'; // empprofile.php
  static const String employerJobList = '/employer/jobs'; // empjoblist.php
  static const String employerApplicants =
      '/employer/applicants'; // empapplicants.php
  static const String employerNotifications =
      '/employer/notifications'; // empnotifications.php
  static const String employerSettings =
      '/employer/settings'; // empsettings.php

  // EMPLOYER SETUP FLOW (mirrors frontend/employer/ setup files)
  static const String employerAccountSetup =
      '/employer/setup'; // empaccsetup.php
  static const String employerDescription =
      '/employer/setup/description'; // empdescription.php
  static const String employerPreferences =
      '/employer/setup/preferences'; // empreferences.php
  static const String employerSocialLinks =
      '/employer/setup/social'; // empsocmedlinks.php
  static const String employerUploadLogo =
      '/employer/setup/logo'; // empuploadlogo.php

  /// Route Map - Maps URLs to Screens (exactly like your web structure)
  static Map<String, WidgetBuilder> get routes {
    return {
      // LANDING PAGES
      landingHome: (context) =>
          const LandingHomeScreen(), // index.php equivalent
      landingAbout: (context) =>
          const LandingAboutScreen(), // landing_about.php equivalent
      landingJobs: (context) =>
          const LandingJobsScreen(), // landing_jobs.php equivalent

      // CANDIDATE ROUTES
      candidateLogin: (context) => const LoginScreen(),
      candidateSignup: (context) => const SignupScreen(),
      candidateDashboard: (context) => const CandidateDashboardScreen(),
      candidateProfile: (context) => const CandidateProfileScreen(),
      candidateApplications: (context) => const CandidateApplicationsScreen(),
      candidateJobListings: (context) => const CandidateJobListingsScreen(),
      // candidateNotifications: (context) => const CandidateNotificationsScreen(),
      candidateSettings: (context) => const CandidateSettingsScreen(),

      // CANDIDATE SETUP ROUTES
      candidateAccountSetup: (context) => const AccountSetupScreen(),
      candidateSkillSelection: (context) => const SkillSelectionScreen(),
      candidateWorkstyle: (context) => const WorkstyleScreen(),
      candidateJobType: (context) => const JobtypeScreen(),
      candidateDisabilityTypeSetup: (context) => const DisabilityTypeScreen(),
      candidateApparentWorkplaceSetup: (context) => const ApparentNeedsScreen(),
      candidateNonApparentWorkplaceSetup: (context) =>
          const NonApparentNeedsScreen(),
      candidateUploadResumeSetup: (context) => const UploadResumeScreen(),

      // EMPLOYER ROUTES (Will be implemented in later phases)
      // employerLogin: (context) => const EmployerLoginScreen(),
      // employerSignup: (context) => const EmployerSignupScreen(),
      // employerDashboard: (context) => const EmployerDashboardScreen(),
      // employerProfile: (context) => const EmployerProfileScreen(),
      // employerJobList: (context) => const EmployerJobListScreen(),
      // employerApplicants: (context) => const EmployerApplicantsScreen(),
      // employerNotifications: (context) => const EmployerNotificationsScreen(),
      // employerSettings: (context) => const EmployerSettingsScreen(),

      // EMPLOYER SETUP ROUTES (Will be implemented in later phases)
      // employerAccountSetup: (context) => const EmployerAccountSetupScreen(),
      // employerDescription: (context) => const EmployerDescriptionScreen(),
      // employerPreferences: (context) => const EmployerPreferencesScreen(),
      // employerSocialLinks: (context) => const EmployerSocialLinksScreen(),
      // employerUploadLogo: (context) => const EmployerUploadLogoScreen(),
    };
  }

  /// Navigation Helper Methods (same as your web navigation)

  // Landing Navigation
  static void goToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, landingHome, (route) => false);
  }

  static void goToAbout(BuildContext context) {
    Navigator.pushNamed(context, landingAbout);
  }

  static void goToJobs(BuildContext context) {
    Navigator.pushNamed(context, landingJobs);
  }

  // Candidate Navigation
  static void goToCandidateLogin(BuildContext context) {
    Navigator.pushNamed(context, candidateLogin);
  }

  /// Navigate to Candidate Signup (with optional Google data)
  static void goToCandidateSignup(
    BuildContext context, {
    Map<String, dynamic>? googleData,
  }) {
    Navigator.pushReplacementNamed(
      context,
      candidateSignup,
      arguments: googleData,
    );
  }

  static void goToCandidateDashboard(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, candidateDashboard, (route) => false);
  }

  // Employer Navigation
  static void goToEmployerLogin(BuildContext context) {
    Navigator.pushNamed(context, employerLogin);
  }

  static void goToEmployerSignup(BuildContext context) {
    Navigator.pushNamed(context, employerSignup);
  }

  static void goToEmployerDashboard(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, employerDashboard, (route) => false);
  }

  // Setup Flow Navigation
  static void goToCandidateSetup(BuildContext context) {
    Navigator.pushNamed(context, candidateAccountSetup);
  }

  static void goToEmployerSetup(BuildContext context) {
    Navigator.pushNamed(context, employerAccountSetup);
  }

  // Utility Methods
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  static void goBackToRoot(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, landingHome, (route) => false);
  }
}
