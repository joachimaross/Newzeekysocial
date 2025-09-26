import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:zeeky_social/providers/theme_provider.dart';
import 'package:zeeky_social/services/auth_service.dart';
import 'package:zeeky_social/services/firestore_service.dart';
import 'package:zeeky_social/services/ai_service.dart';
import 'package:zeeky_social/services/storage_service.dart';
import 'package:zeeky_social/services/notification_service.dart';

/// Centralized app providers configuration
/// This module provides all necessary providers for the app
class AppProviders {
  static List<SingleChildWidget> get providers => [
    // Theme provider
    ChangeNotifierProvider<ThemeProvider>(
      create: (context) => ThemeProvider(),
    ),

    // Service providers
    Provider<AuthService>(
      create: (_) => AuthService(),
    ),

    Provider<FirestoreService>(
      create: (_) => FirestoreService(),
    ),

    Provider<AIService>(
      create: (_) => AIService(),
    ),

    Provider<StorageService>(
      create: (_) => StorageService(),
    ),

    // Notification service depends on FirestoreService
    ProxyProvider<FirestoreService, NotificationService>(
      update: (context, firestoreService, previous) => 
          NotificationService(firestoreService),
    ),
  ];
}