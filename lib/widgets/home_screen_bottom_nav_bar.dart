import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../utils/app_constants.dart';
import '../utils/dimensions.dart';
import 'bottom_bar_item.dart';

class HomeScreenBottomNavBar extends StatelessWidget {
  const HomeScreenBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    AppController appController = Get.find<AppController>();

    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Obx(
      () => ClipRect(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            // borderRadius: BorderRadius.circular(Dimensions.radius30),
          ),
          padding: EdgeInsets.only(
            bottom: bottomPadding,
            left: Dimensions.width15,
            right: Dimensions.width15,
            top: Dimensions.height15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BottomBarItem(
                name: 'Home',
                image: 'home',
                isActive: appController.currentAppPage.value == 0,
                onClick: () {
                  appController.changeCurrentAppPage(0);
                },
              ),
              BottomBarItem(
                name: 'Activities',
                image: 'activities',
                isActive: appController.currentAppPage.value == 1,
                onClick: () {
                  appController.changeCurrentAppPage(1);
                },
              ),

              InkWell(
                onTap: ()async{
                  appController.currentAppPage.value == 2;
                  appController.changeCurrentAppPage(2);
                },
                child: Image.asset(
                  AppConstants.getPngAsset('add'),
                  height: Dimensions.height10*8,
                  width: Dimensions.width10*8,
                ),
              ),
              BottomBarItem(
                name: 'Messages',
                image: 'messages',
                isActive: appController.currentAppPage.value == 3,
                onClick: () {
                  appController.changeCurrentAppPage(3);
                },
              ),
              BottomBarItem(
                name: 'Profile',
                image: 'profile',
                isActive: appController.currentAppPage.value == 4,
                onClick: () {
                  appController.changeCurrentAppPage(4);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
