# Zeeky Social

**Creator: Joa’Chima Ross**

Zeeky Social is a next-generation AI-powered social and messaging platform that unites communication, creativity, and community into one seamless ecosystem. It blends the best of Apple iMessage, Google Messages, and modern social networks, then reimagines them with AI at the core.

At the heart of the platform is Zeeky—an intelligent AI assistant who is more than a chatbot: he’s a partner, a creator, and a collaborator.

This is not just another app. Zeeky Social is the blueprint for the future of digital interaction.

---

## 🚀 Core Features

- **Unified Messaging Hub**
  - SMS, MMS, RCS, and encrypted chat support.
  - Rich media messaging, reactions, read receipts, and seamless syncing across devices.

- **Zeeky AI Assistant**
  - Personal assistant, content creator, and conversation partner.
  - Helps draft posts, replies, and stories.
  - Generates music, videos, and art.
  - Handles scheduling, reminders, and productivity tasks.

- **Social Media Reimagined**
  - AI-enhanced posts (auto-captions, smart hashtags, creative filters).
  - Public and private communities.
  - Dynamic interactive feed designed for connection, not noise.

- **Business + Productivity Integration**
  - Smart scheduling and task management.
  - Auto social posting with AI-generated captions.
  - Deep integration with calendar, notes, and files.

- **Entertainment + Creativity**
  - AI-driven music, story, and video generation.
  - Interactive content sharing and remix culture.
  - Community-driven creative challenges.

- **Security + Trust**
  - End-to-end encryption by default.
  - Multi-factor authentication.
  - Continuous auditing for performance, privacy, and resilience.

---

## 🛠️ Tech Stack
- **Frontend**: Flutter (cross-platform mobile + web) / React Native
- **Backend**: Firebase + Node.js microservices
- **Database**: Firestore + Realtime DB
- **AI/ML**: OpenAI API + custom models for personalization and media generation
- **Hosting & Infrastructure**: Firebase Hosting, Vercel, Cloudflare, optional Docker deployment
- **Version Control**: GitHub

---

## 📦 Installation & Setup

### Prerequisites
- Flutter SDK (>=3.0.0)
- For iOS: Xcode 12.0 or later, iOS 12.0+ deployment target
- For Android: Android Studio with Android SDK
- Firebase project with iOS and Android apps configured

### General Setup
1. Clone the repo:
   ```bash
   git clone https://github.com/joachimaross/Newzeekysocial.git
   cd Newzeekysocial
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

### iOS Setup & Firebase Configuration

#### 1. Install CocoaPods Dependencies
```bash
cd ios
pod install
cd ..
```

#### 2. Firebase Project Configuration
1. **Create Firebase Project**: 
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or select existing one
   
2. **Add iOS App to Firebase**:
   - Click "Add app" and select iOS
   - Use bundle ID: `com.example.myap`
   - Download `GoogleService-Info.plist` (optional - app uses programmatic configuration)

3. **Enable Firebase Services**:
   - **Authentication**: Enable sign-in methods (Email/Password, Google, etc.)
   - **Firestore Database**: Create database in production mode
   - **Storage**: Set up Firebase Storage with appropriate security rules
   - **App Check**: Configure App Check with iOS DeviceCheck provider
   - **Cloud Messaging**: Enable for push notifications

#### 3. Build and Run iOS
```bash
# Open iOS project in Xcode (optional)
open ios/Runner.xcworkspace

# Run on iOS simulator
flutter run -d ios

# Run on physical iPhone device (requires Apple Developer account)
flutter run -d <device_id>
```

#### 4. iOS-Specific Configuration Notes
- **Minimum iOS Version**: 12.0+
- **Bundle Identifier**: `com.example.myap` (matches Firebase configuration)
- **Permissions**: Camera and Photo Library access configured for image uploads
- **Firebase Integration**: Uses programmatic Firebase configuration via `firebase_options.dart`
- **App Check**: Configured with `IOSProvider.deviceCheck` for production security

### Android Setup
1. Configure Android signing keys and Firebase setup following standard Flutter practices
2. Run with: `flutter run -d android`

### Web Setup
1. Configure Firebase for web platform
2. Run with: `flutter run -d chrome`

### Development Workflow
```bash
# Development server
flutter run

# Hot reload during development
# Press 'r' in terminal or save files in IDE

# Build for release
flutter build ios --release
flutter build apk --release
```

### Firebase Services Used
- **Firebase Core**: App initialization and configuration
- **Firebase Auth**: User authentication and management  
- **Cloud Firestore**: Real-time database for posts and user data
- **Firebase Storage**: Image and file uploads
- **Firebase Messaging**: Push notifications
- **Firebase App Check**: Security and abuse prevention
- **Firebase AI**: Generative AI chat features (Gemini integration)

### Troubleshooting iOS Build Issues

#### Common Issues & Solutions

1. **CocoaPods Issues**:
   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   ```

2. **Xcode Build Errors**:
   - Ensure Xcode is up to date (12.0+)
   - Check iOS deployment target is set to 12.0+
   - Clean build folder: `flutter clean && flutter pub get`

3. **Firebase Configuration Issues**:
   - Verify bundle ID matches Firebase project: `com.example.myap`
   - Ensure all Firebase services are enabled in Firebase Console
   - Check `firebase_options.dart` has correct iOS configuration

4. **Device/Simulator Issues**:
   ```bash
   # List available devices
   flutter devices
   
   # Run on specific device
   flutter run -d "iPhone 14 Pro"
   ```

5. **Permission Issues**:
   - Camera/Photo permissions are configured in Info.plist
   - For production, ensure proper provisioning profiles and certificates

---

## 🌍 Vision

Zeeky Social is more than software—it’s a movement.

We’re creating a living digital ecosystem where AI isn’t just a tool, but a companion:
- A partner in communication.
- A collaborator in business and creativity.
- A connector across communities, cultures, and platforms.

The goal: build the first Fortune 500–level AI-powered social platform that redefines how humans and AI coexist, communicate, and create together.

This is the future of social.

---

## 🤝 Contributing

We welcome innovators, developers, designers, and dreamers.
1. Fork the repo.
2. Create your feature branch (`git checkout -b feature/amazing-feature`).
3. Commit changes (`git commit -m 'Add amazing feature'`).
4. Push to branch (`git push origin feature/amazing-feature`).
5. Submit a Pull Request.

---

## 📜 License

This project is licensed under the MIT License – see the `LICENSE` file for details.

---

### ⚡ Zeeky Social — Where AI Meets Humanity.
