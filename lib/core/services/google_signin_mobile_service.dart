import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Mobile-Specific Google Sign-In Service for ThisAble
/// ✅ FIXED: Now accepts BOTH idToken and accessToken for better compatibility
/// Works reliably on mobile platforms AND handles web edge cases
class GoogleSignInMobileService {
  // Private constructor to prevent direct instantiation
  GoogleSignInMobileService._();

  // Singleton instance
  static final GoogleSignInMobileService _instance =
      GoogleSignInMobileService._();
  static GoogleSignInMobileService get instance => _instance;

  // Google Sign-In instance configured for mobile
  late final GoogleSignIn _googleSignIn;

  // Initialization state
  bool _isInitialized = false;
  GoogleSignInAccount? _currentUser;

  /// Initialize the mobile Google Sign-In service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure Google Sign-In for mobile platforms
      // Uses your existing working configuration
      _googleSignIn = GoogleSignIn(
        clientId:
            '83628564105-ebo9ng5modqfhkgepbm55rkv92d669l9.apps.googleusercontent.com',
        scopes: [
          'email',
          'profile',
        ],
      );

      // Listen for authentication state changes
      _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
        _currentUser = account;
        _debugLog(
            '🔧 Mobile Auth State Changed: ${account?.email ?? 'No user'}');
      });

      // Get current user if already signed in
      _currentUser = _googleSignIn.currentUser;

      _isInitialized = true;
      _debugLog('✅ Mobile Google Sign-In Service initialized');
    } catch (e) {
      _debugLog('❌ Mobile Google Sign-In initialization failed: $e');
      rethrow;
    }
  }

  /// ✅ FIXED: Sign in with flexible token handling
  /// Accepts BOTH idToken (mobile) and accessToken (web fallback)
  Future<GoogleSignInResult> signIn() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _debugLog('🚀 Starting mobile Google Sign-In flow...');

      // Use the traditional signIn() method - works great on mobile!
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        _debugLog('❌ User cancelled sign-in');
        return GoogleSignInResult.cancelled();
      }

      // Get authentication details
      final GoogleSignInAuthentication auth = await account.authentication;

      // ✅ FIXED: Accept EITHER idToken OR accessToken
      final hasIdToken = auth.idToken != null && auth.idToken!.isNotEmpty;
      final hasAccessToken =
          auth.accessToken != null && auth.accessToken!.isNotEmpty;

      // Validate that we have at least ONE valid token
      if (!hasIdToken && !hasAccessToken) {
        _debugLog('❌ Failed to get any authentication token');
        throw Exception('Failed to get any authentication tokens from Google');
      }

      // Log what we received
      _debugLog('✅ Mobile Google Sign-In successful!');
      _debugLog('📧 Email: ${account.email}');
      _debugLog('👤 Name: ${account.displayName}');
      _debugLog('🔑 Has idToken: $hasIdToken');
      _debugLog('🎫 Has accessToken: $hasAccessToken');

      // ✅ FIXED: Warn if only accessToken (unusual for mobile, but acceptable)
      if (!hasIdToken && hasAccessToken) {
        _debugLog(
            '⚠️ No idToken received (unusual for mobile, but continuing with accessToken)');
      }

      return GoogleSignInResult.success(
        account: account,
        authentication: auth,
      );
    } catch (e) {
      _debugLog('❌ Mobile Google Sign-In error: $e');
      return GoogleSignInResult.error(e.toString());
    }
  }

  /// Sign in silently (restore previous session)
  Future<GoogleSignInResult?> signInSilently() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _debugLog('🔍 Attempting silent sign-in...');

      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();

      if (account == null) {
        _debugLog('ℹ️ No cached account found for silent sign-in');
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication auth = await account.authentication;

      _debugLog('✅ Silent sign-in successful: ${account.email}');

      return GoogleSignInResult.success(
        account: account,
        authentication: auth,
      );
    } catch (e) {
      _debugLog('⚠️ Silent sign-in failed: $e');
      return null;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _debugLog('✅ Mobile Google Sign-Out successful');
    } catch (e) {
      _debugLog('❌ Mobile Google Sign-Out error: $e');
      rethrow;
    }
  }

  /// Disconnect (revoke all permissions)
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      _currentUser = null;
      _debugLog('✅ Mobile Google Disconnect successful');
    } catch (e) {
      _debugLog('❌ Mobile Google Disconnect error: $e');
      rethrow;
    }
  }

  /// Force account selection (for signup flow)
  /// This is your existing "choose different account" functionality
  Future<GoogleSignInResult> signInWithAccountSelection() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _debugLog('🔄 Forcing account selection...');

      // Sign out first to force account picker
      await _googleSignIn.signOut();
      await Future.delayed(const Duration(milliseconds: 300));

      // Now sign in (will show account picker)
      return await signIn();
    } catch (e) {
      _debugLog('❌ Account selection flow error: $e');
      return GoogleSignInResult.error(e.toString());
    }
  }

  /// Get current signed-in user
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Check if user is currently signed in
  bool get isSignedIn => _currentUser != null;

  /// Debug logging (only in debug mode)
  void _debugLog(String message) {
    if (kDebugMode) {
      print('[GoogleSignInMobileService] $message');
    }
  }
}

/// Result class for Google Sign-In operations (shared with web service)
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

/// Types of Google Sign-In results (shared with web service)
enum GoogleSignInResultType {
  success,
  cancelled,
  error,
}
