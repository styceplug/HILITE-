import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../data/repo/app_repo.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';

class AppController extends GetxController {
  final AppRepo appRepo;

  AppController({required this.appRepo});

  Rx<ThemeMode> themeMode = Rx<ThemeMode>(ThemeMode.system);

  var currentAppPage = 0.obs;
  PageController pageController = PageController();

  final List<Widget> pages = [
    // const StudioScreen(),
    // const FormulatorScreen(),
    // const ColorClub(),
    // ProfileScreen(),
  ];

  @override
  void onInit() {
    // initializeApp();
    super.onInit();
  }

  void initializeApp() async {
    await Future.wait([
      // Get.find<VersionController>().fetchActiveClasses(),
    ]);
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
