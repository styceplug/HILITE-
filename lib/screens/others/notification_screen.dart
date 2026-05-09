import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/notification_controller.dart';
import '../../models/notification_model.dart';
import '../../routes/routes.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../widgets/snackbars.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationController notificationController = Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationController.getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A1B), // Premium Dark Background
      appBar: CustomAppbar(
        backgroundColor: const Color(0xFF030A1B),
        centerTitle: false,
        customTitle: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Notifications',
            style: TextStyle(
              fontSize: Dimensions.font20,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        leadingIcon: const BackButton(color: Colors.white),
        actionIcon: GestureDetector(
          onTap: () {
            notificationController.markAllAsRead();
          },
          child: Container(
            margin: EdgeInsets.only(right: Dimensions.width10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      body: GetBuilder<NotificationController>(
        builder: (controller) {
          // Check if we are loading and the list is empty
          final bool isInitialLoad = controller.isLoading && controller.notificationList.isEmpty;

          return RefreshIndicator(
            color: AppColors.buttonColor,
            backgroundColor: const Color(0xFF1F2937),
            onRefresh: () async {
              await controller.getNotifications();
            },
            // --- TRUE SKELETONIZER MAGIC HAPPENS HERE ---
            child: Skeletonizer(
              enabled: isInitialLoad,
              child: isInitialLoad || controller.notificationList.isNotEmpty
                  ? ListView.separated(
                padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
                // If loading, show 7 dummy items. Otherwise, show real items.
                itemCount: isInitialLoad ? 7 : controller.notificationList.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.05),
                  indent: Dimensions.width20 * 3.5,
                ),
                itemBuilder: (context, index) {

                  if (isInitialLoad) {
                    // Pass dummy text to the REAL layout so Skeletonizer paints over it perfectly
                    return _buildNotificationLayout(
                      typeColor: Colors.grey,
                      typeIcon: Iconsax.notification, // Make sure you have Iconsax imported
                      isUnread: false,
                      title: 'Loading Notification Title',
                      message: 'This is a placeholder message to allow the skeletonizer to draw realistic text lines.',
                      onTap: null,
                    );
                  }

                  // Render Real Data
                  var notification = controller.notificationList[index];
                  return _buildNotificationTile(notification, controller);
                },
              )
                  : Stack(
                children: [
                  ListView(), // Allows Pull-to-refresh even when empty
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.notification, size: 70, color: Colors.white.withOpacity(0.1)),
                        SizedBox(height: Dimensions.height20),
                        const Text(
                          'No notifications yet',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: Dimensions.height10),
                        Text(
                          'You have no new alerts at this time.',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Extracts real data and passes it to the master layout
  Widget _buildNotificationTile(NotificationModel notification, NotificationController controller) {
    Color typeColor = controller.getColorByType(notification.type);
    IconData typeIcon = controller.getIconByType(notification.type);
    bool isUnread = notification.isRead == false;

    return _buildNotificationLayout(
      typeColor: typeColor,
      typeIcon: typeIcon,
      isUnread: isUnread,
      title: notification.title ?? "Notification",
      message: notification.message ?? "",
      onTap: () {
        notificationController.markSingleNotificationAsRead(notification.id);

        String? target = notification.userId;

        if (target != null && target.trim().isNotEmpty) {
          Get.toNamed(
            AppRoutes.othersProfileScreen,
            arguments: {'targetId': target.trim()},
          );
        } else {
          CustomSnackBar.showToast(message: 'Can not view profile at this time, try again later.');
        }
      },
    );
  }


  Widget _buildNotificationLayout({
    required Color typeColor,
    required IconData typeIcon,
    required bool isUnread,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.white.withOpacity(0.05),
      splashColor: Colors.white.withOpacity(0.1),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Dimensions.height15,
          horizontal: Dimensions.width20,
        ),
        decoration: BoxDecoration(
          color: isUnread ? Colors.white.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Circle
            Container(
              height: Dimensions.height10 * 5,
              width: Dimensions.width10 * 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: typeColor.withOpacity(0.15),
                border: Border.all(color: typeColor.withOpacity(0.3)),
              ),
              child: Icon(
                typeIcon,
                color: typeColor,
                size: Dimensions.iconSize24,
              ),
            ),
            SizedBox(width: Dimensions.width15),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.font16,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: Dimensions.height5),
                  Text(
                    message,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: Dimensions.font14,
                      color: isUnread ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.4),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: Dimensions.width10),

            // Dot Indicator for Unread
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(top: 6),
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.buttonColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.buttonColor.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}