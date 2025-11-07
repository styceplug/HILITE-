import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

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


  DateTime? lastPressed;

  RxInt previousPage = 0.obs;

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    const maxDuration = Duration(seconds: 2);

    if (appController.currentAppPage.value != 0) {
      appController.changeCurrentAppPage(0);
      appController.pageController.jumpToPage(0);
      return false;
    }
    if (lastPressed == null || now.difference(lastPressed!) > maxDuration) {
      lastPressed = now;
      Fluttertoast.showToast(
        msg: "Press again to exit",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        bool shouldExit = await _onWillPop();
        if (shouldExit) {
          Navigator.of(context).maybePop(result);
        }
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
                      if (index == 1) {
                        //fetch quick references
                      }
                    },
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: HomeScreenBottomNavBar(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
