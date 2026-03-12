import 'package:get/get.dart';

import '../../utils/app_constants.dart';
import '../api/api_client.dart';


class NotificationRepo extends GetxService {
  final ApiClient apiClient;

  NotificationRepo({required this.apiClient});

  Future<Response> getNotifications() async {
    return await apiClient.getData(AppConstants.GET_NOTIFICATIONS);
  }

  Future<Response> markAllAsRead() async {
    return await apiClient.putData(AppConstants.MARK_NOTIFICATIONS_AS_READ, {});
  }

  Future<Response> markSingleNotificationAsRead(String notificationId) async {
    return await apiClient.putData(AppConstants.MARK_SINGLE_NOTIFICATION_AS_READ(notificationId), {});
  }
}