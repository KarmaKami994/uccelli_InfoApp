// lib/services/content_service.dart

import 'package:flutter/foundation.dart'; // Für debugPrint
import 'package:supabase_flutter/supabase_flutter.dart'; // NEU: Supabase Import

// Der html_unescape Import wird nicht mehr benötigt, da die Daten in Supabase
// bereits unescaped oder direkt als HTML-String gespeichert sein sollten.
// import 'package:html_unescape/html_unescape.dart'; // ENTFERNT

class ContentService {
  // Supabase Client Instanz
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches posts from Supabase.
  /// Accepts optional pagination parameters: [page] and [perPage].
  Future<List<Map<String, dynamic>>> fetchPosts({int page = 1, int perPage = 10}) async {
    try {
      // Berechne den Offset für die Pagination
      final int offset = (page - 1) * perPage;

      // Daten von der 'posts'-Tabelle abrufen
      // Wähle alle Spalten aus und sortiere nach Datum absteigend
      final List<Map<String, dynamic>> response = await _supabase
          .from('posts')
          .select('*') // Wähle alle Spalten aus, einschliesslich der übersetzten
          .order('date', ascending: false) // Sortiere nach Datum (neueste zuerst)
          .range(offset, offset + perPage - 1); // Pagination

      // Die Daten enthalten jetzt direkt die benötigten Felder, einschliesslich der übersetzten.
      // Kein HTML unescaping hier, da es entweder bereits im Backend passiert ist oder
      // in der UI gehandhabt werden muss, wenn HTML-Tags in den Strings enthalten sind.
      return response;
    } catch (e) {
      debugPrint('Error fetching posts from Supabase: $e');
      throw Exception('Failed to load posts from Supabase');
    }
  }

  /// Fetches an individual post by its [id] from Supabase.
  Future<Map<String, dynamic>?> fetchPostById(int id) async { // ID ist jetzt int, nicht String
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from('posts')
          .select('*')
          .eq('id', id) // Filter nach ID
          .limit(1); // Nur einen Datensatz erwarten

      if (response.isNotEmpty) {
        return response.first;
      } else {
        return null; // Post nicht gefunden
      }
    } catch (e) {
      debugPrint('Error fetching post by ID $id from Supabase: $e');
      throw Exception('Failed to load post with ID: $id from Supabase');
    }
  }

  /// Fetches upcoming events from Supabase.
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    try {
      // Daten von der 'events'-Tabelle abrufen
      // Sortiere nach Startdatum aufsteigend (kommende Events zuerst)
      final List<Map<String, dynamic>> response = await _supabase
          .from('events')
          .select('*') // Wähle alle Spalten aus, einschliesslich der übersetzten
          .order('start_date', ascending: true); // Sortiere nach Startdatum

      // Kein HTML unescaping hier
      return response;
    } catch (e) {
      debugPrint('Error fetching events from Supabase: $e');
      throw Exception('Failed to load events from Supabase');
    }
  }

  /// Fetches detailed information for a specific event by [eventId] from Supabase.
  Future<Map<String, dynamic>?> fetchEventDetails(int eventId) async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from('events')
          .select('*')
          .eq('id', eventId) // Filter nach ID
          .limit(1); // Nur einen Datensatz erwarten

      if (response.isNotEmpty) {
        return response.first;
      } else {
        return null; // Event nicht gefunden
      }
    } catch (e) {
      debugPrint('Error fetching event details for ID $eventId from Supabase: $e');
      throw Exception('Failed to load event details for ID $eventId from Supabase');
    }
  }
}
