// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:dio/dio.dart'; // <-- Import für Dio
import 'package:path_provider/path_provider.dart'; // <-- Import für path_provider
import 'package:open_filex/open_filex.dart'; // <-- Import für open_filex
import 'dart:io'; // <-- Import für File
import 'package:permission_handler/permission_handler.dart'; // <-- Import für permission_handler
import 'package:fluttertoast/fluttertoast.dart'; // <-- Import für fluttertoast
import 'package:url_launcher/url_launcher.dart'; // <-- Import für url_launcher
import 'package:package_info_plus/package_info_plus.dart'; // <-- Import für package_info_plus (schon da, aber wichtig für diesen Task)
import 'package:app_settings/app_settings.dart'; // <-- Import für app_settings

// >>> Importiere generierten Lokalisierungs-Code <<<
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// <<< Ende Import >>>


import '../providers/theme_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/wordpress_service.dart';
import '../widgets/custom_app_bar.dart';
import '../services/update_service.dart'; // <-- Import hinzufügen

import 'event_details_page.dart';
import 'post_details_page.dart';
import 'favorites_page.dart';
import 'settings_page.dart';

// Füge WidgetsBindingObserver Mixin hinzu
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver { // <-- Start der _HomePageState Klasse

  final WordPressService wpService = WordPressService();
  late Future<List<dynamic>> postsFuture;
  late Future<List<dynamic>> eventsFuture;

  String postsSearchQuery = '';
  String eventsSearchQuery = '';

  // Variable zum Speichern der Update-Informationen
  AppUpdateInfo? _availableUpdate;


  @override
  void initState() {
    super.initState();
    // Beobachter hinzufügen
    WidgetsBinding.instance.addObserver(this);
    postsFuture = wpService.fetchPosts();
    eventsFuture = wpService.fetchEvents();
    _checkForUpdates(); // <-- Aufruf hinzufügen: Auf Updates prüfen, wenn die Seite geladen wird
  }

  @override
  void dispose() {
    // Beobachter entfernen, wenn das Widget verworfen wird
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Methode des WidgetsBindingObserver: Wird bei Änderungen des App-Lebenszyklus aufgerufen
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Wenn die App aus dem Hintergrund zurückkehrt
    if (state == AppLifecycleState.resumed) {
      // Prüfen, ob wir Update-Informationen gespeichert haben und ob eine Snackbar angezeigt werden kann
      // Wir fügen eine kleine Verzögerung hinzu, um sicherzustellen, dass die UI bereit ist, bevor die Snackbar angezeigt wird.
      Future.delayed(const Duration(milliseconds: 500), () {
         if (_availableUpdate != null && _availableUpdate!.updateAvailable && _availableUpdate!.downloadUrl != null) {
           // Zeige die Update-Snackbar erneut an
           _showUpdateSnackbar(_availableUpdate!);
         }
      });
    }
  }


  Future<void> _refreshPosts() async {
    setState(() => postsFuture = wpService.fetchPosts());
  }

  Future<void> _refreshEvents() async {
    setState(() => eventsFuture = wpService.fetchEvents());
  }

  // Hilfsmethode zum Anzeigen der Update-Snackbar
  void _showUpdateSnackbar(AppUpdateInfo updateInfo) {
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update verfügbar! Neueste Version: ${updateInfo.latestVersion}'), // TODO: Diesen Text lokalisieren
          action: SnackBarAction(
            label: 'Herunterladen', // TODO: Diesen Label lokalisieren
            onPressed: () {
              print('Download-Button gedrückt. URL: ${updateInfo.downloadUrl}'); // Behalte den Print für Debugging
              // Snackbar abweisen, damit sie nicht doppelt erscheint
              ScaffoldMessenger.of(context).hideCurrentSnackBar();

              if (updateInfo.downloadUrl != null) {
                _downloadAndInstallApk(context, updateInfo.downloadUrl!); // Aufruf der Download-Methode
              } else {
                 Fluttertoast.showToast(
                     msg: "Download-URL nicht verfügbar.", // TODO: Diesen Text lokalisieren
                     toastLength: Toast.LENGTH_LONG,
                     gravity: ToastGravity.BOTTOM,
                     backgroundColor: Colors.red,
                     textColor: Colors.white,
                     fontSize: 16.0
                 );
              }
            },
          ),
          duration: const Duration(seconds: 15), // Zeige die Snackbar mit dem Button für 15 Sekunden
        ),
      );
  }


  // Methode zur Update-Prüfung und Anzeige einer Benachrichtigung (Speichert jetzt das Ergebnis)
  Future<void> _checkForUpdates() async { // <-- Anfang der _checkForUpdates Methode
    // Gebe der UI eine Sekunde Zeit, um sich aufzubauen, bevor die Snackbar kommt
    await Future.delayed(const Duration(seconds: 1));

    final updateService = UpdateService();
    final updateInfo = await updateService.checkForUpdate();

    print('Update check result: $updateInfo'); // Debugging-Ausgabe in der Konsole

    if (updateInfo.updateAvailable && updateInfo.downloadUrl != null) {
      // Speichere die Update-Informationen
      _availableUpdate = updateInfo;
      // Zeige die Snackbar (erstmalig)
      _showUpdateSnackbar(_availableUpdate!); // <-- Ruft die Hilfsmethode auf
    } else {
      // Setze die Update-Informationen zurück, wenn kein Update verfügbar ist oder ein Fehler auftrat
      _availableUpdate = null;
       debugPrint('Kein Update verfügbar oder Fehler bei der Prüfung.');
    }
  } // <-- Ende der _checkForUpdates Methode


  // >>> METHODE: APK herunterladen und Installation starten <<<
  Future<void> _downloadAndInstallApk(BuildContext context, String apkUrl) async { // <-- Anfang der _downloadAndInstallApk Methode
    // --- Prüfung auf Berechtigung "Unbekannte Apps installieren" (Android >= 8.0) ---
    // Diese Berechtigung ist notwendig, um eine APK herunterzuladen und die Installation zu starten.
    final status = await Permission.requestInstallPackages.status;
    print('Install unknown apps permission status: $status'); // Debugging Ausgabe

    if (status.isGranted) {
      // Berechtigung ist erteilt, fahre mit Download und Installation fort.
      // Verwende Fluttertoast für diese Nachricht
      Fluttertoast.showToast(
          msg: "Berechtigung erteilt. Download startet...", // TODO: Diesen Text lokalisieren
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0
      );
      print('Berechtigung erteilt. Download startet...'); // Behalte print für Konsole

      try {
        // Temporäres Verzeichnis zum Speichern der APK finden
        // getTemporaryDirectory ist gut für Cache-Dateien, die das System löschen kann
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/app-update.apk';

        // Stelle sicher, dass das Verzeichnis existiert
        await Directory(directory.path).create(recursive: true);

        // Dio Instanz erstellen
        final dio = Dio();

        // APK herunterladen
        await dio.download(
          apkUrl,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              // Optional: Fortschritt in der Konsole anzeigen
              print('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
              // Du könntest hier eine Fortschrittsanzeige in der UI aktualisieren (z.g. mit einem State oder Provider)
              // oder einen temporären Toast mit Fortschritt anzeigen (kann aber sehr viele Toasts erzeugen)
            }
          },
        );

        // Zeige Nachricht, dass der Download abgeschlossen ist
        Fluttertoast.showToast(
            msg: "Download abgeschlossen. Installation wird gestartet...", // TODO: Diesen Text lokalisieren
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0
        );
        print('Download abgeschlossen. Installation wird gestartet...'); // Behalte print

        // Datei öffnen, um die Installation auszulösen
        final result = await OpenFilex.open(filePath);

        // Überprüfen, ob das Öffnen erfolgreich war (optional)
        if (result.type != ResultType.done) {
           print('Failed to open file: ${result.message}');
           Fluttertoast.showToast(
               msg: 'Fehler beim Starten der Installation: ${result.message}', // TODO: Diesen Text lokalisieren
               toastLength: Toast.LENGTH_LONG,
               gravity: ToastGravity.BOTTOM,
               backgroundColor: Colors.red, // Rot für Fehler
               textColor: Colors.white,
               fontSize: 16.0
           );
        }

      } catch (e) {
        // Fehler während des Downloads oder der Dateioperationen
        print('Error during download or install: $e');
        Fluttertoast.showToast(
            msg: 'Fehler beim Herunterladen oder Installieren: $e', // TODO: Diesen Text lokalisieren
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red, // Rot für Fehler
            textColor: Colors.white,
            fontSize: 16.0
        );
      }

    } else if (status.isDenied || status.isRestricted) {
      print('Install unknown apps permission denied or restricted. Showing dialog.');
      // Behalte den AlertDialog für die Berechtigungsanfrage
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Berechtigung erforderlich'), // TODO: Diesen Text lokalisieren
          content: const Text('Um Updates direkt installieren zu können, benötigst du die Berechtigung "Unbekannte Apps installieren" für diese App. Tippe auf "Einstellungen öffnen", um die Berechtigung zu erteilen.'), // TODO: Diesen Text lokalisieren
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'), // TODO: Diesen Text lokalisieren
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Einstellungen öffnen'), // TODO: Diesen Text lokalisieren
              onPressed: () async { // <<< Async machen
                Navigator.of(context).pop(); // Schließt den Dialog

                try {
                  // --- Spezifische Einstellungsseite mit app_settings öffnen ---
                  // Verwende das korrekte Paket und den richtigen AppSettingsType für diese spezifische Einstellung
                  // Kein Zuweisen zu bool, da openAppSettings void zurückgibt.
                  await AppSettings.openAppSettings( // <-- await Aufruf ohne Zuweisung
                    type: AppSettingsType.manageUnknownAppSources, // <-- Korrekter Typ für "Unbekannte Apps installieren"
                  );

                  // Kein if (!launched) Check mehr, da openAppSettings void ist.
                  // Fehler werden durch den catch-Block abgefangen.

                } catch (e) {
                  // Fehler während des Startens der Einstellungsseite (z.B. Intent nicht verfügbar auf Gerät)
                  print('Error launching settings: $e');
                  // Verwende Fluttertoast für Benutzerfeedback bei einem Fehler
                  Fluttertoast.showToast(
                      msg: 'Fehler beim Öffnen der Einstellungen: $e', // TODO: Diesen Text lokalisieren
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                  // Fallback: Bei einem Fehler, öffne die allgemeinen App-Einstellungen
                  // Dies ist ein Fallback, falls der spezifische Intent fehlschlägt
                  openAppSettings(); // Methode vom permission_handler Paket
                }
              }, // <<< Ende onPressed
            ),
          ],
        ),
      );
    } else {
      print('Install unknown apps permission status: $status');
       Fluttertoast.showToast(
          msg: 'Berechtigung zur Installation unbekannter Apps hat Status: $status', // TODO: Diesen Text lokalisieren
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange, // Orange für Warnung
          textColor: Colors.white,
          fontSize: 16.0
       );
    }
  } // <-- Ende der _downloadAndInstallApk Methode


  @override // <-- Diese @override Anmerkung gehört hierher, direkt vor der build Methode
  Widget build(BuildContext context) { // <-- Start der build Methode
    final themeProvider = Provider.of<ThemeProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    const cardMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    // >>> Zugriff auf lokalisierte Texte <<<
    final l10n = AppLocalizations.of(context)!; // <-- Hol dir die Instanz der lokalisierten Texte


    return DefaultTabController( // <-- Das ist der Beginn deines Widget-Baums in build
      length: 2,
      child: Scaffold(
        appBar: customAppBar(
          context,
          title: l10n.homePageTitle, // <-- Verwende lokalisierten App Bar Titel
          bottom: TabBar( // Kein const mehr, da die Texte lokalisiert sind
            tabs: [
              Tab(text: l10n.latestPostsTabTitle), // <-- Verwende lokalisierten Text
              Tab(text: l10n.upcomingEventsTabTitle), // <-- Verwende lokalisierten Text
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode), // <-- KORRIGIERT: Icons.dark_mode
              onPressed: themeProvider.toggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.favorite), // const bleibt hier
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()), // TODO: Page Title lokalisieren
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings), // const bleibt hier // TODO: Page Title lokalisieren
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()), // TODO: Page Title lokalisieren
              ),
            ),
            const SizedBox(width: 8), // const bleibt hier
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: TabBarView(
          children: [
            // ─── Latest Posts ───────────────────────────────────────────────────────
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0), // const bleibt hier
                  child: TextField(
                    decoration: InputDecoration( // Kein const mehr wegen lokalisiertem LabelText
                      labelText: l10n.searchPostsLabel, // <-- Verwende lokalisierten Text
                      border: const OutlineInputBorder(), // const bleibt hier
                      prefixIcon: const Icon(Icons.search), // const bleibt hier
                    ),
                    onChanged: (v) => setState(() => postsSearchQuery = v.toLowerCase()),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshPosts,
                    child: FutureBuilder<List<dynamic>>(
                      future: postsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator()); // const bleibt hier
                        } else if (snapshot.hasError) {
                          // >>> Lokalisierter Text mit String-Interpolation <<<
                          return Center(child: Text('${l10n.errorLoadingPosts} ${snapshot.error}')); // <-- Verwende lokalisierten Text
                        }

                        final filtered = snapshot.data!
                            .where((post) {
                              final title = html_parser
                                  .parse(post['title']['rendered']
                                      .toString())
                                  .documentElement
                                  ?.text
                                  .toLowerCase() ?? '';
                            return title.contains(postsSearchQuery);
                          })
                          .toList();

                        if (filtered.isEmpty) {
                          // >>> Lokalisierter Text <<<
                          return Center(child: Text(l10n.noPostsFound)); // <-- Verwende lokalisierten Text
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 16), // const bleibt hier
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12), // const bleibt hier
                          itemBuilder: (context, index) {
                            final post = filtered[index];
                            final title = post['title']['rendered'] as String;
                            final id    = post['id'].toString();
                            final isFav = favoritesProvider.isFavorite(id);

                            return FadeIn(
                              duration: const Duration(milliseconds: 500), // const bleibt hier
                              delay: Duration(milliseconds: index * 100),
                              child: Card(
                                margin: cardMargin, // const bleibt hier
                                shape: RoundedRectangleBorder( // <-- Entferne const hier
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  title: Text(title),
                                  // >>> Lokalisierter Text mit String-Interpolation <<<
                                  subtitle: Text('${l10n.eventStartsPrefix} ${post['date'] ?? ''}'), // <-- Verwende lokalisierten Präfix
                                  trailing: const Icon(Icons.chevron_right), // const bleibt hier
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PostDetailsPage(post: post), // TODO: Page Title lokalisieren
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            // ─── Upcoming Events ────────────────────────────────────────────────────
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0), // const bleibt hier
                  child: TextField(
                    decoration: InputDecoration( // Kein const mehr wegen lokalisiertem LabelText
                      labelText: l10n.searchEventsLabel, // <-- Verwende lokalisierten Text
                      border: const OutlineInputBorder(), // const bleibt hier
                      prefixIcon: const Icon(Icons.search), // const bleibt hier
                    ),
                    onChanged: (v) => setState(() => eventsSearchQuery = v.toLowerCase()),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshEvents,
                    child: FutureBuilder<List<dynamic>>(
                      future: eventsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator()); // const bleibt hier
                        } else if (snapshot.hasError) {
                          // >>> Lokalisierter Text mit String-Interpolation <<<
                          return Center(child: Text('${l10n.errorLoadingEvents} ${snapshot.error}')); // <-- Verwende lokalisierten Text
                        }

                        final filtered = snapshot.data!
                            .where((event) {
                              final title = html_parser
                                  .parse(event['title'].toString())
                                  .documentElement
                                  ?.text
                                  .toLowerCase() ?? '';
                              return title.contains(eventsSearchQuery);
                            })
                            .toList();

                        if (filtered.isEmpty) {
                          // >>> Lokalisierter Text <<<
                          return Center(child: Text(l10n.noEventsFound)); // <-- Verwende lokalisierten Text
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 16), // const bleibt hier
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12), // const bleibt hier
                          itemBuilder: (context, index) { // <-- Anfang Events itemBuilder
                            final event  = filtered[index];
                            final title  = html_parser
                                    .parse(event['title'].toString())
                                    .documentElement
                                    ?.text ?? '';
                            // final start  = event['start_date'] ?? ''; // <-- DIESE ZEILE ENTFERNEN

                            return FadeIn(
                              duration: const Duration(milliseconds: 500), // const bleibt hier
                              delay: Duration(milliseconds: index * 100),
                              child: Card(
                                margin: cardMargin, // const bleibt hier
                                shape: RoundedRectangleBorder( // <-- Stelle sicher, dass 'const' hier entfernt ist
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  title: Text(title),
                                  // >>> Lokalisierter Text mit String-Interpolation <<<
                                  subtitle: Text('${l10n.eventStartsPrefix} ${event['start_date'] ?? ''}'), // <-- HIER direkt event['start_date'] verwenden
                                  trailing: const Icon(Icons.chevron_right), // const bleibt hier
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EventDetailsPage(event: event), // TODO: Page Title lokalisieren
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }, // <-- Ende Events itemBuilder
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  } // <-- Ende der build Methode
} // <-- Ende der _HomePageState Klasse