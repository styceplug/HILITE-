import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hilite/helpers/push_notification.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/utils/app_constants.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/app_loading_overlay.dart';

import 'controllers/app_controller.dart';
import 'controllers/post_controller.dart';
import 'firebase_options.dart';
// import 'helpers/dependencies.dart' as VersionService;
import 'helpers/dependencies.dart' as dep;
import 'helpers/global_loader_controller.dart';
import 'helpers/version_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primary,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  await VersionService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService().initialize();
  await dep.init();

  final appLinks = AppLinks();

  try {
    final Uri? initialUri = await appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }
  } catch (e) {
    print("Initial link error: $e");
  }

  appLinks.uriLinkStream.listen(
    (Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    },
    onError: (err) {
      print("Link stream error: $err");
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GlobalLoaderController>(
      builder: (_) {
        return GetBuilder<AppController>(
          builder: (_) {
            return LayoutBuilder(
              builder: (context, constraint) {
                Dimensions.init(context);

                return GetMaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: AppConstants.APP_NAME,
                  theme: ThemeData(
                    fontFamily: 'Poppins',
                    scaffoldBackgroundColor: AppColors.backgroundColor,
                    textTheme: Theme.of(context).textTheme.apply(
                      bodyColor: AppColors.textColor,
                      displayColor: AppColors.textColor,
                    )
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
                            const Positioned.fill(child: AppLoadingOverlay()),
                        ],
                      );
                    });
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

void _handleDeepLink(Uri uri) {
  // Check if link is https://hiliteapp.net/post/6926...
  if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'post') {
    String videoId = uri.pathSegments[1];
    print("🔗 Deep Link to Post ID: $videoId");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<PostController>()) {
        Get.find<PostController>().handleDeepLink(videoId);
      }
    });
  }
}
