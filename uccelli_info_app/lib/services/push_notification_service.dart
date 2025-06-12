// lib/services/push_notification_service.dart

import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  // Ersetzen Sie dies mit Ihrer echten OneSignal App ID aus dem Dashboard
  static const String _oneSignalAppId = '22e51939-e386-42ac-b5d8-c6b67f9982e8';

  /// Initialisiert OneSignal und registriert das Gerät.
  static Future<void> init() async {
    // Nur initialisieren, wenn wir auf einem echten Gerät laufen (nicht im Web)
    if (kIsWeb) return;

    // Setzt das Log-Level für OneSignal (nützlich für das Debugging)
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Initialisiert den OneSignal-Service
    OneSignal.initialize(_oneSignalAppId);

    // Fordert die Berechtigung vom Benutzer an, Benachrichtigungen zu senden (wichtig für iOS)
    // Dies zeigt dem Benutzer beim ersten Start einen Dialog an.
    OneSignal.Notifications.requestPermission(true);

    // Fügt einen Listener hinzu, um die Player ID zu erhalten, sobald sie verfügbar ist.
    OneSignal.User.pushSubscription.addObserver((state) {
      if (state.current.id != null) {
        debugPrint('OneSignal Player ID: ${state.current.id}');
        // Sende die neue Player ID an Supabase, sobald wir sie haben
        _sendPlayerIdToSupabase(state.current.id!);
      }
    });
  }

  /// Speichert die Player ID in der Supabase-Datenbank, um später Benachrichtigungen senden zu können.
  static Future<void> _sendPlayerIdToSupabase(String playerId) async {
    if (playerId.isEmpty) return;

    try {
      // 'upsert' versucht, einen neuen Eintrag zu erstellen.
      // Da die 'player_id'-Spalte UNIQUE ist, schlägt dies fehl, wenn die ID bereits
      // existiert, was genau das ist, was wir wollen (keine Duplikate).
      await Supabase.instance.client.from('player_ids').upsert(
        {'player_id': playerId},
        onConflict: 'player_id', // Diese Option sorgt dafür, dass bei einem Konflikt nichts passiert.
      );
      debugPrint('Player ID erfolgreich in Supabase gespeichert.');
    } catch (error) {
      // Fehler hier sind nicht kritisch für den App-Lauf, aber gut zu wissen.
      debugPrint('Fehler beim Speichern der Player ID in Supabase: $error');
    }
  }
}
