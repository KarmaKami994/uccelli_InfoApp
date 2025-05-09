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
  ///   context,
  ///   MaterialPageRoute(
  ///     builder: (_) => EventDetailsPage(event: yourEventMap),
  ///   ),
  /// );
  const EventDetailsPage({Key? key, required this.event}) : super(key: key);

  void _addToCalendar(BuildContext context) {
    // Parse out the fields we need
    final title = parse(event['title']?.toString() ?? '')
            .body
            ?.text ??
        'No title';
    final description = parse(event['description']?.toString() ?? '')
            .body
            ?.text ??
        '';
    final start = DateTime.parse(
      event['start_date'].toString().replaceFirst(' ', 'T'),
    );
    final end = DateTime.parse(
      event['end_date'].toString().replaceFirst(' ', 'T'),
    );

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

    final calendarEvent = Event(
      title: title,
      description: description,
      location: location,
      startDate: start,
      endDate: end,
      iosParams: IOSParams(
        // on iOS you can set a reminder before the event
        reminder: const Duration(hours: 1),
      ),
      androidParams: AndroidParams(
        // optional: invite emails
        emailInvites: <String>[],
      ),
    );

    // This launches the native calendar app with your event pre-filled
    Add2Calendar.addEvent2Cal(calendarEvent);
  }

  void _shareEvent(BuildContext context) {
    final title = parse(event['title']?.toString() ?? '')
            .body
            ?.text ??
        '';
    final link = event['website'] as String? ?? '';
    Share.share('$title\n$link', subject: title);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final title = parse(event['title']?.toString() ?? '')
            .body
            ?.text ??
        '';
    final descriptionHtml = event['description']?.toString() ?? '';
    final imageUrl = (event['image'] is Map<String, dynamic>)
        ? event['image']['url'] as String?
        : null;

    return Scaffold(
      appBar: customAppBar(
        context,
        title: title,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () =>
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareEvent(context),
          ),
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

          // ─── INFO BOX ──────────────────────────────────
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.access_time, size: 18),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Zeit: ${event['start_date']} – ${event['end_date']}',
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
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
                                'Eintritt: ${event['cost']}',
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

          // ─── DESCRIPTION BOX ─────────────────────────
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
                    Html(data: descriptionHtml),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ─── VENUE BOX ───────────────────────────────
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
                    if (event['venue'] is Map<String, dynamic>) ...[
                      Text(
                        event['venue']['venue'] as String,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
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

          // ─── BUTTONS ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Add to Calendar'),
                    onPressed: () => _addToCalendar(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.event_available),
                    label: const Text('Join the Event'),
                    onPressed: () {
                      // your existing “join event” logic…
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
