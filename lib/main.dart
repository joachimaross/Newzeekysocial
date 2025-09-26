import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zeeky_social/config/environment_config.dart';
import 'package:zeeky_social/services/firebase_initialization_service.dart';
import 'package:zeeky_social/app/app.dart';
import 'package:zeeky_social/providers/app_providers.dart';
import 'dart:developer' as developer;

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Configure logging for main function
  developer.log(
    'Starting Zeeky Social app...',
    name: 'zeeky_social.main',
    level: 800,
  );

  try {
    // Initialize environment configuration
    await EnvironmentConfig.initialize();
    
    // Validate configuration
    EnvironmentConfig.validateConfig();

    // Initialize Firebase services
    await FirebaseInitializationService.initialize();

    developer.log(
      'App initialization completed successfully',
      name: 'zeeky_social.main',
      level: 800,
    );

    // Start the app
    runApp(
      MultiProvider(
        providers: AppProviders.providers,
        child: const ZeekySocialApp(),
      ),
    );

  } catch (error, stackTrace) {
    developer.log(
      'Failed to initialize app',
      name: 'zeeky_social.main',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );

    // Show error UI instead of crashing
    runApp(
      MaterialApp(
        home: AppInitializationErrorScreen(
          error: error,
          stackTrace: stackTrace,
        ),
      ),
    );
  }
}

/// Error screen shown when app fails to initialize
class AppInitializationErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;

  const AppInitializationErrorScreen({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[700],
              ),
              const SizedBox(height: 24),
              Text(
                'Failed to Initialize App',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'The app encountered an error during startup. Please check your configuration and try again.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (EnvironmentConfig.isDevelopment) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error Details (Development Mode):',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: () {
                  // Restart the app by reloading the page (web) or exiting (mobile)
                  // In a real app, you might want to implement proper restart logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Restart App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}