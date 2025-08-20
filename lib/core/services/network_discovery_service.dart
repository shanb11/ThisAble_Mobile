import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Network Discovery Service for ThisAble Mobile
/// Automatically finds your computer's IP address across different locations
class NetworkDiscoveryService {
  static const String _cachedIPKey = 'cached_computer_ip';
  static const String _projectPath = 'ThisAble';
  static const int _timeoutSeconds = 3;

  /// Find working IP address automatically
  static Future<String?> findWorkingIP() async {
    print('🔍 Auto-discovering computer IP address...');

    // Step 1: Try cached IP first
    final cachedIP = await _getCachedIP();
    if (cachedIP != null) {
      print('🔍 Testing cached IP: $cachedIP');
      if (await _testIP(cachedIP)) {
        print('✅ Cached IP still works: $cachedIP');
        return cachedIP;
      }
      print('❌ Cached IP no longer works, scanning...');
    }

    // Step 2: Scan network range
    final deviceIP = await _getDeviceIP();
    if (deviceIP != null) {
      print('📱 Device IP: $deviceIP');

      final networkBase = _getNetworkBase(deviceIP);
      if (networkBase != null) {
        print('🔍 Scanning network range: $networkBase.x');

        final workingIP = await _scanNetworkRange(networkBase);
        if (workingIP != null) {
          await _cacheIP(workingIP);
          return workingIP;
        }
      }
    }

    // Step 3: Try common IP ranges
    print('🔍 Trying common IP ranges...');
    final commonRanges = [
      '10.212.51', // Your hotspot range
      '192.168.43', // Android hotspot
      '172.20.10', // iPhone hotspot
      '192.168.1', // Regular WiFi
      '192.168.0',
      '10.0.0',
      '172.16.0'
    ];

    for (String range in commonRanges) {
      final workingIP = await _scanNetworkRange(range);
      if (workingIP != null) {
        await _cacheIP(workingIP);
        return workingIP;
      }
    }

    print('❌ No working IP found');
    return null;
  }

  /// Test if a specific IP address works
  static Future<bool> _testIP(String ip) async {
    try {
      final response = await http.get(
        Uri.parse('http://$ip/$_projectPath/api/test.php'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get device's current IP address
  static Future<String?> _getDeviceIP() async {
    try {
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
              return addr.address;
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
            return addr.address;
          }
        }
      }

      return null;
    } catch (e) {
      print('Error getting device IP: $e');
      return null;
    }
  }

  /// Extract network base from IP (e.g., 192.168.1.100 -> 192.168.1)
  static String? _getNetworkBase(String ip) {
    final parts = ip.split('.');
    if (parts.length >= 3) {
      return '${parts[0]}.${parts[1]}.${parts[2]}';
    }
    return null;
  }

  /// Scan a network range for working XAMPP server
  static Future<String?> _scanNetworkRange(String networkBase) async {
    // Common computer IP addresses
    final commonLastBytes = [
      // Your hotspot IPs first!
      18, // Your phone (gateway)
      157, // Your laptop current IP
      // Common hotspot range
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19, 20,
      21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
      // Common static IPs
      100, 101, 102, 103, 104, 105, 217,
      // Other ranges
      50, 51, 52, 53, 54, 55,
    ];

    // Test IPs in parallel for speed
    final futures = commonLastBytes.map((lastByte) async {
      final ip = '$networkBase.$lastByte';
      final works = await _testIP(ip);
      return works ? ip : null;
    }).toList();

    final results = await Future.wait(futures);

    // Return first working IP
    for (String? result in results) {
      if (result != null) {
        print('✅ Found working IP: $result');
        return result;
      }
    }

    return null;
  }

  /// Cache working IP for next time
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

  /// Get cached IP if still valid (within 7 days)
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

  /// Clear cached IP (useful for debugging)
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

  /// Manual IP override (for debugging)
  static Future<void> setManualIP(String ip) async {
    if (await _testIP(ip)) {
      await _cacheIP(ip);
      print('✅ Manual IP set and verified: $ip');
    } else {
      print('❌ Manual IP failed verification: $ip');
      throw Exception('Manual IP is not working');
    }
  }
}
