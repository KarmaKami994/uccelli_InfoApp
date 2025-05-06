// lib/pages/event_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' show parse;
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/theme_provider.dart';
import '../widgets/custom_app_bar.dart';

class EventDetailsPage extends StatefulWidget {
  final int eventId;
  final Future<Map<String, dynamic>?> eventFuture;

  const EventDetailsPage({
    Key? key,
    required this.eventId,
    required this.eventFuture,
  }) : super(key: key);

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _email = '';

  void _showJoinDialog(String eventName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join the Event'),
        content: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              onSaved: (v) => _fullName = v!.trim(),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter your email';
                final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                return regex.hasMatch(v.trim()) ? null : 'Enter a valid email';
              },
              onSaved: (v) => _email = v!.trim(),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.pop(ctx);
                Share.share(
                  'Event: $eventName\nFull Name: $_fullName\nEmail: $_email',
                  subject: 'Join: $eventName - $_fullName',
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _addToCalendar(Map<String, dynamic> event) {
    final title = parse(event['title']?.toString() ?? '').body?.text ?? '';
    final description = parse(event['description']?.toString() ?? '').body?.text ?? '';
    final start = DateTime.parse(event['start_date'].replaceFirst(' ', 'T'));
    final end = DateTime.parse(event['end_date'].replaceFirst(' ', 'T'));

    String location = '';
    final venueRaw = event['venue'];
    if (venueRaw is Map<String, dynamic>) {
      final addr = venueRaw['address'] as String? ?? '';
      final zip  = venueRaw['zip']     as String? ?? '';
      final city = venueRaw['city']    as String? ?? '';
      location = [addr, zip, city].where((s) => s.isNotEmpty).join(', ');
    }

    final calendarEvent = Event(
      title: title,
      description: description,
      location: location,
      startDate: start,
      endDate: end,
    );
    Add2Calendar.addEvent2Cal(calendarEvent);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FutureBuilder<Map<String, dynamic>?>(
      future: widget.eventFuture,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError || snap.data == null) {
          return Scaffold(body: Center(child: Text('Error loading event.')));
        }

        final event = snap.data!;
        final title   = parse(event['title']?.toString() ?? '').body?.text ?? '';
        final imageUrl = (event['image'] is Map) ? event['image']['url'] as String? : null;
        final descriptionHtml = event['description']?.toString() ?? '';

        return Scaffold(
          appBar: customAppBar(
            context,
            title: title,
            actions: [
              IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => themeProvider.toggleTheme(),
              ),
            ],
          ),
          body: ListView(
            children: [
              // HEADER IMAGE
              if (imageUrl != null)
                Image.network(imageUrl, height: 220, width: double.infinity, fit: BoxFit.cover)
              else
                Container(height: 220, color: Colors.grey.shade300),

              const SizedBox(height: 16),

              // INFO BOX with wrapping rows
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Info', style: Theme.of(context).textTheme.titleMedium),
                        const Divider(),

                        // Time row
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

                        // Cost row (if present)
                        if ((event['cost'] as String?)?.isNotEmpty ?? false) ...[
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

              // DESCRIPTION BOX
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Beschreibung', style: Theme.of(context).textTheme.titleMedium),
                        const Divider(),
                        Html(data: descriptionHtml),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // VENUE BOX
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Veranstaltungsort', style: Theme.of(context).textTheme.titleMedium),
                        const Divider(),
                        if (event['venue'] is Map<String, dynamic>) ...[
                          Text(
                            event['venue']['venue'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text([
                            event['venue']['address'],
                            event['venue']['zip'],
                            event['venue']['city'],
                          ].whereType<String>().join(', ')),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // BUTTONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Add to Calendar'),
                      onPressed: () => _addToCalendar(event),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.event_available),
                      label: const Text('Join the Event'),
                      onPressed: () => _showJoinDialog(title),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
