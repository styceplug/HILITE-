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

  // Helper to make the dates look like "2h", "1d", "Just now"
  String _getTimeAgo(DateTime? date) {
    if (date == null) return '';

    try {
      DateTime localDate = date.toLocal();
      Duration diff = DateTime.now().difference(localDate);

      if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y';
      if (diff.inDays > 0) return '${diff.inDays}d';
      if (diff.inHours > 0) return '${diff.inHours}h';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m';

      return 'Just now';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A1B),
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
              fontWeight: FontWeight.w700, // Slightly bolder for a premium feel
              letterSpacing: 0.5,
            ),
          ),
        ),
        leadingIcon: const BackButton(color: Colors.white),
        actionIcon: GestureDetector(
          onTap: () => notificationController.markAllAsRead(),
          child: Container(
            margin: EdgeInsets.only(right: Dimensions.width10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1), // Brand tint
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      body: GetBuilder<NotificationController>(
        builder: (controller) {
          final bool isInitialLoad = controller.isLoading && controller.notificationList.isEmpty;

          return RefreshIndicator(
            color: Colors.blueAccent,
            backgroundColor: const Color(0xFF161E2E),
            onRefresh: () async {
              await controller.getNotifications();
            },
            child: Skeletonizer(
              enabled: isInitialLoad,
              // Customize the skeleton sweeping effect
              effect: ShimmerEffect(
                baseColor: Colors.white.withOpacity(0.05),
                highlightColor: Colors.white.withOpacity(0.1),
                duration: const Duration(seconds: 2),
              ),
              child: isInitialLoad || controller.notificationList.isNotEmpty
                  ? ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
                itemCount: isInitialLoad ? 8 : controller.notificationList.length,
                itemBuilder: (context, index) {
                  if (isInitialLoad) {
                    return _buildSkeletonTile();
                  }
                  var notification = controller.notificationList[index];
                  return _buildNotificationTile(notification, controller);
                },
              )
                  : _buildEmptyState(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Stack(
      children: [
        ListView(physics: const AlwaysScrollableScrollPhysics()), // Allows pull-to-refresh
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
                child: Icon(Iconsax.notification_bing, size: 60, color: Colors.white.withOpacity(0.2)),
              ),
              SizedBox(height: Dimensions.height20),
              const Text(
                'You\'re all caught up!',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                'No new notifications at this time.',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Specifically designed layout to look perfect when Skeletonizer paints over it
  Widget _buildSkeletonTile() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height10, horizontal: Dimensions.width20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Bone.circle(size: 48), // Explicit Skeletonizer bone
          SizedBox(width: Dimensions.width15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Bone.text(words: 3),
                SizedBox(height: Dimensions.height10),
                const Bone.text(words: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification, NotificationController controller) {
    Color typeColor = controller.getColorByType(notification.type);
    IconData typeIcon = controller.getIconByType(notification.type);
    bool isUnread = notification.isRead == false;
    String timeAgo = _getTimeAgo(notification.createdAt);

    return InkWell(
      onTap: () {
        notificationController.markSingleNotificationAsRead(notification.id);
        String? target = notification.url;

        if (target != null && target.trim().isNotEmpty) {
          Get.toNamed(
            AppRoutes.othersProfileScreen,
            arguments: {'targetId': target.trim()},
          );
        } else {
          CustomSnackBar.showToast(message: 'Profile unavailable at this time.');
        }
      },
      highlightColor: Colors.white.withOpacity(0.02),
      splashColor: Colors.white.withOpacity(0.05),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: Dimensions.width15, vertical: 6),
        padding: EdgeInsets.all(Dimensions.width15),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFF161E2E) : Colors.transparent, // Elevated card look for unread
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? Colors.white.withOpacity(0.08) : Colors.transparent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Circle
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: typeColor.withOpacity(0.15),
                border: Border.all(color: typeColor.withOpacity(0.3)),
              ),
              child: Icon(typeIcon, color: typeColor, size: 22),
            ),
            SizedBox(width: Dimensions.width15),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title ?? "Alert",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Dimensions.font16,
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (timeAgo.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: isUnread ? Colors.blueAccent : Colors.white.withOpacity(0.4),
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height5),
                  Text(
                    notification.message ?? "",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: Dimensions.font14,
                      color: isUnread ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.5),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Dot Indicator for Unread (Optional since we have the elevated background, but keeps it clear)
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(top: 6, left: 10),
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.5),
                      blurRadius: 8,
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