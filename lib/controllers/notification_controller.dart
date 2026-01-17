import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repo/notification_repo.dart';
import '../models/notification_model.dart';
import '../utils/colors.dart';


class NotificationController extends GetxController {
  final NotificationRepo notificationRepo;

  NotificationController({required this.notificationRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<NotificationModel> _notificationList = [];
  List<NotificationModel> get notificationList => _notificationList;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  @override
  void onInit() {
    super.onInit();
    getNotifications();
  }

  /// Fetch Notifications
  Future<void> getNotifications() async {
    _isLoading = true;
    update();
    print('starting...');

    Response response = await notificationRepo.getNotifications();

    if (response.statusCode == 200) {
      // Parse the nested data object
      var data = NotificationResponse.fromJson(response.body['data']);
      _notificationList = data.notifications ?? [];
      _unreadCount = data.unreadCount ?? 0;
      print('Notification data : $data');
    } else {
      // Handle error
    }

    _isLoading = false;
    update();
  }

  /// Mark all as Read
  Future<void> markAllAsRead() async {
    Response response = await notificationRepo.markAllAsRead();
    if (response.statusCode == 200) {
      _unreadCount = 0;
      _notificationList = _notificationList.map((item) {
        return item.copyWith(isRead: true);
      }).toList();
      update();
      Get.snackbar("Success", "All notifications marked as read");
    }
  }

  /// Helper: Get Icon based on Type
  IconData getIconByType(String? type) {
    switch (type) {
      case 'follow':
        return Icons.person_add;
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  /// Helper: Get Color based on Type
  Color getColorByType(String? type) {
    switch (type) {
      case 'follow':
        return AppColors.primary;
      case 'like':
        return Colors.redAccent;
      case 'comment':
        return Colors.blueAccent;
      case 'system':
        return Colors.orangeAccent;
      default:
        return AppColors.grey4;
    }
  }
}