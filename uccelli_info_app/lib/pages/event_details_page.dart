// lib/pages/event_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser; // Beibehalten für Textbereinigung bei Bedarf
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// >>> Importiere generierten Lokalisierungs-Code <<<
import 'package:uccelli_info_app/gen_l10n/app_localizations.dart';
// <<< Ende Import >>>

import '../providers/theme_provider.dart';
import '../widgets/custom_app_bar.dart';

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsPage({Key? key, required this.event}) : super(key: key);

  // Hilfsfunktion zur Auswahl des Titels basierend auf der Sprache
  String _getDisplayedTitle(BuildContext context) {
    final currentLanguageCode = Localizations.localeOf(context).languageCode;
    final String originalTitle = event['title']?.toString() ?? 'No title';
    final String? translatedTitle = event['title_en']?.toString();

    if (currentLanguageCode == 'en' && translatedTitle != null && translatedTitle.isNotEmpty) {
      return translatedTitle;
    }
    return originalTitle;
  }

  // Hilfsfunktion zur Auswahl der Beschreibung basierend auf der Sprache
  String _getDisplayedDescription(BuildContext context) {
    final currentLanguageCode = Localizations.localeOf(context).languageCode;
    final String originalDescription = event['description']?.toString() ?? '';
    final String? translatedDescription = event['description_en']?.toString();

    if (currentLanguageCode == 'en' && translatedDescription != null && translatedDescription.isNotEmpty) {
      return translatedDescription;
    }
    return originalDescription;
  }

  void _addToCalendar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Lokalisierung hinzufügen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.addToCalendarFunctionEntered)), // Lokalisieren
    );
    debugPrint('_addToCalendar function entered.');

    try {
      final title = _getDisplayedTitle(context); // Verwende den ausgewählten Titel
      final description = html_parser.parse(_getDisplayedDescription(context)).body?.text ?? ''; // Beschreibung unescape für Kalender

      DateTime start;
      DateTime end;
      try {
        start = DateTime.parse(event['start_date'].toString().replaceFirst(' ', 'T'));
        end = DateTime.parse(event['end_date'].toString().replaceFirst(' ', 'T'));
      } on FormatException catch (e) {
        debugPrint('Error parsing date: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorParsingEventDate)), // Lokalisieren
        );
        return;
      } catch (e) {
        debugPrint('Unexpected error during date parsing: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.unexpectedErrorParsingEventData)), // Lokalisieren
        );
        return;
      }

      String location = '';
      final venue = event['venue']; // Venue ist jetzt ein JSONB-Objekt
      if (venue is Map<String, dynamic>) {
        final venueName = venue['venue'] as String? ?? '';
        final addr      = venue['address'] as String? ?? '';
        final zip       = venue['zip']     as String? ?? '';
        final city      = venue['city']    as String? ?? '';
        location = [venueName, addr, zip, city].where((s) => s.isNotEmpty).join(', ');
      }

      final calendarEvent = Event(
        title: title,
        description: description,
        location: location,
        startDate: start,
        endDate: end,
        iosParams: const IOSParams(
          reminder: Duration(hours: 1),
        ),
        androidParams: const AndroidParams(
          emailInvites: <String>[],
        ),
      );

      Add2Calendar.addEvent2Cal(calendarEvent);
    } catch (e) {
      debugPrint('An unexpected error occurred in _addToCalendar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.generalErrorAddingToCalendar)), // Lokalisieren
      );
    }
  }

  void _shareEvent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Lokalisierung hinzufügen
    final title = _getDisplayedTitle(context); // Verwende den ausgewählten Titel
    final link = event['url'] as String? ?? ''; // Link kommt jetzt aus 'url'

    if (link.isNotEmpty) {
      Share.share('$title\n$link', subject: title);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noLinkAvailableForEvent)), // Lokalisieren
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context)!; // Lokalisierung hinzufügen

    final title = _getDisplayedTitle(context); // Verwende die neue Hilfsfunktion
    final descriptionHtml = _getDisplayedDescription(context); // Verwende die neue Hilfsfunktion
    // Im Supabase-Schema haben wir keine 'image' oder 'featured_media_url' für Events definiert.
    // Wenn du Event-Bilder hast, musst du diese Spalte im Schema hinzufügen und im syncScript befüllen.
    final imageUrl = null; // event['featured_media_url'] as String? ?? null; // Annahme: Event hat featured_media_url

    return Scaffold(
      appBar: customAppBar(
        context,
        title: title,
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareEvent(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Header image with graceful fallback
          if (imageUrl != null)
            Image.network(
              imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, progress) =>
                  progress == null
                      ? child
                      : Container(
                          height: 220,
                          color: Colors.grey.shade300,
                        ),
              errorBuilder: (ctx, err, stack) =>
                  Container(height: 220, color: Colors.grey.shade300),
            )
          else
            Container(height: 220, color: Colors.grey.shade300),

          const SizedBox(height: 16),

          // ─── INFO BOX (Zeit, Eintritt) ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.infoSectionTitle, style: theme.textTheme.titleMedium), // Lokalisieren
                    const Divider(),
                    // Zeit anzeigen
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.access_time, size: 18),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${l10n.timePrefix} ${event['start_date'] ?? ''} – ${event['end_date'] ?? ''}', // Lokalisieren
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
                                '${l10n.entryFeePrefix} ${event['cost']}', // Lokalisieren
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.descriptionSectionTitle, style: theme.textTheme.titleMedium), // Lokalisieren
                    const Divider(),
                    Html(data: descriptionHtml), // Render the selected content
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.venueSectionTitle, style: theme.textTheme.titleMedium), // Lokalisieren
                    const Divider(),
                    if (event['venue'] is Map<String, dynamic>) ...[
                      Text(
                        event['venue']['venue'] as String? ?? '', // Sicherstellen, dass es ein String ist
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text([
                        event['venue']['address'],
                        event['venue']['zip'],
                        event['venue']['city']
                      ].whereType<String>().join(', ')),
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
                    label: Text(l10n.addToCalendarButtonLabel), // Lokalisieren
                    onPressed: () => _addToCalendar(context),
                  ),
                ),
                const SizedBox(width: 16),
                // Join the Event Button
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.event_available),
                    label: Text(l10n.joinEventButtonLabel), // Lokalisieren
                    onPressed: () {
                      // Deine bestehende “join event” Logik…
                      final eventUrl = event['url'] as String?; // Link kommt jetzt aus 'url'
                      if (eventUrl != null && eventUrl.isNotEmpty) {
                        launchUrl(Uri.parse(eventUrl));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.noLinkAvailableForEvent)), // Lokalisieren
                        );
                      }
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
