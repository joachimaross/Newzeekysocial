import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:zeeky_social/config/environment_config.dart';
import 'dart:developer' as developer;

/// Firebase initialization service that handles secure setup of all Firebase services
class FirebaseInitializationService {
  static bool _isInitialized = false;
  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;
  static FirebasePerformance? _performance;

  static FirebaseAnalytics? get analytics => _analytics;
  static FirebaseCrashlytics? get crashlytics => _crashlytics;
  static FirebasePerformance? get performance => _performance;

  /// Initialize all Firebase services
  static Future<void> initialize() async {
    if (_isInitialized) {
      developer.log(
        'Firebase already initialized',
        name: 'zeeky_social.firebase',
        level: 800,
      );
      return;
    }

    try {
      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: EnvironmentConfig.firebaseOptions,
      );

      developer.log(
        'Firebase Core initialized for ${EnvironmentConfig.currentEnvironment}',
        name: 'zeeky_social.firebase',
        level: 800,
      );

      // Configure Firebase emulators in development
      if (EnvironmentConfig.useEmulators) {
        await _configureEmulators();
      }

      // Initialize App Check for security
      await _initializeAppCheck();

      // Initialize Analytics (production only)
      if (EnvironmentConfig.isProduction) {
        await _initializeAnalytics();
      }

      // Initialize Crashlytics
      await _initializeCrashlytics();

      // Initialize Performance Monitoring
      await _initializePerformanceMonitoring();

      _isInitialized = true;

      developer.log(
        'All Firebase services initialized successfully',
        name: 'zeeky_social.firebase',
        level: 800,
      );

    } catch (e, stackTrace) {
      developer.log(
        'Failed to initialize Firebase services',
        name: 'zeeky_social.firebase',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      
      // Re-throw to prevent app from starting with broken Firebase
      rethrow;
    }
  }

  /// Configure Firebase emulators for development
  static Future<void> _configureEmulators() async {
    try {
      // Use Firebase emulators in development
      const host = 'localhost';

      // Configure Firestore emulator
      FirebaseFirestore.instance.useFirestoreEmulator(
        host, 
        EnvironmentConfig.firestoreEmulatorPort,
      );

      // Configure Auth emulator
      await FirebaseAuth.instance.useAuthEmulator(
        host, 
        EnvironmentConfig.authEmulatorPort,
      );

      // Configure Storage emulator
      await FirebaseStorage.instance.useStorageEmulator(
        host, 
        EnvironmentConfig.storageEmulatorPort,
      );

      developer.log(
        'Firebase emulators configured',
        name: 'zeeky_social.firebase',
        level: 800,
      );

    } catch (e) {
      developer.log(
        'Failed to configure emulators (this is expected if emulators are not running)',
        name: 'zeeky_social.firebase',
        level: 900,
        error: e,
      );
    }
  }

  /// Initialize Firebase App Check
  static Future<void> _initializeAppCheck() async {
    try {
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider(EnvironmentConfig.recaptchaV3SiteKey),
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
      );

      developer.log(
        'Firebase App Check initialized',
        name: 'zeeky_social.firebase',
        level: 800,
      );

    } catch (e) {
      developer.log(
        'Failed to initialize App Check',
        name: 'zeeky_social.firebase',
        level: 900,
        error: e,
      );
    }
  }

  /// Initialize Firebase Analytics
  static Future<void> _initializeAnalytics() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      
      // Configure analytics settings
      await _analytics!.setAnalyticsCollectionEnabled(true);
      
      // Log app initialization event
      await _analytics!.logEvent(
        name: 'app_initialized',
        parameters: {
          'environment': EnvironmentConfig.currentEnvironment,
          'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
        },
      );

      developer.log(
        'Firebase Analytics initialized',
        name: 'zeeky_social.firebase',
        level: 800,
      );

    } catch (e) {
      developer.log(
        'Failed to initialize Analytics',
        name: 'zeeky_social.firebase',
        level: 900,
        error: e,
      );
    }
  }

  /// Initialize Firebase Crashlytics
  static Future<void> _initializeCrashlytics() async {
    try {
      _crashlytics = FirebaseCrashlytics.instance;
      
      // Enable crashlytics collection only in production
      await _crashlytics!.setCrashlyticsCollectionEnabled(
        EnvironmentConfig.isProduction,
      );

      // Set up automatic crash reporting for Flutter errors
      FlutterError.onError = _crashlytics!.recordFlutterFatalError;

      // Handle async errors
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics!.recordError(error, stack, fatal: true);
        return true;
      };

      developer.log(
        'Firebase Crashlytics initialized',
        name: 'zeeky_social.firebase',
        level: 800,
      );

    } catch (e) {
      developer.log(
        'Failed to initialize Crashlytics',
        name: 'zeeky_social.firebase',
        level: 900,
        error: e,
      );
    }
  }

  /// Initialize Firebase Performance Monitoring
  static Future<void> _initializePerformanceMonitoring() async {
    try {
      _performance = FirebasePerformance.instance;
      
      // Enable performance monitoring
      await _performance!.setPerformanceCollectionEnabled(
        EnvironmentConfig.isProduction,
      );

      developer.log(
        'Firebase Performance Monitoring initialized',
        name: 'zeeky_social.firebase',
        level: 800,
      );

    } catch (e) {
      developer.log(
        'Failed to initialize Performance Monitoring',
        name: 'zeeky_social.firebase',
        level: 900,
        error: e,
      );
    }
  }

  /// Log a custom event to Analytics (if available)
  static Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    if (_analytics != null) {
      await _analytics!.logEvent(name: name, parameters: parameters);
    }
  }

  /// Record a non-fatal error to Crashlytics (if available)
  static void recordError(dynamic error, StackTrace? stackTrace, {bool fatal = false}) {
    if (_crashlytics != null) {
      _crashlytics!.recordError(error, stackTrace, fatal: fatal);
    }
    
    // Also log to developer console
    developer.log(
      'Recorded error: $error',
      name: 'zeeky_social.firebase',
      level: fatal ? 1000 : 900,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Create a custom performance trace
  static Trace? createTrace(String name) {
    return _performance?.newTrace(name);
  }

  /// Check if Firebase is properly initialized
  static bool get isInitialized => _isInitialized;
}