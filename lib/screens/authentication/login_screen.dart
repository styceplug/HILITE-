import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:hilite/widgets/custom_textfield.dart';

import '../../routes/routes.dart';
import '../../utils/dimensions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool viewPassword = false;

  void togglePass() {
    setState(() {
      viewPassword = !viewPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          children: [
            Container(
              height: Dimensions.screenHeight / 3,
              width: Dimensions.screenWidth,
              padding: EdgeInsets.symmetric(vertical: Dimensions.height20),
              color: AppColors.primary,
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    bottom: Dimensions.height20,
                    child: Text(
                      'SIGN IN',
                      style: TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: Dimensions.font30 * 4,
                        color: AppColors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width20,
                          vertical: Dimensions.height50,
                        ),
                        child: Text(
                          'HILITE',
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: Dimensions.font30,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width20,
                        ),
                        child: Text(
                          'SIGN IN WITH YOUR \nEMAIL OR USERNAME',
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: Dimensions.font30 * 1.2,
                            color: AppColors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomTextField(hintText: 'Email or Username'),
                  SizedBox(height: Dimensions.height20),
                  CustomTextField(
                    hintText: 'Password',
                    obscureText: !viewPassword,
                    maxLines: 1,
                    suffixIcon: InkWell(
                      onTap: () {
                        togglePass();
                      },
                      child:
                          viewPassword
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  InkWell(
                    onTap: () {
                      Get.toNamed(AppRoutes.forgotPasswordScreen);
                    },
                    child: Text(
                      'Forgot Password?',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: AppColors.grey5),
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  CustomButton(text: 'SIGN IN', onPressed: () {}),
                  SizedBox(height: Dimensions.height20),
                  Text(
                    'If you’ve signed into the app before, use the same credentials here. otherwise',
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: AppColors.grey5),
                  ),
                  SizedBox(height: Dimensions.height20),
                  CustomButton(
                    text: 'SIGN UP',
                    onPressed: () {
                      Get.toNamed(AppRoutes.createAccountScreen);
                    },
                    backgroundColor: AppColors.bgColor,
                    borderColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
