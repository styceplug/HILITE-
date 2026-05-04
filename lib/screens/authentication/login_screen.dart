import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:hilite/widgets/custom_textfield.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:iconsax/iconsax.dart';

import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool viewPassword = false;
  bool isRememberMe = false;

  void togglePass() {
    setState(() {
      viewPassword = !viewPassword;
    });
  }

  void toggleRememberMe() {
    setState(() {
      isRememberMe = !isRememberMe;
    });
  }

  AuthController authController = Get.find<AuthController>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() {
    final input = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      CustomSnackBar.failure(message: 'Both fields are required');
      return;
    }

    authController.login(input, password, staySignedIn: isRememberMe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // height: Dimensions.screenHeight / 3,
              width: Dimensions.screenWidth,
              padding: EdgeInsets.symmetric(vertical: Dimensions.height20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
               /*   Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height50,
                    ),
                    child: Image.asset(
                      AppConstants.getPngAsset('logo3'),
                      height: Dimensions.height70,
                    ),
                  ),*/

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Welcome back to',
                              style: TextStyle(
                                // fontFamily: 'BebasNeue',
                                fontSize: Dimensions.font30,
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              ' Hilite',
                              style: TextStyle(
                                // fontFamily: 'BebasNeue',
                                fontSize: Dimensions.font30,
                                color: AppColors.buttonColor,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.height15),
                        Text(
                          'Show your talent. Get discovered',
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: Dimensions.font16,
                          ),
                        ),
                      ],
                    ),
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
                  CustomTextField(
                    hintText: 'Email or Username',
                    prefixIcon: CupertinoIcons.person_circle,
                    controller: usernameController,
                    // labelText: 'Email or Username',
                    autofillHints: [
                      AutofillHints.email,
                      AutofillHints.username,
                    ],
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: Dimensions.height20),
                  CustomTextField(
                    prefixIcon: Iconsax.lock,
                    hintText: 'Password',
                    obscureText: !viewPassword,
                    // labelText: 'Password',
                    maxLines: 1,
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    autofillHints: [AutofillHints.password],
                    suffixIcon: InkWell(
                      onTap: () {
                        togglePass();
                      },
                      child:
                          viewPassword
                              ? Icon(
                                Icons.visibility,
                                color: AppColors.textColor,
                              )
                              : Icon(
                                Icons.visibility_off,
                                color: AppColors.textColor,
                              ),
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          toggleRememberMe();
                          print(isRememberMe);
                        },
                        child: Row(
                          children: [
                            !isRememberMe
                                ? Icon(
                                  Icons.check_box_outline_blank,
                                  size: Dimensions.iconSize16,
                                  color: AppColors.textColor,
                                )
                                : Icon(
                                  Icons.check_box,
                                  size: Dimensions.iconSize16,
                                  color: AppColors.textColor,
                                ),
                            SizedBox(width: Dimensions.width5),
                            Text(
                              'Stay Signed in?',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: AppColors.textColor),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.forgotPasswordScreen);
                        },
                        child: Text(
                          'Forgot Password?',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: AppColors.textColor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height20),
                  CustomButton(
                    text: 'SIGN IN',
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      login();
                    },
                    backgroundColor: AppColors.buttonColor,
                  ),
                  SizedBox(height: Dimensions.height50),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'or continue with',
                      style: TextStyle(color: AppColors.textColor),
                    ),
                  ),
                  SizedBox(height: Dimensions.height40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        child: Image.asset(
                          height: Dimensions.height70,
                          AppConstants.getPngAsset('google'),
                        ),
                      ),
                      Container(
                        child: Image.asset(
                          height: Dimensions.height70,
                          AppConstants.getPngAsset('apple'),
                        ),
                      ),
                      Container(
                        child: Image.asset(
                          height: Dimensions.height70,
                          AppConstants.getPngAsset('facebook'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height20),
                  CustomButton(
                    text: 'New here? Join Hilite',
                    onPressed: () {
                      Get.toNamed(AppRoutes.selectCategoryScreen);
                    },
                    backgroundColor: Colors.transparent,
                    borderColor: Colors.transparent,
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
