import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/widgets/snackbars.dart';

import '../../routes/routes.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../utils/storage_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool isPasswordVisible = false;
  bool termsPolicy = false;
  Timer? debounceTimer;
  AuthController authController = Get.find<AuthController>();
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void togglePass() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void toggleTerms() {
    setState(() {
      termsPolicy = !termsPolicy;
    });
  }

  void storeBody() async {
    final name = nameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    FocusScope.of(context).unfocus();

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      CustomSnackBar.failure(message: 'Please fill all required fields');
      return;
    }

    if (termsPolicy == false) {
      CustomSnackBar.failure(message: 'Please accept Terms & Privacy Policy');
      return;
    }

    final passwordValid = _validatePassword(password);
    if (!passwordValid) {
      CustomSnackBar.failure(
        message:
            'Password must be at least 8 chars, include 1 uppercase and 1 symbol',
      );
      return;
    }

    await authController.checkUsername(username);

    if (!authController.isUsernameAvailable.value) {
      CustomSnackBar.failure(
        message:
            authController.usernameMessage.value ?? 'Username not available',
      );
      return;
    }

    try {
      await StorageHelper.saveBasicInfo(
        name: name,
        username: username,
        email: email,
      );
      await StorageHelper.savePassword(password);

      print('Account info saved locally');

      Get.toNamed(AppRoutes.selectCategoryScreen);
    } catch (e, s) {
      print(
        'Failed to save data locally. Try again. ${e.toString()}, ${s.toString()}',
      );
    }
  }

  bool _validatePassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasSymbol = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasMinLength && hasUpper && hasSymbol;
  }

  void checkUsername() {
    final username = usernameController.text.trim();
    authController.checkUsername(username);
  }

  @override
  void dispose() {
    debounceTimer?.cancel();
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
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
                    right: -Dimensions.width100 * 4,
                    bottom: Dimensions.height20,
                    child: Text(
                      'CREATE ACCOUNT',
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
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width20,
                        ),
                        child: Text(
                          'CREATE AN ACCOUNT TODAY!',
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: Dimensions.font30 * 1.2,
                            color: AppColors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width20,
                        ),
                        child: Text(
                          'Get news,game updates highlights and more info on your favorite teams',
                          style: TextStyle(
                            fontSize: Dimensions.font16,
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
                  CustomTextField(hintText: 'Full Name',controller: nameController,),
                  SizedBox(height: Dimensions.height20),
                  CustomTextField(
                    hintText: 'Username',
                    controller: usernameController,
                    onChanged: (value) {
                      if (value.trim().isNotEmpty) {
                        debounceTimer?.cancel();
                        debounceTimer = Timer(
                          const Duration(milliseconds: 600),
                          () {
                            checkUsername();
                          },
                        );
                      }
                    },
                    suffixIcon: Obx(() {
                      if (authController.isCheckingUsername.value) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                            vertical: Dimensions.height10,
                          ),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 4,
                          ),
                        );
                      } else if (authController.usernameMessage.isNotEmpty) {
                        return Icon(
                          authController.isUsernameAvailable.value
                              ? Icons.check_circle
                              : Icons.error,
                          color:
                              authController.isUsernameAvailable.value
                                  ? Colors.green
                                  : Colors.red,
                          size: Dimensions.iconSize16,
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ),
                  SizedBox(height: Dimensions.height5),
                  Obx(
                    () =>
                        authController.usernameMessage.value.isNotEmpty
                            ? Text(
                              authController.usernameMessage.value,
                              style: TextStyle(
                                color:
                                    authController.isUsernameAvailable.value
                                        ? Colors.green
                                        : Colors.red,
                                fontSize: Dimensions.font12,
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                  SizedBox(height: Dimensions.height20),
                  CustomTextField(
                    hintText: 'Email Address',
                    controller: emailController,
                    autofillHints: [AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: Dimensions.height20),
                  CustomTextField(
                    hintText: 'Password',
                    maxLines: 1,
                    controller: passwordController,
                    obscureText: isPasswordVisible,
                    suffixIcon: InkWell(
                      onTap: () {
                        togglePass();
                        print(isPasswordVisible);
                      },
                      child: Icon(
                        !isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  Text(
                    'Password must be at least 8 character long and include 1 capital letter and 1 symbol',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.grey5,
                      fontSize: Dimensions.font13,
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  InkWell(
                    onTap: () {
                      toggleTerms();
                      print(termsPolicy);
                    },
                    child: Row(
                      children: [
                        Icon(
                          termsPolicy
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank,
                          color: AppColors.grey5,
                        ),
                        SizedBox(width: Dimensions.width5),
                        Text(
                          'I agree to  the Terms and Privacy Policy',
                          style: TextStyle(
                            color: AppColors.grey5,
                            fontSize: Dimensions.font13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  CustomButton(
                    text: 'CREATE ACCOUNT',
                    onPressed: () {
                      storeBody();
                    },
                  ),
                  SizedBox(height: Dimensions.height20),
                  Text(
                    'By agreeing to the above terms, you are consenting that your personal information will be collected, stored, and processed on behalf of HILITE',
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: AppColors.grey5),
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
