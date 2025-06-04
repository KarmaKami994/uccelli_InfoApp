// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:html/parser.dart' as html_parser; // Beibehalten für Suchfilter
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

// >>> Importiere generierten Lokalisierungs-Code <<<
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// <<< Ende Import >>>

import '../providers/theme_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/content_service.dart'; // Umbenannt von wordpress_service.dart
import '../widgets/custom_app_bar.dart';
import '../services/update_service.dart';

import 'event_details_page.dart';
import 'post_details_page.dart';
import 'favorites_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final ContentService contentService = ContentService(); // Klassennamen-Anpassung
  late Future<List<Map<String, dynamic>>> postsFuture; // Typ-Anpassung
  late Future<List<Map<String, dynamic>>> eventsFuture; // Typ-Anpassung

  String postsSearchQuery = '';
  String eventsSearchQuery = '';

  AppUpdateInfo? _availableUpdate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    postsFuture = contentService.fetchPosts(); // Klassennamen-Anpassung
    eventsFuture = contentService.fetchEvents(); // Klassennamen-Anpassung
    _checkForUpdates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_availableUpdate != null && _availableUpdate!.updateAvailable && _availableUpdate!.downloadUrl != null) {
          _showUpdateSnackbar(_availableUpdate!);
        }
      });
    }
  }

  Future<void> _refreshPosts() async {
    setState(() => postsFuture = contentService.fetchPosts()); // Klassennamen-Anpassung
  }

  Future<void> _refreshEvents() async {
    setState(() => eventsFuture = contentService.fetchEvents()); // Klassennamen-Anpassung
  }

  void _showUpdateSnackbar(AppUpdateInfo updateInfo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Update verfügbar! Neueste Version: ${updateInfo.latestVersion}'),
        action: SnackBarAction(
          label: 'Herunterladen',
          onPressed: () {
            print('Download-Button gedrückt. URL: ${updateInfo.downloadUrl}');
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            if (updateInfo.downloadUrl != null) {
              _downloadAndInstallApk(context, updateInfo.downloadUrl!);
            } else {
              Fluttertoast.showToast(
                msg: "Download-URL nicht verfügbar.",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          },
        ),
        duration: const Duration(seconds: 15),
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    await Future.delayed(const Duration(seconds: 1));

    final updateService = UpdateService();
    final updateInfo = await updateService.checkForUpdate();

    print('Update check result: $updateInfo');

    if (updateInfo.updateAvailable && updateInfo.downloadUrl != null) {
      _availableUpdate = updateInfo;
      _showUpdateSnackbar(_availableUpdate!);
    } else {
      _availableUpdate = null;
      debugPrint('Kein Update verfügbar oder Fehler bei der Prüfung.');
    }
  }

  // METHODE: APK herunterladen und Installation starten
  Future<void> _downloadAndInstallApk(BuildContext context, String apkUrl) async {
    final status = await Permission.requestInstallPackages.status;
    print('Install unknown apps permission status: $status');

    if (status.isGranted) {
      Fluttertoast.showToast(
        msg: "Berechtigung erteilt. Download startet...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print('Berechtigung erteilt. Download startet...');

      try {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/app-update.apk';

        await Directory(directory.path).create(recursive: true);

        final dio = Dio();

        await dio.download(
          apkUrl,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              print('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
            }
          },
        );

        Fluttertoast.showToast(
          msg: "Download abgeschlossen. Installation wird gestartet...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print('Download abgeschlossen. Installation wird gestartet...');

        final result = await OpenFilex.open(filePath);

        if (result.type != ResultType.done) {
          print('Failed to open file: ${result.message}');
          Fluttertoast.showToast(
            msg: 'Fehler beim Starten der Installation: ${result.message}',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        print('Error during download or install: $e');
        Fluttertoast.showToast(
          msg: 'Fehler beim Herunterladen oder Installieren: $e',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else if (status.isDenied || status.isRestricted) {
      print('Install unknown apps permission denied or restricted. Showing dialog.');
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Berechtigung erforderlich'),
          content: const Text('Um Updates direkt installieren zu können, benötigst du die Berechtigung "Unbekannte Apps installieren" für diese App. Tippe auf "Einstellungen öffnen", um die Berechtigung zu erteilen.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Einstellungen öffnen'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  // Öffnet die allgemeinen App-Einstellungen, da AppSettings entfernt wurde
                  await openAppSettings(); // Von permission_handler
                } catch (e) {
                  print('Error launching settings: $e');
                  Fluttertoast.showToast(
                    msg: 'Fehler beim Öffnen der Einstellungen: $e',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
            ),
          ],
        ),
      );
    } else {
      print('Install unknown apps permission status: $status');
      Fluttertoast.showToast(
        msg: 'Berechtigung zur Installation unbekannter Apps hat Status: $status',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    const cardMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    final l10n = AppLocalizations.of(context)!;
    // KORRIGIERT: Zugriff auf die Locale über Localizations.localeOf(context)
    final currentLanguageCode = Localizations.localeOf(context).languageCode;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: customAppBar(
          context,
          title: l10n.homePageTitle,
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.latestPostsTabTitle),
              Tab(text: l10n.upcomingEventsTabTitle),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: themeProvider.toggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: TabBarView(
          children: [
            // ─── Latest Posts ───────────────────────────────────────────────────────
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: l10n.searchPostsLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => postsSearchQuery = v.toLowerCase()),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshPosts,
                    child: FutureBuilder<List<Map<String, dynamic>>>( // Typ-Anpassung
                      future: postsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('${l10n.errorLoadingPosts} ${snapshot.error}'));
                        }

                        final filtered = snapshot.data!
                            .where((post) {
                              // Für die Suche den Titel parsen, da er HTML enthalten könnte
                              final title = html_parser
                                  .parse(post['title'].toString()) // title ist jetzt direkt ein String
                                  .documentElement
                                  ?.text
                                  .toLowerCase() ?? '';
                              return title.contains(postsSearchQuery);
                            })
                            .toList();

                        if (filtered.isEmpty) {
                          return Center(child: Text(l10n.noPostsFound));
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final post = filtered[index];
                            
                            // Logik zur Auswahl des Titels basierend auf der Sprache
                            final String displayedTitle = 
                                (currentLanguageCode == 'en' && post.containsKey('title_en') && post['title_en'] != null)
                                ? post['title_en'] as String
                                : post['title'] as String;

                            final id = post['id'].toString(); // ID bleibt String für FavoritesProvider
                            final isFav = favoritesProvider.isFavorite(id);

                            return FadeIn(
                              duration: const Duration(milliseconds: 500),
                              delay: Duration(milliseconds: index * 100),
                              child: Card(
                                margin: cardMargin,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  title: Text(displayedTitle), // Verwende den ausgewählten Titel
                                  subtitle: Text('${l10n.eventStartsPrefix} ${post['date'] ?? ''}'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PostDetailsPage(post: post),
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
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: l10n.searchEventsLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => eventsSearchQuery = v.toLowerCase()),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshEvents,
                    child: FutureBuilder<List<Map<String, dynamic>>>( // Typ-Anpassung
                      future: eventsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('${l10n.errorLoadingEvents} ${snapshot.error}'));
                        }

                        final filtered = snapshot.data!
                            .where((event) {
                              // Für die Suche den Titel parsen, da er HTML enthalten könnte
                              final title = html_parser
                                  .parse(event['title'].toString()) // title ist jetzt direkt ein String
                                  .documentElement
                                  ?.text
                                  .toLowerCase() ?? '';
                              return title.contains(eventsSearchQuery);
                            })
                            .toList();

                        if (filtered.isEmpty) {
                          return Center(child: Text(l10n.noEventsFound));
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final event = filtered[index];
                            
                            // Logik zur Auswahl des Titels basierend auf der Sprache
                            final String displayedTitle = 
                                (currentLanguageCode == 'en' && event.containsKey('title_en') && event['title_en'] != null)
                                ? event['title_en'] as String
                                : event['title'] as String;

                            return FadeIn(
                              duration: const Duration(milliseconds: 500),
                              delay: Duration(milliseconds: index * 100),
                              child: Card(
                                margin: cardMargin,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  title: Text(displayedTitle), // Verwende den ausgewählten Titel
                                  subtitle: Text('${l10n.eventStartsPrefix} ${event['start_date'] ?? ''}'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EventDetailsPage(event: event),
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
          ],
        ),
      ),
    );
  }
}
