import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/platform_utils.dart';
import 'google_signin_web_service.dart';
import 'google_signin_mobile_service.dart';

/// Platform-Aware Google Sign-In Controller for ThisAble
/// Automatically chooses the right service (web or mobile) based on platform
/// Provides unified interface that eliminates deprecation warnings
class GoogleSignInController {
  // Private constructor to prevent direct instantiation
  GoogleSignInController._();

  // Singleton instance
  static final GoogleSignInController _instance = GoogleSignInController._();
  static GoogleSignInController get instance => _instance;

  // Service instances (lazy loaded)
  GoogleSignInWebService? _webService;
  GoogleSignInMobileService? _mobileService;

  // Initialization state
  bool _isInitialized = false;

  /// Initialize the controller (safe, non-blocking)
  Future<void> initialize() async {
    if (_isInitialized) {
      _debugLog('ℹ️ Controller already initialized');
      return;
    }

    try {
      _debugLog('🎯 Initializing Platform-Aware Google Sign-In Controller...');
      _debugLog('🔍 Current platform: ${PlatformUtils.platformName}');

      // Don't initialize services here - they'll be lazy loaded when needed
      // This prevents the blocking issue we had before

      _isInitialized = true;
      _debugLog(
          '✅ Controller initialized successfully (services will load on-demand)');
    } catch (e) {
      _debugLog('❌ Controller initialization failed: $e');
      rethrow;
    }
  }

  /// Get the appropriate service for current platform (lazy loaded)
  Future<dynamic> _getService() async {
    if (PlatformUtils.isWeb) {
      // Web platform - use web service
      _webService ??= GoogleSignInWebService.instance;
      await _webService!.initialize();
      _debugLog('🌐 Using Web Service');
      return _webService;
    } else {
      // Mobile platform - use mobile service
      _mobileService ??= GoogleSignInMobileService.instance;
      await _mobileService!.initialize();
      _debugLog('📱 Using Mobile Service');
      return _mobileService;
    }
  }

  /// Unified sign-in method that works across all platforms
  Future<GoogleSignInControllerResult> signIn() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _debugLog('🚀 Starting platform-aware sign-in...');

      // Get the appropriate service for current platform
      final service = await _getService();

      // Call the service's sign-in method
      final result = await service.signIn();

      // Convert service result to controller result
      if (result.success) {
        _debugLog('✅ Platform-aware sign-in successful!');
        return GoogleSignInControllerResult.success(
          account: result.account!,
          authentication: result.authentication!,
          platformUsed: PlatformUtils.platformName,
        );
      } else {
        _debugLog('❌ Platform-aware sign-in failed: ${result.error}');
        return GoogleSignInControllerResult.error(
          result.error ?? 'Sign-in failed',
          platformUsed: PlatformUtils.platformName,
        );
      }
    } catch (e) {
      _debugLog('❌ Controller sign-in error: $e');
      return GoogleSignInControllerResult.error(
        e.toString(),
        platformUsed: PlatformUtils.platformName,
      );
    }
  }

  /// Unified sign-out method that works across all platforms
  Future<void> signOut() async {
    try {
      if (PlatformUtils.isWeb && _webService != null) {
        await _webService!.signOut();
      } else if (PlatformUtils.isMobile && _mobileService != null) {
        await _mobileService!.signOut();
      }
      _debugLog('✅ Platform-aware sign-out successful');
    } catch (e) {
      _debugLog('❌ Platform-aware sign-out error: $e');
      rethrow;
    }
  }

  /// Check if user is currently signed in
  bool get isSignedIn {
    if (PlatformUtils.isWeb && _webService != null) {
      return _webService!.isSignedIn;
    } else if (PlatformUtils.isMobile && _mobileService != null) {
      return _mobileService!.isSignedIn;
    }
    return false;
  }

  /// Get current signed-in user
  GoogleSignInAccount? get currentUser {
    if (PlatformUtils.isWeb && _webService != null) {
      return _webService!.currentUser;
    } else if (PlatformUtils.isMobile && _mobileService != null) {
      return _mobileService!.currentUser;
    }
    return null;
  }

  /// Mobile-specific: Force account selection (for signup flow)
  Future<GoogleSignInControllerResult> signInWithAccountSelection() async {
    if (!PlatformUtils.isMobile) {
      return GoogleSignInControllerResult.error(
        'Account selection only available on mobile platforms',
        platformUsed: PlatformUtils.platformName,
      );
    }

    try {
      final service = await _getService() as GoogleSignInMobileService;
      final result = await service.signInWithAccountSelection();

      if (result.success) {
        return GoogleSignInControllerResult.success(
          account: result.account!,
          authentication: result.authentication!,
          platformUsed: PlatformUtils.platformName,
        );
      } else {
        return GoogleSignInControllerResult.error(
          result.error ?? 'Account selection failed',
          platformUsed: PlatformUtils.platformName,
        );
      }
    } catch (e) {
      return GoogleSignInControllerResult.error(
        e.toString(),
        platformUsed: PlatformUtils.platformName,
      );
    }
  }

  /// Get platform-specific configuration info
  Map<String, dynamic> get platformInfo {
    return {
      'platform': PlatformUtils.platformName,
      'isWeb': PlatformUtils.isWeb,
      'isMobile': PlatformUtils.isMobile,
      'isInitialized': _isInitialized,
      'webServiceLoaded': _webService != null,
      'mobileServiceLoaded': _mobileService != null,
      'isSignedIn': isSignedIn,
      'currentUser': currentUser?.email,
    };
  }

  /// Debug logging (only in debug mode)
  void _debugLog(String message) {
    if (kDebugMode) {
      print('[GoogleSignInController] $message');
    }
  }
}

/// Result class for platform-aware Google Sign-In operations
class GoogleSignInControllerResult {
  final bool success;
  final GoogleSignInAccount? account;
  final GoogleSignInAuthentication? authentication;
  final String? error;
  final String platformUsed;
  final GoogleSignInControllerResultType type;

  const GoogleSignInControllerResult._({
    required this.success,
    required this.type,
    required this.platformUsed,
    this.account,
    this.authentication,
    this.error,
  });

  /// Successful sign-in
  factory GoogleSignInControllerResult.success({
    required GoogleSignInAccount account,
    required GoogleSignInAuthentication authentication,
    required String platformUsed,
  }) {
    return GoogleSignInControllerResult._(
      success: true,
      type: GoogleSignInControllerResultType.success,
      platformUsed: platformUsed,
      account: account,
      authentication: authentication,
    );
  }

  /// User cancelled sign-in
  factory GoogleSignInControllerResult.cancelled({
    required String platformUsed,
  }) {
    return GoogleSignInControllerResult._(
      success: false,
      type: GoogleSignInControllerResultType.cancelled,
      platformUsed: platformUsed,
      error: 'User cancelled sign-in',
    );
  }

  /// Error during sign-in
  factory GoogleSignInControllerResult.error(
    String errorMessage, {
    required String platformUsed,
  }) {
    return GoogleSignInControllerResult._(
      success: false,
      type: GoogleSignInControllerResultType.error,
      platformUsed: platformUsed,
      error: errorMessage,
    );
  }

  @override
  String toString() {
    return 'GoogleSignInControllerResult(success: $success, type: $type, platform: $platformUsed, account: ${account?.email}, error: $error)';
  }
}

/// Types of controller results
enum GoogleSignInControllerResultType {
  success,
  cancelled,
  error,
}
