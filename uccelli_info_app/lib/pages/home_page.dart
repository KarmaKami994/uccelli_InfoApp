// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:html/parser.dart' as html_parser;

import '../providers/theme_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/wordpress_service.dart';
import '../widgets/custom_app_bar.dart';
import 'event_details_page.dart';
import 'post_details_page.dart';
import 'favorites_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WordPressService wpService = WordPressService();
  late Future<List<dynamic>> postsFuture;
  late Future<List<dynamic>> eventsFuture;

  String postsSearchQuery = '';
  String eventsSearchQuery = '';

  @override
  void initState() {
    super.initState();
    postsFuture = wpService.fetchPosts();
    eventsFuture = wpService.fetchEvents();
  }

  Future<void> _refreshPosts() async {
    setState(() => postsFuture = wpService.fetchPosts());
  }

  Future<void> _refreshEvents() async {
    setState(() => eventsFuture = wpService.fetchEvents());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    const cardMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: customAppBar(
          context,
          title: 'Uccelli Society',
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Latest Posts'),
              Tab(text: 'Upcoming Events'),
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
            // Latest Posts Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Posts',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => postsSearchQuery = v.toLowerCase()),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshPosts,
                    child: FutureBuilder<List<dynamic>>(
                      future: postsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error loading posts: ${snapshot.error}'));
                        }

                        final filtered = snapshot.data!
                            .where((post) {
                              final title = post['title']['rendered']
                                  .toString()
                                  .toLowerCase();
                              return title.contains(postsSearchQuery);
                            })
                            .toList();

                        if (filtered.isEmpty) {
                          return const Center(child: Text('No posts found.'));
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final post = filtered[index];
                            final title = post['title']['rendered'] as String;
                            final id = post['id'].toString();
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
                                  title: Text(title),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isFav ? Icons.favorite : Icons.favorite_border,
                                          color: isFav ? Colors.red : Colors.grey,
                                        ),
                                        onPressed: () => favoritesProvider.toggleFavorite(id),
                                      ),
                                      const Icon(Icons.chevron_right),
                                    ],
                                  ),
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

            // Upcoming Events Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Events',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => eventsSearchQuery = v.toLowerCase()),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshEvents,
                    child: FutureBuilder<List<dynamic>>(
                      future: eventsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error loading events: ${snapshot.error}'));
                        }

                        final filtered = snapshot.data!
                            .where((event) {
                              final title = html_parser
                                  .parse(event['title'].toString())
                                  .documentElement
                                  ?.text
                                  .toLowerCase() ?? '';
                              return title.contains(eventsSearchQuery);
                            })
                            .toList();

                        if (filtered.isEmpty) {
                          return const Center(child: Text('No events found.'));
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final event = filtered[index];
                            final title = html_parser.parse(event['title'].toString()).documentElement?.text ?? '';
                            final startDate = event['start_date'];

                            return FadeIn(
                              duration: const Duration(milliseconds: 500),
                              delay: Duration(milliseconds: index * 100),
                              child: Card(
                                margin: cardMargin,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  title: Text(title),
                                  subtitle: Text('Starts: $startDate'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EventDetailsPage(
                                        eventId: event['id'],
                                        eventFuture: wpService.fetchEventDetails(event['id']),
                                      ),
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
