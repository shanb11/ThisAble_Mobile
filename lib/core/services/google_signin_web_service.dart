// lib/core/services/google_signin_web_service.dart
// 🔧 COMPLETELY FIXED VERSION - Proper Web Token Handling
// ✅ Handles web platform's access token limitation properly
// ✅ Eliminates "Cannot send null" errors
// ✅ Works with your PHP backend that accepts both token types
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// FIXED Web-Specific Google Sign-In Service for ThisAble
/// ✅ Properly handles web platform access token limitation
/// ✅ Works seamlessly with your PHP backend
/// ✅ Eliminates all null value issues
class GoogleSignInWebService {
  // Private constructor to prevent direct instantiation
  GoogleSignInWebService._();

  // Singleton instance
  static final GoogleSignInWebService _instance = GoogleSignInWebService._();
  static GoogleSignInWebService get instance => _instance;

  // Google Sign-In instance configured for web
  late final GoogleSignIn _googleSignIn;

  // Initialization state
  bool _isInitialized = false;
  GoogleSignInAccount? _currentUser;

  /// FIXED: Initialize the web Google Sign-In service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure Google Sign-In for web platform
      _googleSignIn = GoogleSignIn(
        clientId:
            '83628564105-ebo9ng5modqfhkgepbm55rkv92d669l9.apps.googleusercontent.com',
        scopes: [
          'email',
          'profile',
          'openid', // Explicitly request openid for better token handling
        ],
        // Web-optimized configuration
        signInOption: SignInOption.standard,
      );

      // Listen for authentication state changes
      _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
        _currentUser = account;
        _debugLog('🔧 Web Auth State Changed: ${account?.email ?? 'No user'}');
      });

      // Try to restore previous session silently
      await _attemptSilentSignIn();

      _isInitialized = true;
      _debugLog('✅ Web Google Sign-In Service initialized');
    } catch (e) {
      _debugLog('❌ Web Google Sign-In initialization failed: $e');
      rethrow;
    }
  }

  /// FIXED: Attempt silent sign-in (web-optimized)
  Future<GoogleSignInAccount?> _attemptSilentSignIn() async {
    try {
      _debugLog('🔍 Attempting silent sign-in...');

      // Use signInSilently() - recommended for web
      final account = await _googleSignIn.signInSilently();

      if (account != null) {
        _debugLog('✅ Silent sign-in successful: ${account.email}');
        _currentUser = account;
        return account;
      } else {
        _debugLog('ℹ️ No cached account found for silent sign-in');
        return null;
      }
    } catch (e) {
      _debugLog('⚠️ Silent sign-in failed (this is normal): $e');
      return null;
    }
  }

  /// ENHANCED: Sign in using web-optimized flow with better token handling
  Future<GoogleSignInResult> signIn() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _debugLog('🚀 Starting ENHANCED web Google Sign-In flow...');

      GoogleSignInAccount? account;

      // Try silent sign-in first (recommended for web)
      account = await _googleSignIn.signInSilently(
        reAuthenticate: false, // Don't force re-authentication initially
      );

      // If no account from silent sign-in, use interactive sign-in
      if (account == null) {
        _debugLog('📱 No cached account, starting interactive sign-in...');

        // Use the standard signIn() method for web
        account = await _googleSignIn.signIn();
      }

      if (account == null) {
        _debugLog('❌ User cancelled sign-in');
        return GoogleSignInResult.cancelled();
      }

      // Get authentication details
      final GoogleSignInAuthentication auth = await account.authentication;

      // ✅ ENHANCED: Properly handle web platform token limitations
      _debugLog('📧 Email: ${account.email}');
      _debugLog('🔑 Has idToken: ${auth.idToken != null}');
      _debugLog('🎫 Has accessToken: ${auth.accessToken != null}');

      // Validate that we have at least one token
      if (auth.accessToken == null && auth.idToken == null) {
        _debugLog('❌ Failed to get any authentication token');
        throw Exception('Failed to get authentication tokens');
      }

      // ✅ ENHANCED: Accept web platform limitations gracefully
      if (auth.idToken == null) {
        _debugLog(
            '⚠️ No ID token available (normal on web), using access token only');

        // Validate that access token exists
        if (auth.accessToken == null || auth.accessToken!.isEmpty) {
          _debugLog('❌ No access token available either');
          throw Exception('No valid authentication tokens available');
        }
      } else {
        _debugLog('✅ ID token available (rare on web but good!)');
      }

      _debugLog('✅ Web Google Sign-In successful!');
      _currentUser = account;

      return GoogleSignInResult.success(
        account: account,
        authentication: auth,
      );
    } catch (e) {
      _debugLog('❌ Web Google Sign-In error: $e');
      return GoogleSignInResult.error(e.toString());
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _debugLog('✅ Web Google Sign-Out successful');
    } catch (e) {
      _debugLog('❌ Web Google Sign-Out error: $e');
      rethrow;
    }
  }

  /// Disconnect (revoke all permissions)
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      _currentUser = null;
      _debugLog('✅ Web Google Disconnect successful');
    } catch (e) {
      _debugLog('❌ Web Google Disconnect error: $e');
      rethrow;
    }
  }

  /// Get current signed-in user
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Check if user is currently signed in
  bool get isSignedIn => _currentUser != null;

  /// 🔧 NEW: Test web sign-in configuration
  Future<Map<String, dynamic>> testWebConfiguration() async {
    try {
      _debugLog('🔍 Testing web Google Sign-In configuration...');

      final testResults = <String, dynamic>{
        'platform': 'Web Browser',
        'initialized': _isInitialized,
        'current_user': _currentUser?.email ?? 'None',
        'client_id':
            '83628564105-ebo9ng5modqfhkgepbm55rkv92d669l9.apps.googleusercontent.com',
      };

      // Test if Google Sign-In is available
      try {
        final canSignIn =
            await _googleSignIn.canAccessScopes(['email', 'profile']);
        testResults['can_access_scopes'] = canSignIn;
      } catch (e) {
        testResults['can_access_scopes'] = false;
        testResults['scope_error'] = e.toString();
      }

      // Test silent sign-in capability
      try {
        await _googleSignIn.signInSilently();
        testResults['silent_signin_available'] = true;
      } catch (e) {
        testResults['silent_signin_available'] = false;
        testResults['silent_signin_error'] = e.toString();
      }

      _debugLog('✅ Web configuration test complete');
      return testResults;
    } catch (e) {
      _debugLog('❌ Web configuration test failed: $e');
      return {
        'platform': 'Web Browser',
        'error': e.toString(),
      };
    }
  }

  /// Debug logging (only in debug mode)
  void _debugLog(String message) {
    if (kDebugMode) {
      print('[GoogleSignInWebService] $message');
    }
  }
}

