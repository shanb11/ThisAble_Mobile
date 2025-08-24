import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

/// FIXED Network Discovery Service for ThisAble Mobile
/// PRIORITY: Physical device discovery (your original working method)
/// SECONDARY: Emulator/web fallbacks
class NetworkDiscoveryService {
  static const String _cachedIPKey = 'cached_computer_ip';
  static const String _projectPath = 'ThisAble';
  static const int _timeoutSeconds = 3;

  /// Main discovery method - PHYSICAL DEVICE PRIORITY
  static Future<String?> findWorkingIP() async {
    print('🔍 Auto-discovering computer IP address...');
    print('🔍 Platform: ${_getPlatformName()}');

    // Step 1: Try cached IP first (works for all platforms)
    final cachedIP = await _getCachedIP();
    if (cachedIP != null) {
      print('🔍 Testing cached IP: $cachedIP');
      if (await _testIP(cachedIP)) {
        print('✅ Cached IP still works: $cachedIP');
        return cachedIP;
      }
      print('❌ Cached IP no longer works, running discovery...');
    }

    // Step 2: Platform-specific discovery with CORRECT priorities
    String? discoveredIP;

    if (kIsWeb) {
      // Web browser discovery
      discoveredIP = await _discoverWebHostIP();
    } else if (Platform.isAndroid) {
      // Android discovery - FIXED LOGIC
      discoveredIP = await _discoverAndroidHostIP();
    } else if (Platform.isIOS) {
      // iOS discovery - FIXED LOGIC
      discoveredIP = await _discoverIOSHostIP();
    } else {
      // Unknown platform - try common methods
      discoveredIP = await _discoverUnknownPlatformIP();
    }

    // Step 3: Cache and return if successful
    if (discoveredIP != null) {
      await _cacheIP(discoveredIP);
      return discoveredIP;
    }

    print('❌ No working IP found across all discovery methods');
    return null;
  }

  /// FIXED Android discovery - Physical device FIRST, emulator ONLY if physical fails AND actually emulator
  static Future<String?> _discoverAndroidHostIP() async {
    print('🤖 Android platform detected');

    // FIRST: Always try physical device discovery (your original working method)
    print('📱 Attempting physical device discovery...');
    final physicalDeviceIP = await _discoverPhysicalDeviceIP();
    if (physicalDeviceIP != null) {
      print('✅ Physical device discovery successful: $physicalDeviceIP');
      return physicalDeviceIP;
    }

    print('📱 Physical device discovery failed');

    // SECOND: Only try emulator discovery if this might actually be an emulator
    if (await _isLikelyAndroidEmulator()) {
      print(
          '🤖 Detected likely Android emulator, trying emulator discovery...');
      return await _discoverAndroidEmulatorHostIP();
    } else {
      print(
          '📱 This appears to be a physical device, not attempting emulator methods');
      return null;
    }
  }

  /// FIXED iOS discovery - Physical device FIRST, simulator ONLY if physical fails
  static Future<String?> _discoverIOSHostIP() async {
    print('📱 iOS platform detected');

    // FIRST: Always try physical device discovery
    print('📱 Attempting physical device discovery...');
    final physicalDeviceIP = await _discoverPhysicalDeviceIP();
    if (physicalDeviceIP != null) {
      print('✅ Physical device discovery successful: $physicalDeviceIP');
      return physicalDeviceIP;
    }

    print('📱 Physical device discovery failed, trying simulator methods...');
    return await _discoverIOSSimulatorHostIP();
  }

  /// Web browser discovery (unchanged)
  static Future<String?> _discoverWebHostIP() async {
    print('🌐 Web browser detected');

    // For web, try localhost first
    const String localhost = 'localhost';
    if (await _testIP(localhost)) {
      print('✅ Web localhost connection successful');
      return localhost;
    }

    // If localhost fails, try common development IPs
    print('🌐 Localhost failed, trying common development IPs...');
    return await _discoverCommonHostIPs();
  }

  /// Unknown platform fallback discovery
  static Future<String?> _discoverUnknownPlatformIP() async {
    print('❓ Unknown platform, trying all discovery methods...');

    // Try localhost first
    if (await _testIP('localhost')) {
      return 'localhost';
    }

    // Try physical device discovery
    final physicalIP = await _discoverPhysicalDeviceIP();
    if (physicalIP != null) {
      return physicalIP;
    }

    // Try common IPs
    return await _discoverCommonHostIPs();
  }

