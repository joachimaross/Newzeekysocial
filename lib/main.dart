import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:myapp/screens/auth_gate.dart';
import 'package:myapp/screens/ai_chat_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/feed_screen.dart';
import 'package:myapp/screens/chat_screen.dart';
import 'package:myapp/screens/stories_screen.dart';
import 'package:myapp/screens/events_screen.dart';
import 'package:myapp/screens/search_screen.dart';
import 'package:myapp/screens/communities_screen.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/services/storage_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/presence_service.dart';
import 'package:myapp/services/media_service.dart';
import 'package:myapp/services/search_service.dart';
import 'package:myapp/services/story_service.dart';
import 'package:myapp/services/event_service.dart';
import 'package:myapp/services/moderation_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    providerWeb: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.playIntegrity,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => StorageService()),
        Provider(create: (_) => NotificationService()),
        Provider(create: (_) => AIService()),
        Provider(create: (_) => PresenceService()),
        Provider(create: (_) => MediaService()),
        Provider(create: (_) => SearchService()),
        Provider(create: (_) => StoryService()),
        Provider(create: (_) => EventService()),
        Provider(create: (_) => ModerationService()),
      ],
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Color(0xFF6200EA); // Modern purple

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.inter(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.grey[50],
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Zeeky Social',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthGate(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late PresenceService _presenceService;
  late StoryService _storyService;
  late EventService _eventService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize services
    _presenceService = Provider.of<PresenceService>(context, listen: false);
    _storyService = Provider.of<StoryService>(context, listen: false);
    _eventService = Provider.of<EventService>(context, listen: false);
    
    _presenceService.initialize();
    _storyService.initialize();
    _eventService.initialize();
    
    _initializeNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _presenceService.dispose();
    _storyService.dispose();
    _eventService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _presenceService.updateUserPresence(PresenceStatus.online);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _presenceService.updateUserPresence(PresenceStatus.away);
        break;
      case AppLifecycleState.detached:
        _presenceService.updateUserPresence(PresenceStatus.offline);
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _initializeNotifications() async {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      await notificationService.initNotifications();
      await notificationService.saveTokenForCurrentUser(user.uid);
    }
  }

  List<Widget> get _widgetOptions => [
    const FeedScreen(),
    const SearchScreen(),
    const StoriesScreen(),
    const ChatScreen(),
    const EventsScreen(),
    const CommunitiesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Create',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Post'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreatePostDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Story'),
                onTap: () {
                  Navigator.pop(context);
                  _createStory();
                },
              ),
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Event'),
                onTap: () {
                  Navigator.pop(context);
                  _createEvent();
                },
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Community'),
                onTap: () {
                  Navigator.pop(context);
                  _createCommunity();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePostDialog() {
    final postController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New Post'),
          content: TextField(
            controller: postController,
            decoration: const InputDecoration(
              hintText: "What's on your mind?",
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final firestoreService = Provider.of<FirestoreService>(context, listen: false);
                final authService = Provider.of<AuthService>(context, listen: false);
                final currentUser = authService.currentUser;
                final navigator = Navigator.of(dialogContext);
                if (postController.text.isNotEmpty && currentUser != null) {
                  await firestoreService.addPost(
                    postController.text,
                    currentUser.uid,
                  );
                  navigator.pop();
                }
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  void _createStory() {
    // TODO: Implement story creation UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Story creation coming soon!')),
    );
  }

  void _createEvent() {
    // TODO: Implement event creation UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event creation coming soon!')),
    );
  }

  void _createCommunity() {
    // TODO: Implement community creation UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Community creation coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Stories',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Communities',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOptions,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.flash_on,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Zeeky Social',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIChatScreen()),
              );
            },
            tooltip: 'AI Assistant',
          ),
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark 
                  ? Icons.light_mode 
                  : Icons.dark_mode
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
    );
  }
}
