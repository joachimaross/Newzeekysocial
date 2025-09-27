import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zeeky_social/models/notification_model.dart';
import 'dart:developer' as developer;

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log("Handling a background message: ${message.messageId}", name: 'myapp.notification');
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  NotificationService();

  Future<void> initNotifications() async {
    // Request permission from the user
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle initial message if app was opened from a terminated state
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> _requestPermission() async {
    final NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    developer.log('User granted permission: ${settings.authorizationStatus}', name: 'myapp.notification');
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    developer.log('Received foreground message: ${message.messageId}', name: 'myapp.notification');
    
    // Show local notification when app is in foreground
    _showLocalNotification(message);
  }

  void _handleNotificationTap(RemoteMessage message) {
    developer.log('Notification tapped: ${message.messageId}', name: 'myapp.notification');
    // TODO: Handle navigation based on message data
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    developer.log('Local notification tapped: ${response.payload}', name: 'myapp.notification');
    // TODO: Handle navigation based on payload
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = 
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  // Enhanced notification methods
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> saveTokenForCurrentUser(String userId) async {
    final token = await getToken();
    if (token != null) {
      try {
        await _db.collection('user_tokens').doc(userId).set({
          'token': token,
          'updatedAt': FieldValue.serverTimestamp(),
          'platform': 'flutter',
        });
        developer.log('Token saved for user: $userId', name: 'myapp.notification');
      } catch (e) {
        developer.log('Failed to save token: $e', name: 'myapp.notification');
      }
    }
  }

  Future<void> deleteTokenForCurrentUser(String userId) async {
    try {
      await _db.collection('user_tokens').doc(userId).delete();
      developer.log('Token deleted for user: $userId', name: 'myapp.notification');
    } catch (e) {
      developer.log('Failed to delete token: $e', name: 'myapp.notification');
    }
  }

  // Send notification to user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic> data = const {},
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    try {
      final notification = AppNotification(
        id: '',
        userId: userId,
        title: title,
        body: body,
        type: NotificationType.values.firstWhere(
          (e) => e.toString().split('.').last == type,
          orElse: () => NotificationType.system,
        ),
        priority: priority,
        data: data,
        createdAt: DateTime.now(),
      );

      await _db.collection('notifications').add(notification.toMap());

      // Also send push notification
      await _sendPushNotification(userId, title, body, data);
    } catch (e) {
      developer.log('Failed to send notification: $e', name: 'myapp.notification');
    }
  }

  Future<void> _sendPushNotification(
    String userId,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    try {
      // Get user's token
      final tokenDoc = await _db.collection('user_tokens').doc(userId).get();
      if (!tokenDoc.exists) return;

      final token = tokenDoc.data()?['token'] as String?;
      if (token == null) return;

      // In a real implementation, you would use Firebase Admin SDK or Cloud Functions
      // to send the push notification. For now, this is a placeholder.
      developer.log('Would send push notification to token: $token', name: 'myapp.notification');
    } catch (e) {
      developer.log('Failed to send push notification: $e', name: 'myapp.notification');
    }
  }

  // Get user's notifications
  Stream<List<AppNotification>> getUserNotifications({int limit = 50}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Failed to mark notification as read: $e', name: 'myapp.notification');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final unreadQuery = await _db
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _db.batch();
      for (final doc in unreadQuery.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      developer.log('Failed to mark all notifications as read: $e', name: 'myapp.notification');
    }
  }

  // Get unread notification count
  Stream<int> getUnreadCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _db
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      developer.log('Subscribed to topic: $topic', name: 'myapp.notification');
    } catch (e) {
      developer.log('Failed to subscribe to topic: $e', name: 'myapp.notification');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      developer.log('Unsubscribed from topic: $topic', name: 'myapp.notification');
    } catch (e) {
      developer.log('Failed to unsubscribe from topic: $e', name: 'myapp.notification');
    }
  }

  // Clean up old notifications
  Future<void> cleanupOldNotifications({int daysToKeep = 30}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      final oldQuery = await _db
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _db.batch();
      for (final doc in oldQuery.docs) {
        batch.delete(doc.reference);
      }

      if (oldQuery.docs.isNotEmpty) {
        await batch.commit();
        developer.log('Cleaned up ${oldQuery.docs.length} old notifications', name: 'myapp.notification');
      }
    } catch (e) {
      developer.log('Failed to cleanup old notifications: $e', name: 'myapp.notification');
    }
  }
}

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
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    // developer.log('User granted permission: \${settings.authorizationStatus}', name: 'myapp.notification');
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
