import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/app_controller.dart';
import 'package:hilite/routes/routes.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:permission_handler/permission_handler.dart';

import '../controllers/user_controller.dart';
import '../widgets/snackbars.dart';



@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🌙 Background Message: ${message.messageId} | data: ${message.data}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Local notifications init
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannels();

    // iOS: show notifications while app is open (optional but recommended)
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _initPushNotifications();
  }

  Future<bool> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission from the user (iOS triggers a popup, Android 13+ triggers a popup)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false, // Set to true if you want silent notifications initially
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
      CustomSnackBar.success(message: "Notification permission granted");
      return true;
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('✅ User granted provisional permission');
      CustomSnackBar.success(message: "Notification permission granted");
      return true;
    } else {
      print('⚠️ User declined or has not accepted permission');
      return false;
    }
  }

  Future<void> _initPushNotifications() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('❌ Push Permission Denied');
      return;
    }

    print('✅ Push Permission Granted');

    // Get current token + sync
    await syncTokenToServer();

    // Token refresh (VERY IMPORTANT)
    _fcm.onTokenRefresh.listen((newToken) async {
      print("🔁 FCM Token refreshed: $newToken");
      await syncTokenToServer(tokenOverride: newToken);
    });

    // Foreground messages -> show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;

      if (notification != null && Platform.isAndroid) {
        showRemoteNotification(notification, message.data);
      }
    });

    // Click from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNavigation(message.data);
    });

    // Click from terminated
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNavigation(initialMessage.data);
    }
  }

  /// Call this after login too (and it’s safe to call multiple times)


  Future<void> syncTokenToServer({String? tokenOverride}) async {
    String? token = tokenOverride;

    try {
      if (token == null) {
        // ✅ 1. Wait for APNs token on iOS FIRST
        if (Platform.isIOS) {
          String? apnsToken = await _fcm.getAPNSToken();

          // Wait up to 3 seconds for the APNs token if it's not immediately available
          int retries = 0;
          while (apnsToken == null && retries < 3) {
            await Future.delayed(const Duration(seconds: 1));
            apnsToken = await _fcm.getAPNSToken();
            retries++;
          }

          if (apnsToken == null) {
            print("⚠️ APNs token not received. Cannot fetch FCM token.");
            return;
          }
        }

        // ✅ 2. Now it is safe to request the FCM token
        token = await _fcm.getToken();
      }

      if (token == null) return;

      // ✅ 3. Sync to backend
      final userController = Get.find<UserController>();
      await userController.saveDeviceToken();
      print("✅ Token synced to backend: $token");

    } catch (e) {
      print("⚠️ Could not sync token now: $e");
    }
  }


  Future<void> showRemoteNotification(
      RemoteNotification notification,
      Map<String, dynamic> payload,
      ) async {
    const androidDetails = AndroidNotificationDetails(
      'general_channel',
      'General Notifications',
      channelDescription: 'otoNav system alerts',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(payload),
    );
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
    >();

    const generalChannel = AndroidNotificationChannel(
      'general_channel',
      'General Notifications',
      description: 'otoNav system alerts',
      importance: Importance.max,
      playSound: true,
    );

    await androidPlugin?.createNotificationChannel(generalChannel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) return;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      // _handleNavigation(data);
    } catch (_) {
      // ignore
    }
  }

  void _handleNavigation(Map<String, dynamic> data) {
    // You decide your payload contract from backend.
    // Example:
    // { "type": "order", "orderId": "123", "status": "picked_up" }

    // final type = data['type'];
    //
    // if (type == 'order' && data['orderId'] != null) {
    //   Get.toNamed(AppRoutes.orderDetails, arguments: {
    //     "orderId": data['orderId'],
    //   });
    //   return;
    // }

    // fallback
    Get.offAllNamed(AppRoutes.splashScreen);
  }
}