  /// RESTORED - Your original physical device IP discovery method (WORKING VERSION)
  static Future<String?> _discoverPhysicalDeviceIP() async {
    try {
      print(
          '📱 Using NetworkInterface.list() for physical device discovery...');
      final interfaces = await NetworkInterface.list();

      print('📱 Found ${interfaces.length} network interfaces');

      // Step 1: Look for WiFi interfaces first (your original logic)
      for (var interface in interfaces) {
        print('📱 Checking interface: ${interface.name}');

        if (interface.name.toLowerCase().contains('wlan') ||
            interface.name.toLowerCase().contains('wifi') ||
            interface.name.toLowerCase().contains('en0')) {
          for (var addr in interface.addresses) {
            if (addr.type == InternetAddressType.IPv4 &&
                !addr.isLoopback &&
                addr.address.startsWith(RegExp(r'192\.168\.|10\.|172\.'))) {
              print('📱 Found device IP: ${addr.address}');

              // Now find your computer's IP on the same network
              final computerIP =
                  await _findComputerIPFromDeviceIP(addr.address);
              if (computerIP != null) {
                print('✅ Physical device found computer IP: $computerIP');
                return computerIP;
              }
            }
          }
        }
      }

      // Step 2: Fallback to any non-loopback IPv4 (your original logic)
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              !addr.isLoopback &&
              addr.address.startsWith(RegExp(r'192\.168\.|10\.|172\.'))) {
            print('📱 Found device IP (fallback): ${addr.address}');

            final computerIP = await _findComputerIPFromDeviceIP(addr.address);
            if (computerIP != null) {
              print(
                  '✅ Physical device found computer IP (fallback): $computerIP');
              return computerIP;
            }
          }
        }
      }

      print('❌ Physical device: No valid network interfaces found');
      return null;
    } catch (e) {
      print('❌ Physical device discovery error: $e');
      return null;
    }
  }

  /// NEW: Find computer IP from device IP (scan same network)
  static Future<String?> _findComputerIPFromDeviceIP(String deviceIP) async {
    print('📱 Device is on IP: $deviceIP');

    // Get network base (e.g., 192.168.1.100 -> 192.168.1)
    final networkBase = _getNetworkBase(deviceIP);
    if (networkBase == null) {
      print('❌ Could not determine network base from $deviceIP');
      return null;
    }

    print('📱 Scanning network $networkBase.x for XAMPP server...');

    // Scan the network for XAMPP server
    return await _scanNetworkRange(networkBase);
  }

  /// Check if this is likely an Android emulator
  static Future<bool> _isLikelyAndroidEmulator() async {
    try {
      // Simple emulator detection methods

      // Method 1: Check environment variables
      if (Platform.environment.containsKey('ANDROID_EMU_CONSOLE_AUTH_TOKEN') ||
          Platform.environment.containsKey('ANDROID_AVD_NAME')) {
        return true;
      }

      // Method 2: Check device IP patterns
      try {
        final interfaces = await NetworkInterface.list();
        for (var interface in interfaces) {
          for (var addr in interface.addresses) {
            // Android emulator typically gets IPs in 10.0.2.x range
            if (addr.address.startsWith('10.0.2.')) {
              return true;
            }
          }
        }
      } catch (e) {
        // If we can't check interfaces, assume physical device
      }

      return false;
    } catch (e) {
      // If detection fails, assume physical device (safer)
      return false;
    }
  }

  /// Android emulator host IP discovery (only called if confirmed emulator)
  static Future<String?> _discoverAndroidEmulatorHostIP() async {
    print('🤖 Scanning for Android emulator host IP...');

    // Android emulator specific: scan common host network ranges
    final commonRanges = [
      '192.168.1', // Most common home WiFi
      '192.168.0', // Alternative home WiFi
      '10.0.0', // Some corporate networks
      '172.20.10', // iPhone hotspot range
      '192.168.43', // Android hotspot range
      '10.212.51', // Your specific hotspot range (from your files)
    ];

    for (String networkBase in commonRanges) {
      print('🔍 Scanning network range: $networkBase.x');
      final ip = await _scanNetworkRange(networkBase);
      if (ip != null) {
        print('✅ Android emulator host IP found: $ip');
        return ip;
      }
    }

    print('❌ Android emulator host IP not found in common ranges');
    return null;
  }

  /// iOS simulator host IP discovery
  static Future<String?> _discoverIOSSimulatorHostIP() async {
    print('📱 Scanning for iOS simulator host IP...');

    // iOS simulator typically can use localhost
    if (await _testIP('localhost')) {
      return 'localhost';
    }

    // If localhost fails, try common patterns
    return await _discoverCommonHostIPs();
  }

  /// Discover common host IPs (used by multiple platforms)
  static Future<String?> _discoverCommonHostIPs() async {
    print('🔍 Scanning common host IP patterns...');

    final commonRanges = [
      '192.168.1', // Most common
      '192.168.0', // Very common
      '10.0.0', // Corporate
      '172.16.0', // Alternative
      '192.168.43', // Android hotspot
      '172.20.10', // iPhone hotspot
      '10.212.51', // Your specific range
    ];

    for (String networkBase in commonRanges) {
      final ip = await _scanNetworkRange(networkBase);
      if (ip != null) {
        return ip;
      }
    }

    return null;
  }

  /// Extract network base from IP (e.g., 192.168.1.100 -> 192.168.1)
  static String? _getNetworkBase(String ip) {
    final parts = ip.split('.');
    if (parts.length >= 3) {
      return '${parts[0]}.${parts[1]}.${parts[2]}';
    }
    return null;
  }

  /// Scan a network range for working XAMPP server (enhanced version)
  static Future<String?> _scanNetworkRange(String networkBase) async {
    // Enhanced version with better IP priority
    final prioritizedIPs = [
      // High priority IPs (your current/recent IPs from files)
      157, 3, 18, // From your existing config

      // Common computer IPs
      100, 101, 102, 103, 104, 105,

      // Router and gateway IPs
      1, 254,

      // Common DHCP range
      2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19, 20,
      21, 22, 23, 24, 25, 26, 27, 28, 29, 30,

      // Extended range
      50, 51, 52, 53, 54, 55, 217,
    ];

    // Test IPs in parallel for speed (your existing approach)
    final futures = prioritizedIPs.map((lastByte) async {
      final ip = '$networkBase.$lastByte';
      final works = await _testIP(ip);
      return works ? ip : null;
    }).toList();

    final results = await Future.wait(futures);

    // Return first working IP
    for (String? result in results) {
      if (result != null) {
        print('✅ Found working IP in range $networkBase.x: $result');
        return result;
      }
    }

    return null;
  }

  /// Test if a specific IP address works (your existing method)
  static Future<bool> _testIP(String ip) async {
    try {
      final response = await http.get(
        Uri.parse('http://$ip/$_projectPath/api/test.php'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final success = data['success'] == true;
        if (success) {
          print('✅ IP $ip responded successfully');
        }
        return success;
      }
      return false;
    } catch (e) {
      // Silence individual IP test failures (too much noise)
      return false;
    }
  }

  /// Cache working IP for next time (your existing method)
  static Future<void> _cacheIP(String ip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedIPKey, ip);
      await prefs.setInt(
          '${_cachedIPKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
      print('💾 Cached working IP: $ip');
    } catch (e) {
      print('Error caching IP: $e');
    }
  }

  /// Get cached IP if still valid (your existing method)
  static Future<String?> _getCachedIP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedIP = prefs.getString(_cachedIPKey);
      final timestamp = prefs.getInt('${_cachedIPKey}_timestamp');

      if (cachedIP != null && timestamp != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        final maxAge = 7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds

        if (cacheAge < maxAge) {
          return cachedIP;
        }
      }

      return null;
    } catch (e) {
      print('Error getting cached IP: $e');
      return null;
    }
  }

  /// Clear cached IP (your existing method)
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedIPKey);
      await prefs.remove('${_cachedIPKey}_timestamp');
      print('🗑️ Cleared IP cache');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Manual IP override (your existing method)
  static Future<void> setManualIP(String ip) async {
    if (await _testIP(ip)) {
      await _cacheIP(ip);
      print('✅ Manual IP set and verified: $ip');
    } else {
      print('❌ Manual IP failed verification: $ip');
      throw Exception('Manual IP is not working');
    }
  }

  /// Get platform name for debugging
  static String _getPlatformName() {
    if (kIsWeb) return 'Web Browser';
    try {
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      if (Platform.isWindows) return 'Windows';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isLinux) return 'Linux';
    } catch (e) {
      // Platform detection might fail in some environments
    }
    return 'Unknown';
  }

  /// Get discovery status for debugging
  static Future<Map<String, dynamic>> getDiscoveryStatus() async {
    return {
      'platform': _getPlatformName(),
      'cached_ip': await _getCachedIP(),
      'cache_timestamp': await _getCacheTimestamp(),
      'is_web': kIsWeb,
      'supports_network_interface': await _supportsNetworkInterface(),
      'likely_emulator': !kIsWeb && Platform.isAndroid
          ? await _isLikelyAndroidEmulator()
          : false,
    };
  }

  static Future<int?> _getCacheTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('${_cachedIPKey}_timestamp');
    } catch (e) {
      return null;
    }
  }

  static Future<bool> _supportsNetworkInterface() async {
    if (kIsWeb) return false;
    try {
      await NetworkInterface.list();
      return true;
    } catch (e) {
      return false;
    }
  }
}
