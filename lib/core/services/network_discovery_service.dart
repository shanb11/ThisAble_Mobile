import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

/// Enhanced Network Discovery Service for ThisAble Mobile
/// NOW SUPPORTS: Physical devices, Android emulator, iOS simulator, Web browser
/// Automatically finds your computer's IP address across different platforms and locations
class NetworkDiscoveryService {
  static const String _cachedIPKey = 'cached_computer_ip';
  static const String _projectPath = 'ThisAble';
  static const int _timeoutSeconds = 3;

  /// Main discovery method - platform-intelligent
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

    // Step 2: Platform-specific discovery
    String? discoveredIP;

    if (kIsWeb) {
      // Web browser discovery
      discoveredIP = await _discoverWebHostIP();
    } else if (Platform.isAndroid) {
      // Android discovery (physical device or emulator)
      discoveredIP = await _discoverAndroidHostIP();
    } else if (Platform.isIOS) {
      // iOS discovery (physical device or simulator)
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

  /// Android-specific discovery (physical device + emulator)
  static Future<String?> _discoverAndroidHostIP() async {
    print('🤖 Android platform detected');

    try {
      // Try physical device discovery first (your current method)
      final physicalDeviceIP = await _discoverPhysicalDeviceIP();
      if (physicalDeviceIP != null) {
        print('📱 Physical device IP discovery successful');
        return physicalDeviceIP;
      }
    } catch (e) {
      print('📱 Physical device discovery failed: $e');
    }

    // If physical device fails, try emulator discovery
    print('🤖 Attempting Android emulator host discovery...');
    return await _discoverAndroidEmulatorHostIP();
  }

  /// iOS-specific discovery (physical device + simulator)
  static Future<String?> _discoverIOSHostIP() async {
    print('📱 iOS platform detected');

    try {
      // Try physical device discovery first
      final physicalDeviceIP = await _discoverPhysicalDeviceIP();
      if (physicalDeviceIP != null) {
        print('📱 Physical device IP discovery successful');
        return physicalDeviceIP;
      }
    } catch (e) {
      print('📱 Physical device discovery failed: $e');
    }

    // If physical device fails, try simulator discovery
    print('📱 Attempting iOS simulator host discovery...');
    return await _discoverIOSSimulatorHostIP();
  }

  /// Web browser discovery
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

    // Try common IPs
    return await _discoverCommonHostIPs();
  }

  /// Physical device IP discovery (your original method)
  static Future<String?> _discoverPhysicalDeviceIP() async {
    try {
      print('📱 Attempting physical device network interface discovery...');
      final interfaces = await NetworkInterface.list();

      for (var interface in interfaces) {
        // Look for WiFi interface
        if (interface.name.toLowerCase().contains('wlan') ||
            interface.name.toLowerCase().contains('wifi') ||
            interface.name.toLowerCase().contains('en0')) {
          for (var addr in interface.addresses) {
            if (addr.type == InternetAddressType.IPv4 &&
                !addr.isLoopback &&
                addr.address.startsWith(RegExp(r'192\.168\.|10\.|172\.'))) {
              // Test this IP to make sure it works
              if (await _testIP(addr.address)) {
                print('✅ Physical device IP found: ${addr.address}');
                return addr.address;
              }
            }
          }
        }
      }

      // Fallback: any non-loopback IPv4
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              !addr.isLoopback &&
              addr.address.startsWith(RegExp(r'192\.168\.|10\.|172\.'))) {
            if (await _testIP(addr.address)) {
              print('✅ Physical device IP found (fallback): ${addr.address}');
              return addr.address;
            }
          }
        }
      }

      return null;
    } catch (e) {
      print('❌ Physical device discovery error: $e');
      return null;
    }
  }

  /// Android emulator host IP discovery
  static Future<String?> _discoverAndroidEmulatorHostIP() async {
    print('🤖 Scanning for Android emulator host IP...');

    // Android emulator specific: 10.0.2.2 is the host machine
    // But we need to find the actual IP on the host's network

    // Strategy 1: Test common IP patterns based on typical networks
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

  /// Scan a network range for working XAMPP server (your existing logic enhanced)
  static Future<String?> _scanNetworkRange(String networkBase) async {
    // Enhanced version of your existing method with better IP priority
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

  /// Test if a specific IP address works (your existing method enhanced)
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

  /// Manual IP override (your existing method enhanced)
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
