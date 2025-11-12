/*
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fyndr/controllers/auth_controller.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../routes/routes.dart';
import '../utils/app_constants.dart';

import 'dart:convert';


@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  print("🔔 Background notification clicked: ${response.payload}");
}

class FirebaseMessagingHelper {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Call this from `main.dart`
  static Future<void> initializeFCM() async {
    await _requestPermissions();
    await _setupLocalNotifications();
    await _syncDeviceToken();
    _setupListeners();
  }

  static Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('🔔 Notification permission: ${settings.authorizationStatus}');
  }

  static Future<void> _syncDeviceToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token == null) return;

      final auth = Get.find<AuthController>();
      final isMerchant = auth.sharedPreferences.getBool(AppConstants.isMerchant) ?? false;
      final platform = Platform.isIOS ? 'ios' : 'android';
      final newToken = DeviceToken(token: token, platform: platform);

      if (isMerchant && auth.currentMerchant.value != null) {
        final merchant = auth.currentMerchant.value!;
        final updatedTokens = _mergeTokens(merchant.deviceTokens, newToken);
        auth.currentMerchant.value = merchant.copyWith(deviceTokens: updatedTokens);
        print('✅ Synced token for merchant: $token');
      } else if (auth.currentUser.value != null) {
        final user = auth.currentUser.value!;
        final updatedTokens = _mergeTokens(user.deviceTokens, newToken);
        auth.currentUser.value = user.copyWith(deviceTokens: updatedTokens);
        print('✅ Synced token for user: $token');
      }
    } catch (e) {
      print('❌ Error syncing token: $e');
    }
  }

  static List<DeviceToken> _mergeTokens(List<DeviceToken>? existing, DeviceToken newToken) {
    final tokens = List<DeviceToken>.from(existing ?? []);
    tokens.removeWhere((t) => t.token == newToken.token);
    tokens.add(newToken);
    return tokens;
  }

  static Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications',
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        print('🔔 Foreground notification tapped: ${response.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );
  }

  static void _setupListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('📩 FCM received (foreground): ${message.notification?.title}');
      await _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📦 App opened from notification: ${message.notification?.title}');
      // Optional: navigate using message.data
      Get.toNamed(AppRoutes.notificationScreen);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('🟡 App launched from terminated state via notification');
        // Optional: handle deep links here
      }
    });
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final String? imageUrl = message.notification?.android?.imageUrl ?? message.notification?.apple?.imageUrl;

    BigPictureStyleInformation? style;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      style = BigPictureStyleInformation(
        FilePathAndroidBitmap(imageUrl),
        largeIcon: FilePathAndroidBitmap(imageUrl),
        contentTitle: notification?.title,
        summaryText: notification?.body,
      );
    }

    final androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      icon: '@mipmap/ic_launcher',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: style,
    );

    final iosDetails = DarwinNotificationDetails(
      attachments: imageUrl != null ? [DarwinNotificationAttachment(imageUrl)] : [],
    );

    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification?.title,
      notification?.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("📨 [BG] Title: ${message.notification?.title}");
    print("📨 [BG] Body: ${message.notification?.body}");
    print("📨 [BG] Data: ${message.data}");
  }
}*/

import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:permission_handler/permission_handler.dart';

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