import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'config/constants.dart';
import 'config/routes.dart';

/// Main App Structure - Mirrors your web application structure
class ThisAbleApp extends StatelessWidget {
  const ThisAbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,

      // Navigation system matching your web structure
      initialRoute: AppRoutes.landingHome,
      routes: AppRoutes.routes,

      // Debug settings
      debugShowCheckedModeBanner: false,

      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const NotFoundScreen(),
        );
      },
    );
  }
}

/// 404 Screen for unknown routes
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              '404 - Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'The page you are looking for does not exist.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
