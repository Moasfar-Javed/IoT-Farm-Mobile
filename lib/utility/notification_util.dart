import 'dart:convert';

import 'package:farm/styles/color_style.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationUtils {
  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'farm', 'farm_01',
      importance: Importance.max, playSound: true);

  static FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> showNotification(Map<String, dynamic> payload) async {
    await plugin.show(
        1,
        payload['title'],
        payload['message'],
        NotificationDetails(
          iOS: const DarwinNotificationDetails(
            presentSound: true,
            presentBadge: true,
            presentAlert: true,
          ),
          android: AndroidNotificationDetails(channel.id, channel.name,
              color: ColorStyle.primaryColor,
              playSound: true,
              priority: Priority.max,
              styleInformation: BigTextStyleInformation(payload['tile'] ?? ""),
              icon: '@drawable/ic_notification'),
        ),
        payload: json.encode(payload));
  }

  static void initializeFirebase() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await plugin.initialize(initializationSettings);

    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> handleInitialMessage(RemoteMessage? message) async {
    if (message != null) {
      Map<String, dynamic> notificationData = message.data;
      _performNotificationTap(
          notificationData["action"], notificationData["id"].toString());
    }
  }


  static Future<void> notificationHandler(String? payload) async {
    if (payload != null) {
      Map<String, dynamic> data = json.decode(payload);
      _performNotificationTap(data["action"].toString(), data["id"].toString());
    }
  }

  static void _performNotificationTap(String action, String id) {
    // Handle notification tap
  }
}
