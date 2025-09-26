import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:developer' as developer;

/// Environment configuration service that manages app environment
/// variables and Firebase configuration securely.
class EnvironmentConfig {
  static late String _currentEnvironment;
  static bool _isInitialized = false;

  static String get currentEnvironment => _currentEnvironment;
  static bool get isInitialized => _isInitialized;

  /// Initialize environment configuration
  /// Should be called before Firebase initialization
  static Future<void> initialize({String environment = 'development'}) async {
    try {
      _currentEnvironment = environment;
      
      // Load appropriate environment file
      final envFile = environment == 'production' ? '.env.prod' : '.env.dev';
      
      await dotenv.load(fileName: envFile);
      _isInitialized = true;
      
      developer.log(
        'Environment initialized: $environment',
        name: 'zeeky_social.config',
        level: 800,
      );
    } catch (e) {
      developer.log(
        'Failed to load environment configuration',
        name: 'zeeky_social.config',
        level: 1000,
        error: e,
      );
      
      // Fallback to hardcoded values for development
      _isInitialized = true;
      _currentEnvironment = 'development';
    }
  }

  /// Get Firebase options based on current platform and environment
  static FirebaseOptions get firebaseOptions {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: _getEnvVar('FIREBASE_API_KEY', 'AIzaSyC6N1O6feQjTNhWqAIh3QZ71m7qvx9pqSE'),
        appId: _getEnvVar('FIREBASE_APP_ID', '1:961063588565:web:0857f2508591e3f185c85c'),
        messagingSenderId: _getEnvVar('FIREBASE_MESSAGING_SENDER_ID', '961063588565'),
        projectId: _getEnvVar('FIREBASE_PROJECT_ID', 'gen-lang-client-0610030211'),
        authDomain: _getEnvVar('FIREBASE_AUTH_DOMAIN', 'gen-lang-client-0610030211.firebaseapp.com'),
        storageBucket: _getEnvVar('FIREBASE_STORAGE_BUCKET', 'gen-lang-client-0610030211.firebasestorage.app'),
        measurementId: _getEnvVar('FIREBASE_MEASUREMENT_ID', 'G-Y2F39Q4BXM'),
      );
    }
    
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: _getEnvVar('FIREBASE_ANDROID_API_KEY', 'AIzaSyDDtQTL3-egsBm5xKkDpYBR-VdyHTeHVQ4'),
          appId: _getEnvVar('FIREBASE_ANDROID_APP_ID', '1:961063588565:android:83bf87b7457e81b285c85c'),
          messagingSenderId: _getEnvVar('FIREBASE_MESSAGING_SENDER_ID', '961063588565'),
          projectId: _getEnvVar('FIREBASE_PROJECT_ID', 'gen-lang-client-0610030211'),
          storageBucket: _getEnvVar('FIREBASE_STORAGE_BUCKET', 'gen-lang-client-0610030211.firebasestorage.app'),
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: _getEnvVar('FIREBASE_IOS_API_KEY', 'AIzaSyBMCpmSCBmVb4OjG9Mp6POu2DDQkxF9zoI'),
          appId: _getEnvVar('FIREBASE_IOS_APP_ID', '1:961063588565:ios:eeb532226e716b3685c85c'),
          messagingSenderId: _getEnvVar('FIREBASE_MESSAGING_SENDER_ID', '961063588565'),
          projectId: _getEnvVar('FIREBASE_PROJECT_ID', 'gen-lang-client-0610030211'),
          storageBucket: _getEnvVar('FIREBASE_STORAGE_BUCKET', 'gen-lang-client-0610030211.firebasestorage.app'),
          iosBundleId: _getEnvVar('FIREBASE_IOS_BUNDLE_ID', 'com.example.myap'),
        );
      case TargetPlatform.macOS:
        return FirebaseOptions(
          apiKey: _getEnvVar('FIREBASE_MACOS_API_KEY', 'AIzaSyBMCpmSCBmVb4OjG9Mp6POu2DDQkxF9zoI'),
          appId: _getEnvVar('FIREBASE_MACOS_APP_ID', '1:961063588565:ios:7eac9ed45f6be66f85c85c'),
          messagingSenderId: _getEnvVar('FIREBASE_MESSAGING_SENDER_ID', '961063588565'),
          projectId: _getEnvVar('FIREBASE_PROJECT_ID', 'gen-lang-client-0610030211'),
          storageBucket: _getEnvVar('FIREBASE_STORAGE_BUCKET', 'gen-lang-client-0610030211.firebasestorage.app'),
          iosBundleId: _getEnvVar('FIREBASE_MACOS_BUNDLE_ID', 'com.example.myapp'),
        );
      case TargetPlatform.windows:
        return FirebaseOptions(
          apiKey: _getEnvVar('FIREBASE_WINDOWS_API_KEY', 'AIzaSyC6N1O6feQjTNhWqAIh3QZ71m7qvx9pqSE'),
          appId: _getEnvVar('FIREBASE_WINDOWS_APP_ID', '1:961063588565:web:004dd64d7291ef5a85c85c'),
          messagingSenderId: _getEnvVar('FIREBASE_MESSAGING_SENDER_ID', '961063588565'),
          projectId: _getEnvVar('FIREBASE_PROJECT_ID', 'gen-lang-client-0610030211'),
          authDomain: _getEnvVar('FIREBASE_AUTH_DOMAIN', 'gen-lang-client-0610030211.firebaseapp.com'),
          storageBucket: _getEnvVar('FIREBASE_STORAGE_BUCKET', 'gen-lang-client-0610030211.firebasestorage.app'),
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase has not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'Firebase is not supported for this platform.',
        );
    }
  }

  /// Get reCAPTCHA v3 site key for App Check
  static String get recaptchaV3SiteKey => 
      _getEnvVar('RECAPTCHA_V3_SITE_KEY', 'recaptcha-v3-site-key');

  /// Check if running in development mode
  static bool get isDevelopment => 
      _getEnvVar('FLUTTER_ENV', 'development') == 'development';

  /// Check if running in production mode
  static bool get isProduction => 
      _getEnvVar('FLUTTER_ENV', 'development') == 'production';

  /// Get Firebase project ID
  static String get projectId => 
      _getEnvVar('FIREBASE_PROJECT_ID', 'gen-lang-client-0610030211');

  /// Get emulator configuration (development only)
  static bool get useEmulators => isDevelopment;
  
  static int get firestoreEmulatorPort => 
      int.tryParse(_getEnvVar('FIRESTORE_EMULATOR_PORT', '8080')) ?? 8080;
      
  static int get authEmulatorPort => 
      int.tryParse(_getEnvVar('AUTH_EMULATOR_PORT', '9099')) ?? 9099;
      
  static int get functionsEmulatorPort => 
      int.tryParse(_getEnvVar('FUNCTIONS_EMULATOR_PORT', '5001')) ?? 5001;
      
  static int get storageEmulatorPort => 
      int.tryParse(_getEnvVar('STORAGE_EMULATOR_PORT', '9199')) ?? 9199;

  /// Private helper to get environment variable with fallback
  static String _getEnvVar(String key, String fallback) {
    if (!_isInitialized) {
      developer.log(
        'Environment not initialized, using fallback values',
        name: 'zeeky_social.config',
        level: 900,
      );
      return fallback;
    }

    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      developer.log(
        'Environment variable $key not found, using fallback',
        name: 'zeeky_social.config',
        level: 900,
      );
      return fallback;
    }

    return value;
  }

  /// Validate that all required environment variables are present
  static void validateConfig() {
    final requiredVars = [
      'FIREBASE_PROJECT_ID',
      'FIREBASE_API_KEY',
      'FIREBASE_APP_ID',
      'FIREBASE_MESSAGING_SENDER_ID',
    ];

    final missing = <String>[];
    
    for (final variable in requiredVars) {
      if (!dotenv.env.containsKey(variable) || (dotenv.env[variable]?.isEmpty ?? true)) {
        missing.add(variable);
      }
    }

    if (missing.isNotEmpty) {
      developer.log(
        'Missing required environment variables: ${missing.join(', ')}',
        name: 'zeeky_social.config',
        level: 1000,
      );
    }
  }
}