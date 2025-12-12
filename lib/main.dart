import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/utils/app_constants.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/app_loading_overlay.dart';

import 'controllers/app_controller.dart';
import 'firebase_options.dart';
import 'helpers/dependencies.dart' as VersionService;
import 'helpers/dependencies.dart' as dep;
import 'helpers/global_loader_controller.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.deepOrange,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,

      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  await VersionService.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dep.init();
  Get.put(GlobalLoaderController(), permanent: true);
  HardwareKeyboard.instance.clearState();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GlobalLoaderController>(builder: (_) {
      return GetBuilder<AppController>(builder: (_) {
        return LayoutBuilder(builder: (context, constraint) {
          Dimensions.init(context);

          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConstants.APP_NAME,
            theme: ThemeData(
                fontFamily: 'Poppins',
                scaffoldBackgroundColor: AppColors.bgColor
            ),
            getPages: AppRoutes.routes,
            initialRoute: AppRoutes.splash,
            builder: (context, child) {
              final loaderController = Get.find<GlobalLoaderController>();
              return Obx(() {
                return Stack(
                  children: [
                    child!,
                    if (loaderController.isLoading.value)
                      const Positioned.fill(
                        child: AppLoadingOverlay(),
                      ),
                  ],
                );
              });
            },
          );
        });
      });
    });
  }
}

