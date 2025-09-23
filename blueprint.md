# Project Blueprint

## Overview

This document outlines the architecture and implementation plan for a Flutter application with Firebase integration. The application will include core features like user authentication, a social feed, real-time chat, and a new generative AI-powered chat feature.

## Features

### Implemented Features

*   **User Authentication:** Users can sign up, sign in, and sign out using Firebase Authentication.
*   **Social Feed:** Users can create and view posts in a real-time feed.
*   **Real-time Chat:** Users can chat with each other in real-time.
*   **Theming:** The application supports both light and dark themes.
*   **Notifications:** Users receive push notifications for new messages.
*   **App Check:** The application uses Firebase App Check to protect against abuse.

### Current Plan: Re-implement Generative AI Chat

This plan outlines the steps to re-implement the generative AI chat feature using the `firebase_ai` package. The previous implementation was removed to address dependency and build issues. This new implementation will be done in a careful, step-by-step manner to ensure stability.

**Steps:**

1.  **Add `firebase_ai` Dependency:** Add the `firebase_ai` package back to the `pubspec.yaml` file.
2.  **Create `ai_service.dart`:** Create a new service file to encapsulate the logic for interacting with the Gemini API.
3.  **Create `ai_chat_screen.dart`:** Create a new screen for the AI chat feature.
4.  **Integrate `AIService`:** Provide the `AIService` to the application using `Provider`.
5.  **Add Navigation:** Add a button to the `MainScreen` to navigate to the `AIChatScreen`.
6.  **Verify Implementation:** Run `flutter analyze` and `flutter run` to verify that the new implementation is free of errors.
