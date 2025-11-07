import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/screens/home/pages/live_score_screen.dart';
import 'package:hilite/screens/home/pages/new_post.dart';
import 'package:hilite/screens/home/pages/profile_screen.dart';
import 'package:hilite/screens/home/pages/reels_screen.dart';

import '../data/repo/app_repo.dart';

class AppController extends GetxController {
  final AppRepo appRepo;

  AppController({required this.appRepo});

  Rx<ThemeMode> themeMode = Rx<ThemeMode>(ThemeMode.system);

  var currentAppPage = 0.obs;
  PageController pageController = PageController();

  final List<Widget> pages = [
    LiveScoreScreen(),
    ReelsScreen(),
    NewPost(),
    ProfileScreen()
  ];

  @override
  void onInit() {
    super.onInit();
  }

  void initializeApp() async {
    await Future.wait([]);
  }

  bool checkUserLoggedIn() {
    return Get.find<AuthController>().userLoggedIn();
  }

  void changeCurrentAppPage(int page, {bool movePage = true}) {
    currentAppPage.value = page;

    if (movePage) {
      if (pageController.hasClients) {
        pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pageController.hasClients) {
            pageController.animateToPage(
              page,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }

    update();
  }
}
