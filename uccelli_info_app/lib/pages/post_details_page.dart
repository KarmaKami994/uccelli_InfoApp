// lib/pages/post_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:html/parser.dart' show parse;

import '../providers/theme_provider.dart';
import '../widgets/custom_app_bar.dart';

class PostDetailsPage extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostDetailsPage({Key? key, required this.post}) : super(key: key);

  String _parseTitle() {
    return parse(post['title']?['rendered']?.toString() ?? '')
            .body
            ?.text ??
        'No title';
  }

  String _parseContent() {
    return post['content']?['rendered']?.toString() ?? '';
  }

  String _publishedDate() {
    final raw = post['date']?.toString() ?? '';
    if (raw.contains('T')) {
      return raw.split('T').first;
    }
    return raw;
  }

  /// Safely extract the featured image URL from the embedded media
  String? _featuredImageUrl() {
    final embedded = post['_embedded'] as Map<String, dynamic>?;
    final mediaList = embedded?['wp:featuredmedia'] as List<dynamic>?;

    if (mediaList != null && mediaList.isNotEmpty) {
      final firstMedia = mediaList[0];
      if (firstMedia is Map<String, dynamic>) {
        return firstMedia['source_url'] as String?;
      }
    }
    return null;
  }

  void _share(BuildContext context, String title, String link) {
    Share.share('$title\n$link');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final title = _parseTitle();
    final contentHtml = _parseContent();
    final date = _publishedDate();
    final imageUrl = _featuredImageUrl();
    final link = post['link']?.toString() ?? '';

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
                'Veröffentlicht am: $date',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),

              const SizedBox(height: 16),

              // HTML content
              Html(data: contentHtml),

              const SizedBox(height: 24),

              // Share button at bottom
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share this Post'),
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
