import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/controllers/post_controller.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/models/post_model.dart';
import 'package:hilite/screens/home/pages/live_score_screen.dart';
import 'package:hilite/screens/home/pages/activities_screen.dart';
import 'package:hilite/screens/home/pages/profile_screen.dart';
import 'package:hilite/screens/home/pages/reels_screen.dart';
import 'package:hilite/screens/posting/upload_content.dart';
import 'package:hilite/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repo/app_repo.dart';
import '../data/repo/chat_repo.dart';
import '../helpers/socket_helper.dart';
import '../models/message_model.dart';
import '../routes/routes.dart';
import '../screens/messaging/chat_list_screen.dart';
import 'chat_controller.dart';

class AppController extends GetxController {
  final AppRepo appRepo;

  AppController({required this.appRepo});

  Rx<ThemeMode> themeMode = Rx<ThemeMode>(ThemeMode.system);

  var currentAppPage = 0.obs;
  var isFirstTime = false.obs;
  PageController pageController = PageController();
  AuthController authController = Get.find<AuthController>();
  UserController userController = Get.find<UserController>();
  PostController postController = Get.find<PostController>();
  late List<PostModel> post = postController.posts;

  final List<Widget> pages = [
    ReelsScreen(),
    ActivitiesScreen(),
    UploadContent(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> initializeApp() async {
    print('Initializing....');
    await userController.saveDeviceToken();
    await checkFirstTimeUse();
    await checkLoginAndNavigate();


    final sharedPreferences = Get.find<SharedPreferences>();
    final token = sharedPreferences.getString(AppConstants.authToken) ?? '';

    if (token.isNotEmpty) {
      await Get.find<SocketHelper>().connect(
        baseUrl: AppConstants.SOCKET_BASE_URL,
        token: token,
      );

      userController.getPersonalPosts('video');
      userController.getPersonalPosts('image');
      postController.loadRecommendedPosts("video");
      await userController.getUserProfile();
    }

  }



  Future<void> checkLoginAndNavigate() async {
    final loggedIn = authController.userLoggedIn();

    if (isFirstTime.value) {
      Get.offAllNamed(AppRoutes.onboardingScreen);
    } else if (loggedIn) {
      Get.offAllNamed(AppRoutes.homeScreen);
    } else {
      Get.offAllNamed(AppRoutes.onboardingScreen);
    }
  }

  Future<void> checkFirstTimeUse() async {
    final prefs = appRepo.sharedPreferences;
    final seen = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!seen) {
      isFirstTime.value = true;
      await prefs.setBool('hasSeenOnboarding', true);
    } else {
      isFirstTime.value = false;
    }
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
