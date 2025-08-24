import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import your existing dynamic config system
import '../../../config/dynamic_api_config.dart';
import '../../../core/services/network_discovery_service.dart';
import '../../../core/services/api_service.dart';

class SimpleApiTestScreen extends StatefulWidget {
  const SimpleApiTestScreen({super.key});

  @override
  State<SimpleApiTestScreen> createState() => _SimpleApiTestScreenState();
}

class _SimpleApiTestScreenState extends State<SimpleApiTestScreen> {
  String _results = 'Tap buttons below to test your API connection...';
  bool _isLoading = false;

  // Manual IP input
  final TextEditingController _ipController = TextEditingController(
    text: '10.212.51.157', // Your current IP
  );

  /// Test basic connection using DYNAMIC CONFIG (not hardcoded)
  Future<void> _testDynamicConnection() async {
    setState(() {
      _isLoading = true;
      _results = 'Testing connection using Dynamic API Config...\n';
    });

    try {
      // Get current configuration status
      final currentConfig = await DynamicApiConfig.getStatus();
      setState(() {
        _results += 'Current Config:\n';
        _results += '  IP: ${currentConfig['current_ip'] ?? 'None'}\n';
        _results +=
            '  Base URL: ${currentConfig['current_base_url'] ?? 'None'}\n';
        _results += '  Initialized: ${currentConfig['is_initialized']}\n\n';
      });

      // Test using your existing API service
      final response = await ApiService.testConnection();

      setState(() {
        _results += 'API Service Test Result:\n';
        _results += '  Success: ${response['success']}\n';
        _results += '  Message: ${response['message']}\n';

        if (response['success'] == true && response['data'] != null) {
          final data = response['data'];
          _results += '  Server: ${data['message']}\n';
          _results += '  Database: ${data['database_status']}\n';
          _results += '  Candidates: ${data['total_candidates']}\n';
          _results += '  Time: ${data['server_time']}\n';
          _results += '\n✅ DYNAMIC CONFIG WORKING!\n';
        } else {
          _results += '\n❌ Dynamic config failed\n';
        }
      });
    } catch (e) {
      setState(() {
        _results += '❌ Dynamic Connection Failed: $e\n\n';
        _results += 'This means your cached IP might be wrong.\n';
        _results += 'Try "Force Refresh" to clear cache.\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Force refresh the network configuration
  Future<void> _forceRefresh() async {
    setState(() {
      _isLoading = true;
      _results = 'Force refreshing network configuration...\n';
    });

    try {
      // Clear cache and force rediscovery
      await NetworkDiscoveryService.clearCache();
      setState(() {
        _results += '✅ Cache cleared\n';
      });

      // Force reinitialize
      final success = await DynamicApiConfig.refresh();

      if (success) {
        final newConfig = await DynamicApiConfig.getStatus();
        setState(() {
          _results += '✅ Network rediscovered!\n';
          _results += 'New IP: ${newConfig['current_ip']}\n';
          _results += 'New Base URL: ${newConfig['current_base_url']}\n\n';
          _results += 'Try "Test Dynamic Connection" again.\n';
        });
      } else {
        setState(() {
          _results += '❌ Auto-discovery failed\n';
          _results += 'Use "Set Manual IP" with correct IP address.\n';
        });
      }
    } catch (e) {
      setState(() {
        _results += '❌ Force refresh failed: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Set manual IP address
  Future<void> _setManualIP() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      setState(() {
        _results = 'Please enter an IP address first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _results = 'Setting manual IP: $ip...\n';
    });

    try {
      // Set manual IP using your existing system
      final success = await DynamicApiConfig.setManualIP(ip);

      if (success) {
        setState(() {
          _results += '✅ Manual IP set successfully!\n';
          _results += 'New Base URL: http://$ip/ThisAble/api\n\n';
        });

        // Test the connection immediately
        await _testJobsAPI();
      } else {
        setState(() {
          _results += '❌ Failed to set manual IP\n';
          _results += 'Make sure XAMPP is running on that IP.\n';
        });
      }
    } catch (e) {
      setState(() {
        _results += '❌ Manual IP setting failed: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Test the specific jobs API that's failing
  Future<void> _testJobsAPI() async {
    setState(() {
      _isLoading = true;
      _results += '\nTesting Jobs API (the one that was failing)...\n';
    });

    try {
      // Test the specific jobs API that was timing out
      final response = await ApiService.getLandingJobs(
        category: 'customer',
        limit: 3,
      );

      setState(() {
        if (response['success'] == true) {
          final jobs = response['data']['jobs'] as List;
          _results += '✅ JOBS API WORKING!\n';
          _results += 'Found ${jobs.length} test jobs\n';
          if (jobs.isNotEmpty) {
            _results += 'Sample job: ${jobs.first['title']}\n';
          }
          _results += '\n🎉 YOUR CONNECTION IS FIXED!\n';
        } else {
          _results += '❌ Jobs API failed: ${response['message']}\n';
        }
      });
    } catch (e) {
      setState(() {
        _results += '❌ Jobs API test failed: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Copy current IP to clipboard
  void _copyIP() {
    Clipboard.setData(ClipboardData(text: _ipController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('IP copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced API Test'),
        backgroundColor: const Color(0xFF257180),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Manual IP Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manual IP Override',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ipController,
                            decoration: const InputDecoration(
                              labelText: 'Your Laptop IP',
                              hintText: '10.212.51.157',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _copyIP,
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy IP',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            ElevatedButton(
              onPressed: _isLoading ? null : _testDynamicConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF257180),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading && _results.contains('Dynamic')
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Text('Testing...'),
                      ],
                    )
                  : const Text('1. Test Dynamic Connection'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _isLoading ? null : _forceRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading && _results.contains('refresh')
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Text('Refreshing...'),
                      ],
                    )
                  : const Text('2. Force Refresh (Clear Cache)'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _isLoading ? null : _setManualIP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading && _results.contains('manual')
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Text('Setting...'),
                      ],
                    )
                  : const Text('3. Set Manual IP (Quick Fix)'),
            ),

            const SizedBox(height: 16),

            // Results Section
            Card(
              child: Container(
                width: double.infinity,
                height: 400,
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Text(
                    _results,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
