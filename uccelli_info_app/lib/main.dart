// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Firebase Core & Messaging
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Hive for local cache
import 'package:hive_flutter/hive_flutter.dart';
import 'services/post_cache_service.dart';

// Push-notification setup
import 'services/push_notification_service.dart';

// State providers
import 'providers/theme_provider.dart';
import 'providers/favorites_provider.dart';

// Entry page
import 'pages/splash_screen.dart';

/// Background FCM handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage msg) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📥 [bg] ${msg.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Init Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2️⃣ Init Hive & open cache box
  await Hive.initFlutter();
  await Hive.openBox(PostCacheService.postsBoxName);

  // 3️⃣ Init local notifications + FCM listeners
  await PushNotificationService.init();

  // 4️⃣ Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 5️⃣ Run the app
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);

    // Your brand & accent colors
    const primary   = Color(0xFFDFBF8F);
    const greyAcc   = Color(0xFF6A6A6A);
    const darkBg    = Color(0xFF252525);

    // Minimal light theme overrides
    final light = ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: greyAcc),
        ),
      ),
      colorScheme: ColorScheme.fromSwatch(accentColor: greyAcc),
    );

    // Minimal dark theme overrides
    final dark = ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBg.withOpacity(.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: greyAcc),
        ),
      ),
      colorScheme: ColorScheme.fromSwatch(
        brightness: Brightness.dark,
        accentColor: greyAcc,
      ),
    );

    return MaterialApp(
      title: 'Uccelli Society',
      debugShowCheckedModeBanner: false,
      themeMode: themeProv.themeMode,
      theme: light,
      darkTheme: dark,
      home: const SplashScreen(),
    );
  }
}
