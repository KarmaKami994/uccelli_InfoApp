import 'dart:convert';
import 'package:http/http.dart' as http;

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
      return jsonDecode(response.body);
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
      return jsonDecode(response.body);
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
        return decodedResponse['events'];
      } else {
        return []; // Return an empty list if no events key found.
      }
    } else {
      print('Failed to load events: ${response.statusCode}');
      return [];
    }
  }

  /// Fetches detailed information for a specific event by [eventId].
  Future<Map<String, dynamic>?> fetchEventDetails(int eventId) async {
    final response = await http.get(Uri.parse('$tribeBaseUrl/events/$eventId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      print('Event not found: $eventId');
      return null;
    } else {
      print('Failed to load event details for ID $eventId: ${response.statusCode}');
      return null;
    }
  }
}
