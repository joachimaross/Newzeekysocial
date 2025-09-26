# Firebase iOS Setup Guide for Zeeky Social

This guide walks you through setting up Firebase for iOS in the Zeeky Social project.

## Prerequisites

- macOS with Xcode 12.0 or later installed
- Flutter SDK installed and configured
- Apple Developer account (for physical device testing)
- Firebase project with iOS app configured

## Step-by-Step Firebase iOS Configuration

### 1. Firebase Console Setup

1. **Create/Access Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create new project or select existing project: `gen-lang-client-0610030211`

2. **Add iOS App**:
   - Click "Add app" → iOS
   - **Bundle ID**: `com.example.myap` (must match exactly)
   - **App Nickname**: "Zeeky Social iOS"
   - **App Store ID**: Leave blank for now
   
3. **Download Configuration** (Optional):
   - Download `GoogleService-Info.plist` 
   - Note: This project uses programmatic configuration via `firebase_options.dart`, so this file is optional

### 2. Enable Firebase Services

#### Authentication
- Go to Authentication → Sign-in method
- Enable desired providers:
  - Email/Password ✅
  - Google (optional)
  - Apple (recommended for iOS)

#### Firestore Database
- Go to Firestore Database → Create database
- Start in production mode
- Choose appropriate region
- Configure security rules as needed

#### Storage
- Go to Storage → Get started
- Start in production mode
- Configure security rules for image uploads

#### App Check
- Go to App Check → Apps
- Select iOS app
- **Provider**: Apple DeviceCheck API
- Click "Save"

#### Cloud Messaging (FCM)
- Go to Cloud Messaging
- No additional setup required initially
- Configure APNs certificates for production

### 3. Local Development Setup

#### Install Dependencies
```bash
cd ios
pod install
```

#### Verify Configuration
```bash
# Run validation script
./ios_validation.sh
```

### 4. Build and Test

#### Simulator Testing
```bash
flutter run -d ios
```

#### Physical Device Testing
1. Connect iPhone via USB
2. Trust the development certificate in iOS Settings
3. Run:
```bash
flutter run -d <device_name>
```

### 5. Production Considerations

#### App Store Distribution
1. **Update Bundle ID**: Change from `com.example.myap` to your production bundle ID
2. **Update Firebase Project**: Add production app with new bundle ID
3. **Provisioning Profiles**: Configure proper distribution profiles
4. **APNs Certificates**: Upload production APNs certificates to Firebase

#### Security
- **App Check**: Uses DeviceCheck API for production security
- **Security Rules**: Review and update Firestore/Storage rules
- **API Keys**: Ensure API keys are properly restricted in Google Cloud Console

### 6. Troubleshooting

#### Common Issues

**CocoaPods Issues**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

**Xcode Build Issues**:
- Clean Build Folder (Product → Clean Build Folder)
- Check iOS Deployment Target is 12.0+
- Verify Firebase dependencies are properly linked

**Firebase Initialization Issues**:
- Check bundle ID matches Firebase configuration exactly
- Verify `firebase_options.dart` has correct iOS configuration
- Ensure App Check is properly configured

#### Debug Logging
Add to `AppDelegate.swift` for debugging:
```swift
override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    // Enable Firebase debug logging
    #if DEBUG
    FirebaseConfiguration.shared.setLoggerLevel(.debug)
    #endif
    
    FirebaseApp.configure()
    // ... rest of method
}
```

### 7. Firebase Services Integration

The app integrates these Firebase services:

- **Core**: App initialization and configuration
- **Auth**: User authentication and session management
- **Firestore**: Real-time database for social posts and user data
- **Storage**: Image and file uploads
- **Messaging**: Push notifications for social interactions
- **App Check**: Security and abuse prevention
- **AI**: Gemini integration for AI chat features

### 8. Support

For additional help:
- [Flutter Firebase Documentation](https://firebase.flutter.dev/)
- [Firebase iOS SDK Documentation](https://firebase.google.com/docs/ios/setup)
- Check `ios_validation.sh` for configuration verification