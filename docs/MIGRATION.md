# Migration Guide: Legacy to Refactored Zeeky Social

## 🔄 Overview

This guide helps migrate from the legacy monolithic codebase to the new modular, production-ready architecture.

## 📋 Migration Checklist

### Phase 1: Environment Setup ✅

- [x] **Backup existing `.env` files** (if any)
- [x] **Copy `.env.example` to `.env.dev`**
- [x] **Configure environment variables** with actual Firebase values
- [x] **Update `.gitignore`** to prevent committing secrets
- [x] **Test environment loading** with new configuration

### Phase 2: Code Migration

#### Main Entry Point
- [x] **Replace `lib/main.dart`** with `lib/main_new.dart`
- [x] **Update import statements** to use new package name (`zeeky_social`)
- [x] **Test app initialization** with new modular structure

#### Provider Migration
- [x] **Move theme logic** from inline to `ThemeProvider`
- [x] **Update provider configuration** in `AppProviders`
- [x] **Test state management** functionality

#### Service Updates
- [x] **Enhanced error handling** in all services
- [x] **Added logging** with `dart:developer`
- [x] **Firebase service initialization** refactored

### Phase 3: Firebase Configuration

#### Environment Variables
```bash
# Replace hardcoded values in firebase_options.dart with environment-based config
# Old: hardcoded API keys
# New: EnvironmentConfig.firebaseOptions
```

#### Service Integration
- [x] **Analytics integration** for production
- [x] **Crashlytics setup** for error reporting  
- [x] **Performance monitoring** enabled
- [x] **App Check configuration** for security

### Phase 4: Testing & Quality

- [x] **Fix broken widget tests**
- [x] **Add comprehensive unit tests**
- [x] **Update analysis options** with strict linting
- [x] **Set up GitHub Actions CI/CD**

## 🔧 Step-by-Step Migration

### Step 1: Update Main Entry Point

Replace your current `lib/main.dart` with the new modular version:

```bash
# Backup current main.dart
mv lib/main.dart lib/main_legacy.dart

# Use new main entry point
mv lib/main_new.dart lib/main.dart
```

### Step 2: Update Package References

Update all import statements to use the new package name:

```dart
// Old imports
import 'package:myapp/...';

// New imports  
import 'package:zeeky_social/...';
```

### Step 3: Configure Environment

1. **Create environment file:**
   ```bash
   cp .env.example .env.dev
   ```

2. **Update with your Firebase values:**
   ```env
   FIREBASE_PROJECT_ID=your_actual_project_id
   FIREBASE_API_KEY=your_actual_api_key
   # ... other values
   ```

### Step 4: Update Dependencies

Run the following to update dependencies:
```bash
flutter pub get
```

### Step 5: Test Migration

1. **Run the app:**
   ```bash
   flutter run -d web --dart-define=FLUTTER_ENV=development
   ```

2. **Run tests:**
   ```bash
   flutter test
   ```

3. **Check linting:**
   ```bash
   flutter analyze
   ```

## 🚨 Breaking Changes

### Import Changes
```dart
// OLD ❌
import 'package:myapp/screens/auth_gate.dart';
import 'package:myapp/services/auth_service.dart';

// NEW ✅
import 'package:zeeky_social/screens/auth_gate.dart';
import 'package:zeeky_social/services/auth_service.dart';
```

### Firebase Initialization
```dart
// OLD ❌ - Hardcoded configuration
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

// NEW ✅ - Environment-based configuration
await EnvironmentConfig.initialize();
await FirebaseInitializationService.initialize();
```

### Theme Management
```dart
// OLD ❌ - Inline theme provider
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  // Simple implementation
}

// NEW ✅ - Enhanced theme provider with system theme support
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  // Comprehensive theme management with logging
}
```

### Error Handling
```dart
// OLD ❌ - Basic error handling
try {
  // Firebase operation
} catch (e) {
  rethrow;
}

// NEW ✅ - Comprehensive error handling with logging
try {
  // Firebase operation
} on FirebaseAuthException catch (e) {
  developer.log('Auth error: ${e.code}', name: 'app.auth', level: 1000);
  rethrow;
} catch (e, stackTrace) {
  developer.log('Unexpected error', name: 'app.auth', error: e, stackTrace: stackTrace);
  rethrow;
}
```

## 🔍 Validation Steps

### 1. Environment Validation
```bash
# Check environment loading
flutter run -d web --dart-define=FLUTTER_ENV=development
# Should show logs: "Environment initialized: development"
```

### 2. Firebase Service Validation
```bash
# Check Firebase initialization logs in console
# Should see: "All Firebase services initialized successfully"
```

### 3. Theme System Validation
```bash
# Test theme switching in app
# Should see logs: "Theme toggled to: dark/light"
```

### 4. Error Handling Validation
```bash
# Check error logs are structured and helpful
# Should see developer console logs with proper categorization
```

## 🔄 Rollback Plan

If migration issues occur, follow this rollback procedure:

### Immediate Rollback
1. **Restore original main.dart:**
   ```bash
   mv lib/main.dart lib/main_new.dart
   mv lib/main_legacy.dart lib/main.dart
   ```

2. **Revert package name:**
   ```bash
   # In pubspec.yaml, change back to:
   name: myapp
   ```

3. **Restore old imports:**
   ```bash
   # Run find/replace to change package imports back
   find lib/ -name "*.dart" -exec sed -i 's/package:zeeky_social/package:myapp/g' {} \;
   ```

### Clean Rollback
1. **Checkout previous commit:**
   ```bash
   git stash  # Save any work
   git reset --hard HEAD~1  # Go back one commit
   ```

2. **Verify functionality:**
   ```bash
   flutter pub get
   flutter run
   ```

## ⚠️ Known Issues & Solutions

### Issue: Environment not loading
**Symptoms:** App crashes on startup with "Failed to load environment configuration"
**Solution:** 
1. Ensure `.env.dev` file exists
2. Check file format (no quotes around values unless needed)
3. Verify flutter_dotenv is in pubspec.yaml

### Issue: Import errors
**Symptoms:** "Target URI doesn't exist" errors
**Solution:**
1. Update all imports to use `zeeky_social` package name
2. Run `flutter clean && flutter pub get`
3. Check IDE indexing is complete

### Issue: Firebase initialization fails
**Symptoms:** "Failed to initialize Firebase services" error
**Solution:**
1. Verify Firebase project configuration
2. Check API keys in environment file
3. Ensure Firebase services are enabled in console

## 📞 Support

For migration issues:

1. **Check the logs** - New system provides detailed logging
2. **Review documentation** - See `docs/SETUP.md` for detailed setup
3. **Test incrementally** - Migrate one component at a time
4. **Use rollback plan** - If issues persist, rollback and investigate

## 🎯 Post-Migration Benefits

After successful migration, you'll have:

- ✅ **Secure environment management** - No more hardcoded secrets
- ✅ **Comprehensive error handling** - Better debugging and monitoring  
- ✅ **Modular architecture** - Easier maintenance and testing
- ✅ **Production-ready Firebase** - Analytics, Crashlytics, Performance
- ✅ **Enhanced theming** - Material Design 3 with system theme support
- ✅ **CI/CD pipeline** - Automated testing and deployment
- ✅ **Comprehensive documentation** - Setup, security, and development guides

The migration improves code quality, security, maintainability, and provides a solid foundation for future development.