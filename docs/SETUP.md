# Zeeky Social - Setup & Development Guide

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.24.x or later
- Dart SDK 3.0.0 or later
- Node.js 20.x or later (for Firebase CLI)
- Firebase project with the following services enabled:
  - Authentication
  - Firestore
  - Storage
  - Functions
  - Hosting
  - Analytics
  - Crashlytics
  - Performance Monitoring
  - App Check

### Environment Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/joachimaross/Newzeekysocial.git
   cd Newzeekysocial
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables:**
   ```bash
   # Copy the example environment file
   cp .env.example .env.dev
   
   # Edit .env.dev with your actual Firebase configuration
   nano .env.dev
   ```

4. **Configure Firebase (if not already done):**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase in the project (if needed)
   firebase init
   ```

### Running the App

#### Development Mode
```bash
# Web (with hot reload)
flutter run -d web --dart-define=FLUTTER_ENV=development

# Android
flutter run -d android --dart-define=FLUTTER_ENV=development

# iOS
flutter run -d ios --dart-define=FLUTTER_ENV=development
```

#### Production Mode
```bash
# Web build
flutter build web --release --dart-define=FLUTTER_ENV=production

# Android build
flutter build apk --release --dart-define=FLUTTER_ENV=production
flutter build appbundle --release --dart-define=FLUTTER_ENV=production

# iOS build
flutter build ios --release --dart-define=FLUTTER_ENV=production
```

## 🔧 Development Workflow

### Code Quality Checks

```bash
# Run linting
flutter analyze

# Format code
flutter format .

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Firebase Emulator Setup

For local development with Firebase emulators:

1. **Install and configure emulators:**
   ```bash
   firebase setup:emulators:firestore
   firebase setup:emulators:auth
   firebase setup:emulators:functions
   firebase setup:emulators:storage
   ```

2. **Start emulators:**
   ```bash
   firebase emulators:start
   ```

3. **Run app with emulators:**
   ```bash
   flutter run -d web --dart-define=FLUTTER_ENV=development
   ```

## 📁 Project Structure

```
lib/
├── app/                    # App configuration & theming
│   ├── app.dart           # Main app widget
│   └── theme.dart         # Material Design 3 theming
├── config/                # Configuration management
│   └── environment_config.dart
├── models/                # Data models
├── providers/             # State management (Provider)
│   ├── app_providers.dart # Centralized provider setup
│   └── theme_provider.dart
├── screens/               # UI screens
├── services/              # Business logic & Firebase services
│   ├── auth_service.dart
│   ├── ai_service.dart
│   ├── firestore_service.dart
│   ├── firebase_initialization_service.dart
│   ├── notification_service.dart
│   └── storage_service.dart
├── main.dart             # Legacy main (deprecated)
└── main_new.dart         # New modular main entry point

test/
├── config/               # Configuration tests
├── providers/            # Provider tests
├── services/             # Service tests
└── widget_test.dart      # Widget tests
```

## 🔐 Environment Configuration

### Required Environment Variables

Create `.env.dev` for development and `.env.prod` for production:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your_project.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_MEASUREMENT_ID=your_measurement_id

# Platform-specific configurations
FIREBASE_ANDROID_API_KEY=your_android_api_key
FIREBASE_ANDROID_APP_ID=your_android_app_id
FIREBASE_IOS_API_KEY=your_ios_api_key
FIREBASE_IOS_APP_ID=your_ios_app_id

# App Check
RECAPTCHA_V3_SITE_KEY=your_recaptcha_site_key

# Environment
FLUTTER_ENV=development
```

### Security Best Practices

1. **Never commit `.env.*` files to version control**
2. **Use Firebase App Check for production**
3. **Configure Firestore security rules**
4. **Enable Firebase Authentication**
5. **Use HTTPS only in production**

## 🧪 Testing Strategy

### Unit Tests
```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/providers/theme_provider_test.dart

# Run tests with coverage
flutter test --coverage
```

### Integration Tests
```bash
# Run integration tests (when available)
flutter test integration_test/
```

### Widget Tests
```bash
# Run widget tests
flutter test test/widget_test.dart
```

## 🚀 Deployment

### Firebase Hosting

1. **Build the web app:**
   ```bash
   flutter build web --release --dart-define=FLUTTER_ENV=production
   ```

2. **Deploy to Firebase Hosting:**
   ```bash
   firebase deploy --only hosting
   ```

### Android Deployment

1. **Build APK:**
   ```bash
   flutter build apk --release --dart-define=FLUTTER_ENV=production
   ```

2. **Build App Bundle (recommended for Play Store):**
   ```bash
   flutter build appbundle --release --dart-define=FLUTTER_ENV=production
   ```

### iOS Deployment

1. **Build iOS app:**
   ```bash
   flutter build ios --release --dart-define=FLUTTER_ENV=production
   ```

2. **Open in Xcode for App Store deployment:**
   ```bash
   open ios/Runner.xcworkspace
   ```

## 📊 Monitoring & Analytics

### Firebase Analytics
- Automatically enabled in production
- Custom events logged through `FirebaseInitializationService`

### Firebase Crashlytics
- Automatic crash reporting in production
- Manual error reporting available

### Firebase Performance
- Automatic performance monitoring
- Custom traces available through `FirebaseInitializationService`

## 🔧 Troubleshooting

### Common Issues

1. **Environment variables not loading:**
   - Ensure `.env.dev` exists
   - Check file format and syntax
   - Verify `flutter_dotenv` dependency

2. **Firebase initialization fails:**
   - Check Firebase project configuration
   - Verify API keys and project ID
   - Ensure Firebase services are enabled

3. **Build failures:**
   - Run `flutter clean`
   - Delete `pubspec.lock` and run `flutter pub get`
   - Check Flutter version compatibility

4. **Emulator connection issues:**
   - Verify emulators are running
   - Check port conflicts
   - Ensure Firebase CLI is up to date

### Getting Help

- Check the [Issues](https://github.com/joachimaross/Newzeekysocial/issues) for known problems
- Review Firebase documentation
- Check Flutter documentation for framework issues

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Follow the development workflow
4. Run tests and quality checks
5. Submit a pull request

All contributions must pass CI/CD checks and follow the established code style.