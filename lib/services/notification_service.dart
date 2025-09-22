
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myapp/services/firestore_service.dart';
import 'dart:developer' as developer;

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp(); // Not needed if already initialized in main

  developer.log("Handling a background message: \${message.messageId}", name: 'myapp.notification');
  // You can process the message here (e.g., show a local notification)
  // For simplicity, we're letting FCM handle the display of the notification.
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirestoreService _firestoreService;

  NotificationService(this._firestoreService);

  Future<void> initNotifications() async {
    // Request permission from the user
    await _requestPermission();

    // Get the FCM token
    final String? token = await _getFCMToken();
    if (token != null) {
      // Save the token to Firestore
      // Note: This should be called when the user is logged in
      developer.log("FCM Token: \$token", name: 'myapp.notification');
    }

    // Initialize local notifications
    await _initLocalNotifications();

    // Handle foreground messages
    _handleForegroundMessages();

    // Set the background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    developer.log('User granted permission: \${settings.authorizationStatus}', name: 'myapp.notification');
  }

  Future<String?> _getFCMToken() async {
    try {
      final String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      developer.log('Failed to get FCM token: \$e', name: 'myapp.notification', error: e);
      return null;
    }
  }

  Future<void> _initLocalNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS initialization settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create a high-importance Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _handleForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('Got a message whilst in the foreground!', name: 'myapp.notification');
      developer.log('Message data: \${message.data}', name: 'myapp.notification');

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users.
      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel', // channel id
              'High Importance Notifications', // channel name
              channelDescription: 'This channel is used for important notifications.',
              icon: android.smallIcon,
              // other properties...
            ),
          ),
        );
      }
    });
  }

  // Call this method when a user logs in to save their token
  Future<void> saveTokenForCurrentUser(String userId) async {
    final String? token = await _getFCMToken();
    if (token != null) {
      developer.log('Saving FCM token for user: \$userId', name: 'myapp.notification');
      // Update the user's profile with the new token
      await _firestoreService.updateUserProfile(userId, {'fcmToken': token});
    }
  }

   // Call this when a user logs out
  Future<void> deleteTokenForCurrentUser(String userId) async {
     developer.log('Deleting FCM token for user: \$userId', name: 'myapp.notification');
     await _firestoreService.updateUserProfile(userId, {'fcmToken': FieldValue.delete()});
  }
}
