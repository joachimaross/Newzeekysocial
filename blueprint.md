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
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── profile_screen.dart
│   ├── signup_screen.dart
│   └── user_list_screen.dart
├── services
│   ├── ai_service.dart
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── storage_service.dart
├── main.dart
└── firebase_options.dart
```

## Current Task: Refactor App Name

**Goal:** Rename the app from "Zeeky Social" to "My Awesome App".

**Steps Taken:**

1.  **Updated `pubspec.yaml`:** Changed the project name from `zeeky_social` to `myapp`.
2.  **Renamed Files:** Renamed `lib/screens/zeeky_chat_screen.dart` to `lib/screens/ai_chat_screen.dart`.
3.  **Updated Import Paths:** Updated all import paths to use `myapp` instead of `zeeky_social`.
4.  **Updated Class Names:** Renamed `ZeekyChatScreen` to `AIChatScreen` and updated all references.
5.  **Updated Content:** Replaced all occurrences of "Zeeky Social" with "My Awesome App" in user-facing strings and comments.
6.  **Updated `AIService`:** Updated the system prompt in `AIService` to reflect the new app name.
