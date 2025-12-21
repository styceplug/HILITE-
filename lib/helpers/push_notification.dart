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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Setup Timezones (Your existing code)
    tzData.initializeTimeZones();

    // 2. Setup Local Notification Settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 3. Setup Channels (Added a "General" channel for social alerts)
    await _createNotificationChannels();

    // 4. Initialize Push Notifications (FCM)
    await _initPushNotifications();
  }

  /// 📡 Setup Firebase Cloud Messaging
  Future<void> _initPushNotifications() async {
    // A. Request Permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true, badge: true, sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Push Permission Granted');

      // B. Get Token & Sync with Server
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        // We use Get.find safely to call the logic we wrote earlier
        try {
          Get.find<UserController>().saveDeviceToken();
        } catch(e) {
          print("⚠️ UserController not ready yet, token will sync on login.");
        }
      }

      // C. Handle Background Messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // D. Handle Foreground Messages (App is OPEN)
      // Firebase doesn't show alerts when app is open, so we use Local Notifications to show them manually.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("☀️ Foreground Message: ${message.notification?.title}");
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          showRemoteNotification(notification, message.data);
        }
      });

      // E. Handle Notification Click (When App opens from background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("👆 Notification Clicked (Background): ${message.data}");
        _handleNavigation(message.data);
      });

    } else {
      print('❌ Push Permission Denied');
    }
  }

  /// 🔔 Helper to show FCM message as a Local Notification
  Future<void> showRemoteNotification(RemoteNotification notification, Map<String, dynamic> payload) async {
    const androidDetails = AndroidNotificationDetails(
      'general_channel', // Channel ID
      'General Notifications', // Channel Name
      channelDescription: 'Social interactions and system alerts',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color:  Color(0xFFFFFFFF), // AppColors.primary
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: payload.toString(), // Pass data payload to handler
    );
  }

  /// 🛠 Create Channels (Android requirement)
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    // 1. Your Live Room Channel
    const liveChannel = AndroidNotificationChannel(
      'live_room_channel', 'Live Room Notifications',
      description: 'Notifications for upcoming live room sessions',
      importance: Importance.high,
    );

    // 2. New General Channel (For Likes, Follows, etc.)
    const generalChannel = AndroidNotificationChannel(
      'general_channel', 'General Notifications',
      description: 'Social interactions and system alerts',
      importance: Importance.max,
      playSound: true,
    );

    await androidPlugin?.createNotificationChannel(liveChannel);
    await androidPlugin?.createNotificationChannel(generalChannel);
  }

  /// 👆 Handle Taps (Local & Foreground)
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      print('👆 Notification Tapped (Foreground): ${response.payload}');
      // TODO: Parse the payload string back to Map if needed
      // _handleNavigation(parsedData);
    }
  }

  /// 🧭 Central Navigation Handler
  void _handleNavigation(Map<String, dynamic> data) {
    // Navigate based on your API response structure
    // e.g., if (data['type'] == 'follow') Get.toNamed(AppRoutes.profile, arguments: data['userId']);

    if (data.containsKey('type')) {
      String type = data['type'];
      if(type == 'follow') {
        Get.offAllNamed(AppRoutes.homeScreen);
        AppController appController = Get.find<AppController>();
        appController.changeCurrentAppPage(2);
      } else if (type == 'comment') {
        // Navigate to post details
      }
    }
  }

  Future<void> cancelNotification(int id) async => _notifications.cancel(id);

  Future<void> cancelAllNotifications() async => _notifications.cancelAll();
}