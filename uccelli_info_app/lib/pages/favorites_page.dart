import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../services/wordpress_service.dart';
import '../widgets/custom_app_bar.dart';
import 'post_details_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final wp = WordPressService();
  late Future<List<Map<String, dynamic>>> _future;

  Future<List<Map<String, dynamic>>> _loadFavs() async {
    final ids = Provider.of<FavoritesProvider>(context, listen: false)
        .favoriteIds
        .toList();
    return Future.wait(ids.map((id) => wp.fetchPostById(id)));
  }

  @override
  void initState() {
    super.initState();
    _future = _loadFavs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, title: 'Favorites'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final posts = snap.data!;
          if (posts.isEmpty) {
            return const Center(child: Text('No favorites yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: posts.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, i) {
              final post = posts[i];
              final title = post['title']['rendered'] as String? ?? '';
              final id = post['id'].toString();
              return ListTile(
                title: Text(title),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {
                    Provider.of<FavoritesProvider>(context, listen: false)
                        .toggleFavorite(id);
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
