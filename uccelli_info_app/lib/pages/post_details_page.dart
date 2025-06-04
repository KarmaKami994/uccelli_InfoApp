// lib/pages/post_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:html/parser.dart' as html_parser; // Beibehalten für Textbereinigung bei Bedarf

// >>> Importiere generierten Lokalisierungs-Code <<<
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// <<< Ende Import >>>

import '../providers/theme_provider.dart';
import '../widgets/custom_app_bar.dart';

class PostDetailsPage extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostDetailsPage({Key? key, required this.post}) : super(key: key);

  // Hilfsfunktion zur Auswahl des Titels basierend auf der Sprache
  String _getDisplayedTitle(BuildContext context) {
    final currentLanguageCode = Localizations.localeOf(context).languageCode;
    final String originalTitle = post['title']?.toString() ?? 'No title';
    final String? translatedTitle = post['title_en']?.toString();

    if (currentLanguageCode == 'en' && translatedTitle != null && translatedTitle.isNotEmpty) {
      return translatedTitle;
    }
    return originalTitle;
  }

  // Hilfsfunktion zur Auswahl des Inhalts basierend auf der Sprache
  String _getDisplayedContent(BuildContext context) {
    final currentLanguageCode = Localizations.localeOf(context).languageCode;
    final String originalContent = post['content']?.toString() ?? '';
    final String? translatedContent = post['content_en']?.toString();

    if (currentLanguageCode == 'en' && translatedContent != null && translatedContent.isNotEmpty) {
      return translatedContent;
    }
    return originalContent;
  }

  String _publishedDate() {
    final raw = post['date']?.toString() ?? '';
    if (raw.contains('T')) {
      return raw.split('T').first;
    }
    return raw;
  }

  /// Safely extract the featured image URL from the Supabase data
  String? _featuredImageUrl() {
    // In Supabase sollte die URL direkt im Feld 'featured_media_url' sein
    return post['featured_media_url'] as String?;
  }

  void _share(BuildContext context, String title, String link) {
    Share.share('$title\n$link');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context)!; // Lokalisierung hinzufügen

    final title = _getDisplayedTitle(context); // Verwende die neue Hilfsfunktion
    final contentHtml = _getDisplayedContent(context); // Verwende die neue Hilfsfunktion
    final date = _publishedDate();
    final imageUrl = _featuredImageUrl();
    final link = post['link']?.toString() ?? '';

    return Scaffold(
      appBar: customAppBar(
        context,
        title: title, // App Bar Titel ist der ausgewählte Titel
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _share(context, title, link),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Header image with graceful fallback
          if (imageUrl != null)
            Image.network(
              imageUrl,
              height: 220,
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Container(height: 220, color: Colors.grey.shade300);
              },
              errorBuilder: (ctx, error, stack) => Container(height: 220, color: Colors.grey.shade300),
            )
          else
            Container(height: 220, color: Colors.grey.shade300),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Published date
              Text(
                '${l10n.publishedOnPrefix} $date', // Lokalisierung hinzufügen
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),

              const SizedBox(height: 16),

              // HTML content
              Html(data: contentHtml), // Render the selected content

              const SizedBox(height: 24),

              // Share button at bottom
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: Text(l10n.sharePostButtonLabel), // Lokalisierung hinzufügen
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () => _share(context, title, link),
                ),
              ),

              const SizedBox(height: 24),
            ]),
          ),
        ]),
      ),
    );
  }
}
