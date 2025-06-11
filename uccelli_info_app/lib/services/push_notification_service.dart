// lib/services/push_notification_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// --- KORREKTUR 1: Callback-Funktionen auf die oberste Ebene verschoben ---
// Diese Funktionen sind jetzt "top-level" und können von Flutter aus dem Hintergrund
// sicher aufgerufen werden.

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Dieser Handler wird aufgerufen, wenn auf eine Benachrichtigung getippt wird,
  // während die App im Hintergrund oder beendet ist.
  debugPrint('🔔 [background_tap] Payload: ${notificationResponse.payload}');
  // TODO: Hier Logik für die Hintergrundbehandlung einfügen.
}

void notificationTapForeground(NotificationResponse notificationResponse) {
  // Dieser Handler wird aufgerufen, wenn auf eine Benachrichtigung getippt wird,
  // während die App im Vordergrund ist.
  debugPrint('🔔 [foreground_tap] Payload: ${notificationResponse.payload}');
  // TODO: Hier Logik für die Vordergrundbehandlung einfügen (z.B. Navigation).
}


class PushNotificationService {
  static final _local = FlutterLocalNotificationsPlugin();

  /// Diese Methode am App-Start aufrufen (vor dem Ende von runApp).
  static Future<void> init() async {
    // 1️⃣ Lokale Benachrichtigungen initialisieren
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      
      // --- KORREKTUR 2: Referenziert jetzt die Top-Level-Funktionen ---
      onDidReceiveNotificationResponse: notificationTapForeground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  /// Zeigt eine lokale Benachrichtigung an.
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload, // Optionaler Payload für die Handhabung von Taps
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'uccelli_channel',
      'Uccelli Notifications',
      channelDescription: 'Local notifications for Uccelli Society',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _local.show(
      id, // Eindeutige ID für die Benachrichtigung
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload, // Payload kann hier übergeben werden
    );
  }

  /// Optional: Methode zum Entfernen aller lokalen Benachrichtigungen
  static Future<void> cancelAllNotifications() async {
    await _local.cancelAll();
  }
}