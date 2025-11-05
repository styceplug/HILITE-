import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/version_controller.dart';
import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: Container(
          height: Dimensions.screenHeight,
          width: Dimensions.screenWidth,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(AppConstants.getPngAsset('sitting-ballers')),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Game. \nYour Spotlight.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: Dimensions.font30 * 2,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'BebasNeue',
                        height: 1,
                        color: Colors.white
                      ),
                    ),
                    Text(
                      'Show your skills, connect with scouts, and get discovered.',
                      style: TextStyle(
                        fontSize: Dimensions.font18,
                        fontWeight: FontWeight.w300,
                        color: Colors.white
                      ),
                    ),
                    SizedBox(height: Dimensions.height30),
                    CustomButton(
                      text: 'LOGIN',
                      onPressed: () {
                        Get.toNamed(AppRoutes.loginScreen);
                      },
                    ),
                    SizedBox(height: Dimensions.height10),
                    CustomButton(
                      text: 'CREATE ACCOUNT',
                      onPressed: () {
                        Get.toNamed(AppRoutes.createAccountScreen);
                      },
                      backgroundColor: AppColors.bgColor,
                      borderColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height50),
            ],
          ),
        ),
      ),
    );
  }
}
