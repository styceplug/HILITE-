import 'dart:io';
import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/app_controller.dart';
import 'package:hilite/routes/routes.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:permission_handler/permission_handler.dart';

import '../controllers/user_controller.dart';



@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🌙 Background Message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tzData.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // ✅ Pre-create channel so Android doesn’t block notifications silently
    const androidChannel = AndroidNotificationChannel(
      'live_room_channel',
      'Live Room Notifications',
      description: 'Notifications for upcoming live room sessions',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      print('Notification tapped with payload: ${response.payload}');
      // Handle navigation here if needed
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImpl =
      _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        final granted = await androidImpl.requestNotificationsPermission();
        await Permission.scheduleExactAlarm.request();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final iosImpl =
      _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await iosImpl?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return false;
  }

  Future<void> scheduleRoomNotification({
    required int id,
    required String title,
    required String hostName,
    required String sessionType,
    required DateTime scheduledDateTime,
  }) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) throw Exception('Notification permissions not granted');

    final now = DateTime.now();
    final notificationTime = scheduledDateTime.subtract(const Duration(minutes: 5));

    // ✅ Fix: Don’t throw for close times — just trigger instantly if needed
    final targetTime = notificationTime.isBefore(now) ? now.add(const Duration(seconds: 5)) : notificationTime;

    const androidDetails = AndroidNotificationDetails(
      'live_room_channel',
      'Live Room Notifications',
      channelDescription: 'Notifications for upcoming live room sessions',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Live Room Starting Soon',
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.zonedSchedule(
      id,
      '$sessionType Live Room Starting Soon! 🎙️',
      '$hostName is hosting "$title" — Join in 5 minutes!',
      tz.TZDateTime.from(targetTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'live_room_$id',
      matchDateTimeComponents: DateTimeComponents.time, // optional, can remove if not repeating
    );

    print('✅ Notification scheduled for $targetTime');
  }

  Future<void> cancelNotification(int id) async => _notifications.cancel(id);

  Future<void> cancelAllNotifications() async => _notifications.cancelAll();
}
