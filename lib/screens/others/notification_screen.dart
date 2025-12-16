import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/notification_controller.dart';
import '../../models/notification_model.dart';
import '../../routes/routes.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/empty_state_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Notifications',
        leadingIcon: BackButton(),
        actionIcon: InkWell(
          onTap: () {
            Get.find<NotificationController>().markAllAsRead();
          },
          child: Text(
            'Mark all as read',
            style: TextStyle(color: AppColors.black),
          ),
        ),
      ),
      body: GetBuilder<NotificationController>(
        init: NotificationController(notificationRepo: Get.find()),
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
            height: Dimensions.screenHeight,
            width: Dimensions.screenWidth,
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
            child: controller.notificationList.isEmpty
                ? Center(
              child: EmptyState(
                message: 'No notifications',
                imageAsset: 'no-alarm',
              ),
            )
                : RefreshIndicator(
              onRefresh: () async {
                await controller.getNotifications();
              },
              child: ListView.builder(
                itemCount: controller.notificationList.length,
                itemBuilder: (context, index) {
                  var notification =
                  controller.notificationList[index];
                  return itemCard(
                    notification: notification,
                    controller: controller,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
  Widget itemCard({
    required NotificationModel notification,
    required NotificationController controller,
  }) {
    Color typeColor = controller.getColorByType(notification.type);
    IconData typeIcon = controller.getIconByType(notification.type);
    bool isUnread = notification.isRead == false;

    return Container(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
      color:
      isUnread
          ? AppColors.primary.withOpacity(0.05)
          : Colors.transparent, // Highlight unread
      child: Row(
        children: [
          // Icon Circle
          Container(
            height: Dimensions.height10 * 6,
            width: Dimensions.width10 * 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: typeColor.withOpacity(0.8),
            ),
            child: Icon(
              typeIcon,
              color: AppColors.white,
              size: Dimensions.iconSize30,
            ),
          ),
          SizedBox(width: Dimensions.width10),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  notification.title ?? "Notification",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Dimensions.font18,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                Text(
                  notification.message ?? "",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: Dimensions.font14,
                    color: isUnread ? AppColors.black : AppColors.grey4,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Dimensions.width10),

          // Dot Indicator for Unread
          if (isUnread)
            Container(
              height: Dimensions.height10,
              width: Dimensions.width10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
