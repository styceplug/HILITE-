import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/post_controller.dart';
import 'package:hilite/widgets/upload_progress_pill.dart';

import '../../controllers/app_controller.dart';
import '../../utils/dimensions.dart';
import '../../widgets/home_screen_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppController appController = Get.find<AppController>();
  PostController postController = Get.find<PostController>();


  DateTime? lastPressed;

  RxInt previousPage = 0.obs;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final now = DateTime.now();
        const maxDuration = Duration(seconds: 2);

        if(appController.currentAppPage.value != 0){
          appController.changeCurrentAppPage(0);
          appController.pageController.jumpToPage(0);
          return;
        }

        if(lastPressed == null || now.difference(lastPressed!) > maxDuration){
          lastPressed = now;

          Fluttertoast.showToast(msg: "Press again to exit",
          toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);

          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        body: GetBuilder<AppController>(
          builder: (appController) {
            return SizedBox(
              height: Dimensions.screenHeight,
              width: double.maxFinite,
              child: Stack(
                children: [
                  SizedBox(
                    height: Dimensions.screenHeight,
                    width: double.maxFinite,
                  ),
                  PageView.builder(
                    controller: appController.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appController.pages.length,
                    itemBuilder: (context, index) => appController.pages[index],
                    onPageChanged: (index) {
                      if (appController.currentAppPage.value != index) {
                        appController.changeCurrentAppPage(
                          index,
                          movePage: false,
                        );
                      }
                      if (index !=0) {
                        unawaited(postController.deactivatePlayback());
                      } else {
                        postController.activatePlayback();
                      }
                    },
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: HomeScreenBottomNavBar(),
                  ),
                  UploadProgressPill(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
