import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/utils/app_constants.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/empty_state_widget.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/notification_controller.dart';
import '../../../models/notification_model.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with AutomaticKeepAliveClientMixin<ActivitiesScreen> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Activities',
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
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: Dimensions.height150,
                      decoration: BoxDecoration(
                        color: AppColors.grey3,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius15,
                        ),
                      ),
                      child: Center(child: Text('Ads Placement')),
                    ),
                    SizedBox(height: Dimensions.height10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: Dimensions.height10,
                          width: Dimensions.width10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.grey4,
                          ),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Container(
                          height: Dimensions.height10,
                          width: Dimensions.width10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.grey4,
                          ),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Container(
                          height: Dimensions.height10,
                          width: Dimensions.width10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.grey4,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height20),
                    ItemCard(
                      icon: Iconsax.finger_cricle,
                      title: 'Notifications',
                      subtitle: 'Check last notifications here',
                      color: AppColors.error,
                      onTap: (){Get.toNamed(AppRoutes.notificationsScreen);}
                    ),
                    ItemCard(
                      icon: Icons.sports_soccer,
                      title: 'Trials',
                      subtitle: 'Check open trials here',
                      color: AppColors.warning,
                      onTap: (){Get.toNamed(AppRoutes.trialListScreen);}
                    ),
                    ItemCard(
                      icon: Icons.table_rows,
                      title: 'Competitions',
                      subtitle: 'Check open competitions here',
                      color: AppColors.success,
                      onTap: (){
                        Get.toNamed(AppRoutes.competitionsScreen);
                      }
                    ),
                  ],
                ),

                Positioned(
                  right: 0,
                  bottom: Dimensions.bottomNavIconHeight + Dimensions.height150,
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(AppRoutes.uploadContent);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width20,
                        vertical: Dimensions.height20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.plus, color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget ItemCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
        child: Row(
          children: [
            // Icon Circle
            Container(
              height: Dimensions.height10 * 6,
              width: Dimensions.width10 * 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.8),
              ),
              child: Icon(
                icon,
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
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Dimensions.font18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: Dimensions.font14,
                      color: AppColors.grey4,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
