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
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,

      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
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

                return AnnotatedRegion(child: GetMaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: AppConstants.APP_NAME,
                  unknownRoute: GetPage(
                    name: '/notfound',
                    page: () => const Scaffold(backgroundColor: AppColors.backgroundColor),
                  ),
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
                ), value: SystemUiOverlayStyle.light);
              },
            );
          },
        );
      },
    );
  }
}

String? _lastProcessedLinkId;

void _handleDeepLink(Uri uri) {
  if (uri.pathSegments.length >= 2 &&
      uri.pathSegments[0] == 'post' &&
      uri.pathSegments[1].isNotEmpty) {

    final videoId = uri.pathSegments[1];

    if (_lastProcessedLinkId == videoId) {
      print("🎛️ Skipped duplicate deep link event for ID: $videoId");
      return;
    }

    _lastProcessedLinkId = videoId;

    Future.delayed(const Duration(seconds: 2), () {
      _lastProcessedLinkId = null;
    });

    void tryHandle() {
      if (Get.isRegistered<PostController>()) {
        Get.find<PostController>().handleDeepLink(videoId);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) => tryHandle());
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => tryHandle());
  }
}
