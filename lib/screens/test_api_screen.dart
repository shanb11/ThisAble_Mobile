import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SimpleApiTestScreen extends StatefulWidget {
  const SimpleApiTestScreen({super.key});

  @override
  State<SimpleApiTestScreen> createState() => _SimpleApiTestScreenState();
}

class _SimpleApiTestScreenState extends State<SimpleApiTestScreen> {
  String _results = 'Tap Test Connection to start...';
  bool _isLoading = false;

  Future<void> _testBasicConnection() async {
    setState(() {
      _isLoading = true;
      _results = 'Testing connection...\n';
    });

    try {
      // Test basic connection to your API
      final response = await http.get(
        Uri.parse('http://192.168.1.3/ThisAble/api/test.php'),
        headers: {'Content-Type': 'application/json'},
      );

      setState(() {
        _results += 'Status Code: ${response.statusCode}\n';
        _results += 'Response: ${response.body}\n\n';
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _results += '✅ API CONNECTION SUCCESS!\n';
            _results += 'Your app can reach XAMPP server.\n\n';
          });
        } else {
          setState(() {
            _results += '❌ API responded but with error\n';
          });
        }
      } else {
        setState(() {
          _results += '❌ HTTP Error: ${response.statusCode}\n';
        });
      }
    } catch (e) {
      setState(() {
        _results += '❌ Connection Failed: $e\n\n';
        _results += 'Check:\n';
        _results += '1. XAMPP is running\n';
        _results += '2. Phone & computer on same WiFi\n';
        _results += '3. IP address is correct\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
        backgroundColor: const Color(0xFF257180),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testBasicConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF257180),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test Connection'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
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
