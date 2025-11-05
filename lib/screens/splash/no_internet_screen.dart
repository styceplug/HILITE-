import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_button.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                height: Dimensions.height10 * 30,
                width: Dimensions.screenWidth,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppConstants.getPngAsset('no-internet')),
                  ),
                ),
              ),
              SizedBox(height: Dimensions.height20),
              Text(
                'Oops! No Internet.',
                style: TextStyle(
                  fontSize: Dimensions.font25 + Dimensions.font12,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                'Please check your internet connection and try again',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w400,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'RETRY',
                onPressed: () {
                  Get.offAllNamed(AppRoutes.splashScreen);
                },
              ),
              SizedBox(height: Dimensions.height30),
            ],
          ),
        ),
      ),
    );
  }}
