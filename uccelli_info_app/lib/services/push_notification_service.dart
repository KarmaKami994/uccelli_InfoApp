import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  static final _fcm = FirebaseMessaging.instance;
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
    );

    // 2️⃣ Request FCM permissions
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 3️⃣ Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // 4️⃣ (Optional) Handle taps on notifications when app is backgrounded
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      // You can navigate based on msg.data here
    });
  }

  /// Display a local notification for an incoming FCM message.
  static Future<void> _showLocalNotification(RemoteMessage msg) async {
    final notif = msg.notification;
    if (notif == null) return;

    const androidDetails = AndroidNotificationDetails(
      'uccelli_channel',
      'Uccelli Notifications',
      channelDescription: 'Push notifications for Uccelli Society',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _local.show(
      notif.hashCode,
      notif.title,
      notif.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
