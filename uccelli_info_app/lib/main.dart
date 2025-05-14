// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- Import hinzufügen

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

// >>> Importiere generierten Lokalisierungs-Code <<<
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// >>> Importiere Standard Lokalisierungs-Delegates <<<
import 'package:flutter_localizations/flutter_localizations.dart';


/// Top-level background handler for FCM messages.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Re-initialize Firebase in the background isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📥 [bg] ${message.notification?.title} / ${message.data}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2️⃣ Initialize Hive and open your cache box
  await Hive.initFlutter();
  await Hive.openBox(PostCacheService.postsBoxName);

  // 3️⃣ Initialize local notifications & FCM listeners
  await PushNotificationService.init();

  // 4️⃣ Register the background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 5️⃣ Launch the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      // Übergib die MyApp, die jetzt ein StatefulWidget ist
      child: const MyApp(),
    ),
  );
}

// Ändere MyApp von StatelessWidget zu StatefulWidget
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Static Methode, um vom State aus auf den State zuzugreifen
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();


  @override
  State<MyApp> createState() => _MyAppState();
}

// Der State für MyApp
class _MyAppState extends State<MyApp> {
  // Variable zum Speichern der Benutzer-Sprachpräferenz (null initial)
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    // Lade die gespeicherte Sprachpräferenz, wenn der State initialisiert wird
    _loadLocalePreference();
  }

  // Methode zum Laden der gespeicherten Sprachpräferenz aus SharedPreferences
  Future<void> _loadLocalePreference() async {
    final prefs = await SharedPreferences.getInstance();
    // Versuche, den gespeicherten Sprachcode zu laden
    final savedLangCode = prefs.getString('user_language_code'); // <-- Schlüssel zum Speichern der Sprache

    if (savedLangCode != null) {
      // Wenn ein Sprachcode gespeichert ist, erstelle die Locale
      final loadedLocale = Locale(savedLangCode);
      // Überprüfe, ob die geladene Locale in den unterstützten Locales enthalten ist
      // (um Probleme zu vermeiden, falls eine nicht unterstützte Sprache gespeichert wurde)
      if (AppLocalizations.supportedLocales.contains(loadedLocale)) {
         // Wenn die geladene Locale unterstützt wird, aktualisiere den State
        setState(() {
          _locale = loadedLocale;
        });
      } else {
        // Wenn die geladene Locale nicht unterstützt wird, setze _locale auf null,
        // damit MaterialApp die Gerätesprache verwendet (oder den Fallback)
         setState(() {
          _locale = null;
        });
      }

    }
    // Wenn savedLangCode null ist, bleibt _locale null, und MaterialApp verwendet die Gerätesprache
  }

  // Methode zum Speichern der Benutzer-Sprachauswahl und Aktualisieren der UI
  // Diese Methode wird später von der SettingsPage aufgerufen
  void setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    // Speichere den Sprachcode (z.B. 'de', 'en')
    await prefs.setString('user_language_code', locale.languageCode);
    // Aktualisiere den State, um die UI zu rebuilden mit der neuen Sprache
    setState(() {
      _locale = locale;
    });
  }


  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);

    // Your brand & accent colors
    const primary   = Color(0xFFDFBF8F);
    const greyAcc   = Color(0xFF6A6A6A);
    const darkBg    = Color(0xFF252525);

    // Light theme overrides
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

    // Dark theme overrides
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
        fillColor: darkBg.withOpacity(0.2),
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
      // >>> Lokalisierungseinstellungen hinzufügen <<<
      localizationsDelegates: const [
        AppLocalizations.delegate, // Dein generierter Delegate (basierend auf app_de.arb)
        GlobalMaterialLocalizations.delegate, // Standard Delegate für Material Widgets
        GlobalWidgetsLocalizations.delegate, // Standard Delegate für allgemeine Widgets
        GlobalCupertinoLocalizations.delegate, // Standard Delegate für Cupertino Widgets
      ],
      supportedLocales: AppLocalizations.supportedLocales, // <-- Nutze die vom gen_l10n Tool generierte Liste unterstützter Locales
      // Nutze die vom Benutzer gewählte Locale (_locale). Wenn _locale null ist,
      // verwendet MaterialApp die Gerätesprache und fällt auf die erste in supportedLocales zurück, wenn die Gerätesprache nicht unterstützt wird.
      locale: _locale, // <-- Setzt die vom Benutzer geladene oder gewählte Locale

      title: 'Uccelli Society', // Dieser Titel wird überschrieben, wenn Lokalisierung verwendet wird
      debugShowCheckedModeBanner: false,
      themeMode: themeProv.themeMode,
      theme: light,
      darkTheme: dark,
      home: const SplashScreen(), // Die Splash Screen wird zuerst angezeigt
      // ... andere MaterialApp Eigenschaften ...
    );
  }
}