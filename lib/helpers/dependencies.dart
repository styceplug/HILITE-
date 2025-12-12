import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/notification_controller.dart';
import 'package:hilite/controllers/post_controller.dart';
import 'package:hilite/controllers/trial_controller.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/controllers/wallet_controller.dart';
import 'package:hilite/data/api/api_checker.dart';
import 'package:hilite/data/repo/post_repo.dart';
import 'package:hilite/data/repo/trial_repo.dart';
import 'package:hilite/data/repo/user_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/app_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/version_controller.dart';
import '../data/api/api_client.dart';
import '../data/repo/app_repo.dart';
import '../data/repo/auth_repo.dart';
import '../data/repo/notification_repo.dart';
import '../data/repo/version_repo.dart';
import '../utils/app_constants.dart';
import 'global_loader_controller.dart';

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  Get.put(sharedPreferences);

  //api clients
  Get.lazyPut(
    () => ApiClient(
      appBaseUrl: AppConstants.BASE_URL,
      sharedPreferences: Get.find(),
    ),
  );
  Get.lazyPut(
    () => ApiChecker(
    ),
  );

  // repos
  Get.lazyPut(
    () => AppRepo(apiClient: Get.find(), sharedPreferences: Get.find()),
  );
  Get.lazyPut(() => VersionRepo(apiClient: Get.find()));
  Get.lazyPut(
    () => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()),
  );
  Get.lazyPut(
    () => UserRepo(
      apiClient: Get.find(),
      sharedPreferences: Get.find(),
      authRepo: Get.find(),
    ),
  );
  Get.lazyPut(() => PostRepo(apiClient: Get.find()));
  Get.lazyPut(() => TrialRepo(apiClient: Get.find()));
  Get.lazyPut(() => NotificationRepo(apiClient: Get.find()));

  //controllers
  Get.lazyPut(() => AppController(appRepo: Get.find()));
  Get.lazyPut(() => VersionController(versionRepo: Get.find()));
  Get.lazyPut(
    () => AuthController(authRepo: Get.find(), sharedPreferences: Get.find()),
  );
  Get.lazyPut(
    () => UserController(userRepo: Get.find(), sharedPreferences: Get.find()),
  );
  Get.lazyPut(() => GlobalLoaderController());
  Get.lazyPut(() => WalletController());
  Get.lazyPut(() => PostController(postRepo: Get.find()));
  Get.lazyPut(() => NotificationController(notificationRepo: Get.find()));
  Get.lazyPut(() => TrialController(trialRepo: Get.find()), fenix: true);
}
