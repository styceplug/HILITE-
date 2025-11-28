import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../utils/dimensions.dart';
import 'bottom_bar_item.dart';

class HomeScreenBottomNavBar extends StatelessWidget {
  const HomeScreenBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    AppController appController = Get.find<AppController>();

    return Obx(
      () => ClipRect(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            // borderRadius: BorderRadius.circular(Dimensions.radius30),
          ),
          padding: EdgeInsets.only(
            bottom: Dimensions.height40,
            left: Dimensions.width15,
            right: Dimensions.width15,
            top: Dimensions.height15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              BottomBarItem(
                name: 'Reels',
                image: 'nav2',
                isActive: appController.currentAppPage.value == 0,
                onClick: () {
                  appController.changeCurrentAppPage(0);
                },
              ),
              BottomBarItem(
                name: 'Activities',
                image: 'nav3',
                isActive: appController.currentAppPage.value == 1,
                onClick: () {
                  appController.changeCurrentAppPage(1);
                },
              ),
              BottomBarItem(
                name: 'Profile',
                image: 'nav4',
                isActive: appController.currentAppPage.value == 2,
                onClick: () {
                  appController.changeCurrentAppPage(2);
                },

              ),
            ],
          ),
        ),
      ),
    );
  }
}
