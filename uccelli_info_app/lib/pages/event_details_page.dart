// lib/pages/event_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' show parse;
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/theme_provider.dart';
import '../widgets/custom_app_bar.dart';

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> event;

  /// You should push this page with:
  /// Navigator.push(
  ///   context,
  ///   MaterialPageRoute(
  ///     builder: (_) => EventDetailsPage(event: yourEventMap),
  ///   ),
  /// );
  const EventDetailsPage({Key? key, required this.event}) : super(key: key);

  void _addToCalendar(BuildContext context) {
    // --- Debugging: Überprüfen, ob Funktion aufgerufen wird ---
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Function entered!')),
    );
    print('_addToCalendar function entered.'); // Auch für die Debug-Konsole
    // --------------------------------------------------------

    try {
      // Parse out the fields we need
      final title = parse(event['title']?.toString() ?? '')
              .body
              ?.text ??
          'No title';
      final description = parse(event['description']?.toString() ?? '')
              .body
              ?.text ??
          '';

      // --- Fehlerbehandlung für Datums-Parsing ---
      DateTime start;
      DateTime end;
      try {
        // Versuche, die Start- und Enddaten zu parsen
        // Das replaceFirst(' ', 'T') hilft bei einigen Datumsformaten
        start = DateTime.parse(
          event['start_date'].toString().replaceFirst(' ', 'T'),
        );
        end = DateTime.parse(
          event['end_date'].toString().replaceFirst(' ', 'T'),
        );
      } on FormatException catch (e) {
         // Fängt Fehler ab, wenn das Datumsformat falsch ist (z.B. von der API)
         print('Error parsing date: $e'); // Ausgabe in der Debug-Konsole
         ScaffoldMessenger.of(context).showSnackBar( // Rückmeldung für den Benutzer
           const SnackBar(content: Text('Fehler beim Parsen der Event-Daten. Ungültiges Datumsformat.')),
         );
         return; // Verarbeitung stoppen
      } catch (e) {
         // Fängt andere unerwartete Fehler beim Parsen ab
         print('Unexpected error during date parsing: $e'); // Ausgabe in der Debug-Konsole
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Ein unerwarteter Fehler ist beim Parsen der Daten aufgetreten.')),
         );
         return; // Verarbeitung stoppen
      }
      // -----------------------------------------


      // Build a human-friendly location string
      String location = '';
      final venue = event['venue'];
      if (venue is Map<String, dynamic>) {
        final venueName = venue['venue'] as String? ?? '';
        final addr      = venue['address'] as String? ?? '';
        final zip       = venue['zip']     as String? ?? '';
        final city      = venue['city']    as String? ?? '';
        location = [venueName, addr, zip, city]
            .where((s) => s.isNotEmpty)
            .join(', ');
      }

      // Erstelle das Event-Objekt für das Plugin
      final calendarEvent = Event(
        title: title,
        description: description,
        location: location,
        startDate: start,
        endDate: end,
        iosParams: const IOSParams(
          // on iOS you can set a reminder before the event
          reminder: Duration(hours: 1), // Beispiel: Erinnerung 1 Stunde vorher
          // url: "http://example.com", // Optional: URL hinzufügen
        ),
        androidParams: const AndroidParams(
          // optional: invite emails
          emailInvites: <String>[],
          // optional: isAllDay
          // isAllDay: false,
        ),
        // allDay: false, // Optional: Ganztägig? Wird oft von start/end Dates abgeleitet
      );

      // --- Aufruf des Plugins und grundlegende Fehlerbehandlung ---
      Add2Calendar.addEvent2Cal(calendarEvent);
      // Das Plugin selbst sollte die native UI öffnen, wenn erfolgreich.
      // Eine explizite Erfolgsmeldung ist oft nicht nötig.
      // ScaffoldMessenger.of(context).showSnackBar(
      //    const SnackBar(content: Text('Event zum Kalender hinzugefügt.')),
      // );
      // --------------------------------------

    } catch (e) {
      // Fängt alle anderen unerwarteten Fehler in der Funktion ab (z.B. Plugin-Fehler)
      print('An unexpected error occurred in _addToCalendar: $e'); // Ausgabe in der Debug-Konsole
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ein allgemeiner Fehler ist beim Hinzufügen zum Kalender aufgetreten.')),
      );
    }
  }

  void _shareEvent(BuildContext context) {
    final title = parse(event['title']?.toString() ?? '')
            .body
            ?.text ??
        '';
    final link = event['website'] as String? ?? ''; // Annahme: Website-Link im Event-Daten
    Share.share('$title\n$link', subject: title);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    // Event-Daten für die Anzeige extrahieren
    final title = parse(event['title']?.toString() ?? '')
            .body
            ?.text ??
        '';
    final descriptionHtml = event['description']?.toString() ?? ''; // HTML-Beschreibung
    final imageUrl = (event['image'] is Map<String, dynamic>)
        ? event['image']['url'] as String? // Annahme: Bild-URL im Event-Daten
        : null;

    return Scaffold(
      appBar: customAppBar(
        context,
        title: title,
        actions: [
          // Dark/Light Mode Umschalter
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () =>
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme(),
          ),
          // Teilen Button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareEvent(context),
          ),
          // Favoriten Button - Annahme, dass favoritesProvider existiert und toggleFavorite Methode hat
          // Consumer<FavoritesProvider>(
          //   builder: (context, favoritesProvider, child) {
          //     final isFavorite = favoritesProvider.isFavorite(event['id']); // Annahme: Event hat eine 'id'
          //     return IconButton(
          //       icon: Icon(
          //         isFavorite ? Icons.favorite : Icons.favorite_border,
          //         color: isFavorite ? Colors.red : null,
          //       ),
          //       onPressed: () {
          //         favoritesProvider.toggleFavorite(event); // Annahme: toggleFavorite nimmt das Event-Map
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(
          //             content: Text(isFavorite ? 'Von Favoriten entfernt' : 'Zu Favoriten hinzugefügt'),
          //             duration: const Duration(seconds: 1),
                          // action: SnackBarAction( // Optional: Action auf der Snackbar
                          //   label: 'UNDO',
                          //   onPressed: () {
                          //     // Undo logic
                          //   },
                          // ),
          //           ),
          //         );
          //       },
          //     );
          //   },
          // ),
        ],
      ),
      body: ListView(
        children: [
          // ─── HEADER IMAGE ─────────────────────────────
          if (imageUrl != null)
            Image.network(
              imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, progress) =>
                  progress == null
                      ? child
                      : Container( // Placeholder während des Ladens
                          height: 220,
                          color: Colors.grey.shade300,
                        ),
              errorBuilder: (ctx, err, stack) =>
                  Container(height: 220, color: Colors.grey.shade300), // Placeholder bei Fehler
            )
          else
            Container(height: 220, color: Colors.grey.shade300), // Standard-Placeholder wenn keine URL

          const SizedBox(height: 16),

          // ─── INFO BOX (Zeit, Eintritt) ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Info', style: theme.textTheme.titleMedium),
                    const Divider(),
                    // Zeit anzeigen
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.access_time, size: 18),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            // Annahme, dass start_date und end_date Strings sind
                            'Zeit: ${event['start_date']} – ${event['end_date']}',
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    // Eintritt anzeigen (falls vorhanden)
                    if ((event['cost'] as String?)?.isNotEmpty ?? false)
                      ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.euro, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Eintritt: ${event['cost']}', // Annahme: cost ist String
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ─── DESCRIPTION BOX (HTML Inhalt) ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Beschreibung', style: theme.textTheme.titleMedium),
                    const Divider(),
                    // HTML Inhalt rendern
                    Html(data: descriptionHtml), // 'flutter_html' Plugin
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ─── VENUE BOX (Veranstaltungsort Details) ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Veranstaltungsort',
                        style: theme.textTheme.titleMedium),
                    const Divider(),
                    // Venue Details anzeigen (falls vorhanden und Map ist)
                    if (event['venue'] is Map<String, dynamic>) ...[
                      Text(
                        event['venue']['venue'] as String, // Annahme: Venue Name als String
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text([
                        event['venue']['address'], // Annahme: Adresse
                        event['venue']['zip'], // Annahme: PLZ
                        event['venue']['city'] // Annahme: Stadt
                      ].whereType<String>().join(', ')), // Nur Strings verknüpfen
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── BUTTONS (Add to Calendar, Join) ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Add to Calendar Button
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Add to Calendar'),
                    onPressed: () => _addToCalendar(context), // Ruft die Funktion mit Fehlerbehandlung auf
                  ),
                ),
                const SizedBox(width: 16),
                // Join the Event Button (bisher nicht implementiert)
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.event_available),
                    label: const Text('Join the Event'),
                    onPressed: () {
                      // deine bestehende “join event” Logik…
                          // Beispiel: URL öffnen, falls ein Link vorhanden ist
                          // final eventUrl = event['website'] as String?; // Annahme: Website-Link
                          // if (eventUrl != null && eventUrl.isNotEmpty) {
                          //   launchUrl(Uri.parse(eventUrl));
                          // } else {
                          //    ScaffoldMessenger.of(context).showSnackBar(
                          //      const SnackBar(content: Text('Kein Link für dieses Event verfügbar.')),
                          //    );
                          // }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}