# Blueprint

## Overview

This document outlines the structure and features of the "My Awesome App" Flutter application. This app is a social media platform with a built-in AI assistant.

## Features

- **Authentication:** Users can sign up and sign in using their email and password.
- **Feed:** A chronological feed of posts from all users.
- **Posts:** Users can create new posts with text content.
- **Chat:** Users can chat with each other in real-time.
- **AI Assistant:** A friendly AI assistant to answer user questions and provide help.
- **Profile:** A profile screen where users can view their information.
- **Theming:** The app supports both light and dark themes.
- **Push Notifications:** The app can receive push notifications.

## Project Structure

```
lib
├── models
│   ├── chat_room_model.dart
│   ├── post_model.dart
│   └── user_model.dart
├── screens
│   ├── ai_chat_screen.dart
│   ├── auth_gate.dart
│   ├── chat_conversation_screen.dart
│   ├── chat_screen.dart
│   ├── feed_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── profile_screen.dart
│   ├── signup_screen.dart
│   └── user_list_screen.dart
├── services
│   ├── ai_service.dart
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── notification_service.dart
│   └── storage_service.dart
├── main.dart
└── firebase_options.dart
```

## Improvements

### Enhanced Security with Firebase App Check
- **Description:** Integrated Firebase App Check to protect the app's backend resources from abuse, such as billing fraud or phishing. This is a crucial security feature for any production application.
- **Implementation:**
  - Added the `firebase_app_check` dependency to `pubspec.yaml`.
  - Initialized App Check in `lib/main.dart` using the `PlayIntegrity` provider for Android and `ReCaptchaV3Provider` for web.

### Improved Code Organization
- **Description:** Refactored the main UI components into separate files to improve code readability, maintainability, and scalability. This follows the principle of separation of concerns.
- **Implementation:**
  - Moved the `FeedScreen` widget into its own file at `lib/screens/feed_screen.dart`.
  - Created a `PostListItem` widget within `feed_screen.dart` to encapsulate the UI for a single post.
  - Moved the `ChatScreen` widget into its own file at `lib/screens/chat_screen.dart`.
  - Created a `ChatListItem` widget within `chat_screen.dart` to encapsulate the UI for a single chat room entry.
  - Updated `lib/main.dart` to import the new screen files.

## Known Issues

### Persistent Build Error: `FirebaseVertexAI` Not Defined
- **Description:** The project consistently fails to build with an error indicating that `FirebaseVertexAI` is not defined in `AIService`. This prevents the application from running.
- **Troubleshooting Steps Taken:**
  1.  **`flutter clean` and `flutter pub get`:** Performed a clean build and fetched dependencies multiple times.
  2.  **Reinstalled Dependencies:** Removed and re-added the `firebase_ai` package to `pubspec.yaml`.
  3.  **Code Verification:** Confirmed that the `firebase_ai` package is correctly imported and used in `lib/services/ai_service.dart`.
  4.  **Environment Check:** The persistence of the error suggests a potential issue within the development environment or a deeper dependency conflict that is not immediately apparent.
- **Status:** The issue is currently unresolved and is blocking further development and testing. The next step is to investigate the build environment and explore more advanced dependency debugging techniques.
