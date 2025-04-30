// lib/pages/event_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' show parse;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.pop(ctx);

                final subject = Uri.encodeComponent('$eventName + $_fullName');
                final body = Uri.encodeComponent('Full Name: $_fullName\nEmail: $_email');
                final mailtoUri = Uri.parse(
                  'mailto:uccelli.society@gmail.com?subject=$subject&body=$body',
                );

                if (await canLaunchUrl(mailtoUri)) {
                  await launchUrl(mailtoUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open email client.')),
                  );
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  String _formatICalDate(DateTime dt) {
    final utc = dt.toUtc();
    return utc.toIso8601String()
        .replaceAll('-', '')
        .replaceAll(':', '')
        .split('.')
        .first + 'Z';
  }

  void _addToCalendar(Map<String, dynamic> event) async {
    final title = parse(event['title']?.toString() ?? '').body?.text ?? '';
    final start = DateTime.parse(event['start_date'].replaceFirst(' ', 'T'));
    final end = DateTime.parse(event['end_date'].replaceFirst(' ', 'T'));
    final dates = '${_formatICalDate(start)}/${_formatICalDate(end)}';
    final details = parse(event['description']?.toString() ?? '').body?.text ?? '';

    String location = '';
    final venueRaw = event['venue'];
    if (venueRaw is Map<String, dynamic>) {
      final address = venueRaw['address'] as String? ?? '';
      final zip     = venueRaw['zip']     as String? ?? '';
      final city    = venueRaw['city']    as String? ?? '';
      location = [address, zip, city].where((s) => s.isNotEmpty).join(', ');
    }

    final uri = Uri.https('www.google.com', '/calendar/render', {
      'action': 'TEMPLATE',
      'text': title,
      'dates': dates,
      'details': details,
      'location': location,
    });

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open calendar.')),
      );
    }
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

        String? imageUrl;
        final imageRaw = event['image'];
        if (imageRaw is Map<String, dynamic>) {
          imageUrl = imageRaw['url'] as String?;
        }

        final title   = parse(event['title']?.toString() ?? '').body?.text ?? '';
        final start   = event['start_date'] ?? '';
        final end     = event['end_date']   ?? '';
        final cost    = event['cost']        ?? '';
        final website = event['website'] as String? ?? '';
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
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => Share.share('Check out: $title\n$website'),
              ),
            ],
          ),

          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER IMAGE
                if (imageUrl != null)
                  Image.network(
                    imageUrl,
                    height: 220,
                    fit: BoxFit.cover,
                    loadingBuilder: (c, child, p) => p == null ? child : Container(height:220, color:Colors.grey.shade300),
                    errorBuilder: (c, e, s) => Container(height:220, color:Colors.grey.shade300),
                  )
                else
                  Container(height: 220, color: Colors.grey.shade300),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // ==== INFO BOX ====
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Info', style: Theme.of(context).textTheme.titleMedium),
                          const Divider(),

                          Row(children: [
                            const Icon(Icons.access_time, size: 18),
                            const SizedBox(width: 8),
                            Text('Time: $start – $end'),
                          ]),
                          if (cost.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(children: [
                              const Icon(Icons.euro, size: 18),
                              const SizedBox(width: 8),
                              Text('Cost: $cost'),
                            ]),
                          ],
                          if (website.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => launchUrl(Uri.parse(website)),
                              child: Row(children: [
                                const Icon(Icons.link, size: 18),
                                const SizedBox(width: 8),
                                Text('Visit Website', style: TextStyle(color: Theme.of(context).primaryColor)),
                              ]),
                            ),
                          ],
                        ]),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==== DESCRIPTION BOX ====
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Beschreibung', style: Theme.of(context).textTheme.titleMedium),
                          const Divider(),
                          Html(data: descriptionHtml),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==== VENUE BOX ====
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Veranstaltungsort', style: Theme.of(context).textTheme.titleMedium),
                          const Divider(),
                          if (event['venue'] is Map<String, dynamic>) ...[
                            Text(event['venue']['venue'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              [
                                event['venue']['address'],
                                event['venue']['zip'],
                                event['venue']['city']
                              ].whereType<String>().join(', '),
                            ),
                          ],
                        ]),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==== BUTTONS ====
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Add to Calendar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: () => _addToCalendar(event),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.event_available),
                        label: const Text('Join the Event'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: () => _showJoinDialog(title),
                      ),
                    ]),

                    const SizedBox(height: 24),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
