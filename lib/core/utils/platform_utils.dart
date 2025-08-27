import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// Platform Detection Utilities for ThisAble
/// Provides cross-platform detection and configuration helpers
class PlatformUtils {
  // Private constructor to prevent instantiation
  PlatformUtils._();

  /// Check if running on web platform
  static bool get isWeb => kIsWeb;

  /// Check if running on mobile platform (Android or iOS)
  static bool get isMobile => !kIsWeb;

  /// Check if running on Android platform
  static bool get isAndroid {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid;
    } catch (e) {
      return false;
    }
  }

  /// Check if running on iOS platform
  static bool get isIOS {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  /// Get current platform name for debugging
  static String get platformName {
    if (kIsWeb) {
      return 'Web Browser';
    }

    try {
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      if (Platform.isWindows) return 'Windows';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isLinux) return 'Linux';
    } catch (e) {
      // Platform detection might fail in some environments
    }

    return 'Unknown Platform';
  }

  /// Check if running in debug mode
  static bool get isDebugMode => kDebugMode;

  /// Check if running in release mode
  static bool get isReleaseMode => kReleaseMode;

  /// Get platform-specific configuration for Google Sign-In
  static GoogleSignInConfig get googleSignInConfig {
    if (isWeb) {
      return GoogleSignInConfig.web();
    } else {
      return GoogleSignInConfig.mobile();
    }
  }

  /// Print platform information for debugging
  static void debugPlatformInfo() {
    if (kDebugMode) {
      print('=== PLATFORM INFO ===');
      print('Platform: ${platformName}');
      print('Is Web: ${isWeb}');
      print('Is Mobile: ${isMobile}');
      print('Is Android: ${isAndroid}');
      print('Is iOS: ${isIOS}');
      print('Is Debug: ${isDebugMode}');
      print('===================');
    }
  }
}

/// Configuration class for Google Sign-In based on platform
class GoogleSignInConfig {
  final bool useRenderButton;
  final bool useSignInSilently;
  final bool useDeprecatedSignIn;
  final String configType;

  const GoogleSignInConfig._({
    required this.useRenderButton,
    required this.useSignInSilently,
    required this.useDeprecatedSignIn,
    required this.configType,
  });

  /// Web-specific Google Sign-In configuration
  factory GoogleSignInConfig.web() {
    return const GoogleSignInConfig._(
      useRenderButton: true, // Use renderButton for web
      useSignInSilently: true, // Use signInSilently for web
      useDeprecatedSignIn: false, // Don't use deprecated signIn() on web
      configType: 'Web Platform',
    );
  }

  /// Mobile-specific Google Sign-In configuration
  factory GoogleSignInConfig.mobile() {
    return const GoogleSignInConfig._(
      useRenderButton: false, // Don't use renderButton on mobile
      useSignInSilently: false, // Don't need signInSilently on mobile
      useDeprecatedSignIn: true, // Use traditional signIn() on mobile
      configType: 'Mobile Platform',
    );
  }

  @override
  String toString() {
    return 'GoogleSignInConfig(type: $configType, renderButton: $useRenderButton, signInSilently: $useSignInSilently, deprecatedSignIn: $useDeprecatedSignIn)';
  }
}
