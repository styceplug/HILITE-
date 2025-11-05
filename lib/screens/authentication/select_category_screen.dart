import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/utils/app_constants.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/custom_button.dart';

import '../../routes/routes.dart';
import '../../utils/colors.dart';
import '../../widgets/role_card.dart';

class SelectCategoryScreen extends StatefulWidget {
  const SelectCategoryScreen({super.key});

  @override
  State<SelectCategoryScreen> createState() => _SelectCategoryScreenState();
}

class _SelectCategoryScreenState extends State<SelectCategoryScreen> {
  String selectedRole = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          'CHOOSE ROLE TO PROCEED',
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
                          'Choose your role as it applies to proceed, Welcome to HILITE - From Streets to Stadium',
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

            RoleCard(
              title: 'Football Players/Creators',
              description:
                  'Showcase your talent, share highlights, and connect with agents, scouts, and clubs looking for the next big star.',
              image: 'kick',
              isSelected: selectedRole == 'player',
              onTap: () => setState(() => selectedRole = 'player'),
            ),
            RoleCard(
              title: 'Scout & Football Clubs',
              description:
                  'Discover top football talents, analyze player stats, and build professional connections with clubs and creators.',
              image: 'football',
              isSelected: selectedRole == 'scout-club',
              onTap: () => setState(() => selectedRole = 'scout-club'),
            ),
            RoleCard(
              title: 'Fan',
              description:
                  'Stay close to the game — follow players, watch highlights, and join the football community that never sleeps.',
              image: 'ice-skate',
              isSelected: selectedRole == 'fan',
              onTap: () => setState(() => selectedRole = 'fan'),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height50,
              ),
              child: CustomButton(
                text: 'Continue',
                onPressed: () {
                  if (selectedRole == 'player') {
                    Get.toNamed(AppRoutes.footballerForm);
                  } else if (selectedRole == 'scout-club') {
                    Get.toNamed(AppRoutes.scoutClubForm);
                  } else if (selectedRole == 'fan') {
                    Get.toNamed(AppRoutes.fanForm);
                  }
                },
                isDisabled: selectedRole.isEmpty,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
