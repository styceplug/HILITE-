import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/utils/app_constants.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/custom_button.dart';

import '../../routes/routes.dart';
import '../../utils/colors.dart';
import '../../utils/storage_helper.dart';
import '../../widgets/role_card.dart';

class SelectCategoryScreen extends StatefulWidget {
  const SelectCategoryScreen({super.key});

  @override
  State<SelectCategoryScreen> createState() => _SelectCategoryScreenState();
}

class _SelectCategoryScreenState extends State<SelectCategoryScreen> {
  String selectedRole = '';

  AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
  }

  Map<String, dynamic> body(
    String username,
    String password,
    String email,
    String name,
    String bio,
  ) {
    return {
      "name": name,
      "username": username,
      "email": email,
      "password": password,
      "bio": bio,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
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
                    right: -Dimensions.width100,
                    bottom: Dimensions.height20,
                    child: Text(
                      'CHOOSE ROLE',
                      style: TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: Dimensions.font30 * 4,
                        color: AppColors.white.withOpacity(0),
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
                        child: Image.asset(
                          AppConstants.getPngAsset('logo3'),
                          height: Dimensions.height70,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width20,
                          ),
                          child: Text(
                            'CHOOSE ACCOUNT TYPE',
                            style: TextStyle(
                              fontFamily: 'BebasNeue',
                              fontSize: Dimensions.font30 * 1.1,
                              color: AppColors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width20,
                        ),
                        child: Text(
                          'Choose the option that best describes you and continue your journey,\n \nHILITE - From Streets to Stadium',
                          style: TextStyle(
                            fontSize: Dimensions.font14,
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
            SizedBox(height: Dimensions.height10),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    RoleCard(
                      title: 'Player',
                      description:
                          'Show your game, get discovered.',
                      image: 'footballer-img',
                      isSelected: selectedRole == 'player',
                      onTap: () => setState(() => selectedRole = 'player'),
                    ),
                    RoleCard(
                      title: 'Scout',
                      description:
                          'Find the next star',
                      image: 'scout-img',
                      isSelected: selectedRole == 'scout',
                      onTap: () => setState(() => selectedRole = 'scout'),
                    ),
                    RoleCard(
                      title: 'Team',
                      description:
                          'Showcase, build your legacy',
                      image: 'team',
                      isSelected: selectedRole == 'club',
                      onTap: () => setState(() => selectedRole = 'club'),
                    ),
                    RoleCard(
                      title: 'Fans',
                      description:
                          'Feel the game, support rising stars',
                      image: 'fans',
                      isSelected: selectedRole == 'fan',
                      onTap: () => setState(() => selectedRole = 'fan'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width20,
                        vertical: Dimensions.height50,
                      ),
                      child: CustomButton(
                        text: 'Continue',
                        textStyle: TextStyle(color: AppColors.black,fontWeight: FontWeight.w500),
                        backgroundColor: AppColors.white,
                        onPressed: () {
                          if (selectedRole == 'player') {
                            Get.toNamed(AppRoutes.footballerForm);
                          } else if (selectedRole == 'scout') {
                            Get.toNamed(AppRoutes.agentForm);
                          } else if (selectedRole == 'club') {
                            Get.toNamed(AppRoutes.clubForm);
                          }else if (selectedRole == 'fan') {
                            Get.toNamed(AppRoutes.createAccountScreen);
                          }
                        },
                        isDisabled: selectedRole.isEmpty,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
