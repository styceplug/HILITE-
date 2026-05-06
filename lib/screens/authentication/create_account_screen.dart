import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:iconsax/iconsax.dart';

import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
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
  TextEditingController bioController = TextEditingController();

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

  void createAccount() async {
    final name = nameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final bio = bioController.text.trim(); // Add bio

    FocusScope.of(context).unfocus();

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      CustomSnackBar.failure(message: 'Please fill all required fields');
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
      // 1. Create the data map (body)
      Map<String, dynamic> body = {
        "name": name,
        "username": username,
        "email": email,
        "password": password,
        "bio": bio,
        "role": "fan",
      };

      // 2. Pass the 'body' to the function
      authController.registerFan(body);
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: Dimensions.height100),
            Image.asset(
              AppConstants.getPngAsset('logo3'),
              height: Dimensions.height70,
            ),
            SizedBox(height: Dimensions.height20),
        
            Text(
              'Create your fan account',
              style: TextStyle(
                fontSize: Dimensions.font23,
                color: AppColors.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Dimensions.height5),
        
            Text(
              'Follow players, clubs, and enjoy the game',
              style: TextStyle(
                fontSize: Dimensions.font16,
                color: AppColors.textColor.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height20,
              ),
              child: Column(
                children: [
                  CustomTextField(
                    hintText: 'Full Name',
                    controller: nameController,
                    prefixIcon: CupertinoIcons.person_alt_circle_fill,
                    autofillHints: [AutofillHints.name],
                  ),
                  SizedBox(height: Dimensions.height20),
                  CustomTextField(
                    hintText: 'Username',
                    controller: usernameController,
                    prefixIcon: Icons.person_pin,
                    autofillHints: [AutofillHints.username],
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Obx(
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
                  ),
                  SizedBox(height: Dimensions.height20),
                  CustomTextField(
                    hintText: 'Email Address *',
                    controller: emailController,
                    prefixIcon: Icons.mail,
                    autofillHints: [AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                  ),
        
                  SizedBox(height: Dimensions.height20),
                  CustomTextField(
                    hintText: 'Password',
                    prefixIcon: Icons.lock,
                    maxLines: 1,
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
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
                    'By signing up, you agree to our Terms of Service and Privacy Policy',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: Dimensions.font13,
                    ),
                  ),
        
                  SizedBox(height: Dimensions.height20),
        
                  CustomButton(
                    text: 'SIGN UP',
                    onPressed: createAccount,
                    backgroundColor: AppColors.buttonColor,
                  ),
                  SizedBox(height: Dimensions.height20),
        
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
