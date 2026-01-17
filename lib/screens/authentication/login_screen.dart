import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:hilite/widgets/custom_textfield.dart';
import 'package:hilite/widgets/snackbars.dart';

import '../../routes/routes.dart';
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
        child: SingleChildScrollView(
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
                          child: InkWell(
                            onTap: (){
                              authController.logout();
                            },
                            child: Text(
                              'HILITE',
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: Dimensions.font30,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width20,
                          ),
                          child: Text(
                            'SIGN IN WITH YOUR EMAIL OR USERNAME',
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
                    CustomTextField(
                      hintText: 'Email or Username',
                      controller: usernameController,
                      labelText: 'Email or Username',
                      autofillHints: [AutofillHints.email,AutofillHints.username],
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: Dimensions.height20),
                    CustomTextField(
                      hintText: 'Password',
                      obscureText: !viewPassword,
                      labelText: 'Password',
                      maxLines: 1,
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      autofillHints: [AutofillHints.password],
                      suffixIcon: InkWell(
                        onTap: () {
                          togglePass();
                        },
                        child: viewPassword
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off),
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                toggleRememberMe();
                                print(isRememberMe);
                              },
                              child: !isRememberMe
                                  ? Icon(
                                      Icons.check_box_outline_blank,
                                      size: Dimensions.iconSize16,
                                    )
                                  : Icon(
                                      Icons.check_box,
                                      size: Dimensions.iconSize16,
                                    ),
                            ),
                            SizedBox(width: Dimensions.width5),
                            Text(
                              'Stay Signed in?',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: AppColors.grey5),
                            ),
                          ],
                        ),
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
                      ],
                    ),
                    SizedBox(height: Dimensions.height20),
                    CustomButton(
                      text: 'SIGN IN',
                      onPressed: (){
                        FocusScope.of(context).unfocus();
                        login();
                      },
                    ),
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
                        Get.toNamed(AppRoutes.selectCategoryScreen);
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
      ),
    );
  }
}
