import 'package:flutter_test/flutter_test.dart';
import 'package:zeeky_social/config/environment_config.dart';

void main() {
  group('Environment Configuration Tests', () {
    test('Environment validation works correctly', () {
      // Test configuration validation
      expect(EnvironmentConfig.validateConfig, returnsNormally);
    });

    test('Default values are correct', () {
      // Test default environment values
      expect(EnvironmentConfig.currentEnvironment, isNotEmpty);
    });

    test('Project ID getter works', () {
      // Test project ID getter
      final projectId = EnvironmentConfig.projectId;
      expect(projectId, isA<String>());
      expect(projectId, isNotEmpty);
    });

    test('Environment flags work correctly', () {
      // Test development flag
      expect(EnvironmentConfig.isDevelopment, isA<bool>());
      expect(EnvironmentConfig.isProduction, isA<bool>());
    });

    test('Emulator configuration is accessible', () {
      // Test emulator ports
      expect(EnvironmentConfig.firestoreEmulatorPort, isA<int>());
      expect(EnvironmentConfig.authEmulatorPort, isA<int>());
      expect(EnvironmentConfig.functionsEmulatorPort, isA<int>());
      expect(EnvironmentConfig.storageEmulatorPort, isA<int>());
    });

    test('reCAPTCHA site key is accessible', () {
      // Test reCAPTCHA configuration
      final siteKey = EnvironmentConfig.recaptchaV3SiteKey;
      expect(siteKey, isA<String>());
      expect(siteKey, isNotEmpty);
    });

    test('Firebase options can be generated', () {
      // Test Firebase options generation
      expect(() => EnvironmentConfig.firebaseOptions, returnsNormally);
      final options = EnvironmentConfig.firebaseOptions;
      expect(options.projectId, isNotEmpty);
      expect(options.apiKey, isNotEmpty);
      expect(options.appId, isNotEmpty);
    });
  });
}