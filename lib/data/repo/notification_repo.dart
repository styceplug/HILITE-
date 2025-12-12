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
}