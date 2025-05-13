import 'dart:convert';
import 'package:http/http.dart' as http;
// Import für html_unescape
import 'package:html_unescape/html_unescape.dart'; // <-- Import hinzufügen


class WordPressService {
  // Base URL for The Events Calendar REST API endpoint.
  final String tribeBaseUrl = 'https://uccelli-society.ch/wp-json/tribe/events/v1';

  /// Fetches WordPress blog posts.
  /// Uses `_embed` to include media details.
  /// Accepts optional pagination parameters: [page] and [perPage].
  Future<List<dynamic>> fetchPosts({int page = 1, int perPage = 10}) async {
    final response = await http.get(
      Uri.parse('https://uccelli-society.ch/wp-json/wp/v2/posts?_embed&per_page=$perPage&page=$page'),
    );
    if (response.statusCode == 200) {
      // Optional: Auch in Posts Titel/Beschreibung unescape
      final List<dynamic> posts = jsonDecode(response.body);
      final unescape = HtmlUnescape();
      for (var post in posts) {
         if (post.containsKey('title') && post['title'] is Map && post['title'].containsKey('rendered') && post['title']['rendered'] is String) {
            post['title']['rendered'] = unescape.convert(post['title']['rendered']);
         }
         if (post.containsKey('excerpt') && post['excerpt'] is Map && post['excerpt'].containsKey('rendered') && post['excerpt']['rendered'] is String) {
             post['excerpt']['rendered'] = unescape.convert(post['excerpt']['rendered']);
         }
         if (post.containsKey('content') && post['content'] is Map && post['content'].containsKey('rendered') && post['content']['rendered'] is String) {
             post['content']['rendered'] = unescape.convert(post['content']['rendered']);
         }
      }
      return posts;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  /// Fetches an individual post by its [id].
  Future<Map<String, dynamic>> fetchPostById(String id) async {
    final response = await http.get(
      Uri.parse('https://uccelli-society.ch/wp-json/wp/v2/posts/$id?_embed'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> post = jsonDecode(response.body);
       // Optional: Auch hier Titel/Beschreibung unescape
      final unescape = HtmlUnescape();
      if (post.containsKey('title') && post['title'] is Map && post['title'].containsKey('rendered') && post['title']['rendered'] is String) {
         post['title']['rendered'] = unescape.convert(post['title']['rendered']);
      }
      if (post.containsKey('excerpt') && post['excerpt'] is Map && post['excerpt'].containsKey('rendered') && post['excerpt']['rendered'] is String) {
          post['excerpt']['rendered'] = unescape.convert(post['excerpt']['rendered']);
      }
      if (post.containsKey('content') && post['content'] is Map && post['content'].containsKey('rendered') && post['content']['rendered'] is String) {
          post['content']['rendered'] = unescape.convert(post['content']['rendered']);
      }
      return post;
    } else {
      throw Exception("Failed to load post with ID: $id");
    }
  }

  /// Fetches upcoming events from The Events Calendar.
  Future<List<dynamic>> fetchEvents() async {
    final response = await http.get(Uri.parse('$tribeBaseUrl/events'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      if (decodedResponse.containsKey('events')) {
        List<dynamic> events = decodedResponse['events'];
        // Unescape HTML entities in der Beschreibung und im Titel für jedes Event
        final unescape = HtmlUnescape(); // Instanz erstellen
        for (var event in events) {
          // Annahme: Beschreibung ist im Feld 'description' und ist ein String
          if (event.containsKey('description') && event['description'] is String) {
            event['description'] = unescape.convert(event['description']);
          }
          // Annahme: Titel ist im Feld 'title' und ist ein String
          if (event.containsKey('title') && event['title'] is String) {
             event['title'] = unescape.convert(event['title']);
          }
        }
        return events;
      } else {
        return []; // Leere Liste zurückgeben, wenn kein Events-Schlüssel gefunden wird.
      }
    } else {
      print('Failed to load events: ${response.statusCode}');
      return []; // Leere Liste bei Fehler zurückgeben
    }
  }

  /// Fetches detailed information for a specific event by [eventId].
  Future<Map<String, dynamic>?> fetchEventDetails(int eventId) async {
    final response = await http.get(Uri.parse('$tribeBaseUrl/events/$eventId'));
    if (response.statusCode == 200) {
      Map<String, dynamic> eventDetails = jsonDecode(response.body);
      // Unescape HTML entities in der Beschreibung und im Titel
      final unescape = HtmlUnescape();
      // Annahme: Beschreibung ist im Feld 'description' und ist ein String
      if (eventDetails.containsKey('description') && eventDetails['description'] is String) {
        eventDetails['description'] = unescape.convert(eventDetails['description']);
      }
      // Annahme: Titel ist im Feld 'title' und ist ein String
      if (eventDetails.containsKey('title') && eventDetails['title'] is String) {
         eventDetails['title'] = unescape.convert(eventDetails['title']);
      }
      return eventDetails;
    } else if (response.statusCode == 404) {
      print('Event not found: $eventId');
      return null;
    } else {
      print('Failed to load event details for ID $eventId: ${response.statusCode}');
      return null;
    }
  }
}