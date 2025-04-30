// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Firebase core & messaging
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Hive (for your post cache) and your services/providers
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uccelli_info_app/services/post_cache_service.dart';
import 'package:uccelli_info_app/providers/theme_provider.dart';
import 'package:uccelli_info_app/providers/favorites_provider.dart';

import 'package:uccelli_info_app/pages/splash_screen.dart';

// 1️⃣ Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Re-initialize Firebase in the background isolate
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('📥 [bg] Message received: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2️⃣ Init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3️⃣ Register background FCM handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 4️⃣ Init Hive & open your cache box
  await Hive.initFlutter();
  await Hive.openBox(PostCacheService.postsBoxName);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FirebaseMessaging _messaging;

  @override
  void initState() {
    super.initState();
    _messaging = FirebaseMessaging.instance;

    // 5️⃣ Request permission (iOS & Android 13+)
    _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    ).then((settings) {
      debugPrint('🔔 Permission granted: ${settings.authorizationStatus}');
    });

    // 6️⃣ Get and print the FCM token
    _messaging.getToken().then((token) {
      debugPrint('📲 FCM Token: $token');
      // TODO: send this token to your server if you want server‐driven pushes
    });

    // 7️⃣ Handle messages in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📥 [fg] Message received: ${message.messageId}');
      if (message.notification != null) {
        debugPrint('🔔 Notification: ${message.notification!.title}');
        // TODO: display an in‐app banner or local notification here
      }
    });

    // 8️⃣ Handle taps on notifications (when app is backgrounded)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🚀 [opened_app] via notification: ${message.notification?.title}');
      // TODO: navigate to a particular screen based on message.data
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Uccelli Society',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,

      // Copy in your existing theme definitions here:
      theme: ThemeData( /* your light theme */ ),
      darkTheme: ThemeData( /* your dark theme */ ),

      home: const SplashScreen(),
    );
  }
}
