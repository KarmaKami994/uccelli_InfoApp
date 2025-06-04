// lib/services/push_notification_service.dart

import 'package:flutter/foundation.dart'; // ← for debugPrint
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  // static final _fcm = FirebaseMessaging.instance; // ENTFERNT: FirebaseMessaging Instanz
  static final _local = FlutterLocalNotificationsPlugin();

  /// Call this at app startup (before runApp finishes).
  static Future<void> init() async {
    // 1️⃣ Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings     = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      // Optional: onDidReceiveNotificationResponse, onDidReceiveBackgroundNotificationResponse
      // für die Handhabung von Taps auf Benachrichtigungen, wenn die App im Vorder- oder Hintergrund ist.
      // Für lokale Benachrichtigungen ist dies der Ort, um auf Taps zu reagieren.
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint('🔔 [local_notification_tap] Payload: ${response.payload}');
        // TODO: Hier kannst du Logik hinzufügen, um auf den Tap einer lokalen Benachrichtigung zu reagieren.
        // Zum Beispiel: Navigation zu einem bestimmten Screen basierend auf response.payload.
      },
      onDidReceiveBackgroundNotificationResponse: (NotificationResponse response) async {
        debugPrint('🔔 [local_notification_background_tap] Payload: ${response.payload}');
        // TODO: Logik für Taps auf Benachrichtigungen, wenn die App im Hintergrund ist (aber nicht beendet).
      },
    );

    // 2️⃣ Keine FCM-Berechtigungsanfrage mehr
    // await _fcm.requestPermission(alert: true, badge: true, sound: true); // ENTFERNT

    // 3️⃣ Keine FCM-Nachrichten-Listener mehr
    // FirebaseMessaging.onMessage.listen(_showLocalNotification); // ENTFERNT

    // 4️⃣ Keine Handhabung von Taps auf FCM-Benachrichtigungen mehr
    // FirebaseMessaging.onMessageOpenedApp.listen((msg) { ... }); // ENTFERNT

    // 5️⃣ Keine Handhabung von initialen FCM-Nachrichten mehr
    // final initialMessage = await FirebaseMessaging.instance.getInitialMessage(); // ENTFERNT
  }

  /// Display a local notification.
  /// This method is now generic and does not depend on RemoteMessage.
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
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload, // Payload kann hier übergeben werden
    );
  }

  // Optional: Methode zum Entfernen aller lokalen Benachrichtigungen
  static Future<void> cancelAllNotifications() async {
    await _local.cancelAll();
  }
}
