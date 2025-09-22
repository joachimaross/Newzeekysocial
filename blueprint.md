# Zeeky Social Blueprint

## Overview

Zeeky Social is a social networking application that allows users to connect with each other, share posts, and chat in real-time. The application is built with Flutter and leverages Firebase for backend services, including authentication, Firestore database, and cloud storage.

## Design and Style

The application follows Material Design 3 guidelines, with a modern and intuitive user interface. It features a bottom navigation bar for easy access to the main screens: Feed, Chat, and Profile. The app supports both light and dark themes, which can be toggled by the user.

- **Typography**: The app uses the Lato font from Google Fonts for a clean and readable text.
- **Color Scheme**: The color scheme is based on a deep purple seed color, which is used to generate a harmonious and accessible color palette for both light and dark modes.

## Features

- **Authentication**: Users can sign up and sign in using their email and password. The authentication state is managed using Firebase Authentication.
- **Feed**: The feed screen displays a real-time stream of posts from all users. Users can create new posts, which are then added to the feed.
- **Chat**: The chat feature allows users to have one-on-one conversations. Users can start a new chat by selecting a user from the user list. The chat screen displays a list of all active conversations, with the most recent message and timestamp.
- **AI-Powered Chat**: The application includes a Zeeky Chat screen, which allows users to interact with a generative AI model. This feature can be used for a variety of purposes, such as generating creative text formats, answering questions, or providing assistance.
- **User Profiles**: Users can view and edit their profiles, including their display name and profile picture. Profile pictures are uploaded to Firebase Storage and the profile information is stored in Firestore.
- **User List**: The user list screen displays a list of all registered users, making it easy for users to find and connect with others.
- **Theme Toggle**: Users can switch between light and dark themes to suit their preferences.
