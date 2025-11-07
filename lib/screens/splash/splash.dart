import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/app_controller.dart';
import 'package:hilite/widgets/bouncing_dots_indicator.dart';
import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (Get.find<AppController>().checkUserLoggedIn()) {
        Get.offAllNamed(AppRoutes.homeScreen);
      } else {
        Get.offAllNamed(AppRoutes.onboardingScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        padding: EdgeInsets.only(bottom: Dimensions.height50),
        decoration: const BoxDecoration(
          gradient: AppColors.blueWhiteGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Container(
                height: Dimensions.height100 * 3.5,
                width: Dimensions.width100 * 3.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(AppConstants.getPngAsset('logo2')),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              Text(
                'From Street to Stadium',
                style: TextStyle(
                  fontSize: Dimensions.font22,
                  fontWeight: FontWeight.w700,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF0094FF), Color(0xFF003366)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                ),
              ),
              Spacer(),
              BouncingDotsIndicator(
                color: AppColors.primary,
              )
            ],
          ),
        ),
      ),
    );
  }
}
