import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../services/content_service.dart'; // Umbenannt von wordpress_service.dart
import '../widgets/custom_app_bar.dart';
import 'post_details_page.dart';

// >>> Importiere generierten Lokalisierungs-Code <<<
import 'package:uccelli_info_app/gen_l10n/app_localizations.dart';
// <<< Ende Import >>>

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final ContentService contentService = ContentService(); // Klassennamen-Anpassung
  late Future<List<Map<String, dynamic>>> _future;

  Future<List<Map<String, dynamic>>> _loadFavs() async {
    final ids = Provider.of<FavoritesProvider>(context, listen: false)
        .favoriteIds
        .toList();

    // Rufe jeden Post einzeln ab und filtere null-Ergebnisse heraus.
    // Konvertiere die ID von String zu int.
    final List<Map<String, dynamic>?> fetchedPosts = await Future.wait(
      ids.map((id) => contentService.fetchPostById(int.parse(id))), // ID zu int parsen
    );

    // Filtere alle null-Werte heraus, falls fetchPostById null zurückgibt (z.B. Post nicht gefunden)
    return fetchedPosts.whereType<Map<String, dynamic>>().toList();
  }

  @override
  void initState() {
    super.initState();
    _future = _loadFavs();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Lokalisierung hinzufügen
    final currentLanguageCode = Localizations.localeOf(context).languageCode; // Aktuellen Sprachcode abrufen

    return Scaffold(
      appBar: customAppBar(context, title: l10n.favoritesPageTitle), // Titel lokalisieren
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('${l10n.errorLoadingFavorites} ${snap.error}')); // Fehlertext lokalisieren
          }
          final posts = snap.data!;
          if (posts.isEmpty) {
            return Center(child: Text(l10n.noFavoritesYet)); // Text lokalisieren
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: posts.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, i) {
              final post = posts[i];
              
              // Logik zur Auswahl des Titels basierend auf der Sprache
              final String displayedTitle = 
                  (currentLanguageCode == 'en' && post.containsKey('title_en') && post['title_en'] != null)
                  ? post['title_en'] as String
                  : post['title'] as String;

              final id = post['id'].toString(); // ID bleibt String für FavoritesProvider
              return ListTile(
                title: Text(displayedTitle), // Verwende den ausgewählten Titel
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {
                    Provider.of<FavoritesProvider>(context, listen: false)
                        .toggleFavorite(id);
                    // Nach dem Entfernen/Hinzufügen eines Favoriten die Liste neu laden
                    setState(() => _future = _loadFavs());
                  },
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PostDetailsPage(post: post)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