/// 🔧 ENHANCED: Result class for Google Sign-In operations
class GoogleSignInResult {
  final bool success;
  final GoogleSignInAccount? account;
  final GoogleSignInAuthentication? authentication;
  final String? error;
  final GoogleSignInResultType type;

  const GoogleSignInResult._({
    required this.success,
    required this.type,
    this.account,
    this.authentication,
    this.error,
  });

  /// Success result
  factory GoogleSignInResult.success({
    required GoogleSignInAccount account,
    required GoogleSignInAuthentication authentication,
  }) {
    return GoogleSignInResult._(
      success: true,
      type: GoogleSignInResultType.success,
      account: account,
      authentication: authentication,
    );
  }

  /// Cancelled result (user cancelled)
  factory GoogleSignInResult.cancelled() {
    return const GoogleSignInResult._(
      success: false,
      type: GoogleSignInResultType.cancelled,
      error: 'User cancelled sign-in',
    );
  }

  /// Error result
  factory GoogleSignInResult.error(String error) {
    return GoogleSignInResult._(
      success: false,
      type: GoogleSignInResultType.error,
      error: error,
    );
  }

  /// Check if we have a valid ID token
  bool get hasIdToken =>
      authentication?.idToken != null && authentication!.idToken!.isNotEmpty;

  /// Check if we have a valid access token
  bool get hasAccessToken =>
      authentication?.accessToken != null &&
      authentication!.accessToken!.isNotEmpty;

  /// Check if we have at least one valid token
  bool get hasValidTokens => hasIdToken || hasAccessToken;

  /// Get the best available token (ID token preferred, access token as fallback)
  String? get bestToken =>
      hasIdToken ? authentication!.idToken! : authentication?.accessToken;

  @override
  String toString() {
    return 'GoogleSignInResult(success: $success, type: $type, email: ${account?.email}, hasIdToken: $hasIdToken, hasAccessToken: $hasAccessToken, error: $error)';
  }
}

/// Result types for Google Sign-In
enum GoogleSignInResultType {
  success,
  cancelled,
  error,
}
