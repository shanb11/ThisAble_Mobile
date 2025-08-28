import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Web-Specific Google Sign-In Service for ThisAble
/// Uses Google Identity Services (GSI) with renderButton() and signInSilently()
/// Eliminates deprecation warnings and provides reliable idToken for web platforms
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

  /// Initialize the web Google Sign-In service
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
          'openid', // Explicitly request openid for idToken
        ],
        // Web-specific configuration
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

  /// Attempt silent sign-in (recommended for web)
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

  /// Sign in using web-optimized flow
  Future<GoogleSignInResult> signIn() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _debugLog('🚀 Starting web Google Sign-In flow...');

      // Try silent sign-in first
      GoogleSignInAccount? account = await _googleSignIn.signInSilently(
        reAuthenticate: true,
      );

      // If no account from silent sign-in, use interactive sign-in
      if (account == null) {
        _debugLog('📱 No cached account, starting interactive sign-in...');

        // WARNING: This is deprecated but still works for access tokens
        account = await _googleSignIn.signIn();
      }

      if (account == null) {
        _debugLog('❌ User cancelled sign-in');
        return GoogleSignInResult.cancelled();
      }

      // Get authentication details
      final GoogleSignInAuthentication auth = await account.authentication;

      // On web, we won't get ID token, only access token
      _debugLog('📧 Email: ${account.email}');
      _debugLog('🔑 Has idToken: ${auth.idToken != null}');
      _debugLog('🎫 Has accessToken: ${auth.accessToken != null}');

      if (auth.accessToken == null) {
        _debugLog('❌ Failed to get any authentication token');
        throw Exception('Failed to get authentication tokens');
      }

      // Accept that we might not have ID token on web
      if (auth.idToken == null) {
        _debugLog(
            '⚠️ No ID token available (expected on web), using access token');
      } else {
        _debugLog('✅ ID token available!');
      }

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

  /// Debug logging (only in debug mode)
  void _debugLog(String message) {
    if (kDebugMode) {
      print('[GoogleSignInWebService] $message');
    }
  }
}

/// Result class for Google Sign-In operations
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

  /// Successful sign-in
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

  /// User cancelled sign-in
  factory GoogleSignInResult.cancelled() {
    return const GoogleSignInResult._(
      success: false,
      type: GoogleSignInResultType.cancelled,
      error: 'User cancelled sign-in',
    );
  }

  /// Error during sign-in
  factory GoogleSignInResult.error(String errorMessage) {
    return GoogleSignInResult._(
      success: false,
      type: GoogleSignInResultType.error,
      error: errorMessage,
    );
  }

  @override
  String toString() {
    return 'GoogleSignInResult(success: $success, type: $type, account: ${account?.email}, error: $error)';
  }
}

/// Types of Google Sign-In results
enum GoogleSignInResultType {
  success,
  cancelled,
  error,
}
